---
layout: layout.html
bodyclass: portfolio list
title: "Portfolio"
---

{% if collections.work.length > 0 %}
{% include "_project-list.md", projectList: collections.work, label: "Work", count:12 %}
{% endif %}

[CV & Resumé](/resume/) {.center}

{% if collections.personal.length > 0 %}
{% include "_project-list.md", projectList: collections.personal, label: "Play", summary: "As a Kinesthetic Learner, I need create new things to refine my thinking, and develop new skills.", count:3 %}
{% endif %}


{% if collections.talk.length > 0 %}
{% include "_project-list.md", projectList: collections.talk, label: "Speak", summary: "A great way to learn is to share what you think you know.", count:3 %}
{% endif %}

