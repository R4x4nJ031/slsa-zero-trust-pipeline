const http = require('node:http');

function createServer() {
  return http.createServer((request, response) => {
  if (request.url === '/healthz') {
    response.writeHead(200, { 'content-type': 'application/json' });
    response.end(JSON.stringify({ status: 'ok' }));
    return;
  }

  response.writeHead(200, { 'content-type': 'text/plain; charset=utf-8' });
  response.end('SLSA zero-trust pipeline reference service\n');
  });
}

if (require.main === module) {
  const port = Number(process.env.PORT || 8080);
  createServer().listen(port, '0.0.0.0', () => {
    process.stdout.write(`listening on ${port}\n`);
  });
}

module.exports = { createServer };
