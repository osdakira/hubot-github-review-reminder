Helper = require('hubot-test-helper')
chai = require 'chai'

expect = chai.expect

helper = new Helper('../src/github-review-reminder.coffee')

describe 'github-review-reminder', ->
  beforeEach ->
    updated_at = new Date().toISOString()
    @room = helper.createRoom()
    @room.robot.github.get = (url, callback) ->
      callback([
        {
          title: "pull request title",
          user: { login: "commitGithubName" },
          requested_reviewers: [ login: "reviewerGithubName" ],
          html_url: "https://github.com/any_url",
          updated_at: "2018-06-25T00:00:00Z"
        }
      ])

  afterEach ->
    @room.destroy()

  it 'hears hubot pull-request reviewers', ->
    @room.user.say('bob', 'hubot pull-request reviewers').then =>
      expect(@room.messages).to.eql [
        ['bob', 'hubot pull-request reviewers']
        ['hubot', "Number awaiting review: reviewerGithubName:1\n\npull request title - commitGithubName: https://github.com/any_url\n\treviewers: reviewerGithubName\tLastUpdate: 2018-06-25"]
      ]

  it 'Can response with reminder hubot pull-request reviewers', ->
    @room.user.say('bob', 'Reminder: hubot pull-request reviewers.').then =>
      expect(@room.messages).to.eql [
        ['bob', 'Reminder: hubot pull-request reviewers.']
        ['hubot', "Number awaiting review: reviewerGithubName:1\n\npull request title - commitGithubName: https://github.com/any_url\n\treviewers: reviewerGithubName\tLastUpdate: 2018-06-25"]
      ]

  it 'convert to slack mention', ->
    key = process.env.HUBOT_GITHUB_TO_SLACK_NAME_MAP_KEY
    @room.robot.brain.set(key, { reviewerGithubName: { slackName: "slackId" } })

    @room.user.say('bob', 'hubot pull-request reviewers').then =>
      expect(@room.messages).to.eql [
        ['bob', 'hubot pull-request reviewers']
        ['hubot', "Number awaiting review: <@slackId>:1\n\npull request title - commitGithubName: https://github.com/any_url\n\treviewers: <@slackId>\tLastUpdate: 2018-06-25"]
      ]

  it 'After three days, it will fire', ->
    FOUR_DAYS = (1000 * 60 * 60 * 24 * 4)
    updated_at = new Date(new Date().getTime() - FOUR_DAYS).toISOString()
    updatedDate = updated_at.replace(/T.*/, "")
    @room.robot.github.get = (url, callback) ->
      callback([
        {
          title: "pull request title",
          user: { login: "commitGithubName" },
          requested_reviewers: [ login: "reviewerGithubName" ],
          html_url: "https://github.com/any_url",
          updated_at: updated_at
        }
      ])
    @room.user.say('bob', 'hubot pull-request reviewers').then =>
      expect(@room.messages).to.eql [
        ['bob', 'hubot pull-request reviewers']
        ['hubot', "Number awaiting review: reviewerGithubName:1\n\npull request title - commitGithubName: https://github.com/any_url\n\treviewers: reviewerGithubName\tLastUpdate: #{updatedDate}:fire:"]
      ]
