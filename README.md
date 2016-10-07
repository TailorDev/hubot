# hubot-bang-bang

Repeat the last command directed at hubot

See [`src/bang-bang.coffee`](src/bang-bang.coffee) for full documentation.

## Installation

In hubot project repo, run:

`npm install hubot-bang-bang --save`

Then add **hubot-bang-bang** to your `external-scripts.json`:

```json
["hubot-bang-bang"]
```

## Sample Interaction

```
user1>> hubot hello
hubot>> hello!
user1>> hubot !!
hubot>> hubot hello
hubot>> hello!
```

## NPM Module

https://www.npmjs.com/package/hubot-bang-bang