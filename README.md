Graf Zahl, world's first arithmomantic programming language
===========================================================

Graf Zahl is a small piece of ruby code that, when ```require()```d, injects ruby with arithmomantic character tracking.
Arithmomancy is the old art of fortune telling using the magical properties of numbers. Names are converted into numbers, and the numbers in turn are processed by a highly involved algorithm (to be found in ```Character.doTehArithmancy(something)```) and then looked up in a character table that survived form ancient times.
The character of each thing is modified by everything you do with it (method calls, operators). This way it then can be checked that you do only process values and classes with a pure character. Values which are often used in certain contexts will slowly assume the character of these contexts. So if you often use your ```1``` in an evil environment, over time it might turn evil.

How to try stuff out
====================
Check out and run ```test.rb```. Please note this code is written against ruby 1.9.3 and will very likely not work against anything < 1.9. Also, please note it is *horribly* slow. This is a side effect of Graf Zahl practising a *really* ancient art as well as an implication of the way Graf Zahl does this (think of intercepting *any* method call) and I think is an acceptable price for an artithmomantically verifiable program.

Planned stuff
============
A planned feature is the on-the-fly modification of method calls when there is a character mismatch, details can be found in ```TODO```, just to make it a little more esotheric and harder to use.

Why the fuck?
=============
Just for fun, and because now I know *a lot* more about ruby's way of OO. You may find this code useful because it can be used for pretty deep debugging of ruby code. Just comment out the whole arithmomancy stuff and uncomment the one ```puts``` in ```process_call(...)```. Also, ponies.

Hate, Rage, certainly inappropriate accolade
============================================
The project's code, issue tracker and I can be found on github under https://github.com/jaseg/Graf-Zahl . Fork me!
