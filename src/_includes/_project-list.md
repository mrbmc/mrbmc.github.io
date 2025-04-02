{% assign _heading = heading | slug %}
{% assign _class = "project-list " | append: class %}

{% if heading %}## {{ heading }}{% endif %}

{% if description %}{{ description }}{% endif %}

{% section _heading, _class %}

{% for project in projectList reversed %}{% if forloop.index0 < count %}
<article class="project{%if bodyclass != "home" %} full{% endif %}">

<header>

{% if bodyclass == "home" %}
#### {{ project.data.title }}
{% else %}
#### [{{ project.data.title }}]({{ project.url }})
{% endif %}

{% if project.data.timeline %}#### {{project.data.timeline}}{.timeline}{% endif %}

{% if project.data.description %}{{ project.data.description }}{.summary}{% endif %}

{% for product in project.data.accomplishments %}
- {{ product }}
{% endfor %}{.small-type}

{% if project.data.casestudy %}<a href="#" data-part1="b" data-part2="brianmcconnell" data-part3="me" data-part4="Case Study Request: {{project.data.title}}" class="link-email">Case study available</a>{% endif %}

</header>

{% if bodyclass == "home" %}

<figure>
	<img src="{{ project.data.thumbnail }}" alt="{{ project.data.title }}" />
</figure>

{% else %}

<figure>
	<a href="{{project.url}}"><img src="{{ project.data.thumbnail }}" alt="{{ project.data.title }}" /></a>
</figure>

{% endif %}

</article>
{% endif %}
{% endfor %}

{% endsection %}
