/**
 * Asrar-e-Tibb: Automated Cloud Staging Security Verification Test Harness
 * 
 * Target: Hosted Supabase Staging (https://zhhreesobwvhzmwshaqh.supabase.co)
 * Reference: zhhreesobwvhzmwshaqh
 * 
 * Verifies all 10 documented staging security scenarios:
 * STG-01: Unauthenticated access to protected personal data (schedules/notes)
 * STG-02: Self-promotion to administrator via PATCH
 * STG-03: Self-unblocking via PATCH
 * STG-04: Forged administrator public registration
 * STG-05: Cross-user private note access (RLS isolation)
 * STG-06: Cross-user private note modification or deletion
 * STG-07: Unauthorized post moderation deletion
 * STG-08: Authorized administrator post moderation deletion
 * STG-09: Profile-image folder hijacking (cross-user storage upload)
 * STG-10: Post-image path traversal / root folder upload rejection
 */

const fs = require('fs');
const path = require('path');
const https = require('https');
const http = require('http');

// Automatically parse e:\Asrar-E-Tibb\.env if present
const envPath = path.resolve(__dirname, '../../.env');
if (fs.existsSync(envPath)) {
  const envContent = fs.readFileSync(envPath, 'utf8');
  envContent.split(/\r?\n/).forEach((line) => {
    line = line.trim();
    if (line && !line.startsWith('#') && line.includes('=')) {
      const idx = line.indexOf('=');
      const key = line.substring(0, idx).trim();
      const val = line.substring(idx + 1).trim().replace(/^["']|["']$/g, '');
      if (!process.env[key]) {
        process.env[key] = val;
      }
    }
  });
}

const BASE_URL = process.env.SUPABASE_URL || 'https://zhhreesobwvhzmwshaqh.supabase.co';
const ANON_KEY = process.env.SUPABASE_ANON_KEY || '';

const ADMIN_ID = process.env.STAGING_ADMIN_ID || '7d557deb-4459-409b-84cf-289dbb52324b';
const ADMIN_EMAIL = process.env.STAGING_ADMIN_EMAIL || '';
const ADMIN_PASSWORD = process.env.STAGING_ADMIN_PASSWORD || '';
let ADMIN_TOKEN = process.env.STAGING_ADMIN_TOKEN || '';

const USER_A_EMAIL = process.env.STAGING_USER_A_EMAIL || 'user_a@staging.test';
const USER_A_PASSWORD = process.env.STAGING_USER_A_PASSWORD || 'StagingTest123!';
let USER_A_TOKEN = process.env.STAGING_USER_A_TOKEN || '';

const USER_B_EMAIL = process.env.STAGING_USER_B_EMAIL || 'user_b@staging.test';
const USER_B_PASSWORD = process.env.STAGING_USER_B_PASSWORD || 'StagingTest123!';
let USER_B_TOKEN = process.env.STAGING_USER_B_TOKEN || '';

/**
 * Generic HTTP request utility for Supabase REST, Auth & Storage APIs
 */
async function apiRequest(endpoint, options = {}, payload = null, token = null) {
  return new Promise((resolve, reject) => {
    const url = new URL(endpoint, BASE_URL);
    const isHttps = url.protocol === 'https:';
    const client = isHttps ? https : http;

    const headers = {
      'apikey': ANON_KEY,
      'Content-Type': 'application/json',
      ...options.headers,
    };

    if (token) {
      headers['Authorization'] = `Bearer ${token}`;
    } else if (!headers['Authorization']) {
      headers['Authorization'] = `Bearer ${ANON_KEY}`;
    }

    const reqOptions = {
      method: options.method || 'GET',
      hostname: url.hostname,
      port: url.port || (isHttps ? 443 : 80),
      path: url.pathname + url.search,
      headers,
    };

    const req = client.request(reqOptions, (res) => {
      let data = '';
      res.on('data', (chunk) => data += chunk);
      res.on('end', () => {
        let parsed = null;
        try {
          parsed = data ? JSON.parse(data) : null;
        } catch {
          parsed = data;
        }
        resolve({
          status: res.statusCode,
          data: parsed,
          raw: data,
          headers: res.headers,
        });
      });
    });

    req.on('error', reject);
    if (payload) {
      if (typeof payload === 'string' || Buffer.isBuffer(payload)) {
        req.write(payload);
      } else {
        req.write(JSON.stringify(payload));
      }
    }
    req.end();
  });
}

/**
 * Log in via email/password to retrieve JWT access token
 */
async function loginUser(email, password) {
  if (!email || !password) return null;
  const res = await apiRequest('/auth/v1/token?grant_type=password', {
    method: 'POST'
  }, { email, password });

  if (res.status === 200 && res.data?.access_token) {
    return {
      token: res.data.access_token,
      userId: res.data.user?.id,
      email: res.data.user?.email,
    };
  }
  return { error: res.data, status: res.status };
}

function extractJwtSub(token) {
  try {
    const payload = JSON.parse(Buffer.from(token.split('.')[1], 'base64').toString());
    return payload.sub;
  } catch {
    return null;
  }
}

async function runTestSuite() {
  console.log('================================================================');
  console.log('Asrar-e-Tibb: Cloud Staging Security Verification Suite');
  console.log(`Target: ${BASE_URL}`);
  console.log('================================================================\n');

  if (!ANON_KEY) {
    console.error('ERROR: SUPABASE_ANON_KEY is missing.');
    console.error('Please configure SUPABASE_ANON_KEY in e:\\Asrar-E-Tibb\\.env');
    process.exit(1);
  }

  let passed = 0;
  let total = 0;
  const testResults = [];

  function recordResult(testId, name, condition, details = '') {
    total++;
    const status = condition ? 'PASS' : 'FAIL';
    if (condition) {
      passed++;
      console.log(`[PASS] ${testId}: ${name}`);
    } else {
      console.error(`[FAIL] ${testId}: ${name}`);
    }
    if (details) console.log(`   Details: ${details}`);
    testResults.push({ testId, name, status, details });
  }

  // ---------------------------------------------------------------------------
  // Authenticate / Resolve Sessions
  // ---------------------------------------------------------------------------
  console.log('--- Account Authentication Preflight ---');

  let sessionUserA = null;
  if (USER_A_TOKEN) {
    sessionUserA = { token: USER_A_TOKEN, userId: extractJwtSub(USER_A_TOKEN) };
    console.log(`User A: Token provided (User ID: ${sessionUserA.userId})`);
  } else if (USER_A_EMAIL && USER_A_PASSWORD) {
    const loginA = await loginUser(USER_A_EMAIL, USER_A_PASSWORD);
    if (loginA && loginA.token) {
      sessionUserA = loginA;
      console.log(`User A: Authenticated as ${loginA.email} (ID: ${loginA.userId})`);
    } else {
      console.warn(`User A: Login failed (Status: ${loginA?.status}, Message: ${JSON.stringify(loginA?.error)})`);
    }
  }

  let sessionUserB = null;
  if (USER_B_TOKEN) {
    sessionUserB = { token: USER_B_TOKEN, userId: extractJwtSub(USER_B_TOKEN) };
    console.log(`User B: Token provided (User ID: ${sessionUserB.userId})`);
  } else if (USER_B_EMAIL && USER_B_PASSWORD) {
    const loginB = await loginUser(USER_B_EMAIL, USER_B_PASSWORD);
    if (loginB && loginB.token) {
      sessionUserB = loginB;
      console.log(`User B: Authenticated as ${loginB.email} (ID: ${loginB.userId})`);
    } else {
      console.warn(`User B: Login failed (Status: ${loginB?.status}, Message: ${JSON.stringify(loginB?.error)})`);
    }
  }

  let sessionAdmin = null;
  if (ADMIN_TOKEN) {
    sessionAdmin = { token: ADMIN_TOKEN, userId: extractJwtSub(ADMIN_TOKEN) };
    console.log(`Admin: Token provided (User ID: ${sessionAdmin.userId})`);
  } else if (ADMIN_EMAIL && ADMIN_PASSWORD) {
    const loginAdm = await loginUser(ADMIN_EMAIL, ADMIN_PASSWORD);
    if (loginAdm && loginAdm.token) {
      sessionAdmin = loginAdm;
      console.log(`Admin: Authenticated as ${loginAdm.email} (ID: ${loginAdm.userId})`);
    } else {
      console.warn(`Admin: Login failed (Status: ${loginAdm?.status}, Message: ${JSON.stringify(loginAdm?.error)})`);
    }
  }

  console.log('\n--- Executing 10 Staging Security Test Scenarios ---\n');

  // ---------------------------------------------------------------------------
  // STG-01: Unauthenticated access to protected personal data
  // ---------------------------------------------------------------------------
  const stg01 = await apiRequest('/rest/v1/schedules?select=*');
  const stg01Denied = stg01.status === 401 || (stg01.status === 200 && Array.isArray(stg01.data) && stg01.data.length === 0);
  recordResult(
    'STG-01',
    'Unauthenticated access to protected personal data',
    stg01Denied,
    `Status: ${stg01.status}, Code: ${stg01.data?.code || 'None'}, Data: ${JSON.stringify(stg01.data)}`
  );

  // ---------------------------------------------------------------------------
  // STG-04: Forged administrator registration attempt
  // ---------------------------------------------------------------------------
  const fakeAdminId = '00000000-0000-0000-0000-000000000099';
  const stg04 = await apiRequest('/rest/v1/users', {
    method: 'POST',
    headers: { 'Prefer': 'return=representation' }
  }, {
    id: fakeAdminId,
    email: 'forged_admin@test.local',
    role: 'admin',
    is_admin: true,
    verified: true
  });
  const stg04Blocked = stg04.status === 401 || stg04.status === 403 || stg04.data?.code === '42501';
  recordResult(
    'STG-04',
    'Forged administrator public registration blocked',
    stg04Blocked,
    `Status: ${stg04.status}, Code: ${stg04.data?.code}, Message: ${stg04.data?.message || stg04.raw}`
  );

  // ---------------------------------------------------------------------------
  // STG-10: Post-image path restriction / root traversal
  // ---------------------------------------------------------------------------
  const stg10 = await apiRequest('/storage/v1/object/post-images/root_exploit.exe', {
    method: 'POST',
    headers: { 'Content-Type': 'application/octet-stream' }
  }, 'malicious_binary_content', sessionUserA?.token);
  const stg10Blocked = stg10.status === 400 || stg10.status === 401 || stg10.status === 403;
  recordResult(
    'STG-10',
    'Storage post-image root path traversal rejected',
    stg10Blocked,
    `Status: ${stg10.status}, Response: ${JSON.stringify(stg10.data)}`
  );

  // ---------------------------------------------------------------------------
  // STG-02: User A self-promotion via PATCH
  // ---------------------------------------------------------------------------
  if (sessionUserA) {
    const stg02 = await apiRequest(`/rest/v1/users?id=eq.${sessionUserA.userId}`, {
      method: 'PATCH',
      headers: { 'Prefer': 'return=representation' }
    }, {
      role: 'admin',
      is_admin: true
    }, sessionUserA.token);

    // Either 400/403 with error 42501, or 200 with 0 rows modified, or trigger exception
    const stg02Blocked = stg02.status === 400 || stg02.status === 403 || (stg02.status === 200 && Array.isArray(stg02.data) && stg02.data.length === 0) || stg02.data?.code === '42501';
    recordResult(
      'STG-02',
      'Ordinary user self-promotion to administrator rejected',
      stg02Blocked,
      `Status: ${stg02.status}, Code: ${stg02.data?.code}, Message: ${stg02.data?.message || JSON.stringify(stg02.data)}`
    );
  } else {
    recordResult('STG-02', 'Ordinary user self-promotion', false, 'Awaiting User A credentials in .env');
  }

  // ---------------------------------------------------------------------------
  // STG-03: User A self-unblocking via PATCH
  // ---------------------------------------------------------------------------
  if (sessionUserA) {
    const stg03 = await apiRequest(`/rest/v1/users?id=eq.${sessionUserA.userId}`, {
      method: 'PATCH',
      headers: { 'Prefer': 'return=representation' }
    }, {
      is_blocked: false
    }, sessionUserA.token);

    const stg03Blocked = stg03.status === 400 || stg03.status === 403 || (stg03.status === 200 && Array.isArray(stg03.data) && stg03.data.length === 0) || stg03.data?.code === '42501';
    recordResult(
      'STG-03',
      'Ordinary user self-unblocking rejected',
      stg03Blocked,
      `Status: ${stg03.status}, Code: ${stg03.data?.code}, Message: ${stg03.data?.message || JSON.stringify(stg03.data)}`
    );
  } else {
    recordResult('STG-03', 'Ordinary user self-unblocking', false, 'Awaiting User A credentials in .env');
  }

  // ---------------------------------------------------------------------------
  // STG-05: Cross-user private note access
  // ---------------------------------------------------------------------------
  let noteBId = null;
  if (sessionUserB) {
    const noteCreate = await apiRequest('/rest/v1/notes', {
      method: 'POST',
      headers: { 'Prefer': 'return=representation' }
    }, {
      user_id: sessionUserB.userId,
      title: 'Confidential Medical Note (User B)',
      content: 'Blood pressure reading: 120/80.'
    }, sessionUserB.token);

    if (Array.isArray(noteCreate.data) && noteCreate.data[0]?.id) {
      noteBId = noteCreate.data[0].id;
    }
  }

  if (sessionUserA && sessionUserB) {
    const stg05 = await apiRequest(`/rest/v1/notes?user_id=eq.${sessionUserB.userId}`, {}, null, sessionUserA.token);
    const stg05Isolated = stg05.status === 200 && Array.isArray(stg05.data) && stg05.data.length === 0;
    recordResult(
      'STG-05',
      'Cross-user private note access denied by RLS',
      stg05Isolated,
      `Status: ${stg05.status}, Returned Rows: ${Array.isArray(stg05.data) ? stg05.data.length : 0}`
    );
  } else {
    recordResult('STG-05', 'Cross-user private note access', false, 'Awaiting User A & User B credentials in .env');
  }

  // ---------------------------------------------------------------------------
  // STG-06: Cross-user private note modification or deletion
  // ---------------------------------------------------------------------------
  if (sessionUserA && noteBId) {
    const stg06 = await apiRequest(`/rest/v1/notes?id=eq.${noteBId}`, {
      method: 'DELETE',
      headers: { 'Prefer': 'return=representation' }
    }, null, sessionUserA.token);

    const stg06Denied = (stg06.status === 200 && Array.isArray(stg06.data) && stg06.data.length === 0) || stg06.status === 403;
    recordResult(
      'STG-06',
      'Cross-user private note deletion denied by RLS',
      stg06Denied,
      `Status: ${stg06.status}, Affected Rows: ${Array.isArray(stg06.data) ? stg06.data.length : 0}`
    );
  } else {
    recordResult('STG-06', 'Cross-user private note deletion', false, 'Awaiting User A and User B Note');
  }

  // ---------------------------------------------------------------------------
  // STG-07: Unauthorized moderation deletion
  // ---------------------------------------------------------------------------
  let postBId = null;
  if (sessionUserB) {
    const postCreate = await apiRequest('/rest/v1/posts', {
      method: 'POST',
      headers: { 'Prefer': 'return=representation' }
    }, {
      user_id: sessionUserB.userId,
      content: 'Community health update by User B.'
    }, sessionUserB.token);

    if (Array.isArray(postCreate.data) && postCreate.data[0]?.id) {
      postBId = postCreate.data[0].id;
    }
  }

  if (sessionUserA && postBId) {
    const stg07 = await apiRequest(`/rest/v1/posts?id=eq.${postBId}`, {
      method: 'DELETE',
      headers: { 'Prefer': 'return=representation' }
    }, null, sessionUserA.token);

    const stg07Denied = (stg07.status === 200 && Array.isArray(stg07.data) && stg07.data.length === 0) || stg07.status === 403;
    recordResult(
      'STG-07',
      'Unauthorized user post deletion rejected (0 affected rows)',
      stg07Denied,
      `Status: ${stg07.status}, Affected Rows: ${Array.isArray(stg07.data) ? stg07.data.length : 0}`
    );
  } else {
    recordResult('STG-07', 'Unauthorized post moderation deletion', false, 'Awaiting User A and Post B');
  }

  // ---------------------------------------------------------------------------
  // STG-08: Authorized administrator moderation
  // ---------------------------------------------------------------------------
  if (sessionAdmin && postBId) {
    const stg08 = await apiRequest(`/rest/v1/posts?id=eq.${postBId}`, {
      method: 'DELETE',
      headers: { 'Prefer': 'return=representation' }
    }, null, sessionAdmin.token);

    const stg08Succeeded = stg08.status === 200 && Array.isArray(stg08.data) && stg08.data.length === 1;
    recordResult(
      'STG-08',
      'Authorized administrator post deletion succeeded (1 row deleted)',
      stg08Succeeded,
      `Status: ${stg08.status}, Affected Rows: ${Array.isArray(stg08.data) ? stg08.data.length : 0}`
    );
  } else {
    recordResult('STG-08', 'Authorized administrator moderation', false, 'Awaiting Administrator credentials in .env');
  }

  // ---------------------------------------------------------------------------
  // STG-09: Profile-image folder hijacking
  // ---------------------------------------------------------------------------
  if (sessionUserA && sessionUserB) {
    const maliciousAvatarPath = `/storage/v1/object/profile-pictures/${sessionUserB.userId}/avatar.png`;
    const stg09 = await apiRequest(maliciousAvatarPath, {
      method: 'POST',
      headers: { 'Content-Type': 'image/png' }
    }, 'fake_image_bytes', sessionUserA.token);

    const stg09Blocked = stg09.status === 400 || stg09.status === 403 || stg09.data?.statusCode === '403';
    recordResult(
      'STG-09',
      'Storage profile picture upload to another user folder rejected',
      stg09Blocked,
      `Status: ${stg09.status}, Data: ${JSON.stringify(stg09.data)}`
    );
  } else {
    recordResult('STG-09', 'Storage profile picture folder hijacking', false, 'Awaiting User A & User B');
  }

  console.log('\n================================================================');
  console.log(`Cloud Staging Security Verification Results: ${passed}/${total} passed`);
  console.log('================================================================\n');

  return { total, passed, testResults };
}

if (require.main === module) {
  runTestSuite().catch((err) => {
    console.error('Fatal Test Harness Error:', err);
    process.exit(1);
  });
}

module.exports = { runTestSuite };
