(function() {
const products = [
  {
    name: "Streaming Analytics",
    codename: "Optumus",
    value: 21,
    displayValue: "-$30M/yr",
    x: 0.12,
    y: 0.85,
    color: "var(--primary)",  // DATA & Insights - amber
    type: "save"
  },
  {
    name: "Support Agent Console",
    codename: "Baymax",
    value: 21,
    displayValue: "-$20M/yr",
    x: 0.20,
    y: 0.30,
    color: "var(--tertiary)",  // Growth Life - blue
    type: "save"
  },
  {
    name: "Commerce Orchestration",
    codename: "Genie",
    value: 34,
    displayValue: "+25% MRR YoY",
    x: 0.89,
    y: 0.87,
    color: "var(--tertiary)",  // Growth Life - blue
    type: "make"
  },
  {
    name: "Lifecycle Messaging",
    codename: "Galaxy",
    value: 13,
    displayValue: "-$3M/yr & +MRR",
    x: 0.70,
    y: 0.75,
    color: "var(--tertiary)",  // Growth Life - blue
    type: "make"
  },
  {
    name: "Experimentation",
    codename: "WeaponX",
    value: 13,
    displayValue: "-$5M/yr & +MRR",
    x: 0.65,
    y: 0.50,
    color: "var(--primary)",  // DATA & Insights - amber
    type: "both"
  },
  {
    name: "Content Curation",
    codename: null,
    value: 8,
    displayValue: "+Engagement",
    x: 0.80,
    y: 0.30,
    color: "var(--secondary)",  // Content Experience - purple
    type: "make"
  },
  {
    name: "Design System",
    codename: "Trek",
    value: 2,
    displayValue: "C.O.D.B.",
    x: 0.50,
    y: 0.50,
    color: "var(--quaternary)",
    type: "both"
  },
  {
    name: "Translation Dictionary",
    codename: "Cypher",
    value: 5,
    displayValue: "-$1M/yr & +NET SUBS",
    x: 0.30,
    y: 0.75,
    color: "var(--secondary)",
    type: "save"
  },
];
 
const container = document.getElementById('bubblechart');
const W = container.offsetWidth || 800;
const H = Math.round(W * 0.85);
const PAD = { top: 40, right: 60, bottom: 60, left: 60 };
const innerW = W - PAD.left - PAD.right;
const innerH = H - PAD.top - PAD.bottom;
 
const svg = d3.select('#bubblechart')
  .append('svg')
  .attr('viewBox', `0 0 ${W} ${H}`)
  .attr('preserveAspectRatio', 'xMidYMid meet');
 
const g = svg.append('g')
  .attr('transform', `translate(${PAD.left},${PAD.top})`);
 
// Quadrant backgrounds
const quads = [
  { x: 0, y: 0, w: 0.5, h: 0.5, label: "Save & Indirect", labelX: 0.02, labelY: 0.97, anchor: "start", fill: "var(--muted-background)" },
  { x: 0.5, y: 0, w: 0.5, h: 0.5, label: "Make & Indirect", labelX: 0.98, labelY: 0.97, anchor: "end", fill: "var(--body-background)" },
  { x: 0, y: 0.5, w: 0.5, h: 0.5, label: "Save & Direct", labelX: 0.02, labelY: 0.03, anchor: "start", fill: "var(--body-background)" },
  { x: 0.5, y: 0.5, w: 0.5, h: 0.5, label: "High Impact", labelX: 0.98, labelY: 0.03, anchor: "end", fill: "var(--card-background)" },
];
 
quads.forEach(q => {
  g.append('rect')
    .attr('x', q.x * innerW)
    .attr('y', (1 - q.y - q.h) * innerH)
    .attr('width', q.w * innerW)
    .attr('height', q.h * innerH)
    .attr('fill', q.fill)
    // .attr('fill-opacity', q.label === "High Impact" ? 0.95 : 0.95)
    .attr('stroke', 'var(--border-color)')
    .attr('stroke-width', 0.5);
});
 
// Axis lines
g.append('line')
  .attr('x1', innerW / 2).attr('y1', 0)
  .attr('x2', innerW / 2).attr('y2', innerH)
  .attr('stroke', 'var(--border-color)')
  .attr('stroke-width', 0.5);
 
g.append('line')
  .attr('x1', 0).attr('y1', innerH / 2)
  .attr('x2', innerW).attr('y2', innerH / 2)
  .attr('stroke', 'var(--border-color)')
  .attr('stroke-width', 0.5);
 
// Axis labels
g.append('text')
  .attr('class', 'axis-label')
  .attr('x', innerW * 0.25)
  .attr('y', innerH + 36)
  .attr('text-anchor', 'middle')
  .attr('fill', 'var(--muted-foreground)')
  .text('Save Money');
 
g.append('text')
  .attr('class', 'axis-label')
  .attr('x', innerW * 0.75)
  .attr('y', innerH + 36)
  .attr('text-anchor', 'middle')
  .attr('fill', 'var(--muted-foreground)')
  .text('Make Money');
 
// Vertical axis label
g.append('text')
  .attr('class', 'axis-label')
  .attr('transform', `translate(-42, ${innerH * 0.25}) rotate(-90)`)
  .attr('text-anchor', 'middle')
  .attr('fill', 'var(--muted-foreground)')
  .text('Direct Impact');
 
g.append('text')
  .attr('class', 'axis-label')
  .attr('transform', `translate(-42, ${innerH * 0.75}) rotate(-90)`)
  .attr('text-anchor', 'middle')
  .attr('fill', 'var(--muted-foreground)')
  .text('Indirect Impact');
 
// Bubble size scale
const maxValue = d3.max(products, d => d.value);
const rScale = d3.scaleSqrt()
  .domain([0, maxValue])
  .range([0, innerW * 0.1]);
 
// Clamp bubble centers so they stay within bounds
function clampX(d) {
  const r = rScale(d.value);
  return Math.max(r, Math.min(innerW - r, d.x * innerW));
}
function clampY(d) {
  const r = rScale(d.value);
  return Math.max(r, Math.min(innerH - r, (1 - d.y) * innerH));
}
 
// Draw bubbles
const bubbles = g.selectAll('.bubble')
  .data(products)
  .enter()
  .append('g')
  .attr('class', 'bubble')
  .attr('transform', d => `translate(${clampX(d)}, ${clampY(d)})`);
 
bubbles.append('circle')
  .attr('r', d => rScale(d.value))
  .attr('fill', d => d.color)
  .attr('fill-opacity', 0.25)
  .attr('stroke', d => d.color)
  .attr('stroke-opacity', 0.7)
  .attr('stroke-width', 1.5);
 
// Name and value both below bubble
bubbles.append('text')
  .attr('class', 'bubble-label')
  .attr('y', d => rScale(d.value) + 16)
//   .attr('width', d => rScale(d.value) * 2)
  .attr('text-anchor', 'middle')
  .attr('font-size', 14)
  .attr('fill', 'var(--body-foreground)')
  .text(d => d.name);
 
bubbles.append('text')
  .attr('class', 'bubble-value')
  .attr('y', d => rScale(d.value) + 36)
  .attr('text-anchor', 'middle')
  .attr('font-size', 12)
  .attr('fill', 'var(--body-emphasized)')
  .text(d => d.displayValue);
})();
