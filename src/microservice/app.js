// microservice/app.js
const http = require('http');

const hostname = '0.0.0.0';
const port = 3000;

const server = http.createServer((req, res) => {
  const now = new Date().toISOString();
  console.log(`[${now}] Request from ${req.connection.remoteAddress} - ${req.method} ${req.url}`);

  res.statusCode = 200;
  res.setHeader('Content-Type', 'text/plain');
  res.setHeader('X-Powered-By', 'Node.js on ECS');
  res.end('Hello from Microservice!\n');
});

server.listen(port, hostname, () => {
  console.log(`Microservice is running at http://${hostname}:${port}/`);
  console.log(`Responding with: "Hello from Microservice!"`);
});