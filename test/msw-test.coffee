chai   = require 'chai'
helper = require './test-helper'
assert = chai.assert
nock   = require 'nock'

api = nock('https://api.github.com')

describe 'hubot msw', ->
  beforeEach (done) ->
    @robot = helper.robot()
    @user  = helper.testUser @robot
    @robot.adapter.on 'connected', ->
      @robot.loadFile  helper.SCRIPTS_PATH, 'msw.coffee'
      @robot.parseHelp "#{helper.SCRIPTS_PATH}/msw.coffee"
      done()
    @robot.run()

  afterEach ->
    @robot.shutdown()

  it 'should be included in /help', ->
    assert.include @robot.commands[0], 'msw'

  describe 'add', ->
    it 'should create a new issue with a defaut title', (done) ->
      api
        .post(
          '/repos/TailorDev/ModernScienceWeekly/issues',
          {
            title: 'New link from Slack',
            body: 'http://example.org\n\n---\nSlack URL: none',
            labels: [],
          }
        )
        .reply(201, { number: 123, html_url: 'issue-url' })

      helper.converse @robot, @user, '/msw add http://example.org', (_, response) ->
        assert.equal response, "I've opened the issue <issue-url|#123>."
        done()

    it 'should create a new issue with a custom title', (done) ->
      api
        .post(
          '/repos/TailorDev/ModernScienceWeekly/issues',
          {
            title: 'Example.org website',
            body: 'http://example.org\n\n---\nSlack URL: none',
            labels: [],
          }
        )
        .reply(201, { number: 123, html_url: 'issue-url' })

      helper.converse @robot, @user, '/msw add http://example.org Example.org website', (_, response) ->
        assert.equal response, "I've opened the issue <issue-url|#123>."
        done()

    it 'should create a new issue with a label', (done) ->
      api
        .post(
          '/repos/TailorDev/ModernScienceWeekly/issues',
          {
            title: 'Example.org website',
            body: 'http://example.org\n\n---\nSlack URL: none',
            labels: ['Open Science & Data'],
          }
        )
        .reply(201, { number: 123, html_url: 'issue-url' })

      helper.converse @robot, @user, '/msw add http://example.org Example.org website #open', (_, response) ->
        assert.equal response, "I've opened the issue <issue-url|#123>."
        done()

    it 'should deal with errors', (done) ->
      api
        .post(
          '/repos/TailorDev/ModernScienceWeekly/issues',
          {
            title: 'Example.org website',
            body: 'http://example.org\n\n---\nSlack URL: none',
            labels: [],
          }
        )
        .reply(404, { message: '404' })

      helper.converse @robot, @user, '/msw add http://example.org Example.org website', (_, response) ->
        assert.equal response, 'Looks like something went wrong... :confused:'
        done()

  describe 'list', ->
    results = [
      { title: 'Issue 1', html_url: 'issue-url-1', labels: [{ name: 'foo' }] },
      { title: 'OpenCitations', html_url: 'issue-url-2', labels: [{ name: 'Open Science & Data' }] },
      { title: 'Issue 123', html_url: 'issue-url-123', labels: [] },
      { title: 'Issue with a very very long title', html_url: 'issue-url-5', labels: [] },
    ]

    it 'should list the last 10 issues', (done) ->
      api
        .get('/repos/TailorDev/ModernScienceWeekly/issues?per_page=10')
        .reply(200, results)

      helper.converse @robot, @user, '/msw list', (_, response) ->
        assert.include response, "Here are the last #{results.length} issues I've found:"
        assert.include response, 'Issue with a very very long... - issue-url-5'
        done()

    it 'should tell us when there is no issue', (done) ->
      api
        .get('/repos/TailorDev/ModernScienceWeekly/issues?per_page=10')
        .reply(200, [])

      helper.converse @robot, @user, '/msw list', (_, response) ->
        assert.equal response, 'There is no issue mate.'
        done()

    it 'should list issues by category', (done) ->
      api
        .get('/repos/TailorDev/ModernScienceWeekly/issues?per_page=10&labels=Beyond%20Academia')
        .reply(200, [{ title: 'title', html_url: 'html_url', labels: [] }])

      helper.converse @robot, @user, '/msw list Beyond', (_, response) ->
        assert.include response, "Here is the only issue I've found:"
        done()

    it 'should list issues by category (2)', (done) ->
      api
        .get('/repos/TailorDev/ModernScienceWeekly/issues?per_page=10&labels=Open%20Science%20%26%20Data')
        .reply(200, [{ title: 'title', html_url: 'html_url', labels: [] }])

      helper.converse @robot, @user, '/msw list open', (_, response) ->
        assert.include response, "Here is the only issue I've found:"
        done()

  describe 'categories', ->
    it 'should return the available categories', (done) ->
      helper.converse @robot, @user, '/msw cat', (_, response) ->
        assert.include response, "Beyond Academia: beyond"
        done()

    it 'should return the available categories (2)', (done) ->
      helper.converse @robot, @user, '/msw categories', (_, response) ->
        assert.include response, "Beyond Academia: beyond"
        done()

  describe 'close', ->
    it 'should comment and close the given issues', (done) ->
      for n in [1, 2, 5]
        do (n) ->
          api
            .post(
              "/repos/TailorDev/ModernScienceWeekly/issues/#{n}/comments",
              { body: 'Added to MSW issue n°123.' }
            )
            .reply(201, { number: n, html_url: 'comment-url' })

          api
            .patch("/repos/TailorDev/ModernScienceWeekly/issues/#{n}")
            .reply(200, { title: n, html_url: 'html_url', labels: [] })

      helper.converse @robot, @user, '/msw 123 contains 1,2 5 a', (_, response) ->
        assert.include response, "done!"
        done()
