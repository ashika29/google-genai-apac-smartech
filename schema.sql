-- Smartech Analytics Database Schema
-- Run this in your AlloyDB instance

-- Campaigns table
CREATE TABLE campaigns (
    campaign_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    start_date DATE,
    end_date DATE,
    budget DECIMAL(10,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Leads table
CREATE TABLE leads (
    lead_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    campaign_id UUID REFERENCES campaigns(campaign_id),
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    status VARCHAR(50) DEFAULT 'new', -- new, contacted, converted
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Reports table
CREATE TABLE reports (
    report_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    query TEXT NOT NULL,
    chart_data JSONB NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Sample data
INSERT INTO campaigns (name, description, start_date, end_date, budget) VALUES
('Summer Sale 2024', 'Promotional campaign for summer products', '2024-06-01', '2024-08-31', 50000.00),
('Email Newsletter', 'Monthly newsletter campaign', '2024-01-01', '2024-12-31', 10000.00),
('Social Media Boost', 'Facebook and Instagram ads', '2024-03-01', '2024-05-31', 25000.00),
('Black Friday Deal', 'Massive discount campaign for holiday season', '2024-11-01', '2024-11-30', 75000.00),
('Product Launch', 'New product introduction campaign', '2024-09-01', '2024-10-31', 60000.00),
('Customer Retention', 'Loyalty program and retention marketing', '2024-01-01', '2024-12-31', 30000.00),
('B2B Outreach', 'Business-to-business lead generation', '2024-07-01', '2024-12-31', 45000.00),
('Mobile App Promotion', 'Promote our new mobile application', '2024-08-01', '2024-09-30', 35000.00),
('Holiday Campaign', 'Christmas and New Year promotions', '2024-12-01', '2024-12-31', 80000.00),
('Content Marketing', 'Blog posts and educational content', '2024-01-01', '2024-12-31', 20000.00),
('Influencer Partnership', 'Collaborations with social media influencers', '2024-05-01', '2024-07-31', 55000.00),
('SEO Optimization', 'Search engine optimization campaign', '2024-03-01', '2024-08-31', 25000.00);

INSERT INTO leads (campaign_id, name, email, status, created_at) VALUES
((SELECT campaign_id FROM campaigns WHERE name = 'Summer Sale 2024'), 'John Doe', 'john@example.com', 'converted', '2024-06-15'),
((SELECT campaign_id FROM campaigns WHERE name = 'Summer Sale 2024'), 'Jane Smith', 'jane@example.com', 'contacted', '2024-06-20'),
((SELECT campaign_id FROM campaigns WHERE name = 'Summer Sale 2024'), 'Mike Johnson', 'mike@example.com', 'new', '2024-07-01'),
((SELECT campaign_id FROM campaigns WHERE name = 'Summer Sale 2024'), 'Sarah Wilson', 'sarah@example.com', 'converted', '2024-07-15'),
((SELECT campaign_id FROM campaigns WHERE name = 'Email Newsletter'), 'Bob Johnson', 'bob@example.com', 'new', '2024-02-01'),
((SELECT campaign_id FROM campaigns WHERE name = 'Email Newsletter'), 'Alice Brown', 'alice@example.com', 'contacted', '2024-03-01'),
((SELECT campaign_id FROM campaigns WHERE name = 'Email Newsletter'), 'Tom Davis', 'tom@example.com', 'converted', '2024-04-01'),
((SELECT campaign_id FROM campaigns WHERE name = 'Social Media Boost'), 'Emma Garcia', 'emma@example.com', 'new', '2024-03-15'),
((SELECT campaign_id FROM campaigns WHERE name = 'Social Media Boost'), 'David Lee', 'david@example.com', 'contacted', '2024-04-01'),
((SELECT campaign_id FROM campaigns WHERE name = 'Social Media Boost'), 'Lisa Chen', 'lisa@example.com', 'converted', '2024-04-15'),
((SELECT campaign_id FROM campaigns WHERE name = 'Black Friday Deal'), 'Chris Taylor', 'chris@example.com', 'new', '2024-11-01'),
((SELECT campaign_id FROM campaigns WHERE name = 'Black Friday Deal'), 'Anna Martinez', 'anna@example.com', 'contacted', '2024-11-05'),
((SELECT campaign_id FROM campaigns WHERE name = 'Black Friday Deal'), 'Ryan Anderson', 'ryan@example.com', 'converted', '2024-11-10'),
((SELECT campaign_id FROM campaigns WHERE name = 'Product Launch'), 'Jessica White', 'jessica@example.com', 'new', '2024-09-01'),
((SELECT campaign_id FROM campaigns WHERE name = 'Product Launch'), 'Kevin Rodriguez', 'kevin@example.com', 'contacted', '2024-09-10'),
((SELECT campaign_id FROM campaigns WHERE name = 'Product Launch'), 'Michelle Thompson', 'michelle@example.com', 'converted', '2024-09-20'),
((SELECT campaign_id FROM campaigns WHERE name = 'Customer Retention'), 'Daniel Garcia', 'daniel@example.com', 'new', '2024-01-15'),
((SELECT campaign_id FROM campaigns WHERE name = 'Customer Retention'), 'Amanda Lopez', 'amanda@example.com', 'contacted', '2024-02-01'),
((SELECT campaign_id FROM campaigns WHERE name = 'Customer Retention'), 'James Wilson', 'james@example.com', 'converted', '2024-03-01'),
((SELECT campaign_id FROM campaigns WHERE name = 'B2B Outreach'), 'Jennifer Davis', 'jennifer@example.com', 'new', '2024-07-01'),
((SELECT campaign_id FROM campaigns WHERE name = 'B2B Outreach'), 'Robert Miller', 'robert@example.com', 'contacted', '2024-08-01'),
((SELECT campaign_id FROM campaigns WHERE name = 'B2B Outreach'), 'Linda Moore', 'linda@example.com', 'converted', '2024-09-01'),
((SELECT campaign_id FROM campaigns WHERE name = 'Mobile App Promotion'), 'William Taylor', 'william@example.com', 'new', '2024-08-01'),
((SELECT campaign_id FROM campaigns WHERE name = 'Mobile App Promotion'), 'Elizabeth Anderson', 'elizabeth@example.com', 'contacted', '2024-08-15'),
((SELECT campaign_id FROM campaigns WHERE name = 'Mobile App Promotion'), 'Joseph Thomas', 'joseph@example.com', 'converted', '2024-08-30'),
((SELECT campaign_id FROM campaigns WHERE name = 'Holiday Campaign'), 'Margaret Jackson', 'margaret@example.com', 'new', '2024-12-01'),
((SELECT campaign_id FROM campaigns WHERE name = 'Holiday Campaign'), 'Charles White', 'charles@example.com', 'contacted', '2024-12-10'),
((SELECT campaign_id FROM campaigns WHERE name = 'Holiday Campaign'), 'Patricia Harris', 'patricia@example.com', 'converted', '2024-12-20'),
((SELECT campaign_id FROM campaigns WHERE name = 'Content Marketing'), 'Christopher Martin', 'christopher@example.com', 'new', '2024-01-01'),
((SELECT campaign_id FROM campaigns WHERE name = 'Content Marketing'), 'Nancy Clark', 'nancy@example.com', 'contacted', '2024-02-01'),
((SELECT campaign_id FROM campaigns WHERE name = 'Content Marketing'), 'Donald Lewis', 'donald@example.com', 'converted', '2024-03-01'),
((SELECT campaign_id FROM campaigns WHERE name = 'Influencer Partnership'), 'Dorothy Walker', 'dorothy@example.com', 'new', '2024-05-01'),
((SELECT campaign_id FROM campaigns WHERE name = 'Influencer Partnership'), 'George Hall', 'george@example.com', 'contacted', '2024-06-01'),
((SELECT campaign_id FROM campaigns WHERE name = 'Influencer Partnership'), 'Barbara Allen', 'barbara@example.com', 'converted', '2024-07-01'),
((SELECT campaign_id FROM campaigns WHERE name = 'SEO Optimization'), 'Paul Young', 'paul@example.com', 'new', '2024-03-01'),
((SELECT campaign_id FROM campaigns WHERE name = 'SEO Optimization'), 'Susan King', 'susan@example.com', 'contacted', '2024-04-01'),
((SELECT campaign_id FROM campaigns WHERE name = 'SEO Optimization'), 'Mark Wright', 'mark@example.com', 'converted', '2024-05-01');

-- Sample reports with chart data
INSERT INTO reports (query, chart_data) VALUES
('Show lead status distribution', '{
  "type": "pie",
  "data": {
    "labels": ["New", "Contacted", "Converted"],
    "datasets": [{
      "data": [15, 12, 9],
      "backgroundColor": ["#FF6384", "#36A2EB", "#FFCE56"]
    }]
  },
  "options": {
    "responsive": true,
    "plugins": {
      "title": {
        "display": true,
        "text": "Lead Status Distribution"
      }
    }
  }
}'),
('Compare campaign budgets', '{
  "type": "bar",
  "data": {
    "labels": ["Summer Sale", "Black Friday", "Holiday", "Product Launch", "B2B Outreach"],
    "datasets": [{
      "label": "Budget ($)",
      "data": [50000, 75000, 80000, 60000, 45000],
      "backgroundColor": "#4F46E5"
    }]
  },
  "options": {
    "responsive": true,
    "plugins": {
      "title": {
        "display": true,
        "text": "Campaign Budget Comparison"
      }
    }
  }
}'),
('Leads by campaign', '{
  "type": "horizontalBar",
  "data": {
    "labels": ["Summer Sale 2024", "Email Newsletter", "Social Media Boost", "Black Friday Deal", "Product Launch"],
    "datasets": [{
      "label": "Number of Leads",
      "data": [4, 3, 3, 3, 3],
      "backgroundColor": "#10B981"
    }]
  },
  "options": {
    "responsive": true,
    "plugins": {
      "title": {
        "display": true,
        "text": "Leads Generated by Campaign"
      }
    }
  }
}'),
('Monthly lead conversion trend', '{
  "type": "line",
  "data": {
    "labels": ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"],
    "datasets": [{
      "label": "Converted Leads",
      "data": [1, 2, 3, 2, 1, 2, 3, 4, 3, 2, 3, 4],
      "borderColor": "#F59E0B",
      "fill": false
    }]
  },
  "options": {
    "responsive": true,
    "plugins": {
      "title": {
        "display": true,
        "text": "Monthly Lead Conversion Trend"
      }
    }
  }
}');