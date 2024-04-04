{% if projectList.length > 0 %}<section class="project-list" id="portfolio">

{% if label %}## {{ label }}{% endif %}

{% if summary %}{{ summary }}{% endif %}

{% for project in projectList %}

[![{{project.data.title}}]({{ project.data.thumbnail }})]({{ project.url }}) {.project}

{% endfor %}

</section>{% endif %}