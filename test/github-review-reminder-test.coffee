Helper = require('hubot-test-helper')
chai = require 'chai'

expect = chai.expect

helper = new Helper('../src/github-review-reminder.coffee')

describe 'github-review-reminder', ->
  beforeEach ->
    @room = helper.createRoom()
    @room.robot.github.get = (url, callback) ->
      callback([
        {
          title: "pull request title",
          user: { login: "commitGithubName" },
          requested_reviewers: [ login: "reviewerGithubName" ],
          html_url: "https://github.com/any_url"
        }
      ])

  afterEach ->
    @room.destroy()

  it 'hears hubot pull-request reviewers', ->
    @room.user.say('bob', 'hubot pull-request reviewers').then =>
      expect(@room.messages).to.eql [
        ['bob', 'hubot pull-request reviewers']
        ['hubot', "Number awaiting review: reviewerGithubName:1\n\npull request title - commitGithubName: https://github.com/any_url\n\treviewers: reviewerGithubName"]
      ]

  it 'Can response with reminder hubot pull-request reviewers', ->
    @room.user.say('bob', 'Reminder: hubot pull-request reviewers.').then =>
      expect(@room.messages).to.eql [
        ['bob', 'Reminder: hubot pull-request reviewers.']
        ['hubot', "Number awaiting review: reviewerGithubName:1\n\npull request title - commitGithubName: https://github.com/any_url\n\treviewers: reviewerGithubName"]
      ]

  it 'convert to slack mention', ->
    key = process.env.HUBOT_GITHUB_TO_SLACK_NAME_MAP_KEY
    @room.robot.brain.set(key, { reviewerGithubName: { slackName: "slackId" } })

    @room.user.say('bob', 'hubot pull-request reviewers').then =>
      expect(@room.messages).to.eql [
        ['bob', 'hubot pull-request reviewers']
        ['hubot', "Number awaiting review: <@slackId>:1\n\npull request title - commitGithubName: https://github.com/any_url\n\treviewers: reviewerGithubName"]
      ]
