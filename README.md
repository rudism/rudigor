#rudigor

A bot that does various things for me.

##Tasks

The bot is split up into distinct tasks in the tasks directory. Currently it has the following tasks:

###IFTTT Endpoint

This task mimics a Wordpress blog that you can plug in to [IFTTT](http://ifttt.com) (similar to [ifttt-webhook](https://github.com/captn3m0/ifttt-webhook)). You trigger "hooks" by specifying their name in the tags field of the ifttt action. Currently the only hook is for kindle, which uses [SENDtoREADER](http://send2reader.com/) to convert the page at the provided url into a Kindle-friendly ebook and send it wirelessly to my Kindle.

My use for this task/hook currently is to Kindle-ify any urls I tag with the keyword "kindle" on my [Pinboard](http://pinboard.in) account for later reading.

##Works in Progress

The next task I am building will log into arbitrary XMPP accounts with a low priority, and send any messages it receives as [Pushover](http://pushover.net) notifications to my phone. This essentially provides free push notifications for Jabber/Google talk/Facebook chat messages without requiring their crappy apps on my phone. Once a pushover notification is received, I can load up my preferred XMPP client and continue the conversation.

I currently already do this using a very simple perl script based on the [Bot::Jabbot](https://metacpan.org/pod/Bot::Jabbot) module, but that library is very bloated for my simple purposes and takes up more RAM than it should so I'm rewriting it here.
