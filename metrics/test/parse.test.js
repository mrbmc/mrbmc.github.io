'use strict';

const { test } = require('node:test');
const assert = require('node:assert/strict');
const { filterLine } = require('../lib/parse');

const BROWSER_UA = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36';
const BOT_UA = 'Googlebot/2.1 (+http://www.google.com/bot.html)';

// CloudFront log line: tab-delimited, 15 fields
// date time edge-loc bytes c-ip method host uri status referer ua query cookie result-type req-id
function makeLine(overrides = {}) {
  const fields = {
    date: '2026-04-01',
    time: '12:00:00',
    edgeLoc: 'IAD89-P1',
    bytes: '1234',
    ip: '1.2.3.4',
    method: 'GET',
    host: 'mrbmc.com',
    uri: '/blog/post',
    status: '200',
    referer: '-',
    ua: BROWSER_UA,
    query: '-',
    cookie: '-',
    resultType: 'Hit',
    reqId: 'abc123',
  };
  Object.assign(fields, overrides);
  return [
    fields.date, fields.time, fields.edgeLoc, fields.bytes,
    fields.ip, fields.method, fields.host, fields.uri,
    fields.status, fields.referer, fields.ua, fields.query,
    fields.cookie, fields.resultType, fields.reqId,
  ].join('\t');
}

const emptyLists = { agentPatterns: [], ipSet: new Set(), urlPatterns: [] };

test('passes a valid browser GET 200', () => {
  assert.ok(filterLine(makeLine(), emptyLists));
});

test('blocks non-browser UA', () => {
  assert.ok(!filterLine(makeLine({ ua: BOT_UA }), emptyLists));
});

test('blocks POST method', () => {
  assert.ok(!filterLine(makeLine({ method: 'POST' }), emptyLists));
});

test('blocks HEAD method', () => {
  assert.ok(!filterLine(makeLine({ method: 'HEAD' }), emptyLists));
});

test('blocks 301 status', () => {
  assert.ok(!filterLine(makeLine({ status: '301' }), emptyLists));
});

test('allows 200 status', () => {
  assert.ok(filterLine(makeLine({ status: '200' }), emptyLists));
});

test('allows 404 status', () => {
  assert.ok(filterLine(makeLine({ status: '404' }), emptyLists));
});

test('blocks exact IP in ipSet', () => {
  const lists = { ...emptyLists, ipSet: new Set(['1.2.3.4']) };
  assert.ok(!filterLine(makeLine({ ip: '1.2.3.4' }), lists));
});

test('allows IP not in ipSet', () => {
  const lists = { ...emptyLists, ipSet: new Set(['5.5.5.5']) };
  assert.ok(filterLine(makeLine({ ip: '1.2.3.4' }), lists));
});

test('blocks UA matching agentPatterns', () => {
  const lists = { ...emptyLists, agentPatterns: [/semrushbot/i] };
  assert.ok(!filterLine(makeLine({ ua: 'Mozilla/5.0 (compatible; SemrushBot/7)' }), lists));
});

test('allows UA not matching agentPatterns', () => {
  const lists = { ...emptyLists, agentPatterns: [/semrushbot/i] };
  assert.ok(filterLine(makeLine(), lists));
});

test('blocks URL matching urlPatterns', () => {
  const lists = { ...emptyLists, urlPatterns: [/wp-admin/i] };
  assert.ok(!filterLine(makeLine({ uri: '/wp-admin/login.php' }), lists));
});

test('allows URL not matching urlPatterns', () => {
  const lists = { ...emptyLists, urlPatterns: [/wp-admin/i] };
  assert.ok(filterLine(makeLine({ uri: '/blog/post' }), lists));
});

test('rejects lines with fewer than 12 fields', () => {
  assert.ok(!filterLine('2026-04-01\t12:00:00\tbad-line', emptyLists));
});

test('stats object is updated correctly', () => {
  const stats = { total: 0, passed: 0, filterBrowser: 0, filterMethod: 0,
                  filterStatus: 0, filterIp: 0, filterAgent: 0, filterUrl: 0 };
  filterLine(makeLine({ ua: BOT_UA }), emptyLists, stats);
  assert.equal(stats.filterBrowser, 1);
  assert.equal(stats.filterMethod, 0);
});
