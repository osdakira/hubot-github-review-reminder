# hubot-github-review-reminder

[![CircleCI](https://circleci.com/gh/osdakira/hubot-github-review-reminder.svg?style=svg)](https://circleci.com/gh/osdakira/hubot-github-review-reminder)

Remind the assigned review of github

See [`src/github-review-reminder.coffee`](src/github-review-reminder.coffee) for full documentation.

## Installation

In hubot project repo, run:

`npm install hubot-github-review-reminder --save`

Then add **hubot-github-review-reminder** to your `external-scripts.json`:

```json
[
  "hubot-github-review-reminder"
]
```

If change the github name to the slack id, 
use https://github.com/osdakira/hubot-github-name-slack-id-map

## Sample Interaction

```
user1>> hubot pull-request reviewers
hubot>> Number awaiting review: reviewerGithubName:1
pull request title - commitGithubName: https://github.com/any_url
  reviewers: reviewerGithubName
```

## NPM Module

https://www.npmjs.com/package/hubot-github-review-reminder
