# Copyright 2025 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import os
import json
import uuid
import traceback
from flask import Flask, request, jsonify, render_template
from dotenv import load_dotenv
from google import genai
from google.genai import types
from google.cloud import storage
from sqlalchemy import create_engine, text

# Load environment variables from .env
load_dotenv()

app = Flask(__name__)

# --- Configuration ---
API_KEY = os.getenv("GEMINI_API_KEY")
DATABASE_URL = os.getenv("DATABASE_URL")
BUCKET_NAME = os.getenv("GCS_BUCKET_NAME")

# Initialize Clients
genai_client = None # Initialize to None
storage_client = None
engine = None #Initialize to None

try:
    genai_client = genai.Client(api_key=API_KEY)
    storage_client = storage.Client()
    
    if not DATABASE_URL:
        raise ValueError("DATABASE_URL is not set in environment variables.")
    
    # Increase pool size and handle disconnected sessions
    # pool_pre_ping checks if the connection is alive before using it
    engine = create_engine(DATABASE_URL, pool_pre_ping=True)
except Exception as e:
    print(f"Initialization Error: {traceback.format_exc()}")


def upload_to_gcs(file_bytes, filename):
    """Uploads a file to Google Cloud Storage and returns the public URL."""
    bucket = storage_client.bucket(BUCKET_NAME)
    blob = bucket.blob(f"items/{uuid.uuid4()}-{filename}")
    blob.upload_from_string(file_bytes, content_type="image/jpeg")
    return blob.public_url



@app.route('/')
def home():
    """
    Fetches dashboard data and renders the dashboard template.
    """
    if engine is None:
        return jsonify({"error": "Database engine not initialized."}), 500

    try:
        with engine.connect() as conn:
            # Get total campaigns
            campaign_query = text("SELECT COUNT(*) FROM campaigns")
            total_campaigns = conn.execute(campaign_query).scalar()

            # Get total leads
            lead_query = text("SELECT COUNT(*) FROM leads")
            total_leads = conn.execute(lead_query).scalar()

            # Get recent reports
            report_query = text("SELECT report_id, query, created_at FROM reports ORDER BY created_at DESC LIMIT 5")
            reports_result = conn.execute(report_query)
            recent_reports = []
            for row in reports_result:
                recent_reports.append({
                    "id": str(row[0]),
                    "query": row[1],
                    "created_at": row[2].isoformat() if row[2] else None
                })

            conn.commit()
            return render_template('app.html', total_campaigns=total_campaigns, total_leads=total_leads, recent_reports=recent_reports)
            
    except Exception as e:
        print(f"Error fetching dashboard data: {traceback.format_exc()}")
        return jsonify({
            "error": "Failed to fetch dashboard data", 
            "details": str(e),
            "traceback": traceback.format_exc()
        }), 500


@app.route('/about')
def about():
    """
    Renders the about page.
    """
    return render_template('about.html')

@app.route('/api/campaigns', methods=['GET'])
def get_campaigns():
    """
    Fetches campaigns from the database.
    """
    if engine is None:
        return jsonify({"error": "Database engine not initialized."}), 500
    try:
        with engine.connect() as conn:
            query = text("""
                SELECT campaign_id, name, description, start_date, end_date, budget 
                FROM campaigns 
                ORDER BY start_date DESC
            """)
            result = conn.execute(query)
            
            campaigns = []
            for row in result:
                campaigns.append({
                    "id": str(row[0]),
                    "name": row[1],
                    "description": row[2],
                    "start_date": row[3].isoformat() if row[3] else None,
                    "end_date": row[4].isoformat() if row[4] else None,
                    "budget": float(row[5]) if row[5] else 0
                })
            
            conn.commit()
            return jsonify(campaigns)
            
    except Exception as e:
        print(f"Error fetching campaigns: {traceback.format_exc()}")
        return jsonify({
            "error": "Failed to fetch campaigns", 
            "details": str(e),
            "traceback": traceback.format_exc()
        }), 500

@app.route('/api/leads', methods=['GET'])
def get_leads():
    """
    Fetches leads from the database.
    """
    if engine is None:
        return jsonify({"error": "Database engine not initialized."}), 500
    try:
        with engine.connect() as conn:
            query = text("""
                SELECT l.lead_id, l.name, l.email, l.status, l.created_at, c.name as campaign_name
                FROM leads l
                JOIN campaigns c ON l.campaign_id = c.campaign_id
                ORDER BY l.created_at DESC
            """)
            result = conn.execute(query)
            
            leads = []
            for row in result:
                leads.append({
                    "id": str(row[0]),
                    "name": row[1],
                    "email": row[2],
                    "status": row[3],
                    "created_at": row[4].isoformat() if row[4] else None,
                    "campaign_name": row[5]
                })
            
            conn.commit()
            return jsonify(leads)
            
    except Exception as e:
        print(f"Error fetching leads: {traceback.format_exc()}")
        return jsonify({
            "error": "Failed to fetch leads", 
            "details": str(e),
            "traceback": traceback.format_exc()
        }), 500


