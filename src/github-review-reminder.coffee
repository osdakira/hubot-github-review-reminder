# Description
#   Remind the assigned review of github
#
# Configuration:
#   HUBOT_GITHUB_TOKEN
#   HUBOT_SLACK_TOKEN
#   HUBOT_GITHUB_REPO
#   HUBOT_GITHUB_TO_SLACK_NAME_MAP_KEY
#   HUBOT_GITHUB_REVIEW_REMINDER_ALLOWABLE_NUMBER_OF_DAYS
#
# Commands:
#   hubot pull-request reviewers
#   pull-request reviewers
#
# Author:
#   Akira Osada <osd.akira@gmail.com>

module.exports = (robot) ->
  ONE_DAY = 1000 * 60 * 60 * 24
  ALLOWABLE_NUMBER_OF_DAYS =
    process.env.HUBOT_GITHUB_REVIEW_REMINDER_ALLOWABLE_NUMBER_OF_DAYS ||  3
  _ = require("lodash")
  github = require("githubot")(robot)
  robot.github = github if robot.constructor.name is "MockRobot" # For Test

  urlApiBase = process.env.HUBOT_GITHUB_API || "https://api.github.com"
  repo = process.env.HUBOT_GITHUB_REPO

  regex = new RegExp("#{robot.name} pull-request reviewers\.?$", 'i')
  robot.hear regex, (res) ->
    github.get "#{urlApiBase}/repos/#{repo}/pulls", (pulls) ->
      return res.send "No assigned reviews" if pulls.length == 0

      summaries = _makeSummaries(pulls)
      reviewerCounts = _makeReviewCounts(pulls)
      reviewerCountsStrs = _(reviewerCounts).map (val, key) -> "#{key}:#{val}"

      message = [
        "Number awaiting review: " + reviewerCountsStrs.join(", ")
        "",
        _(summaries).compact().join("\n"),
      ].join("\n")

      res.send message

  _makeSummaries = (pulls) ->
    githubSlackMap = _fetchGithubSlackMap()
    today = new Date()
    pulls.map (pull) ->
      reviewers = pull.requested_reviewers.map (x) ->
        _convertMention(x.login, githubSlackMap)
      return if reviewers.length == 0

      elapsedDays = _getElapsedDays(today, new Date(pull.updated_at))
      fires = _.times(elapsedDays - ALLOWABLE_NUMBER_OF_DAYS, -> ":fire:").join("")
      [
        "#{pull.title} - #{pull.user.login}: #{pull.html_url}",
        "\t#{fires}reviewers: " + reviewers.join(",") + fires,
      ].join("\n")

  _getElapsedDays = (today, updated_at) ->
    diffMSec = today.getTime() - updated_at.getTime()
    Math.floor(diffMSec / ONE_DAY)

  _makeReviewCounts = (pulls) ->
    githubSlackMap = _fetchGithubSlackMap()
    reviewers = pulls.map (pull) ->
      pull.requested_reviewers.map (x) ->
        _convertMention(x.login, githubSlackMap)
    _(reviewers).flatten().compact().countBy().value()

  _fetchGithubSlackMap = ->
    key = process.env.HUBOT_GITHUB_TO_SLACK_NAME_MAP_KEY
    robot.brain.get(key) ? {}

  _convertMention = (githubName, githubSlackMap) ->
    slackIdByName = githubSlackMap[githubName]
    return githubName unless slackIdByName

    slackName = Object.keys(slackIdByName)[0]
    slackId = slackIdByName[slackName]
    "<@#{slackId}>"
