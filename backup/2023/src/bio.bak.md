---
layout: layout.html
bodyclass: home
page-description: Brian McConnell is a design executive with a unique background as a designer, founder, product manager, and engineer. He builds sustainable businesses by designing products that meet real human needs.
title: Competitive Advantage by Design
mastheadSummary: Brian McConnell is a strategic, adaptable, and curious design leader. He builds high-performance design teams that deliver business impact.
---
<a id="main"></a>

{% include "_projects.md", projectList: collections.work, label: "Selected Work" %}

<section id="blog">

## Recent Posts

{% for post in collections.post reversed %}
{% if forloop.index0 < 3 %}
<span class="date">{{ post.data.date | date: "%Y-%d-%m" }}</span> [{{post.data.title}}]({{ post.url }})
{.post}{% endif %}
{% endfor %}

</section>






![Design Artifacts](/images/about-wireframes-l.jpg){.cover}
## Designer, Creator, Maker{#designer}

I love building products, teams, and partnerships that drive business impact through human-centered design. Over 20+ years I've learned to manage change & navigate ambiguity at every scale. Most recently I led Enterprise Experience Design at ![Disney](/images/disney-logo.svg)  for our streaming services Disney+, Hulu, ESPN+, and STAR+. Previously I led Growth Design, UX Research, and Sports Products.

[Design Work](/design/)


![Cycling up Kangamagus Pass](/images/cycling-kankamagus.jpg){.cover}
## Cyclist{#cyclist}

My happy place is riding my bike across the New England countryside; on road and off. It is a source of physical and psychological nourishment for me.

This summer (2023), I rode across the Green Mountains of Vermont – covering 420km (260mi) with 20,000 ft of elevation gain – over four days. [Read about it.](/blog/bike-tour-2023/)

<!--![VT Tour](http://localhost:8080/images/blog/vt-tour.jpg)-->

`FTP in August 2023: 3.5w/kg`

<iframe id="strava-rides"></iframe><script type="text/javascript">
window.addEventListener('load', function() {
    var stravaRides = 'https://www.strava.com/athletes/773650/latest-rides/69a2b8f6090a8e92b3ea1c24ae6bbccdc629077e';
    document.getElementById('strava-rides').src = stravaRides;
}, false);
</script>


![Machu Pichu](/images/backgrounds/bg-machu-pichu.jpg){.cover}
## World Traveller{#traveler}

#### 200+ Cities, 37 Countries, 5 Continents

I believe that travel makes you a more empathetic person and a better designer. My family and I try to explore the world whenever it's safe and reasonable.

![Brian's Travel Map](/images/bmc-travelmap.svg)


![My happy family](/images/family-16x9.jpg){.cover .family}
## Family Man

👧🏻 Melody &nbsp; 💏 Betty &nbsp; 👦🏻 Sandor

Designing good humans is my most important project. It's also an object lesson in stakeholder management. Together we've worked to create an intentional family culture that values **kindness**, **collaboration**, and super-happy-**fun**-time.

</main>

