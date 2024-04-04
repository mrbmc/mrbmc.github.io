---
layout: layout.html 
bodyclass: blog
title: "Brian McConnell | Blog"
masthead: -1
# permalink: /blog/tags/{{ tag | slugify }}
pagination:
  data: collections.posts
  size: 1
  alias: tag
---

<main>
{% assign posts = collections[ tag ] %}
{% for post in posts reversed %}
<span class="date">{{ post.data.date | date: "%Y-%d-%m" }}</span> [{{post.data.title}}]({{ post.url }})
{.post}
{% endfor %}
</main>