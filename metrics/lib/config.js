'use strict';

const path = require('path');
const fs = require('fs');

const BASE = path.resolve(__dirname, '..');

const GEOIP_PATHS = [
  path.join(BASE, 'GeoLite2-City_20250401/GeoLite2-City.mmdb'),
  '/opt/homebrew/var/GeoIP/GeoLite2-City.mmdb',
];

function getGeoIpPath() {
  for (const p of GEOIP_PATHS) {
    if (fs.existsSync(p)) return p;
  }
  return null;
}

const GOACCESS_BASE_ARGS = [
  '--log-format=CLOUDFRONT',
  '--no-query-string',
  '--agent-list',
  '--ignore-crawlers',
  '--unknowns-as-crawlers',
  "--tz=America/New_York",
];

// Explicit field format for stdin piping (avoids CLOUDFRONT log-format ambiguity)
const GOACCESS_STDIN_ARGS = [
  '--date-format=%Y-%m-%d',
  '--time-format=%H:%M:%S',
  '--log-format=%d\t%t\t%^\t%^\t%h\t%m\t%v\t%U\t%s\t%R\t%u\t%q\t%C\t%^\t%^',
  '--no-query-string',
  '--agent-list',
  '--ignore-crawlers',
  '--unknowns-as-crawlers',
  "--tz=America/New_York",
];

function makeLogger(verbose) {
  return {
    section: (msg) => console.log(`\n${'='.repeat(40)}\n${msg}`),
    info: (msg) => console.log(msg),
    debug: (msg) => { if (verbose) console.log(`  ${msg}`); },
    timer: (label, ms) => { if (verbose) console.log(`  [TIMER] ${label}: ${ms}ms`); },
  };
}

module.exports = {
  BASE,
  DOWNLOADS_DIR: path.join(BASE, 'downloads'),
  LOGS_DIR: path.join(BASE, 'logs'),
  WWW_DIR: path.join(BASE, 'www'),
  BLACKLISTS_DIR: path.join(BASE, 'blacklists'),
  EXTERNAL_DIR: path.join(BASE, '_external'),
  S3_BUCKET: 'brianmcconnell.me',
  CF_DIST_ID: 'E1TNSK7JF24IAY',
  GOACCESS_BASE_ARGS,
  GOACCESS_STDIN_ARGS,
  getGeoIpPath,
  makeLogger,
};
