# Description:
#   Get a link to an appear.in video chat room
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot appearin <roomname> - Get a link to appear.in/<roomname>.
#   hubot appearin - Get a random room.
#
# Notes:
#   None
#
# Author:
#   digitalsadhu
#   William Durand

module.exports = (robot) ->

  robot.respond /appearin (.*)/i, (msg) ->
    roomname = msg.match[1]
    msg.send "https://appear.in/#{roomname}"

  robot.respond /appearin$/i, (msg) ->
    robot.http('http://www.setgetgo.com/randomword/get.php')
      .get() (err, res, body) ->
        if body
          msg.send 'https://appear.in/' + body.trim().toLowerCase()
        else
          msg.reply 'Looks like I cannot come up with a random word today...'
