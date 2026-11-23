// Pure helper for usage-dashboard: reconstructs "the most recent capture" from llm_usage
// rows. llm_usage has NO capture/request ID, so this is INFERRED from feature names and
// timestamps only -- the dashboard labels it that way. No message content is read.
//
// Per Send the proxy logs: classifier, output check, main reply (in that order).
// On Done: journal_synthesis, then dweller_profile_summary (a couple of seconds apart).

export interface UsageRow {
  provider: string
  feature: string
  prompt_tokens: number | null
  completion_tokens: number | null
  total_tokens: number | null
  created_at: string
}

export interface Totals {
  calls: number
  promptTokens: number
  completionTokens: number
  totalTokens: number
}

export type Stage = "classifier" | "mainReply" | "outputCheck" | "journalSynthesis" | "profileSummary"

export interface LastCapture {
  startedAt: string
  endedAt: string
  saved: boolean
  turns: number
  providers: string[]
  totals: Totals
  stages: Partial<Record<Stage, Totals>>
  inferred: true
}

export function emptyTotals(): Totals {
  return { calls: 0, promptTokens: 0, completionTokens: 0, totalTokens: 0 }
}

export function stageOf(feature: string): Stage | null {
  switch (feature) {
    case "capture_conversation_safety_classifier": return "classifier"
    case "capture_conversation_safety_output_check": return "outputCheck"
    case "capture_conversation": return "mainReply"
    case "journal_synthesis": return "journalSynthesis"
    case "dweller_profile_summary": return "profileSummary"
    default: return null // prayer, narrative, etc. -- not part of a capture
  }
}

const isSave = (s: Stage) => s === "journalSynthesis" || s === "profileSummary"

const SAVE_PAIR_GAP_MS = 2 * 60 * 1000          // synthesis -> profile summary are seconds apart
const TURN_GAP_MS = 30 * 60 * 1000              // max pause between Sends of one capture
const SAVE_JUNCTION_GAP_MS = 6 * 60 * 60 * 1000 // last Send -> Done/save (can be a long gap)

function add(t: Totals, r: UsageRow) {
  t.calls += 1
  t.promptTokens += r.prompt_tokens ?? 0
  t.completionTokens += r.completion_tokens ?? 0
  t.totalTokens += r.total_tokens ?? 0
}

/// `rowsNewestFirst` must be sorted by created_at DESC (as the dashboard query returns).
export function summarizeLastCapture(rowsNewestFirst: UsageRow[]): LastCapture | null {
  const rows = rowsNewestFirst.filter((r) => stageOf(r.feature) !== null)
  if (rows.length === 0) return null
  const ms = (r: UsageRow) => new Date(r.created_at).getTime()

  const picked: UsageRow[] = []
  let i = 0

  // 1) trailing save rows (journal synthesis + profile summary), if the capture was saved
  while (i < rows.length && isSave(stageOf(rows[i].feature)!)) {
    if (picked.length > 0 && ms(picked[picked.length - 1]) - ms(rows[i]) > SAVE_PAIR_GAP_MS) break
    picked.push(rows[i])
    i++
  }
  const hadSave = picked.length > 0

  // 2) the Sends: walk back through conversation rows until a save row (the previous
  //    capture's end) or a long pause.
  let lastConvMs: number | null = null
  const newestPickedMs = picked.length > 0 ? ms(picked[picked.length - 1]) : null
  while (i < rows.length && !isSave(stageOf(rows[i].feature)!)) {
    const t = ms(rows[i])
    if (lastConvMs === null) {
      if (hadSave && newestPickedMs !== null && newestPickedMs - t > SAVE_JUNCTION_GAP_MS) break
    } else if (lastConvMs - t > TURN_GAP_MS) {
      break
    }
    picked.push(rows[i])
    lastConvMs = t
    i++
  }
  if (picked.length === 0) return null

  const totals = emptyTotals()
  const stages: Partial<Record<Stage, Totals>> = {}
  const providers = new Set<string>()
  let turns = 0
  for (const r of picked) {
    const s = stageOf(r.feature)!
    add(totals, r)
    add(stages[s] ?? (stages[s] = emptyTotals()), r)
    providers.add(r.provider)
    if (s === "classifier") turns += 1
  }
  const times = picked.map(ms)
  return {
    startedAt: new Date(Math.min(...times)).toISOString(),
    endedAt: new Date(Math.max(...times)).toISOString(),
    saved: hadSave && (stages.journalSynthesis?.calls ?? 0) > 0,
    turns,
    providers: [...providers],
    totals,
    stages,
    inferred: true,
  }
}
