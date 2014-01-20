# Interconnect

A high-bandwidth virtual office for open teams. Public rooms are free. Private rooms cost. FOSS.


## TLDR

Think of it as [IRC](http://irccloud.com) for infrastructure, [Sqwiggle](http://sqwiggle.com) for Interface, [Google Hangouts on Air](http://www.google.com/+/learnmore/hangouts/onair.html) for recording, and [GitHub](https://github.com/balupton) for profiles.


## Why?

### The Problem

- In-person communication is the ultimate thing, it's high bandwidth, engages all the senses, and is immediate and personal
- Other communication tools for the open-source world (like IRC, GitHub Issues, etc) are low-bandwidth, interruptive, inpersonal, and frustrating
- Video communication tools (like Skype, Google Hangouts, Sqwiggle) are not catered to open-source project's infinitely large teams and requirement to open-source everything
- Communication tools (like Skype) had too much over-head, you had to arrange meetings, schedule times, across many time-zones, with many remote workers, delaying progress in the mean-time, often in an never-ending loop
- Other communication tools (like Skype, Google Hangouts, Sqwiggle, GitHub Issues, etc) are closed, giving the people no power to create their ideal experiences


### The Solution

- People log in to Interconnect
- Their video is made available, so people can see your availability
- If you are busy, you mark yourself as busy so others can't interrupt you
- If you are interupptable, people can click you (and others) to start an instant (group) video call
- There is a text chat on the left for asynchronous communication and sharing resources
- It is open-source, so you can tweak it to work best for your requirements


### The Impact

- Consultants, Trainers, and Experts no longer need to fly around the world to assist co-workers in their office
  - Instead they can join the virtual office, which is just as good, if not better, than the real office
- Remote open-source teams now finally have access to high-bandwidth communication


### Why doesn't Sqwiggle just implement public free rooms?

[I've suggested it countless times, they are not interested.](https://twitter.com/balupton/status/397272119802736640)

Plus it misses the opportunity to create the next generation de-facto standard communicational tool, as an open-source initiative that everyone has power and control over.


### Example Workflow

1. @balupton joins the `#docpad` IRC Channel via InterConnect
  1. The InterConnect IRC Bot posts on the `#docpad` IRC Channel: `@balupton just joined via http://interconnect.net/docpad`
1. @crito joins the `#docpad` IRC Channel via InterConnect
  1. The InterConnect IRC Bot posts on the `#docpad` IRC Channel: `@crito just joined via http://interconnect.net/docpad`
1. @balupton unmutes @crito to start a call
  1. The InterConnect IRC Bot posts on the `#docpad` IRC Channel: `@balupton and @crito are now video calling on http://interconnect.net/docpad/balupton+crito`
1. @ninabreznik was on IRC and notices the video call link, she clicks it and joins
  1. The InterConnect IRC Bot posts on the `#docpad` IRC Channel: `@balupton, @crito, @ninabreznik are now video calling on http://interconnect.net/docpad/balupton+crito+ninabreznik`
1. @balupton posts a link to an image in the InterConnect chat
  1. The InterConnect chat enhances it on the InterConnect website to embed the actual image
  2. The InterConnect IRC Bot posts on the `#docpad` IRC Channel: `@balupton just posted: http://the.url/to-the.image`
1. The video call finishes, and is uploaded to Vimeo for archival
  1. The InterConnect IRC Bot posts on the `#docpad` IRC Channel: `@balupton, @crito, @ninabreznik video call just finished, watch it here: http://interconnect.net/docpad/call-id`


## How

[Check out the tasks.](https://github.com/bevry/interconnect/issues)

[Check out the code.](https://github.com/bevry/interconnect/branches)


## License

Unless stated otherwise; all works are Copyright © 2013+ [Bevry Pty Ltd](http://bevry.me) <us@bevry.me> and licensed [permissively](http://en.wikipedia.org/wiki/Permissive_free_software_licence) under the [MIT License](http://creativecommons.org/licenses/MIT/) for code and the [Creative Commons Attribution 3.0 Unported License](http://creativecommons.org/licenses/by/3.0/) for everything else (including content, media and design), enjoy!