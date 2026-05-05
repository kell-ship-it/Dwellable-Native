# Phase 3.3: Enhanced Alerting & Notifications

**Status:** ✅ DOCUMENTATION READY — Ready for implementation

**Purpose:** Set up real-time alerts when security incidents are detected.

---

## What Triggers Alerts

| Incident Type | Severity | Action |
|---------------|----------|--------|
| **Brute Force Attack** | Medium | Login alert on user account |
| **Distributed Attack** | High | IP block notification to admin |
| **API Abuse** | High | Rate limit escalation |
| **Unusual Pattern** | Medium | Investigation recommendation |

---

## Alert Delivery Methods

### Option 1: Supabase Functions + Email (Easy, No Cost)

**How it works:**
1. Database trigger fires when incident is created
2. Supabase Function sends email to admin
3. Function includes incident details and recommended action

**Implementation:**

```typescript
// Edge Function: send-security-alert
// Triggered when abuse_incidents table has INSERT

Deno.serve(async (req) => {
  const { email, incident_type, severity, details } = await req.json();

  // Send email via Resend or SendGrid
  const response = await fetch("https://api.resend.com/emails", {
    method: "POST",
    headers: {
      "Authorization": `Bearer ${Deno.env.get("RESEND_API_KEY")}`,
      "Content-Type": "application/json"
    },
    body: JSON.stringify({
      from: "security@dwellable.app",
      to: "admin@dwellable.app",
      subject: `[SECURITY ALERT] ${severity.toUpperCase()}: ${incident_type}`,
      html: `
        <h2>Security Incident Detected</h2>
        <p><strong>Type:</strong> ${incident_type}</p>
        <p><strong>Severity:</strong> ${severity}</p>
        <p><strong>Account:</strong> ${email}</p>
        <p><strong>Time:</strong> ${new Date().toISOString()}</p>
        <pre>${JSON.stringify(details, null, 2)}</pre>
        <p><a href="https://supabase.com/dashboard">View in Dashboard</a></p>
      `
    })
  });

  return new Response(JSON.stringify({ success: true }));
});
```

**Cost:** $0-10/month (Resend free tier: 100 emails/day)

---

### Option 2: In-App Notifications (Best UX)

**How it works:**
1. User logs in and incident is detected
2. App shows banner notification: "Your account had suspicious activity"
3. User can review login history in SettingsView

**Implementation (Future Enhancement):**

```swift
// In AuthManager or LoginView
if let incidents = try? await apiClient.fetchUserIncidents(userId: user.id) {
    if !incidents.isEmpty {
        showSecurityBanner = true
        securityMessage = "We detected \(incidents.count) suspicious attempt(s) on your account. Review your activity in Settings."
    }
}
```

**Cost:** $0 (built-in)

---

### Option 3: Slack Integration (For Team)

**How it works:**
1. Abuse incident detected
2. Webhook sends message to #security Slack channel
3. Team notified in real-time

**Implementation:**

```typescript
// Edge Function: notify-slack-security

const slack_webhook = Deno.env.get("SLACK_WEBHOOK_URL");

const message = {
  text: "🚨 Security Alert",
  blocks: [
    {
      type: "header",
      text: { type: "plain_text", text: "Security Incident Detected" }
    },
    {
      type: "section",
      fields: [
        { type: "mrkdwn", text: `*Type:*\n${incident_type}` },
        { type: "mrkdwn", text: `*Severity:*\n${severity}` },
        { type: "mrkdwn", text: `*Email:*\n${email}` },
        { type: "mrkdwn", text: `*Time:*\n${new Date().toISOString()}` }
      ]
    },
    {
      type: "actions",
      elements: [
        {
          type: "button",
          text: { type: "plain_text", text: "View in Dashboard" },
          url: "https://supabase.com/dashboard"
        }
      ]
    }
  ]
};

await fetch(slack_webhook, {
  method: "POST",
  body: JSON.stringify(message)
});
```

**Cost:** Free (Slack Pro plan)
**Setup:** 
1. Create Slack workspace #security channel
2. Create incoming webhook at api.slack.com
3. Store webhook URL in Supabase environment variables

---

### Option 4: Database Webhooks (Realtime Sync)

**How it works:**
1. Incident created in `abuse_incidents` table
2. Supabase webhook fires immediately
3. External service notified via HTTP POST

