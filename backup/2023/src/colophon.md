---
layout: layout.html
title: Brian McConnell | Design & Product Leadership
masthead: -1
---

# Colophon

## Site Info
This is a static website because reasons:
* Performance: Static websites _almost_ always load faster than apps.
* Durability: I don't have to maintain frameworks and libraries to make it work because it's based on standard web technology.
* Flexibility: The simplicity of the build makes it very easy to make changes
* Portability: Just grab the files and go. 

## Key Apps

* [11ty](https://www.11ty.dev/) is the site generator.
* [Sublime Text](https://www.sublimetext.com/) is my code editor.
* [Obsidian](https://obsidian.md/) is my markdown editor for blog entries and portfolio case studies.
* [Awesome Screenshot](https://chrome.google.com/webstore/detail/alelhddbbhepgpmgidjdcjakblofbmce) is my favorite tool for grabbing screensots and recordings.
* [Amazon S3](https://aws.amazon.com/) & [Cloudfront](https://aws.amazon.com/) for hosting. I don't love AWS but I do love paying 18¢ / month.

## Production Support

Caffeine delivered via <a href="https://www.drinktrade.com">Trade Coffee</a>. I prefer light roast single origin beans brewed using an [AeroPress](https://aeropress.com/).

Transportation provided by a custom [Dengfu R01](https://www.dengfubike.com/products/r01) and a [2017 Crust Romanceür](https://crustbikes.com/products/a-romantic-tale-the-romanceur)

---

## Social Footprint

* [Strava](http://app.strava.com/athletes/773650)
* [Twitter](http://twitter.com/mrbmc)
* [Tumblr](http://mrbmc.tumblr.com)
* [LinkedIn](http://linkedin.com/in/mrbmc)
* [Quora](http://www.quora.com/Brian-McConnell)
* [Instagram](http://instagram.com/mrbmc)
* [Flickr](http://www.flickr.com/photos/mrbmc/)
* [GitHub](https://github.com/mrbmc)
* [CodePen](http://codepen.io/mrbmc)
* [Pinterest](http://pinterest.com/mrbmc/)
* [Vimeo](http://vimeo.com/mrbmc)
* [YouTube](http://www.youtube.com/user/imthebmc)
* [SteelGills](http://steelgills.com/mrbmc)
* [Last FM](http://www.last.fm/user/mrbmc)

---

## Style Guide

### Typography

The primary typeface is [Tomato Grotesk](https://www.thedesignersfoundry.com/tomato-grotesk/) by [The Designers Foundry](https://www.thedesignersfoundry.com/).

For extended prose we use a native serif: Hoefler on MacOS & iOS, Palatino on Android and Windows.

# H1 Titular Heading

## H2 Section Heading Title

### H3 Sub-Section Heading Title

#### H4 Component Heading Title

##### H5 Component Sub-Heading Title

Body: It is a way I have of driving off the spleen and regulating the circulation. Whenever I find myself growing grim about the mouth; whenever it is a damp, drizzly November in my soul; whenever I find myself involuntarily pausing before coffin warehouses, and bringing up the rear of every funeral I meet; and especially whenever my hypos get such an upper hand of me, that it requires a strong moral principle to prevent me from deliberately stepping into the street, and methodically knocking people’s hats off—then, I account it high time to get to sea as soon as I can. 

Body.Serif: It is a way I have of driving off the spleen and regulating the circulation. Whenever I find myself growing grim about the mouth; whenever it is a damp, drizzly November in my soul; whenever I find myself involuntarily pausing before coffin warehouses, and bringing up the rear of every funeral I meet; and especially whenever my hypos get such an upper hand of me, that it requires a strong moral principle to prevent me from deliberately stepping into the street, and methodically knocking people’s hats off—then, I account it high time to get to sea as soon as I can. {.serif}

### Color

Black{.chip .black}

Gray 100{.chip .gray100}

Gray 500{.chip .gray500}

Gray 900{.chip .gray900}

White{.chip .white}

Brand {.chip .brand}

Complement {.chip .complement}

Accent {.chip .accent}

<style>
.chip {
	width: 19%;
	height: 4.5em;
	padding: .25em;
    box-sizing: border-box;
	display: inline-block;
}
.chip.black {
	background: var(--black);
	color: var(--gray-900);
}
.chip.gray100 {
	background: var(--gray-100);
	color: var(--gray-900);
}
.chip.gray500 {
	background: var(--gray-500);
	color: var(--gray-900);
}
.chip.gray900 {
	background: var(--gray-900);
}
.chip.white {
	background: var(--white);
}
.chip.brand {
	background: var(--brandColor);
	color: var(--gray-900);
}
.chip.complement {
	background: var(--brandComplement);
}
.chip.accent {
	background: var(--brandAccent);
}
</style>