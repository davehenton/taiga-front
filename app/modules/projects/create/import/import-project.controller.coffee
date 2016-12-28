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
        '$location',
        '$window',
    ]

    constructor: (@trelloService, @jiraService, @location, @window) ->

    start: ->
        @.from = null
        verifyCode = @location.search().oauth_verifier
        jiraOauthToken = @location.search().oauth_token
        token = @location.search().token
        jiraToken = @location.search().jiraToken

        if token
            # @.from = @location.search().from
            @.from = @location.search().from
            @.token = token

        if verifyCode
            return @trelloService.authorize(verifyCode).then (token) =>
                @location.search({from: "trello", token: token})

        if jiraOauthToken
            @jiraService.authorize().then (data) =>
                @location.search({from: "jira", token: data.token, url: data.url})

    select: (from) ->
        if from == "trello"
            @trelloService.getAuthUrl().then (url) =>
                @window.open(url, "_self")
        else if from == "jira"
            @jiraService.getAuthUrl(@.jiraUrl).then (url) =>
                @window.open(url, "_self")
        else
            @.from = from

    unfoldOptions: (options) ->
        @.unfoldedOptions = options

    onCancel: () ->
        @.from = null

angular.module("taigaProjects").controller("ImportProjectCtrl", ImportProjectController)
