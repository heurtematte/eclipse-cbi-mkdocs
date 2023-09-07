// SPDX-FileCopyrightText: 2022 eclipse foundation
// SPDX-License-Identifier: EPL-2.0

const http = require('http');

const server = http.createServer((req, res) => {
  if (req.method === 'PUT') {
    let body = '';
    req.on('data', chunk => {
      body += chunk.toString();
    });
    req.on('end', () => {
      try {
        const data = JSON.parse(body);
        const currentDate = new Date().toLocaleString();
        console.log(`Current date: ${currentDate}`);
        console.log(data);
        res.end('Data received and logged!');
      } catch (err) {
        res.statusCode = 400;
        res.end(`Error: ${err.message}`);
      }
    });
  } else {
    res.statusCode = 404;
    res.end('Not found');
  }
});

server.listen(3000, () => {
  console.log('Server listening on port 3000');
});