const { createClient } = require('@supabase/supabase-js');

const supabase = createClient(
  'https://lhcjobrtmbawlhjyodxz.supabase.co',
  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxoY2pvYnJ0bWJhd2xoanlvZHh6Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3MjkxNDk3OCwiZXhwIjoyMDg4NDkwOTc4fQ.RvLHrQ29m0UwZGXf8ioE8tN0K7j-q1eHjkCqPn6TLbA'
);

(async () => {
  const { data: users } = await supabase
    .from('users')
    .select('id, email')
    .order('email');

  console.log(`\n📋 All users in Supabase:\n`);
  users.forEach(u => console.log(`  ${u.email}`));
  console.log(`\nTotal: ${users.length} users\n`);
})();
