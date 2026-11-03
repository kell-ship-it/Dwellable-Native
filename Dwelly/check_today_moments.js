const { createClient } = require('@supabase/supabase-js');
const supabase = createClient(
  'https://lhcjobrtmbawlhjyodxz.supabase.co',
  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxoY2pvYnJ0bWJhd2xoanlvZHh6Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3MjkxNDk3OCwiZXhwIjoyMDg4NDkwOTc4fQ.RvLHrQ29m0UwZGXf8ioE8tN0K7j-q1eHjkCqPn6TLbA'
);

(async () => {
  const { data: todayMoments, error } = await supabase
    .from('moments')
    .select('id, user_id, body, created_at')
    .gte('created_at', '2026-04-20T00:00:00Z')
    .lte('created_at', '2026-04-20T23:59:59Z');

  if (error) {
    console.log(`Error: ${error.message}`);
    return;
  }

  console.log(`\n📊 Moments from April 20:\n`);
  
  if (!todayMoments || todayMoments.length === 0) {
    console.log('❌ ZERO moments found from today');
  } else {
    console.log(`✅ Found ${todayMoments.length} moments`);
  }

  const { data: latestMoments } = await supabase
    .from('moments')
    .select('id, created_at')
    .order('created_at', { ascending: false })
    .limit(5);

  console.log(`\n📈 Latest 5 moments:\n`);
  latestMoments.forEach((m, i) => {
    const date = new Date(m.created_at).toLocaleDateString() + ' ' + new Date(m.created_at).toLocaleTimeString();
    console.log(`${i+1}. ${date}`);
  });
})();
