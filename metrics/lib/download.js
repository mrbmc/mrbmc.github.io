'use strict';

const fs = require('fs');
const path = require('path');
const zlib = require('zlib');
const readline = require('readline');
const { spawn } = require('child_process');
const { performance } = require('perf_hooks');
const { DOWNLOADS_DIR, LOGS_DIR, S3_BUCKET } = require('./config');
const { monthRange, toMonthKey } = require('./dates');

function findGzFiles(monthKey) {
  if (!fs.existsSync(DOWNLOADS_DIR)) return [];
  return fs.readdirSync(DOWNLOADS_DIR)
    .filter(f => f.includes(`.${monthKey}`) && f.endsWith('.gz'))
    .map(f => path.join(DOWNLOADS_DIR, f));
}

function spawnAndWait(cmd, args, opts = {}) {
  return new Promise((resolve, reject) => {
    const proc = spawn(cmd, args, { ...opts, stdio: opts.stdio || ['ignore', 'inherit', 'inherit'] });
    proc.on('error', reject);
    proc.on('close', code => {
      if (code !== 0 && !opts.allowNonZero) {
        reject(new Error(`${cmd} exited with code ${code}`));
      } else {
        resolve(code);
      }
    });
  });
}

// Decompress a .gz file and write lines (skipping CloudFront comment headers) to a writable stream
function gunzipToStream(gzPath, out) {
  return new Promise((resolve, reject) => {
    const src = fs.createReadStream(gzPath);
    const gunzip = zlib.createGunzip();
    const rl = readline.createInterface({ input: gunzip, crlfDelay: Infinity });

    let headerDone = false;

    rl.on('line', line => {
      // CloudFront logs begin with #Version and #Fields comment lines
      if (!headerDone && (line.startsWith('#Version') || line.startsWith('#Fields'))) return;
      headerDone = true;
      if (!out.write(line + '\n')) {
        // Pause readline for backpressure
        rl.pause();
        out.once('drain', () => rl.resume());
      }
    });

    rl.on('close', resolve);
    rl.on('error', reject);
    gunzip.on('error', reject);
    src.on('error', reject);

    src.pipe(gunzip);
  });
}

async function download(opts = {}) {
  const { startDate, stopDate, verbose } = opts;
  const log = opts.log || { section: console.log, info: console.log, debug: () => {} };

  // Phase 1: S3 sync for the current month's files
  log.section('DOWNLOADING DATA from s3://' + S3_BUCKET);

  const now = new Date();
  const thisYear = now.getFullYear();
  const thisMonth = String(now.getMonth() + 1).padStart(2, '0');
  const includePattern = `*.${thisYear}-${thisMonth}*.gz`;

  fs.mkdirSync(DOWNLOADS_DIR, { recursive: true });

  const syncArgs = [
    's3', 'sync',
    `s3://${S3_BUCKET}`, DOWNLOADS_DIR,
    '--exclude', '*',
    '--include', includePattern,
  ];
  if (!verbose) syncArgs.push('--quiet');

  try {
    await spawnAndWait('aws', syncArgs);
  } catch (err) {
    console.error('\nDownload failed. If your AWS session has expired, run:\n\n  aws sso login\n\nthen try again.');
    process.exit(1);
  }

  // Phase 2: Gunzip per month
  if (verbose) log.info('----------------------------------------');

  const months = monthRange(startDate, stopDate);
  fs.mkdirSync(LOGS_DIR, { recursive: true });

  for (const monthKey of months) {
    const gzFiles = findGzFiles(monthKey);
    if (!gzFiles.length) {
      log.debug(`[SKIP] No .gz files for ${monthKey}`);
      continue;
    }

    log.debug(`unzipping ${monthKey} (${gzFiles.length} files)`);
    const t0 = performance.now();
    const outputPath = path.join(LOGS_DIR, `log_raw_${monthKey}`);
    const out = fs.createWriteStream(outputPath);

    for (const gzFile of gzFiles) {
      await gunzipToStream(gzFile, out);
    }

    await new Promise(resolve => out.end(resolve));
    const elapsed = Math.round(performance.now() - t0);
    log.debug(`[TIMER] ${monthKey} unzip: ${elapsed}ms`);
  }
}

module.exports = { download, findGzFiles };
