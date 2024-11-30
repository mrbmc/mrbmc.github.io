{% if projectList.length > 0 %}<section class="project-list" id="portfolio">

{% if label %}## {{ label }}{% endif %}

{% if summary %}{{ summary }}{% endif %}

{% for project in projectList %}

[![{{project.data.title}}](/2023{{ project.data.thumbnail }})](/2023{{ project.url }}) {.project}

{% endfor %}

</section>{% endif %}