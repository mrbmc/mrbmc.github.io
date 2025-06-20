---
layout: layout.html
bodyclass: about
title: Design & Product Leadership
description: Brian McConnell is a design executive with a unique background as a designer, founder, product manager, and engineer. He builds sustainable businesses by designing products that meet real human needs.
permalink: /about/
cssfile: "css/pages/about.css"
---

{% section "bio","full-grid" %}

# Hello there.

My family calls me **Brian**. My friends call me **[BMC\*](#killabmc){onclick="event.preventDefault();return false;"}**. I am a father 👧🏻 👦🏻, husband 👩🏻, New Yorker 🗽, ️[cyclist](https://www.strava.com/athletes/773650) 🚲, [divemaster](https://www.steelgills.com) 🤿, [fusion chef](https://www.fusionfamilyfeast.com/) 👨‍🍳, [world traveler](https://www.google.com/maps/d/u/0/edit?mid=1jAS6t-WP2zKeOYag3KsGKZtqxERvSfE) 🌎, and **[digital product maker](/portfolio/)** 👨‍💻.{.large-type}

Short for "killaBMC", my genuine wu-tang-name betrothed by the GZA{#killabmc .tooltip}

![Portrait of Brian](/images/profile/headshot-slash.png) {.portrait  .blur-in}
<!-- ![Portrait of Brian](/images/profile/headshot-slash.png) {.portrait  .blur-in} -->


{% endsection %}

1. [Mission](#intro) 
1. [UX Principles](#principles) 
1. [Design Storytelling](#process)
1. [Leadership Philosophy](#leadership) 

{.sticky-nav}

{% section "intro","" %}

# Ridding the world of crummy software.

I have always been fascinated by tools. Tools augment our capability as a species. They empower us, change us, and mold our view of the world. The power conferred can spark a conversation with evolution. 

Software is a tool that influences our capabilities in unprecedented ways.

Making good software, that is inherently good, has been my career mission. I love the balance of creativity and analysis required to create something that is both useful to people and inherently good. Software Design has an incredible power to give form to ideas. The process of **listening, making, and collaborating** unlocks critical thinking for everyone. 

My unique career path has pivoted between design, product, and engineering thanks to an entrepreneurial instinct to run towards ~~problems~~ opportunities. The common thread has been using Design to deliver through ambiguity at any scale. 

[CV & Resumé](/images/uploads/Brian_McConnell-Resume_2025.pdf)

{% endsection %}


{% include "_principles.md" %}

{% include "_process.md" %}

{% include "_leadership.md" %}

<script type="text/javascript">
window.addEventListener('load', function(e) {
    Array.from(document.getElementsByClassName('blur-in')).map(element => {
        element.classList.toggle('in',true);
    });
    Array.from(document.getElementsByClassName('fade-in')).map(element => {
        element.classList.add('in',true);
    });
    document.querySelector("a[href='#killabmc']").addEventListener('mouseover',function(event){
        const tip = document.getElementById('killabmc');
        var xposition = (event.clientX - this.offsetLeft);
        var yposition = (event.clientY - this.offsetTop);
        tip.style.left = (this.offsetLeft - (tip.offsetWidth / 2)) + "px";
        tip.style.top = (this.offsetTop - tip.offsetHeight) + "px";
        tip.classList.add("in");
    });
    document.querySelector("a[href='#killabmc']").addEventListener('mouseout',function(event){
        const tip = document.getElementById('killabmc');
        tip.classList.remove("in");
    });
});
</script>