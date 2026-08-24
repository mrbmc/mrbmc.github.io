'use strict';

const fs = require('fs');
const path = require('path');
const readline = require('readline');
const { performance } = require('perf_hooks');
const { LOGS_DIR } = require('./config');

// CloudFront W3C log field indices (0-based after tab-split):
// 0=date 1=time 2=x-edge-location 3=sc-bytes 4=c-ip 5=cs-method
// 6=cs(Host) 7=cs-uri-stem 8=sc-status 9=cs(Referer) 10=cs(User-Agent)
// 11=cs-uri-query 12=cs(Cookie) 13=x-edge-result-type 14=x-edge-request-id

const BROWSER_RE = /Mozilla\/5\.0|AppleWebKit|Chrome|Safari|Firefox|Edge|Opera/;

// Pure function — testable in isolation. Matches AWK filter logic exactly.
function filterLine(line, lists, stats) {
  const fields = line.split('\t');
  if (fields.length < 12) return false;

  const ip = fields[4];
  const method = fields[5];
  const uri = fields[7];
  const status = fields[8];
  const ua = fields[10];

  // Filter 1: browser UA
  if (!BROWSER_RE.test(ua)) {
    if (stats) stats.filterBrowser++;
    return false;
  }

  // Filter 2: GET only
  if (method !== 'GET') {
    if (stats) stats.filterMethod++;
    return false;
  }

  // Filter 3: no 301
  if (status === '301') {
    if (stats) stats.filterStatus++;
    return false;
  }

  // Filter 4: IP blocklist (Set.has — same behavior as AWK hash, no CIDR expansion)
  if (lists.ipSet.has(ip)) {
    if (stats) stats.filterIp++;
    return false;
  }

  // Filter 5: UA patterns
  const uaLower = ua.toLowerCase();
  for (const re of lists.agentPatterns) {
    if (re.test(uaLower)) {
      if (stats) stats.filterAgent++;
      return false;
    }
  }

  // Filter 6: URL patterns
  const uriLower = uri.toLowerCase();
  for (const re of lists.urlPatterns) {
    if (re.test(uriLower)) {
      if (stats) stats.filterUrl++;
      return false;
    }
  }

  return true;
}

async function parseMonth(monthKey, lists, opts = {}) {
  const inputPath = path.join(LOGS_DIR, `log_raw_${monthKey}`);
  const outputPath = path.join(LOGS_DIR, `log_clean_${monthKey}`);

  if (!fs.existsSync(inputPath)) {
    if (opts.verbose) console.log(`  [SKIP] No raw log for ${monthKey}`);
    return null;
  }

  const stats = { total: 0, passed: 0, filterBrowser: 0, filterMethod: 0,
                  filterStatus: 0, filterIp: 0, filterAgent: 0, filterUrl: 0 };

  const t0 = performance.now();
  const rl = readline.createInterface({ input: fs.createReadStream(inputPath), crlfDelay: Infinity });
  const out = fs.createWriteStream(outputPath);

  for await (const line of rl) {
    stats.total++;
    if (filterLine(line, lists, stats)) {
      stats.passed++;
      if (!out.write(line + '\n')) {
        await new Promise(resolve => out.once('drain', resolve));
      }
    }
  }

  await new Promise(resolve => out.end(resolve));

  const elapsed = Math.round(performance.now() - t0);
  if (opts.verbose) {
    console.log(`  [TIMER] ${monthKey}: ${elapsed}ms — ${stats.passed}/${stats.total} passed`);
    console.log(`    browser:${stats.filterBrowser} method:${stats.filterMethod} status:${stats.filterStatus} ip:${stats.filterIp} agent:${stats.filterAgent} url:${stats.filterUrl}`);
  }

  return stats;
}

// Append one readable stream to a writable stream, awaiting completion
function pipeAppend(inputPath, out) {
  return new Promise((resolve, reject) => {
    if (!fs.existsSync(inputPath)) { resolve(); return; }
    const src = fs.createReadStream(inputPath);
    src.on('error', reject);
    src.on('end', resolve);
    src.pipe(out, { end: false });
  });
}

// Concatenate log_clean_YYYY-MM files for given years sequentially into log_clean
async function concatMonths(years, opts = {}) {
  const outputPath = path.join(LOGS_DIR, 'log_clean');
  const out = fs.createWriteStream(outputPath);

  for (const year of years) {
    const t0 = performance.now();
    const files = fs.readdirSync(LOGS_DIR)
      .filter(f => f.startsWith(`log_clean_${year}-`))
      .sort()
      .map(f => path.join(LOGS_DIR, f));

    for (const f of files) {
      await pipeAppend(f, out);
    }

    if (opts.verbose) {
      const elapsed = Math.round(performance.now() - t0);
      console.log(`  [TIMER] ${year} concatenation: ${elapsed}ms (${files.length} files)`);
    }
  }

  await new Promise(resolve => out.end(resolve));
}

// Concatenate all raw log files for given years into log_raw
async function concatRaw(opts = {}) {
  const outputPath = path.join(LOGS_DIR, 'log_raw');
  const out = fs.createWriteStream(outputPath);

  const files = fs.readdirSync(LOGS_DIR)
    .filter(f => /^log_raw_202\d-/.test(f))
    .sort()
    .map(f => path.join(LOGS_DIR, f));

  for (const f of files) {
    await pipeAppend(f, out);
  }

  await new Promise(resolve => out.end(resolve));
  if (opts.verbose) console.log(`  Concatenated ${files.length} raw log files`);
}

module.exports = { filterLine, parseMonth, concatMonths, concatRaw };