@app.route('/api/generate-chart', methods=['POST'])
def generate_chart():
    """
    Generates a chart based on user query using Gemini AI.
    """
    if engine is None or genai_client is None:
        return jsonify({"error": "Services not initialized."}), 500

    data = request.json
    query = data.get('query')
    if not query:
        return jsonify({"error": "Query is required"}), 400

    try:
        # Fetch data from DB
        with engine.connect() as conn:
            campaigns_query = text("SELECT name, description, budget FROM campaigns")
            campaigns = conn.execute(campaigns_query).fetchall()

            leads_query = text("SELECT l.name, l.email, l.status, c.name as campaign FROM leads l JOIN campaigns c ON l.campaign_id = c.campaign_id")
            leads = conn.execute(leads_query).fetchall()

        # Prepare data for Gemini
        data_summary = {
            "campaigns": [{"name": c[0], "description": c[1], "budget": float(c[2])} for c in campaigns],
            "leads": [{"name": l[0], "email": l[1], "status": l[2], "campaign": l[3]} for l in leads]
        }

        prompt = f"""
        You are a marketing analytics AI. Analyze the following data and generate a Chart.js compatible chart configuration based on the user's query: "{query}"

        Data:
        {json.dumps(data_summary)}

        Return JSON in this format:
        {{
            "type": "bar|line|pie|doughnut",
            "data": {{
                "labels": ["label1", "label2"],
                "datasets": [{{
                    "label": "Dataset Label",
                    "data": [1, 2, 3]
                }}]
            }},
            "options": {{
                "responsive": true,
                "plugins": {{
                    "title": {{
                        "display": true,
                        "text": "Chart Title"
                    }}
                }}
            }}
        }}
        """

        response = genai_client.models.generate_content(
            model="gemini-3-flash-preview",
            contents=prompt,
            config=types.GenerateContentConfig(response_mime_type="application/json")
        )
        chart_config = json.loads(response.text)

        return jsonify({"chart": chart_config})

    except Exception as e:
        print(f"Error generating chart: {traceback.format_exc()}")
        return jsonify({
            "error": "Failed to generate chart", 
            "details": str(e),
            "traceback": traceback.format_exc()
        }), 500


@app.route('/api/save-report', methods=['POST'])
def save_report():
    """
    Saves a generated report.
    """
    if engine is None:
        return jsonify({"error": "Database engine not initialized."}), 500

    data = request.json
    query = data.get('query')
    chart_data = data.get('chart_data')
    if not query or not chart_data:
        return jsonify({"error": "Query and chart_data are required"}), 400

    try:
        with engine.connect() as conn:
            insert_query = text("""
                INSERT INTO reports (query, chart_data)
                VALUES (:query, :chart_data)
                RETURNING report_id
            """)
            result = conn.execute(insert_query, {
                "query": query,
                "chart_data": json.dumps(chart_data)
            })
            report_id = result.fetchone()[0]
            conn.commit()

        return jsonify({"status": "success", "report_id": str(report_id)})

    except Exception as e:
        print(f"Error saving report: {traceback.format_exc()}")
        return jsonify({
            "error": "Failed to save report", 
            "details": str(e),
            "traceback": traceback.format_exc()
        }), 500

@app.route('/api/reports', methods=['GET'])
def get_reports():
    """
    Fetches saved reports.
    """
    if engine is None:
        return jsonify({"error": "Database engine not initialized."}), 500
    try:
        with engine.connect() as conn:
            query = text("SELECT report_id, query, chart_data, created_at FROM reports ORDER BY created_at DESC")
            result = conn.execute(query)
            
            reports = []
            for row in result:
                chart_data = row[2]
                if isinstance(chart_data, (str, bytes, bytearray)):
                    chart_data = json.loads(chart_data)

                reports.append({
                    "id": str(row[0]),
                    "query": row[1],
                    "chart_data": chart_data,
                    "created_at": row[3].isoformat() if row[3] else None
                })
            
            conn.commit()
            return jsonify(reports)
            
    except Exception as e:
        print(f"Error fetching reports: {traceback.format_exc()}")
        return jsonify({
            "error": "Failed to fetch reports", 
            "details": str(e),
            "traceback": traceback.format_exc()
        }), 500



if __name__ == '__main__':
    # Using threaded=True to handle multiple concurrent requests better
    app.run(host='0.0.0.0', port=int(os.environ.get('PORT', 8080)), threaded=True)
