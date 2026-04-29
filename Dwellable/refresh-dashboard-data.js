#!/usr/bin/env node
/**
 * Refresh Dashboard Data Script
 *
 * Fetches aggregated user/moment data from Supabase and writes to dashboard-data.json
 * Run this script periodically (hourly/daily) to keep dashboard data fresh
 *
 * Usage:
 *   node refresh-dashboard-data.js
 *   # or via cron:
 *   # 0 * * * * cd /Users/kell/Desktop/Dwellable-Native/Dwellable && node refresh-dashboard-data.js
 */

const { createClient } = require('@supabase/supabase-js');
const fs = require('fs');
const path = require('path');

const SUPABASE_URL = 'https://lhcjobrtmbawlhjyodxz.supabase.co';
const SUPABASE_SERVICE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxoY2pvYnJ0bWJhd2xoanlvZHh6Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3MjkxNDk3OCwiZXhwIjoyMDg4NDkwOTc4fQ.kE2anWU0Rcq99v45pEno8KIxXyKlmTbzi2L-cjzvfFc';

async function refreshDashboardData() {
  try {
    console.log('📊 Refreshing dashboard data...');
    console.log(`⏰ ${new Date().toISOString()}`);

    // Initialize Supabase client with service role key
    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY);

    // Fetch users with their moments and usage events
    const [
      { data: usersWithMoments, error: e1 },
      { data: events, error: e2 }
    ] = await Promise.all([
      supabase.from('users').select('id, email, moments(id, created_at)'),
      supabase.from('usage_events').select('id, user_id, event_type, moment_type, timestamp')
    ]);

    if (e1 || e2) {
      throw new Error(`Supabase query failed: ${(e1 || e2).message}`);
    }

    if (!usersWithMoments) {
      throw new Error('No data returned from Supabase');
    }

    // Aggregate the data
    const dashboardData = usersWithMoments.map(user => {
      const moments = user.moments || [];
      const userEvents = events?.filter(e => e.user_id === user.id) || [];

      let firstMoment = null;
      let lastMoment = null;

      if (moments.length > 0) {
        const sorted = [...moments].sort((a, b) =>
          new Date(a.created_at) - new Date(b.created_at)
        );
        firstMoment = sorted[0].created_at;
        lastMoment = sorted[moments.length - 1].created_at;
      }

      // Calculate voice, text, and session counts
      const voiceCount = userEvents.filter(e => e.event_type === 'moment_created' && e.moment_type === 'voice').length;
      const textCount = userEvents.filter(e => e.event_type === 'moment_created' && e.moment_type === 'text').length;
      const sessionCount = userEvents.filter(e => e.event_type === 'app_opened').length;

      return {
        id: user.id,
        email: user.email,
        moment_count: moments.length,
        voice_count: voiceCount,
        text_count: textCount,
        session_count: sessionCount,
        first_moment_created: firstMoment,
        last_moment_created: lastMoment
      };
    });

    // Sort by moment count (descending)
    dashboardData.sort((a, b) => b.moment_count - a.moment_count);

    // Write to dashboard-data.json
    const outputPath = path.join(__dirname, 'dashboard-data.json');
    fs.writeFileSync(outputPath, JSON.stringify(dashboardData, null, 0), 'utf-8');

    // Calculate stats
    const totalUsers = dashboardData.length;
    const totalMoments = dashboardData.reduce((sum, u) => sum + u.moment_count, 0);
    const activeUsers = dashboardData.filter(u => u.moment_count > 0).length;
    const avgMoments = totalUsers > 0 ? (totalMoments / totalUsers).toFixed(1) : '0';

    console.log(`\n✅ Dashboard data refreshed successfully!`);
    console.log(`📈 Stats:`);
    console.log(`   • Total Users: ${totalUsers}`);
    console.log(`   • Total Moments: ${totalMoments}`);
    console.log(`   • Active Users: ${activeUsers}`);
    console.log(`   • Avg Moments/User: ${avgMoments}`);
    console.log(`\n💾 Saved to: ${outputPath}`);
    console.log(`🌐 View dashboard at: http://localhost:8000\n`);

  } catch (err) {
    console.error(`\n❌ Error refreshing dashboard data:`);
    console.error(`   ${err.message}\n`);
    process.exit(1);
  }
}

// Run the refresh
refreshDashboardData();
