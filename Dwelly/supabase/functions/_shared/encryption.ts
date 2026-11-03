// Shared AES-256-GCM encrypt/decrypt for moment content (T-062).
//
// Key management: MOMENT_ENCRYPTION_KEY is a 256-bit key, base64-encoded, set as
// an Edge Function secret (`supabase secrets set MOMENT_ENCRYPTION_KEY=...`).
// It is server-managed -- never derived from the user's password, never sent to
// or stored on the client. See docs/PILLAR_2_SECURITY_STRATEGY.md for the full
// model this implements.

const ALGORITHM = "AES-GCM"
const KEY_LENGTH_BITS = 256
const IV_LENGTH_BYTES = 12 // 96-bit IV, standard for AES-GCM

function base64ToBytes(b64: string): Uint8Array {
  const binary = atob(b64)
  const bytes = new Uint8Array(binary.length)
  for (let i = 0; i < binary.length; i++) bytes[i] = binary.charCodeAt(i)
  return bytes
}

function bytesToBase64(bytes: Uint8Array): string {
  let binary = ""
  for (let i = 0; i < bytes.length; i++) binary += String.fromCharCode(bytes[i])
  return btoa(binary)
}

async function loadKey(): Promise<CryptoKey> {
  const keyB64 = Deno.env.get("MOMENT_ENCRYPTION_KEY")
  if (!keyB64) {
    throw new Error(
      "MOMENT_ENCRYPTION_KEY is not set. Generate one with: openssl rand -base64 32, " +
        "then: supabase secrets set MOMENT_ENCRYPTION_KEY=<value>"
    )
  }
  const keyBytes = base64ToBytes(keyB64)
  if (keyBytes.length * 8 !== KEY_LENGTH_BITS) {
    throw new Error(
      `MOMENT_ENCRYPTION_KEY must decode to exactly ${KEY_LENGTH_BITS / 8} bytes, got ${keyBytes.length}`
    )
  }
  return crypto.subtle.importKey("raw", keyBytes, ALGORITHM, false, ["encrypt", "decrypt"])
}

export interface EncryptedPayload {
  encryptedContent: string // base64 ciphertext (includes GCM auth tag)
  encryptionIv: string // base64 IV, unique per call
}

/** Encrypts plaintext for storage. Call this only inside a trusted server context (Edge Function) -- never on-device. */
export async function encryptText(plaintext: string): Promise<EncryptedPayload> {
  const key = await loadKey()
  const iv = crypto.getRandomValues(new Uint8Array(IV_LENGTH_BYTES))
  const encoded = new TextEncoder().encode(plaintext)

  const ciphertext = await crypto.subtle.encrypt({ name: ALGORITHM, iv }, key, encoded)

  return {
    encryptedContent: bytesToBase64(new Uint8Array(ciphertext)),
    encryptionIv: bytesToBase64(iv),
  }
}

/** Decrypts a stored payload back to plaintext. Result must never be persisted -- display/processing only, per the locked P2 model. */
export async function decryptText(payload: EncryptedPayload): Promise<string> {
  const key = await loadKey()
  const iv = base64ToBytes(payload.encryptionIv)
  const ciphertext = base64ToBytes(payload.encryptedContent)

  const plaintextBytes = await crypto.subtle.decrypt({ name: ALGORITHM, iv }, key, ciphertext)
  return new TextDecoder().decode(plaintextBytes)
}
