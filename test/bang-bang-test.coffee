chai   = require 'chai'
helper = require './test-helper'
assert = chai.assert

describe 'hubot bang-bang', ->
  beforeEach (done) ->
    @robot = helper.robot()
    @user  = helper.testUser @robot
    @robot.adapter.on 'connected', ->
      @robot.loadFile  helper.SCRIPTS_PATH, 'bang-bang.coffee'
      @robot.parseHelp "#{helper.SCRIPTS_PATH}/bang-bang.coffee"
      done()
    @robot.run()

  afterEach ->
    @robot.shutdown()

  it 'should be included in /help', ->
    assert.include @robot.commands[0], '!!'

  it 'should repeat the previous command called', (done) ->
    helper.converse @robot, @user, '/help'

    helper.converse @robot, @user, '/!!', (envelope, response) ->
      assert.include response, 'help'
      done()
