const domains = [
  {
    name: "Growth Life",
    color: "var(--primary)",
    products: [
      { name: "Commerce Orchestration", codename: "Genie", impact: 34, legacy: false },
      { name: "Lifecycle Messaging", codename: "Galaxy", impact: 21, legacy: false },
      { name: "Support Agent Console", codename: "Baymax", impact: 8, legacy: false },
      { name: "Fraud Management", codename: null, impact: 5, legacy: false },
      { name: "Responder Files", codename: null, impact: 3, legacy: false },
      { name: "VX Dashboard", codename: null, impact: 3, legacy: false },
      { name: "ServiceNow Dashboard", codename: null, impact: 2, legacy: false },
      { name: "Hulu Ad Manager", codename: null, impact: 13, legacy: false },
      { name: "Hulu Ad Mission Control", codename: null, impact: 3, legacy: false },
      { name: "Help Sites & Chatbot", codename: null, impact: 2, legacy: true },
      { name: "Commerce Config Tool", codename: null, impact: 2, legacy: true },
    ]
  },
  {
    name: "Content Experience",
    color: "var(--secondary)",
    products: [
      { name: "Content Portal", codename: "Maestro", impact: 13, legacy: false },
      { name: "Catalog Browser", codename: "Tesseract", impact: 8, legacy: false },
      { name: "Metadata Mapping", codename: "KnowsMore", impact: 5, legacy: false },
      { name: "Dictionary & Translation", codename: "Cypher", impact: 21, legacy: false },
      { name: "ML Dashboard", codename: "Nexus", impact: 3, legacy: false },
      { name: "Content Delivery Preview", codename: "Vision", impact: 3, legacy: false },
      { name: "Content Experience Mgmt", codename: null, impact: 3, legacy: true },
    ]
  },
  {
    name: "DATA & Insights",
    color: "var(--tertiary)",
    products: [
      { name: "Streaming QoE Insights", codename: "Optumus", impact: 21, legacy: false },
      { name: "Experimentation", codename: "WeaponX", impact: 34, legacy: false },
      { name: "Data Portal", codename: null, impact: 13, legacy: false },
      { name: "Audience Segmentation", codename: "Proton", impact: 5, legacy: false },
      { name: "Anti-Piracy Operations", codename: null, impact: 5, legacy: false },
      { name: "DATA Instrumentation", codename: "Minerva", impact: 3, legacy: false },
      { name: "DATA Feature Market", codename: "Quantum", impact: 3, legacy: false },
      { name: "Data Activation Framework", codename: null, impact: 2, legacy: true },
      { name: "Snowman", codename: null, impact: 1, legacy: true },
      { name: "Harmony", codename: null, impact: 1, legacy: true },
    ]
  },
  {
    name: "Developer Platform",
    color: "var(--quaternary)",
    products: [
      { name: "EXD Design System", codename: "Trek", impact: 8, legacy: false },
      { name: "Developer Portal", codename: null, impact: 13, legacy: false },
      { name: "Partner Portal", codename: null, impact: 8, legacy: false },
      { name: "CDN Management Console", codename: null, impact: 5, legacy: false },
      { name: "Disney Edge Controller", codename: "DEC", impact: 5, legacy: false },
      { name: "Player Config Service", codename: null, impact: 3, legacy: false },
      { name: "Hulu Ad Revenue Processing", codename: "HARPS", impact: 3, legacy: false },
      { name: "SRE Dashboard", codename: null, impact: 1, legacy: true },
      { name: "Joshua Tree", codename: null, impact: 1, legacy: true },
    ]
  }
];
 
// Build hierarchical data for d3 treemap
const data = {
  name: "root",
  children: domains.map(d => ({
    name: d.name,
    color: d.color,
    children: d.products.map(p => ({
      name: p.name,
      codename: p.codename,
      value: p.impact,
      legacy: p.legacy,
      domainColor: d.color
    }))
  }))
};
 
const container = document.getElementById('treemap-container');
const W = container.offsetWidth || 900;
const H = Math.round(W * 0.58);
 
