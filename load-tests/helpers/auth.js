import http from 'k6/http';

const BASE_URL = __ENV.BASE_URL || 'http://localhost:4000';

export function getAuthToken(email, password) {
  const res = http.post(
    `${BASE_URL}/api/auth/login`,
    JSON.stringify({ email, password }),
    { headers: { 'Content-Type': 'application/json' } }
  );
  if (res.status !== 200) {
    return null;
  }
  return res.json('accessToken');
}

export function authHeaders(token) {
  return {
    'Content-Type': 'application/json',
    'Authorization': `Bearer ${token}`,
  };
}

export { BASE_URL };
