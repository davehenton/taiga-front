###
# Copyright (C) 2014-2016 Taiga Agile LLC <taiga@taiga.io>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#
# File: import-project.controller.coffee
###

class ImportProjectController
    @.$inject = [
        'tgTrelloImportService',
        'tgJiraImportService',
        'tgGithubImportService',
        '$location',
        '$window',
    ]

    constructor: (@trelloService, @jiraService, @githubService, @location, @window) ->

    start: ->
        @.from = null
        trelloOauthToken = @location.search().oauth_verifier
        jiraOauthToken = @location.search().oauth_token
        githubOauthToken = @location.search().code
        token = @location.search().token

        if token
            # @.from = @location.search().from
            @.from = @location.search().from
            @.token = token

        if trelloOauthToken
            return @trelloService.authorize(trelloOauthToken).then (token) =>
                @location.search({from: "trello", token: token})

        if jiraOauthToken
            return @jiraService.authorize().then (data) =>
                @location.search({from: "jira", token: data.token, url: data.url})

        if githubOauthToken
            return @githubService.authorize(githubOauthToken).then (token) =>
                @location.search({from: "github", token: token})

    select: (from) ->
        if from == "trello"
            @trelloService.getAuthUrl().then (url) =>
                @window.open(url, "_self")
        else if from == "jira"
            @jiraService.getAuthUrl(@.jiraUrl).then (url) =>
                @window.open(url, "_self")
        else if from == "github"
            callbackUri = @location.absUrl()
            @githubService.getAuthUrl(callbackUri).then (url) =>
                @window.open(url, "_self")
        else
            @.from = from

    unfoldOptions: (options) ->
        @.unfoldedOptions = options

    onCancel: () ->
        @.from = null

angular.module("taigaProjects").controller("ImportProjectCtrl", ImportProjectController)
