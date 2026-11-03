const https = require('https');

const baseUrl = 'https://lhcjobrtmbawlhjyodxz.supabase.co/rest/v1/moments';
const key = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxoY2pvYnJ0bWJhd2xoanlvZHh6Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3MjkxNDk3OCwiZXhwIjoyMDg4NDkwOTc4fQ.RvLHrQ29m0UwZGXf8ioE8tN0K7j-q1eHjkCqPn6TLbA';

// Query: Count total moments
const url = new URL(baseUrl);
url.searchParams.append('select', 'count');

const req = https.request(url, {
  method: 'GET',
  headers: {
    'apikey': key,
    'Authorization': `Bearer ${key}`,
    'Prefer': 'count=exact'
  }
}, (res) => {
  let data = '';
  res.on('data', chunk => data += chunk);
  res.on('end', () => {
    console.log(`Supabase total moment rows: ${res.headers['content-range']}`);
    
    // Now get the most recent 10
    queryRecent();
  });
});

req.on('error', console.error);
req.end();

function queryRecent() {
  const url2 = new URL(baseUrl);
  url2.searchParams.append('order', 'created_at.desc');
  url2.searchParams.append('limit', '10');
  url2.searchParams.append('select', 'id,user_id,body,created_at');

  const req2 = https.request(url2, {
    method: 'GET',
    headers: {
      'apikey': key,
      'Authorization': `Bearer ${key}`
    }
  }, (res) => {
    let data = '';
    res.on('data', chunk => data += chunk);
    res.on('end', () => {
      const moments = JSON.parse(data);
      console.log('\nMost recent 10 moments in Supabase:');
      moments.forEach((m, i) => {
        const date = new Date(m.created_at).toLocaleDateString() + ' ' + new Date(m.created_at).toLocaleTimeString();
        console.log(`${i+1}. ${date} | ${m.body.substring(0, 30)}...`);
      });
    });
  });

  req2.on('error', console.error);
  req2.end();
}
