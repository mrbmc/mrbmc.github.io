{% assign slug = heading | slug %}
{% unless id %}{% assign id = slug %}{% endunless %}
{% assign _class = "project-list " | append: class %}

{% if heading %}## {{ heading }}{% endif %}

{% if description %}{{ description }}{% endif %}

{% section id, _class %}

{% for project in collection reversed %}{% if forloop.index0 < count %}
<article class="project">

<header>

#### [{{ project.data.title }}]({{ project.url }})

{% if project.data.timeline %}#### {{project.data.timeline}}{.timeline}{% endif %}

{% if project.data.description %}{{ project.data.description }}{.summary}{% endif %}

{% for product in project.data.accomplishments %}
- {{ product }}
{% endfor %}{.small-type}

{{project.templateContent | timeToRead}} to read{.muted .duration}

</header>

[![{{ project.data.title }}]({{ project.data.thumbnail }})]({{project.url}}) {.figure}

</article>
{% endif %}
{% endfor %}

{% endsection %}
