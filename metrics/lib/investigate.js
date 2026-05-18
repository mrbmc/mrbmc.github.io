'use strict';

const fs = require('fs');
const path = require('path');
const readline = require('readline');
const { LOGS_DIR } = require('./config');
const { toISODate, subtractDays, addDays } = require('./dates');

async function investigate(ip, opts = {}) {
  const log = opts.log || { section: console.log, info: console.log, debug: () => {} };

  log.section('INVESTIGATING AN IP');

  const stopDate = opts.stopDate || new Date();
  const startDate = opts.startDate || subtractDays(stopDate, 30);
  const startStr = toISODate(startDate);
  const dayAfter = toISODate(addDays(stopDate, 1));

  const logFile = path.join(LOGS_DIR, 'log_raw');
  const outputFile = path.join(LOGS_DIR, 'investigation.log');

  if (!fs.existsSync(logFile)) {
    log.info(`  log_raw not found — run without --skip-download first`);
    return;
  }

  log.debug(`IP: ${ip}`);
  log.debug(`Range: ${startStr} to ${toISODate(stopDate)}`);
  log.debug(`Output: ${outputFile}`);

  const out = fs.createWriteStream(outputFile);
  const rl = readline.createInterface({ input: fs.createReadStream(logFile), crlfDelay: Infinity });

  let inRange = false;
  let count = 0;

  for await (const line of rl) {
    const date = line.slice(0, 10);
    if (date === startStr) inRange = true;
    if (date === dayAfter) inRange = false;

    if (inRange && line.includes(ip)) {
      if (!out.write(line + '\n')) {
        await new Promise(resolve => out.once('drain', resolve));
      }
      count++;
    }
  }

  await new Promise(resolve => out.end(resolve));
  log.info(`  ${count} requests from ${ip} written to ${outputFile}`);
}

module.exports = { investigate };