**Implementation (Supabase Configuration):**

1. Go to Supabase Dashboard → Database → Webhooks
2. Create webhook on `abuse_incidents` table
3. Select "Insert" event
4. Set webhook URL: `https://api.example.com/security/alert`

```bash
# Example webhook payload:
{
  "type": "INSERT",
  "table": "abuse_incidents",
  "schema": "public",
  "record": {
    "id": "uuid",
    "user_id": "uuid",
    "email": "attacker@example.com",
    "incident_type": "brute_force",
    "severity": "high",
    "details": { ... },
    "detected_at": "2026-03-17T22:30:00Z"
  }
}
```

**Cost:** $0 (Supabase included)

---

## Alert Filtering & Rules

To avoid alert fatigue, implement smart filtering:

```sql
-- Create rule: Only alert on HIGH+ severity incidents
CREATE OR REPLACE FUNCTION alert_on_high_severity_incidents()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.severity IN ('high', 'critical') THEN
    -- Send alert
    PERFORM notify_slack(NEW.email, NEW.incident_type, NEW.severity);
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER abuse_alert_trigger
AFTER INSERT ON abuse_incidents
FOR EACH ROW
EXECUTE FUNCTION alert_on_high_severity_incidents();
```

---

## Recommended Setup for Dwellable

| Phase | Method | Priority | Cost | Timeline |
|-------|--------|----------|------|----------|
| **Now (Phase 3.3)** | In-app notifications + Email (manual) | Medium | $0 | 1 hour |
| **Next Release** | Slack webhook | Medium | Free | 2 hours |
| **Q2 2026** | Automated email via Resend | High | $0-10/mo | 3 hours |
| **Q3 2026** | Database webhooks | Medium | $0 | 2 hours |

---

## Manual Alerting (Until Automated)

Until automated alerts are set up, manually check:

**Daily:**
```sql
SELECT email, incident_type, severity, detected_at
FROM abuse_incidents
WHERE resolved = false
  AND detected_at > NOW() - INTERVAL '1 day'
ORDER BY severity DESC, detected_at DESC;
```

**Weekly:**
- Check suspicious_login_patterns view
- Review API usage spikes
- Scan for new user registrations with suspicious patterns

---

## Incident Response Playbook

When an alert fires:

| Severity | Response Time | Action |
|----------|---------------|--------|
| **Low** | 24 hours | Log and monitor |
| **Medium** | 4 hours | Investigate, consider blocking IP |
| **High** | 1 hour | Block IP, notify user |
| **Critical** | 15 min | Immediate investigation, revoke tokens |

---

## Testing Alert System

### Test Email Alert:
```sql
-- Manually insert incident to trigger alert
INSERT INTO abuse_incidents (
  user_id, email, incident_type, severity, details, detected_at
) VALUES (
  NULL, 'test@example.com', 'brute_force', 'high',
  '{"test": true}'::jsonb, NOW()
);
```

### Test Slack Alert:
1. Create test incident manually (above)
2. Check #security Slack channel within 5 seconds
3. Verify message includes all details

---

## Security Considerations

- **Do NOT** send passwords or sensitive data in alerts
- **Always** use HTTPS for webhook endpoints
- **Verify** webhook signatures (if using signed webhooks)
- **Rotate** webhook secrets quarterly
- **Limit** alert recipients to security team only
- **Archive** alert logs for 90 days for audit

---

## Next Steps

1. **Immediate (This Week):**
   - ✅ Review monitoring tables and views
   - ✅ Set up manual daily checks
   - ✅ Document on-call procedure

2. **Next Release (April):**
   - [ ] Implement in-app notification banner
   - [ ] Add login history to SettingsView
   - [ ] Set up Slack webhook

3. **Later (Q2):**
   - [ ] Integrate email alerting via Resend
   - [ ] Set up automated IP blocking
   - [ ] Create admin dashboard

---

## References

- [Supabase Webhooks](https://supabase.com/docs/guides/realtime/webhooks)
- [Email Alerting Best Practices](https://www.pagerduty.com/blog/alerting-best-practices/)
- [Slack API](https://api.slack.com)

---

**Created:** March 17, 2026
**Status:** Documentation Complete — Ready for Implementation
