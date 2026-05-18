'use strict';

const fs = require('fs');
const path = require('path');
const readline = require('readline');
const { spawn } = require('child_process');
const { LOGS_DIR, WWW_DIR, GOACCESS_BASE_ARGS, GOACCESS_STDIN_ARGS, getGeoIpPath } = require('./config');
const { monthRange, toISODate, subtractDays, addDays } = require('./dates');

function buildFileArgs(verbose) {
  const args = [...GOACCESS_BASE_ARGS];
  const geoip = getGeoIpPath();
  if (geoip) args.push(`--geoip-database=${geoip}`);
  if (!verbose) args.push('--no-progress');
  return args;
}

function buildStdinArgs(verbose) {
  const args = [...GOACCESS_STDIN_ARGS];
  const geoip = getGeoIpPath();
  if (geoip) args.push(`--geoip-database=${geoip}`);
  if (!verbose) args.push('--no-progress');
  return args;
}

function runGoAccess(inputPath, outputPath, extraArgs) {
  return new Promise((resolve, reject) => {
    const args = [inputPath, '-o', outputPath, ...extraArgs];
    const proc = spawn('goaccess', args, { stdio: ['ignore', 'inherit', 'inherit'] });
    proc.on('error', err => {
      if (err.code === 'ENOENT') reject(new Error('goaccess not found — install it with: brew install goaccess'));
      else reject(err);
    });
    proc.on('close', resolve);
  });
}

// Pipe filtered lines from a source file to GoAccess stdin
async function pipeToGoAccess(logPath, outputPath, stdinArgs, filterFn) {
  if (!fs.existsSync(logPath)) return;

  await new Promise((resolve, reject) => {
    const proc = spawn('goaccess', ['-a', '-o', outputPath, ...stdinArgs], {
      stdio: ['pipe', 'inherit', 'inherit'],
    });
    proc.on('error', err => {
      if (err.code === 'ENOENT') reject(new Error('goaccess not found — install it with: brew install goaccess'));
      else reject(err);
    });
    proc.on('close', resolve);

    const rl = readline.createInterface({ input: fs.createReadStream(logPath), crlfDelay: Infinity });

    rl.on('line', line => {
      if (!filterFn || filterFn(line)) {
        if (!proc.stdin.write(line + '\n')) {
          rl.pause();
          proc.stdin.once('drain', () => rl.resume());
        }
      }
    });

    rl.on('close', () => proc.stdin.end());
    rl.on('error', reject);
  });
}

// Per-month GoAccess file analysis
async function analyze(opts = {}) {
  const { startDate, stopDate, raw, verbose } = opts;
  const log = opts.log || { section: console.log, info: console.log, debug: () => {} };

  log.section('ANALYZING DATA');
  if (verbose) log.info(`GoAccess options: ${GOACCESS_BASE_ARGS.join(' ')}`);

  fs.mkdirSync(WWW_DIR, { recursive: true });
  const fileArgs = buildFileArgs(verbose);
  const stdinArgs = buildStdinArgs(verbose);
  const months = monthRange(startDate, stopDate);

  // Per-month file analysis
  for (const monthKey of months) {
    const suffix = raw ? '-raw' : '';
    const logFile = path.join(LOGS_DIR, raw ? `log_raw_${monthKey}` : `log_clean_${monthKey}`);
    const outputFile = path.join(WWW_DIR, `${monthKey}${suffix}.html`);

    if (!fs.existsSync(logFile)) {
      log.debug(`[SKIP] No log for ${monthKey}`);
      continue;
    }

    log.debug(`Analyzing ${monthKey}${raw ? ' RAW' : ' CLEAN'}`);
    await runGoAccess(logFile, outputFile, fileArgs);
  }

  // Rolling period analysis (7d, 14d, 30d, 90d, 365d)
  const periods = [7, 14, 30, 90, 365];
  const today = new Date();
  const logFile = path.join(LOGS_DIR, raw ? 'log_raw' : 'log_clean');

  for (const days of periods) {
    const label = `${days}d`;
    const periodStart = toISODate(subtractDays(today, days));
    const periodEnd = toISODate(addDays(today, 1));
    const outputFile = path.join(WWW_DIR, `l${label}${raw ? '-raw' : ''}.html`);

    log.debug(`Analyzing -${label} (${periodStart} to ${periodEnd})`);
    await pipeToGoAccess(logFile, outputFile, stdinArgs, line => {
      const date = line.slice(0, 10); // 'YYYY-MM-DD'
      return date >= periodStart && date < periodEnd;
    });
  }

  // Full-year analysis if requested
  if (opts.allYears) {
    for (const year of ['2024', '2025']) {
      const suffix = raw ? '-raw' : '';
      const logFile = path.join(LOGS_DIR, raw ? `log_raw_${year}-*` : `log_clean_${year}-*`);
      const outputFile = path.join(WWW_DIR, `${year}${suffix}.html`);
      log.debug(`Analyzing ${year}`);
      // For full-year, use concatenated per-year files via GoAccess directly
      const yearFiles = fs.readdirSync(LOGS_DIR)
        .filter(f => f.match(new RegExp(`^log_${raw ? 'raw' : 'clean'}_${year}-`)))
        .sort()
        .map(f => path.join(LOGS_DIR, f));
      if (!yearFiles.length) continue;
      // Pipe all year files sequentially to GoAccess stdin
      await new Promise((resolve, reject) => {
        const proc = spawn('goaccess', ['-o', outputFile, ...buildFileArgs(verbose)], {
          stdio: ['pipe', 'inherit', 'inherit'],
        });
        proc.on('error', reject);
        proc.on('close', resolve);
        (async () => {
          for (const f of yearFiles) {
            await new Promise((res, rej) => {
              const src = fs.createReadStream(f);
              src.on('error', rej);
              src.on('end', res);
              src.pipe(proc.stdin, { end: false });
            });
          }
          proc.stdin.end();
        })().catch(reject);
      });
    }
  }
}

// Custom date range analysis
async function analyzeRange(startDate, stopDate, opts = {}) {
  const { raw, verbose } = opts;
  const log = opts.log || { section: console.log, info: console.log, debug: () => {} };

  const startStr = toISODate(startDate);
  const stopStr = toISODate(stopDate);
  const dayAfter = toISODate(addDays(stopDate, 1));
  const filename = startStr === stopStr ? startStr : `${startStr}-${stopStr}`;
  const logFile = path.join(LOGS_DIR, raw ? 'log_raw' : 'log_clean');
  const outputFile = path.join(WWW_DIR, `${filename}${raw ? '-raw' : ''}.html`);

  log.section(`ANALYZING RANGE ${startStr} - ${stopStr}`);

  fs.mkdirSync(WWW_DIR, { recursive: true });

  let inRange = false;
  await pipeToGoAccess(logFile, outputFile, buildStdinArgs(verbose), line => {
    const date = line.slice(0, 10);
    if (date === startStr) inRange = true;
    if (date === dayAfter) inRange = false;
    return inRange;
  });
}

module.exports = { analyze, analyzeRange };
