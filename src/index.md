---
layout: layout.html
bodyclass: home
title: Design & Product Leadership
description: Brian McConnell is a design executive with a unique background as a designer, founder, product manager, and engineer. He builds sustainable businesses by designing products that meet real human needs.
eleventyExcludeFromCollections: false
cssfile: "css/home.css"
---

{% section "masthead" %}

# UX design, product discovery, and cross-functional leadership.{.blur-in}

<canvas id="gradient-canvas"></canvas>

{% endsection %}

{% include "_project-list.md", projectList: collections.work, heading: false count: 6, _class: "fullWidth" %}

{% include "_post-list.md", postList: collections.post, heading: "Recent Posts", count: 4 %}

<script type="module" language="javascript">
	import { Gradient } from "/js/gradient.min.js";
    const gradient = new Gradient();
    gradient.initGradient("#gradient-canvas");
</script>