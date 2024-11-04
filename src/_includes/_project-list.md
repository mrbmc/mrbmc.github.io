<section class="project-list" id="{{label | slug}}">

{% if label %}## {{ label }}{% endif %}

{% if summary %}{{ summary }}{% endif %}

{% for project in projectList reversed %}{% if forloop.index0 < count %}
<article class="project{%if bodyclass != "home" %} full{% endif %}" onclick="location.href='{{project.url}}'">
<header>

### {{ project.data.title }}

{% if project.data.timeline %}{{project.data.timeline}}{.timeline}{% endif %}

{% if project.data.summary %}{{ project.data.summary }}{.summary}{% endif %}

</header>

[![{{ project.data.title }}]({{ project.data.thumbnail }})]({{ project.url }}) {.figure}

</article>
{% endif %}
{% endfor %}
</section>