-- ============================================================
-- DWELLABLE PILOT QUERIES
-- Run these in: https://supabase.com/dashboard/project/lhcjobrtmbawlhjyodxz/sql/new
-- ============================================================


-- ────────────────────────────────────────────────────────────
-- 1. PILOT LEADERBOARD — Full summary for every user
-- ────────────────────────────────────────────────────────────
SELECT
  u.email,
  COUNT(DISTINCT m.id)                                                      AS total_moments,
  COUNT(DISTINCT CASE WHEN ue.moment_type = 'voice' THEN ue.id END)        AS voice_moments,
  COUNT(DISTINCT CASE WHEN ue.moment_type = 'text'  THEN ue.id END)        AS text_moments,
  COUNT(DISTINCT CASE WHEN ue.event_type  = 'app_opened' THEN ue.id END)   AS total_sessions,
  MIN(m.created_at)                                                         AS first_moment,
  MAX(m.created_at)                                                         AS last_moment
FROM public.users u
LEFT JOIN public.moments m       ON m.user_id  = u.id
LEFT JOIN public.usage_events ue ON ue.user_id = u.id
GROUP BY u.email
ORDER BY total_moments DESC;


-- ────────────────────────────────────────────────────────────
-- 2. SINGLE USER DEEP DIVE — swap in any email
-- ────────────────────────────────────────────────────────────
SELECT
  COUNT(DISTINCT m.id)                                                      AS total_moments,
  COUNT(DISTINCT CASE WHEN ue.moment_type = 'voice' THEN ue.id END)        AS voice_moments,
  COUNT(DISTINCT CASE WHEN ue.moment_type = 'text'  THEN ue.id END)        AS text_moments,
  COUNT(DISTINCT CASE WHEN ue.event_type  = 'app_opened' THEN ue.id END)   AS total_sessions,
  ROUND(
    COUNT(DISTINCT m.id)::numeric /
    NULLIF(COUNT(DISTINCT CASE WHEN ue.event_type = 'app_opened' THEN ue.id END), 0),
    2
  )                                                                         AS moments_per_session
FROM public.users u
LEFT JOIN public.moments m       ON m.user_id  = u.id
LEFT JOIN public.usage_events ue ON ue.user_id = u.id
WHERE u.email = 'pilot2@dwellable.com';  -- ← change email here


-- ────────────────────────────────────────────────────────────
-- 3. DAILY ACTIVITY — moments per day across all users
-- ────────────────────────────────────────────────────────────
SELECT
  DATE(m.created_at)  AS day,
  COUNT(*)            AS moments_created,
  COUNT(DISTINCT m.user_id) AS active_users
FROM public.moments m
GROUP BY DATE(m.created_at)
ORDER BY day DESC;


-- ────────────────────────────────────────────────────────────
-- 4. VOICE vs TEXT SPLIT — pilot-wide
-- ────────────────────────────────────────────────────────────
SELECT
  moment_type,
  COUNT(*) AS count,
  ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 1) AS pct
FROM public.usage_events
WHERE event_type = 'moment_created'
  AND moment_type IS NOT NULL
GROUP BY moment_type;


-- ────────────────────────────────────────────────────────────
-- 5. RETENTION — users who came back more than once
-- ────────────────────────────────────────────────────────────
SELECT
  u.email,
  COUNT(DISTINCT DATE(ue.timestamp)) AS active_days
FROM public.users u
JOIN public.usage_events ue ON ue.user_id = u.id
WHERE ue.event_type = 'app_opened'
GROUP BY u.email
HAVING COUNT(DISTINCT DATE(ue.timestamp)) > 1
ORDER BY active_days DESC;


-- ────────────────────────────────────────────────────────────
-- 6. ALL MOMENTS FOR A USER — full text, newest first
-- ────────────────────────────────────────────────────────────
SELECT
  m.id,
  m.body,
  m.created_at
FROM public.moments m
JOIN public.users u ON u.id = m.user_id
WHERE u.email = 'pilot2@dwellable.com'  -- ← change email here
ORDER BY m.created_at DESC;


-- ────────────────────────────────────────────────────────────
-- 7. TOTAL PILOT COUNTS — one-line summary
-- ────────────────────────────────────────────────────────────
SELECT
  (SELECT COUNT(*) FROM public.users)                                    AS total_users,
  (SELECT COUNT(*) FROM public.moments)                                  AS total_moments,
  (SELECT COUNT(*) FROM public.usage_events WHERE event_type = 'app_opened') AS total_sessions,
  (SELECT COUNT(*) FROM public.usage_events WHERE moment_type = 'voice') AS voice_moments,
  (SELECT COUNT(*) FROM public.usage_events WHERE moment_type = 'text')  AS text_moments;
