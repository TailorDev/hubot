# Description:
#   A hubot script to manage the ModernScienceWeekly newsletter.
#
# Dependencies:
#   None
#
# Configuration:
#   HUBOT_GITHUB_TOKEN
#   HUBOT_SLACK_TEAM
#
# Commands:
#   hubot msw add <link> <issue title> #<category> - Create a new issue in the MSW repo.
#   hubot msw list <category> - List the last MSW issues (limit = 10).
#   hubot msw categories - List the available categories and their shortcuts.
#
# Author:
#   William Durand

githubot = require 'githubot'
utils = require '../src/utils'
slack = require '../src/slack'

slackTeam  = process.env.HUBOT_SLACK_TEAM ? 'tailordev'
repository = 'TailorDev/ModernScienceWeekly'

module.exports = (robot) ->
  gh = githubot(robot)
  endpoint = "/repos/#{repository}/issues"

  categories = [
    {
      name: 'Open Science & Data',
      alt: ['open', 'open science', 'open data', 'open science & data']
    },
    {
      name: 'Cutting-edge Science',
      alt: ['cutting', 'cutting edge', 'cutting-edge', 'cutting-edge science']
    },
    {
      name: 'Tools for Scientists',
      alt: ['tools', 'tools for scientists']
    },
    {
      name: 'Beyond Academia',
      alt: ['beyond', 'beyond academia']
    }
  ]

  getLabel = (str) ->
    str = str.toLowerCase().trim()
    for c in categories
      if str in c.alt
        return c.name
    return ''

  ###
  Create a new issue given a link (required), a title and a label
  ###
  createIssue = (title, content, label, cb) ->
    payload =
      title: title
      body: content
      labels: if label then [label] else []

    # error handler
    gh.handleErrors (response) ->
      cb response

    gh.post endpoint, payload, (issue) ->
      cb issue

  ###
  ###
  getIssues = (label, limit, cb) ->
    # error handler
    gh.handleErrors (response) ->
      cb response

    url = "#{endpoint}?per_page=#{limit}"
    if label
      url = "#{url}&labels=#{encodeURIComponent(label)}"

    gh.get url, (issues) ->
      cb issues

  ###
  Listeners
  ###

  robot.respond /msw add (https?:\/\/[^\s]+)(\s([^#]+))?(#(.+))?/i, (msg) ->
    link  = msg.match[1]
    title = if msg.match[3] then msg.match[3].trim() else 'New link from Slack'
    label = if msg.match[5] then getLabel msg.match[5] else ''

    permalink = 'none'
    if robot.adapterName is "slack"
      channel = utils.getRoomName robot, msg.message
      permalink = slack.getPermalink slackTeam, channel, msg.message.id

    content = "#{link}\n\n---\nSlack URL: #{permalink}"

    createIssue title, content, label, (response) ->
      if response.error
        reply = 'Looks like something went wrong... :confused:'
      else
        reply = "I've opened the issue <#{response.html_url}|##{response.number}>."

      msg.reply reply

  robot.respond /msw list(\s(.+))?/i, (msg) ->
    label = if msg.match[2] then getLabel msg.match[2] else ''

    formatTitle = (title) ->
      if title.length > 30
        title = "#{title.substr 0, 27}..."
      return title

    formatLabels = (labels) ->
      s = []
      labels.map (l) ->
        s.push l.name
      if s.length > 0
        return "[#{s.join ', '}]"
      return ''

    getIssues label, 10, (response) ->
      if response.error
        reply = 'Looks like something went wrong... :confused:'
      else
        issues = response
        count = issues.length
        if count is 0
          reply = "There is no issue mate."
        else
          if count is 1
            reply = ["Here is the only issue I've found:", ""]
          else
            reply = ["Here are the last #{count} issues I've found:", ""]

          issues.map (i) ->
            reply.push "#{formatTitle i.title} - #{i.html_url} #{formatLabels i.labels}"
          reply = reply.join "\n"

      msg.reply reply

  robot.respond /msw cat(egories)?/i, (msg) ->
    reply = []
    for c in categories
      reply.push "#{c.name}: #{c.alt.join ', '}"

    msg.reply reply.join "\n"
