# ox-twee

ox-twee is a Twee backend for the Emacs Org export engine. [Twee](https://github.com/iftechfoundation/twine-specs/blob/master/twee-3-specification.md) is a text format for making the soruce code of interactive, nonlinear stories in [Twine](https://twinery.org) 

ox-twee is written as a companion to [Twiorg](https://github.com/danishec/twiorg). The two tools allow a writer of interactive, nonlinear stories to go back and forth between Twine and [Emacs](https://www.gnu.org/software/emacs/) to develop the story. Twine provides a nice GUI to organize passages and the links between them. Emacs is a versatile text-editor with immense capabilities. [Org Mode](https://orgmode.org/) is an emacs major mode for authoring (almost) anything in a plain text system. 

## Installation

Copy the ox-twee.el file into your elisp directory included in the load-path and load the ox-twee.el file via ```M-x load-file RET ox-twee.el```

In the org buffer, run ```M-x org-twee-export-as-twee``` to export the org content to a ```*twee-buffer*```.

Or, run ```M-x org-twee-export-to-twee``` to export the org content to a file of the same name and directory as the .org file but with a .twee extension

## Output

Here's an example of its output:

```txt
:: StoryTitle
Daphnes $10 Adventure

:: StoryData
{
  "ifid": "2DADFBDA-06DE-4776-B912-AC93F4F08CBF",
  "format": "Twiorg",
  "format-version": "0.3.5",
  "start": "Daphnes 10 Adventure",
  "zoom": 1
}
:: Meet Daphne  [Intro Edit] {"position":"50,250","size":"100,100"}

<%
window.story.state = {
cash: 10,
};
%>
.. a 7-year-old girl with a heart full of cheer, a mind full of wonder, and a spirit as strong as a horse.

One Sunday during the Summer, Daphne's parents sat her down for a chat. "Daphne," said Dad, "How about we play a game this week? It is called Entrepreneur."

"Ont-po-what?" Daphne giggled.

"An entrepreneur is someone who is creative in solving problems they or others have," explained Mom. 

Daphne has $
<%
window.story.state.cash 
%>

[[continue   ->A Weeklong Adventure!]]
```

generated from the following org file:

```org
#+TITLE: Daphnes $10 Adventure
* Twine 2 Metadata
:PROPERTIES:
:name: Daphnes 10 Adventure
:startnode: 1
:creator: Twine
:creator-version: 2.10.0
:format: Twiorg
:format-version: 0.3.5
:zoom: 1
:ifid: 2DADFBDA-06DE-4776-B912-AC93F4F08CBF
:END:

* Meet Daphne
:PROPERTIES:
:name: Meet Daphne
:pid: 1
:position: 50,250
:size: 100,100
:tags_: Intro Edit
:END:

#+BEGIN_SRC javascript
window.story.state = {
cash: 10,
};
#+END_SRC
.. a 7-year-old girl with a heart full of cheer, a mind full of wonder, and a spirit as strong as a horse.

One Sunday during the Summer, Daphne's parents sat her down for a chat. "Daphne," said Dad, "How about we play a game this week? It is called Entrepreneur."

"Ont-po-what?" Daphne giggled.

"An entrepreneur is someone who is creative in solving problems they or others have," explained Mom. 

Daphne has $
#+BEGIN_SRC javascript
 window.story.state.cash 
#+END_SRC

[[A Weeklong Adventure!][continue  ]]
```
