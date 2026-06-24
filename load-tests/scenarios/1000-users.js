import http from 'k6/http';
import { check, sleep } from 'k6';
import { Trend, Rate, Counter } from 'k6/metrics';
import { getAuthToken, authHeaders, BASE_URL } from '../helpers/auth.js';

const p95Latency = new Trend('p95_latency', true);
const errorRate = new Rate('error_rate');
const throughput = new Counter('throughput');

export const options = {
  scenarios: {
    stress_test: {
      executor: 'ramping-vus',
      startVUs: 0,
      stages: [
        { duration: '2m', target: 1000 },
        { duration: '5m', target: 1000 },
        { duration: '2m', target: 0 },
      ],
    },
  },
  thresholds: {
    http_req_duration: ['p(95)<2000'],
    error_rate: ['rate<0.10'],
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

  const res = http.post(
    `${BASE_URL}/api/chat/conversations/${CONVERSATION_ID}/messages`,
    JSON.stringify({ content: `Stress test ${Date.now()}` }),
    { headers: authHeaders(token) }
  );

  const ok = check(res, {
    'status 201': (r) => r.status === 201,
    'latency < 2s': (r) => r.timings.duration < 2000,
  });

  p95Latency.add(res.timings.duration);
  errorRate.add(!ok);
  throughput.add(1);

  sleep(0.1);
}

export function handleSummary(data) {
  return {
    'load-tests/results/1000-users-summary.json': JSON.stringify(data, null, 2),
  };
}
