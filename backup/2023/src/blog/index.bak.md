---
layout: layout.html 
bodyclass: blog
title: "Brian McConnell | Blog"
masthead: -1
---

{% for post in collections.posts %}
<div class="post">

### [{{post.data.title}}]({{ post.url }})

{{ post.data.date | date: "%Y-%m-%d" }}
{.date}

{%if post.data.summary %}{% endif %}
{{post.data.summary}}
{.summary}

</div>
{% endfor %}
