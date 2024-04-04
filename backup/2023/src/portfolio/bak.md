
<section class="project-list">

{% if collections.play.length > 0 or collections.talk.length %}
## Work
{% endif %}

{% for project in collections.work %}

[![{{project.data.title}}]({{ project.data.thumbnail }})]({{ project.url }}) {.project}

{% endfor %}

</section>

{% if collections.talk.length > 0 %}
<section class="project-list">

## Talks

You must pass on what you know.

{% for project in collections.talk %}
[![{{project.data.title}}]({{ project.data.thumbnail }})]({{ project.url }}) {.project}
{% endfor %}

</section>
{% endif %}

{% if collections.personal.length > 0 %}
<section class="project-list">

## Play

Sometimes I make stuff to clarify my thinking, prototype new designs, or learn new skills. 

{% for project in collections.personal %}

[![{{project.data.title}}]({{ project.data.thumbnail }})]({{ project.url }}) {.project}

{% endfor %}

</section>
{% endif %}
