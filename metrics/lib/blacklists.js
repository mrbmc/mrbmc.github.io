'use strict';

const fs = require('fs');
const path = require('path');
const { BLACKLISTS_DIR, EXTERNAL_DIR } = require('./config');

function loadFile(filePath) {
  if (!fs.existsSync(filePath)) return [];
  return fs.readFileSync(filePath, 'utf8')
    .split('\n')
    .map(l => l.trim())
    .filter(l => l && !l.startsWith('#'));
}

function loadBlacklists() {
  const agentLines = loadFile(path.join(BLACKLISTS_DIR, 'blacklist-agents.txt'));
  const ipLines = loadFile(path.join(BLACKLISTS_DIR, 'blacklist-ips.txt'));
  const urlLines = loadFile(path.join(BLACKLISTS_DIR, 'blacklist-urls.txt'));

  return {
    // Compile regexes once at load time (case-insensitive matching on lowercased input)
    agentPatterns: agentLines.map(l => new RegExp(l, 'i')),
    // Set for O(1) string lookup — preserves current AWK behavior (no CIDR expansion)
    ipSet: new Set(ipLines),
    urlPatterns: urlLines.map(l => new RegExp(l, 'i')),
  };
}

function createTimestampedBackup(filePath) {
  if (!fs.existsSync(filePath)) return;
  const ts = new Date().toISOString().replace(/[:.]/g, '-').slice(0, 19);
  fs.copyFileSync(filePath, `${filePath}.bak-${ts}`);
}

async function updateBlacklists(opts = {}) {
  const log = opts.log || { section: console.log, info: console.log, debug: () => {} };

  log.section('UPDATING BLACKLISTS');

  fs.mkdirSync(EXTERNAL_DIR, { recursive: true });
  fs.mkdirSync(BLACKLISTS_DIR, { recursive: true });

  log.info('Backing up existing blacklists...');
  createTimestampedBackup(path.join(BLACKLISTS_DIR, 'blacklist-agents.txt'));
  createTimestampedBackup(path.join(BLACKLISTS_DIR, 'blacklist-urls.txt'));

  log.info('----------------------------------------');
  log.info('Fetching external lists...');

  async function fetchText(url, label) {
    log.info(`  - ${label}`);
    try {
      const res = await fetch(url);
      if (!res.ok) throw new Error(`HTTP ${res.status}`);
      return await res.text();
    } catch (err) {
      log.info(`  ! Failed to fetch ${label}: ${err.message}`);
      return null;
    }
  }

  const [firehol, crowdsec, crawlerJson] = await Promise.all([
    fetchText('https://iplists.firehol.org/files/firehol_level1.netset', 'FireHOL Level 1 IP blocklist'),
    fetchText('https://blocklist-de.security.fc00.de/', 'CrowdSec community blocklist'),
    fetchText('https://raw.githubusercontent.com/monperrus/crawler-user-agents/master/crawler-user-agents.json', 'GitHub crawler-user-agents'),
  ]);

  // Process IPs: strip comments, keep lines starting with a digit
  const fireholIps = firehol
    ? firehol.split('\n').filter(l => /^[0-9]/.test(l.trim())).map(l => l.trim())
    : [];
  const crowdsecIps = crowdsec
    ? crowdsec.split('\n').filter(l => /^[0-9]/.test(l.trim())).map(l => l.trim())
    : [];

  // Process crawler agents: parse JSON, extract .pattern fields
  let crawlerAgents = [];
  if (crawlerJson) {
    try {
      crawlerAgents = JSON.parse(crawlerJson).map(e => e.pattern).filter(Boolean);
    } catch (err) {
      log.info(`  ! Failed to parse crawler-user-agents.json: ${err.message}`);
    }
  }

  log.info(`  ✓ FireHOL: ${fireholIps.length} IPs`);
  log.info(`  ✓ CrowdSec: ${crowdsecIps.length} IPs`);
  log.info(`  ✓ Crawlers: ${crawlerAgents.length} user agents`);

  log.info('----------------------------------------');
  log.info('Merging with existing blacklists...');

  // Merge and deduplicate IPs
  if (fireholIps.length || crowdsecIps.length) {
    createTimestampedBackup(path.join(BLACKLISTS_DIR, 'blacklist-ips.txt'));
    const today = new Date().toISOString().slice(0, 10);
    const header = `# Auto-updated IP blocklists (${today})\n# Plain text IPs for fast -F (fixed string) matching\n`;
    const allIps = [...new Set([...fireholIps, ...crowdsecIps])].sort();
    fs.writeFileSync(path.join(BLACKLISTS_DIR, 'blacklist-ips.txt'), header + allIps.join('\n') + '\n');
  }

  // Merge crawler agents into blacklist-agents.txt
  if (crawlerAgents.length) {
    const agentsPath = path.join(BLACKLISTS_DIR, 'blacklist-agents.txt');
    const existing = loadFile(agentsPath);
    const today = new Date().toISOString().slice(0, 10);
    const merged = [...new Set([...existing, ...crawlerAgents])].sort();
    const header = `# Auto-updated crawler user agents (${today})\n`;
    fs.writeFileSync(agentsPath, header + merged.join('\n') + '\n');
  }

  const agentCount = loadFile(path.join(BLACKLISTS_DIR, 'blacklist-agents.txt')).length;
  const ipCount = loadFile(path.join(BLACKLISTS_DIR, 'blacklist-ips.txt')).length;
  const urlCount = loadFile(path.join(BLACKLISTS_DIR, 'blacklist-urls.txt')).length;

  log.section('Blacklists updated successfully!');
  log.info(`  - blacklist-agents.txt: ${agentCount} entries`);
  log.info(`  - blacklist-ips.txt: ${ipCount} entries`);
  log.info(`  - blacklist-urls.txt: ${urlCount} entries`);
  log.info('  - Backups saved with timestamp');
}

module.exports = { loadBlacklists, updateBlacklists, createTimestampedBackup };
