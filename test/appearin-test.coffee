chai   = require 'chai'
helper = require './test-helper'
assert = chai.assert
nock   = require 'nock'

describe 'hubot appearin', ->
  beforeEach (done) ->
    @robot = helper.robot()
    @user  = helper.testUser @robot
    @robot.adapter.on 'connected', ->
      @robot.loadFile  helper.SCRIPTS_PATH, 'appearin.coffee'
      @robot.parseHelp "#{helper.SCRIPTS_PATH}/appearin.coffee"
      done()
    @robot.run()

  afterEach ->
    @robot.shutdown()

  it 'should be included in /help', ->
    assert.include @robot.commands[0], 'appearin'

  it 'should return a link to appearin for the given room', (done) ->
    helper.converse @robot, @user, '/appearin tailordev', (envelope, response) ->
      assert.equal response, 'https://framatalk.org/tailordev'
      done()

  it 'should return a link to appearin with a random room', (done) ->
    nock('http://www.setgetgo.com')
      .get('/randomword/get.php')
      .reply(200, 'Foobar')

    helper.converse @robot, @user, '/appearin', (envelope, response) ->
      assert.equal response, 'https://framatalk.org/foobar'
      done()

  it 'should tell people when it is not possible to get a random room name', (done) ->
    nock('http://www.setgetgo.com')
      .get('/randomword/get.php')
      .replyWithError()

    helper.converse @robot, @user, '/appearin', (envelope, response) ->
      assert.equal response, 'Looks like I cannot come up with a random word today...'
      done()
