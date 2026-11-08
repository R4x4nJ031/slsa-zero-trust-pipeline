const assert = require('node:assert/strict');
const { test } = require('node:test');
const { createServer } = require('../src/server');

function request(path) {
  const result = { headers: {}, body: '' };
  const response = {
    writeHead(statusCode, headers) {
      result.statusCode = statusCode;
      result.headers = headers;
    },
    end(body) {
      result.body = body;
    },
  };
  createServer().emit('request', { url: path }, response);
  return result;
}

test('health endpoint returns JSON success status', () => {
  const response = request('/healthz');
  assert.equal(response.statusCode, 200);
  assert.match(response.headers['content-type'], /application\/json/);
  assert.deepEqual(JSON.parse(response.body), { status: 'ok' });
});

test('root endpoint identifies the reference service', () => {
  const response = request('/');
  assert.equal(response.statusCode, 200);
  assert.match(response.body, /SLSA zero-trust pipeline reference service/);
});
