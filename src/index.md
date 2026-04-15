---
layout: layout.html
bodyclass: home
title: Design & Product Leadership
description: Brian McConnell is a design executive with a unique background as a designer, founder, product manager, and engineer. He builds sustainable businesses by designing products that meet real human needs.
eleventyExcludeFromCollections: false
cssfile: "css/pages/home.css"
hidefooter: true
---

{% section "masthead","full-width-grid" %}

# I level up design teams to drive business outcomes.{.blur-in}

<!-- * [Portfolio](/portfolio/)
* [How I Work](/about/)
* [Blog](/blog/)

{.blur-in .nav #mininav} -->

{% endsection %}

## Work{.full-width-grid .blur-in}

{% include "_project-list.md", 
	collection: collections.work, 
	count:6,
	id: "projects", 
	class: "full-width-grid blur-in",
	summary: false %}
