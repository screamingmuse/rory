[![Gem Version](https://badge.fury.io/rb/rory.svg)](http://badge.fury.io/rb/rory)
rory
====

**A lightweight, opinionated framework with Rails-like conventions.**

Introduction
------------

Rory is an [MVC](http://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93controller) framework for [Ruby](https://www.ruby-lang.org).  Its conventions are very similar to that of [Ruby on Rails](http://rubyonrails.org), but fewer.

Rory was started as a self-educational project, but has evolved to the point where it is used in production environments.  Its design goals, therefore, are a moving target, but are gradually moving from "understanding the design and implementation of Rails" to "creating a lightweight, opinionated framework with Rails-like conventions."

History
-------

In 2008, I was first introduced to [Ruby on Rails](http://rubyonrails.org).  I'd been an independent contract PHP developer for over 8 years, and I'd never used an MVC framework before, so I was thirsty for something different.

I loved Ruby (mostly).  And Rails was great for scaffolding - getting a functional web application running quickly.  However, all its "magic" (to enable convention over configuration) made it very difficult for a newcomer to understand what was going on, and to actually learn Ruby.

I griped and griped about the complexity of Rails, and about the arcane maneuvers necessary to code "outside the box," until finally I decided to take a more empathic approach, and ask the question: *Why is Rails the way it is?*

I figured the best way to tackle the question was to start over from scratch.  Start with a specification for a web application, and nothing but the Rack gem.  And thus was born Rory.

Contributing to rory
--------------------
 
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

Copyright
---------

Copyright (c) 2013 Ravi Gadad. See LICENSE.txt for
further details.

