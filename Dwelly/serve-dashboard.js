#!/usr/bin/env node
/**
 * Dwellable Dashboard Server
 * Serves MOMENTS_DASHBOARD.html (and all files in this directory) on port 8000.
 *
 * Usage:
 *   node serve-dashboard.js
 *
 * Then open: http://localhost:8000/MOMENTS_DASHBOARD.html
 */

const http = require('http');
const fs = require('fs');
const path = require('path');
const url = require('url');

const PORT = 8000;
const ROOT = __dirname;

const MIME = {
  '.html': 'text/html; charset=utf-8',
  '.js':   'application/javascript',
  '.css':  'text/css',
  '.json': 'application/json',
  '.png':  'image/png',
  '.jpg':  'image/jpeg',
  '.svg':  'image/svg+xml',
  '.ico':  'image/x-icon',
  '.csv':  'text/csv',
  '.txt':  'text/plain',
};

const server = http.createServer((req, res) => {
  const parsedUrl = url.parse(req.url);
  let pathname = parsedUrl.pathname;

  // Default to MOMENTS_DASHBOARD.html
  if (pathname === '/' || pathname === '') {
    pathname = '/MOMENTS_DASHBOARD.html';
  }

  const filePath = path.join(ROOT, pathname);

  // Security: prevent directory traversal
  if (!filePath.startsWith(ROOT)) {
    res.writeHead(403);
    res.end('Forbidden');
    return;
  }

  fs.readFile(filePath, (err, data) => {
    if (err) {
      if (err.code === 'ENOENT') {
        res.writeHead(404, { 'Content-Type': 'text/plain' });
        res.end(`Not found: ${pathname}`);
      } else {
        res.writeHead(500);
        res.end('Server error');
      }
      return;
    }

    const ext = path.extname(filePath).toLowerCase();
    const mime = MIME[ext] || 'application/octet-stream';
    res.writeHead(200, { 'Content-Type': mime });
    res.end(data);
  });
});

server.listen(PORT, () => {
  console.log(`\n🚀 Dwellable Dashboard Server running`);
  console.log(`\n   Dashboard:  http://localhost:${PORT}/MOMENTS_DASHBOARD.html`);
  console.log(`   Analytics:  http://localhost:${PORT}/tools/analytics-dashboard.html`);
  console.log(`   Sessions:   http://localhost:${PORT}/session-viewer.html`);
  console.log(`\n   Press Ctrl+C to stop\n`);
});