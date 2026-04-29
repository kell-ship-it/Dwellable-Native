const { createClient } = require('@supabase/supabase-js');
const supabase = createClient(
  'https://lhcjobrtmbawlhjyodxz.supabase.co',
  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxoY2pvYnJ0bWJhd2xoanlvZHh6Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3MjkxNDk3OCwiZXhwIjoyMDg4NDkwOTc4fQ.RvLHrQ29m0UwZGXf8ioE8tN0K7j-q1eHjkCqPn6TLbA'
);

(async () => {
  // Query moments created on April 20, 2026
  const { data: todayMoments, error } = await supabase
    .from('moments')
    .select('id, user_id, body, created_at')
    .gte('created_at', '2026-04-20T00:00:00Z')
    .lte('created_at', '2026-04-20T23:59:59Z');

  if (error) {
    console.log(`Error: ${error.message}`);
    return;
  }

  console.log(`\n📊 Moments created today (April 20):\n`);
  
  if (!todayMoments || todayMoments.length === 0) {
    console.log('❌ ZERO moments found from today');
  } else {
    console.log(`✅ Found ${todayMoments.length} moments from today:\n`);
    todayMoments.forEach(m => {
      const time = new Date(m.created_at).toLocaleTimeString();
      const preview = m.body ? m.body.substring(0, 40) : '(empty)';
      console.log(`  ${time} | ${preview}...`);
    });
  }

  // Also check latest moments to see when the last one was created
  const { data: latestMoments } = await supabase
    .from('moments')
    .select('id, user_id, created_at')
    .order('created_at', { ascending: false })
    .limit(10);

  console.log(`\n📈 Latest 10 moments overall:\n`);
  latestMoments.forEach((m, i) => {
    const date = new Date(m.created_at).toLocaleDateString() + ' ' + new Date(m.created_at).toLocaleTimeString();
    console.log(`${i+1}. ${date}`);
  });
})();
