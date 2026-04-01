---
layout: layout.html
bodyclass: portfolio isotope
title: "Portfolio"
cssfile: "css/pages/portfolio.css"
jsfile: "js/portfolio.bundle.js"
permalink: /portfolio/
eleventyImport:
  collections: ["allProjects","post"]
---

<nav class="isotope-filters" id="isotope-filters" aria-label="Filter portfolio items">
<button class="filter-btn active" data-filter="all">All</button><button class="filter-btn" data-filter="work">Work</button><button class="filter-btn" data-filter="play">Play</button><button class="filter-btn" data-filter="write">Write</button><button class="filter-btn" data-filter="speak">Speak</button>
</nav>

<div class="isotope-grid full-width-grid" id="isotope-grid">
{% for entry in isotope %}
  {% if entry.type == "project" %}
    {% assign item = collections.allProjects | getBySlug: entry.slug %}
  {% else %}
    {% assign item = collections.post | getBySlug: entry.slug %}
  {% endif %}
  {% if item %}
<article class="isotope-item {{ entry.size }} {{ entry.filter }}" data-filter="{{ entry.filter }}">
<a href="{{ item.url }}" class="item-link">
{% if item.data.thumbnail %}<figure class="item-figure"><img src="{{ item.data.thumbnail }}" alt="{{ item.data.title }}"></figure>{% elsif item.data.masthead-image %}<figure class="item-figure"><img src="{{ item.data.masthead-image }}" alt="{{ item.data.title }}"></figure>{% else %}<figure class="item-figure item-figure--empty"></figure>{% endif %}
<div class="item-body">
<span class="item-tag tag-{{ entry.filter }}">{{ entry.filter }}</span>
<h3 class="item-title">{{ item.data.title }}</h3>
{% if entry.size == "lg" and item.data.summary %}<p class="item-summary">{{ item.data.summary }}</p>{% endif %}
</div>
</a>
</article>
  {% endif %}
{% endfor %}
</div>