const svg = d3.select('#treemap-container')
  .append('svg')
  .attr('viewBox', `0 0 ${W} ${H}`)
  .attr('preserveAspectRatio', 'xMidYMid meet');
 
const root = d3.hierarchy(data)
  .sum(d => d.value)
  .sort((a, b) => b.value - a.value);
 
const treemap = d3.treemap()
  .size([W, H])
  .padding(2)
  .paddingTop(32)
  .paddingInner(1.5)
  .round(true);
 
treemap(root);
 
const GAP = 1;
 
// Draw domain groups
const domainGroups = svg.selectAll('.domain-group')
  .data(root.children)
  .enter()
  .append('g')
  .attr('class', 'domain-group');
 
domainGroups.append('rect')
  .attr('x', d => d.x0 + GAP)
  .attr('y', d => d.y0 + GAP)
  .attr('width', d => Math.max(0, d.x1 - d.x0 - GAP * 2))
  .attr('height', d => Math.max(0, d.y1 - d.y0 - GAP * 2))
  .attr('fill', d => d.data.color)
  .attr('fill-opacity', 0.08)
  .attr('rx', 3);
 
// Domain label
domainGroups.append('text')
  .attr('class', 'domain-label')
  .attr('x', d => d.x0 + GAP + 8)
  .attr('y', d => d.y0 + GAP + 22)
  .text(d => d.data.name)
  .attr('fill', d => d.data.color)
  .attr('fill-opacity', 0.9);
 
// Draw product tiles
const leaves = svg.selectAll('.leaf')
  .data(root.leaves())
  .enter()
  .append('g')
  .attr('class', 'leaf');
 
leaves.append('rect')
  .attr('x', d => d.x0 + GAP)
  .attr('y', d => d.y0 + GAP)
  .attr('width', d => Math.max(0, d.x1 - d.x0 - GAP * 2))
  .attr('height', d => Math.max(0, d.y1 - d.y0 - GAP * 2))
  .attr('fill', d => d.data.domainColor)
  .attr('fill-opacity', d => d.data.legacy ? 0.08 : 0.28)
  .attr('stroke', d => d.data.domainColor)
  .attr('stroke-opacity', d => d.data.legacy ? 0.15 : 0.4)
  .attr('stroke-width', 0.5)
  .attr('rx', 2);
 
// Product labels -- only show if tile is large enough
leaves.each(function(d) {
  const w = d.x1 - d.x0 - GAP * 2;
  const h = d.y1 - d.y0 - GAP * 2;
  if (w < 60 || h < 24) return;
 
  const g = d3.select(this);
  const cx = d.x0 + GAP + w / 2;
  const cy = d.y0 + GAP + h / 2;
 
  const lines = wrapText(d.data.name, w - 10);
  const lineHeight = 12;
  const totalH = lines.length * lineHeight;
  const startY = cy - totalH / 2 + 6;
 
  lines.forEach((line, i) => {
    g.append('text')
      .attr('class', d.data.legacy ? 'product-label product-label-legacy' : 'product-label')
      .attr('x', cx)
      .attr('y', startY + i * lineHeight)
      .attr('text-anchor', 'middle')
      .attr('dominant-baseline', 'middle')
      .attr('fill-opacity', d.data.legacy ? 0.5 : 1)
      .attr('fill', 'var(--body-foreground)')
      .attr('font-size', '12px')
      .text(line);
  });
});

function wrapText(text, maxWidth) {
  // Rough char-width estimate at 10px Georgia
  const charW = 6.2;
  const maxChars = Math.floor(maxWidth / charW);
  const words = text.split(' ');
  const lines = [];
  let current = '';
 
  words.forEach(word => {
    const test = current ? current + ' ' + word : word;
    if (test.length <= maxChars) {
      current = test;
    } else {
      if (current) lines.push(current);
      current = word;
    }
  });
  if (current) lines.push(current);
  return lines.slice(0, 3); // max 3 lines
}
