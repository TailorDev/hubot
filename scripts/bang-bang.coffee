# Description:
#   None
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot !! - Repeat the last command directed at hubot
#
# Author:
#   None

utils = require '../src/utils'
{ TextMessage } = require 'hubot'

module.exports = (robot) ->
  robot.respond /(.+)/i, (msg) ->
    channel = utils.getRoomName robot, msg.message
    store channel, msg, robot

  robot.respond /!!$/i, (msg) ->
    channel = utils.getRoomName robot, msg.message
    command = robot.brain.get("bang-bang-#{channel}")

    if command?
      msg.send command
      robot.receive new TextMessage \
        msg.message.user,
        "#{robot.name}: #{command}"
    else
      msg.send "I don't remember hearing anything."

store = (channel, msg, robot) ->
  command = msg.match[1].trim()
  if command != '!!'
    robot.brain.set "bang-bang-#{channel}", command
