// Pure encode/decode helpers for encrypted journal bodies and profile summaries.
// Kept free of network/db so they can be unit-tested with --deny-net.
import { decryptText, encryptText, type EncryptedPayload } from "./encryption.ts"

export interface StoredPayload {
  encryptedContent: string
  encryptionIv: string
}

export async function encryptToJson(plaintext: string): Promise<StoredPayload> {
  const p: EncryptedPayload = await encryptText(plaintext)
  return { encryptedContent: p.encryptedContent, encryptionIv: p.encryptionIv }
}

function isPayload(v: unknown): v is StoredPayload {
  const o = v as StoredPayload | null
  return !!o && typeof o.encryptedContent === "string" && typeof o.encryptionIv === "string"
}

/** Decrypts `encrypted` if present; otherwise falls back to legacy plaintext (pre-backfill rows). */
export async function readSecret(
  encrypted: unknown,
  legacyPlaintext: string | null | undefined,
  label: string
): Promise<string | null> {
  if (isPayload(encrypted)) {
    try {
      return await decryptText(encrypted)
    } catch (e) {
      console.error(`Decryption failed for ${label}:`, e)
      return "[Unable to decrypt this entry]"
    }
  }
  return legacyPlaintext ?? null
}

export interface JournalWriteInput {
  id: string
  moment_id: string
  status: string
  title?: string | null
  body?: string | null
  moods?: string[]
  scripture_quote?: string | null
  scripture_reference?: string | null
  starred?: boolean
  edited?: boolean
  created_at: string
  updated_at?: string
  formation_eligible?: boolean
  extracted_facts?: string | null
  profile_excluded?: boolean | null
  photo_path?: string | null
}

/** Builds the DB row. user_id comes from the verified JWT only. Plaintext `body` is never written (only cleared when body is empty). */
export async function buildJournalRow(input: JournalWriteInput, userId: string): Promise<Record<string, unknown>> {
  const row: Record<string, unknown> = {
    id: input.id,
    moment_id: input.moment_id,
    user_id: userId,
    status: input.status,
    title: input.title ?? null,
    moods: input.moods ?? [],
    scripture_quote: input.scripture_quote ?? null,
    scripture_reference: input.scripture_reference ?? null,
    starred: input.starred ?? false,
    edited: input.edited ?? false,
    created_at: input.created_at,
    updated_at: input.updated_at ?? new Date().toISOString(),
    formation_eligible: input.formation_eligible ?? false,
  }
  if (input.photo_path !== undefined) row.photo_path = input.photo_path
  // Same rule as the old client path: only ever send true; column may not exist on older schemas.
  if (input.profile_excluded === true) row.profile_excluded = true
  if (input.body) {
    row.body_encrypted = await encryptToJson(input.body)
  } else {
    row.body_encrypted = null
    row.body = null // no body: make sure no stale plaintext survives
  }
  // extracted_facts gets the same treatment as body.
  if (input.extracted_facts) {
    row.extracted_facts_encrypted = await encryptToJson(input.extracted_facts)
  } else {
    row.extracted_facts_encrypted = null
    row.extracted_facts = null
  }
  return row
}

/** Converts a DB row into the exact shape the app already decodes (plaintext body, no ciphertext, no join extras). */
export async function toClientJournalRow(row: Record<string, unknown>): Promise<Record<string, unknown>> {
  const { body_encrypted, body, extracted_facts_encrypted, extracted_facts, moments: _moments, ...rest } = row
  const plain = await readSecret(body_encrypted, body as string | null, `journal_entry ${row.id}`)
  const facts = await readSecret(extracted_facts_encrypted, extracted_facts as string | null, `journal_entry facts ${row.id}`)
  return { ...rest, body: plain, extracted_facts: facts }
}

export async function toClientProfileRow(row: Record<string, unknown>): Promise<Record<string, unknown>> {
  const { running_summary_encrypted, running_summary, ...rest } = row
  const plain = await readSecret(running_summary_encrypted, running_summary as string | null, `profile ${row.user_id}`)
  return { ...rest, running_summary: plain }
}
