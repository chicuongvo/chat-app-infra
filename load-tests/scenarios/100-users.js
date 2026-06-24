import http from 'k6/http';
import { check, sleep } from 'k6';
import { Trend, Rate, Counter } from 'k6/metrics';
import { getAuthToken, authHeaders, BASE_URL } from '../helpers/auth.js';

const p95Latency = new Trend('p95_latency', true);
const errorRate = new Rate('error_rate');
const messagesSent = new Counter('messages_sent');

export const options = {
  scenarios: {
    login_flow: {
      executor: 'ramping-vus',
      startVUs: 0,
      stages: [
        { duration: '30s', target: 100 },
        { duration: '2m', target: 100 },
        { duration: '30s', target: 0 },
      ],
    },
  },
  thresholds: {
    http_req_duration: ['p(95)<500'],
    error_rate: ['rate<0.01'],
  },
};

const TEST_EMAIL = __ENV.TEST_EMAIL || 'test@example.com';
const TEST_PASSWORD = __ENV.TEST_PASSWORD || 'password123';
const CONVERSATION_ID = __ENV.CONVERSATION_ID || 'test-conversation-id';

export default function () {
  const token = getAuthToken(TEST_EMAIL, TEST_PASSWORD);
  if (!token) {
    errorRate.add(1);
    return;
  }

  const msgRes = http.post(
    `${BASE_URL}/api/chat/conversations/${CONVERSATION_ID}/messages`,
    JSON.stringify({ content: `Load test message at ${Date.now()}` }),
    { headers: authHeaders(token) }
  );

  const ok = check(msgRes, {
    'message sent 201': (r) => r.status === 201,
  });

  p95Latency.add(msgRes.timings.duration);
  errorRate.add(!ok);
  if (ok) messagesSent.add(1);

  sleep(1);
}

export function handleSummary(data) {
  return {
    'load-tests/results/100-users-summary.json': JSON.stringify(data, null, 2),
  };
}
