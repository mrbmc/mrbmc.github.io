{% if postList.length > 0 %}<section id="blog" class="blog">

{% if label %}## {{ label }}{% endif %}

{% if summary %}{{ summary }}{% endif %}

{% for post in postList %}
{% if forloop.index0 < postCount %}
<span class="date">{{ post.data.date | date: "%Y-%d-%m" }}</span> [{{post.data.title}}]({{ post.url }})
{.post}{% endif %}
{% endfor %}

</section>{% endif %}