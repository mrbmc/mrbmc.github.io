'use strict';

function subtractDays(date, n) {
  return new Date(date - n * 86400_000);
}

function addDays(date, n) {
  return new Date(date.getTime() + n * 86400_000);
}

function toMonthKey(date) {
  const y = date.getFullYear();
  const m = String(date.getMonth() + 1).padStart(2, '0');
  return `${y}-${m}`;
}

function toISODate(date) {
  return date.toISOString().slice(0, 10);
}

// Parses 'YYYYMMDD' string to Date (midnight UTC)
function parseYYYYMMDD(str) {
  const y = str.slice(0, 4);
  const m = str.slice(4, 6);
  const d = str.slice(6, 8);
  return new Date(`${y}-${m}-${d}T00:00:00Z`);
}

// Returns sorted unique list of 'YYYY-MM' strings from startDate up to (not including) stopDate
function monthRange(startDate, stopDate) {
  const months = new Set();
  let cur = new Date(startDate);
  while (cur < stopDate) {
    months.add(toMonthKey(cur));
    cur = addDays(cur, 1);
  }
  return Array.from(months).sort();
}

module.exports = { subtractDays, addDays, toMonthKey, toISODate, parseYYYYMMDD, monthRange };
