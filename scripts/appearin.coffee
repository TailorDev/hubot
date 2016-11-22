# Description:
#   Get a link to a appear.in video chat room
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

url = 'https://appear.in/'

module.exports = (robot) ->

  robot.respond /(?:appearin|talk|call) (.*)/i, (msg) ->
    roomname = msg.match[1]
    msg.send "#{url}#{roomname}"

  robot.respond /(?:appearin|talk|call)$/i, (msg) ->
    robot.http('http://www.setgetgo.com/randomword/get.php')
      .get() (err, res, body) ->
        if body
          msg.send url + body.trim().toLowerCase()
        else
          msg.reply 'Looks like I cannot come up with a random word today...'
