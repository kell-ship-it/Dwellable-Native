const { createClient } = require('@supabase/supabase-js');

const supabase = createClient(
  'https://lhcjobrtmbawlhjyodxz.supabase.co',
  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxoY2pvYnJ0bWJhd2xoanlvZHh6Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3MjkxNDk3OCwiZXhwIjoyMDg4NDkwOTc4fQ.RvLHrQ29m0UwZGXf8ioE8tN0K7j-q1eHjkCqPn6TLbA'
);

(async () => {
  const { data: users } = await supabase
    .from('users')
    .select('id, email')
    .eq('email', 'kell@pilot.dwellable.com');

  if (!users || users.length === 0) {
    console.log('User not found');
    return;
  }

  const userId = users[0].id;
  console.log(`\n✅ Found user: ${users[0].email}\n`);

  const { data: moments } = await supabase
    .from('moments')
    .select('id, body, created_at')
    .eq('user_id', userId)
    .order('created_at', { ascending: false })
    .limit(5);

  console.log(`📊 Your latest 5 moments:\n`);
  if (moments && moments.length > 0) {
    moments.forEach((m, i) => {
      const date = new Date(m.created_at).toLocaleDateString() + ' ' + new Date(m.created_at).toLocaleTimeString();
      const preview = m.body ? m.body.substring(0, 50) : '(empty)';
      console.log(`${i+1}. [${date}] ${preview}...`);
    });
  } else {
    console.log('(No moments found)');
  }
})();
