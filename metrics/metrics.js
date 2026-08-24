#!/usr/bin/env node
'use strict';

const yargs = require('yargs/yargs');
const { hideBin } = require('yargs/helpers');

const { download } = require('./lib/download');
const { parseMonth, concatMonths, concatRaw } = require('./lib/parse');
const { analyze, analyzeRange } = require('./lib/analyze');
const { investigate } = require('./lib/investigate');
const { loadBlacklists, updateBlacklists } = require('./lib/blacklists');
const { makeLogger } = require('./lib/config');
const { subtractDays, parseYYYYMMDD, monthRange } = require('./lib/dates');

const { execSync } = require('child_process');

try {
  execSync('which goaccess', { stdio: 'ignore' });
} catch {
  console.error('goaccess is required but not installed.\n\nInstall it with:\n\n  brew install goaccess\n');
  process.exit(1);
}

const argv = yargs(hideBin(process.argv))
  .option('verbose',            { alias: 'v', type: 'boolean', default: false, description: 'Verbose output' })
  .option('skip-download',      { alias: 's', type: 'boolean', default: false, description: 'Skip S3 download step' })
  .option('skip-filter',        { alias: 'F', type: 'boolean', default: false, description: 'Skip log filtering step' })
  .option('raw',                { alias: 'r', type: 'boolean', default: false, description: 'Use raw (unfiltered) logs' })
  .option('from',               { alias: 'f', type: 'string',  description: 'Start date YYYYMMDD' })
  .option('until',              { alias: 'u', type: 'string',  description: 'End date YYYYMMDD' })
  .option('term',               { alias: 't', type: 'string',  description: 'Duration: all | Nd (e.g. 30d)' })
  .option('ip',                 { alias: 'i', type: 'string',  description: 'IP address to investigate' })
  .option('update-blacklists',  { alias: 'b', type: 'boolean', default: false, description: 'Fetch and merge public IP/UA blocklists' })
  .help('h').alias('h', 'help')
  .argv;

async function main() {
  const verbose = argv.verbose;
  const log = makeLogger(verbose);

  // Resolve date range
  const stopDate = argv.until ? parseYYYYMMDD(argv.until) : new Date();
  let startDate;

  if (argv.term === 'all') {
    const y = new Date().getFullYear();
    startDate = new Date(`${y}-01-01T00:00:00Z`);
  } else if (argv.from) {
    startDate = parseYYYYMMDD(argv.from);
  } else {
    startDate = subtractDays(stopDate, 30);
  }

  const opts = { startDate, stopDate, verbose, raw: argv.raw, log };

  // -- update-blacklists
  if (argv['update-blacklists']) {
    await updateBlacklists({ ...opts });
    return;
  }

  // -- investigate IP
  if (argv.ip) {
    await investigate(argv.ip, opts);
    return;
  }

  // -- main flow: download → parse → analyze
  log.section('LOG ANALYSIS');
  if (verbose) log.info(`TIMEFRAME: ${startDate.toISOString().slice(0, 10)} – ${stopDate.toISOString().slice(0, 10)}`);

  if (!argv['skip-download']) {
    await download(opts);
  } else {
    log.section('SKIP DOWNLOAD');
  }

  if (!argv['skip-filter']) {
    if (argv.raw) {
      log.section('PREPARING DATA (raw concat)');
      if (verbose) log.info('Concatenating all raw logs');
      await concatRaw(opts);
    } else {
      log.section('PREPARING DATA');
      if (verbose) log.info('Preparing filters...');

      const lists = loadBlacklists();
      const months = monthRange(startDate, stopDate);

      for (const monthKey of months) {
        await parseMonth(monthKey, lists, opts);
      }

      if (verbose) log.info('Concatenating 2024 clean');
      if (verbose) log.info('Concatenating 2025 clean');
      if (verbose) log.info('Concatenating 2026 clean');
      await concatMonths(['2024', '2025', '2026'], opts);
    }
  } else {
    log.section('SKIP FILTER');
  }

  // analyze: range vs standard
  if (argv.from && argv.until) {
    await analyzeRange(startDate, stopDate, opts);
  } else {
    await analyze({ ...opts, allYears: argv.term === 'all' });
  }

  log.section('LOG ANALYSIS COMPLETE');
}

main().catch(err => {
  console.error(err);
  process.exit(1);
});
