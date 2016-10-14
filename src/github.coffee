githubot = require 'githubot'

module.exports = (robot, options = {}) ->
  gh = githubot(robot, options)

  ###
  Add a new comment on a GitHub issue.
  ###
  gh.comment = (owner, repo, number, comment, cb) ->
    url = "/repos/#{owner}/#{repo}/issues/#{number}/comments"
    payload =
      body: comment

    # error handler
    @handleErrors (response) ->
      cb response

    @post url, payload, (c) ->
      cb c

  return gh
