#rudigor

A bot that does various things for me.

##Tasks

The bot is split up into distinct tasks in the tasks directory. Currently it has the following tasks:

###IFTTT Endpoint

This task mimics a Wordpress blog that you can plug in to [IFTTT](http://ifttt.com) (similar to [ifttt-webhook](https://github.com/captn3m0/ifttt-webhook)). You trigger "hooks" by specifying their name in the tags field of the ifttt action. Currently the only hook is for kindle, which uses [SENDtoREADER](http://send2reader.com/) to convert the page at the provided url into a Kindle-friendly ebook and send it wirelessly to my Kindle.

My use for this task/hook currently is to Kindle-ify any urls I tag with the keyword "kindle" on my [Pinboard](http://pinboard.in) account for later reading.

###XMPP Notifier Bot

The xmpp task logs on to defined XMPP accounts with a low priority and sends [Pushover](https://pushover.net/) notifications when it receives new messages. This allows me to receive push notifications on my phone when people message me on Jabber or Facebook without needing me to have a client running on my phone.

###Draftin to Hexo Endpoint

I have a few blogs that I used to host on [Ghost](http://ghost.org), but the cost of hosting was unjustifiably high for me, so now I host them as static sites in [S3](http://aws.amazon.com/s3) instead. I generate them using [Hexo](http://hexo.io), and write my posts in markdown on [Draftin.com](http://www.draftin.com). This task is an endpoint that I can publish to using Draftin's webhooks which will save the post, generate the Hexo site, and sync it to S3 automatically for me.
