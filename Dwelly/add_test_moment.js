const { createClient } = require('@supabase/supabase-js');

const supabase = createClient(
  'https://lhcjobrtmbawlhjyodxz.supabase.co',
  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxoY2pvYnJ0bWJhd2xoanlvZHh6Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3MjkxNDk3OCwiZXhwIjoyMDg4NDkwOTc4fQ.RvLHrQ29m0UwZGXf8ioE8tN0K7j-q1eHjkCqPn6TLbA'
);

(async () => {
  // Your user ID from dashboard data
  const userId = '88490be7-cad4-475d-b4de-cd942770563d';
  
  const { data, error } = await supabase
    .from('moments')
    .insert([{
      user_id: userId,
      body: 'Test moment created April 20, 2026 via dashboard population',
      sense_of_lord: 'Testing dashboard refresh',
      created_at: new Date().toISOString()
    }])
    .select();

  if (error) {
    console.log(`\n❌ Error: ${error.message}\n`);
  } else {
    console.log(`\n✅ Test moment added successfully!\n`);
    console.log(`ID: ${data[0].id}`);
    console.log(`Created: ${data[0].created_at}`);
    console.log(`\n🌐 Refresh dashboard at http://localhost:8000`);
    console.log(`   (after running: npm start)\n`);
  }
})();
