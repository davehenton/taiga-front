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
# File: github-import.service.coffee
###

class GithubImportService extends taiga.Service
    @.$inject = [
        'tgResources',
        '$location'
    ]

    constructor: (@resources, @location) ->
        @.projects = Immutable.List()
        @.projectUsers = Immutable.List()
        @.token = @location.search().token

    fetchProjects: () ->
        @resources.githubImporter.listProjects(@.token).then (projects) => @.projects = projects

    fetchUsers: (projectId) ->
        @resources.githubImporter.listUsers(@.token, projectId).then (users) => @.projectUsers = users

    importProject: (projectId, userBindings, keepExternalReference, isPrivate) ->
        return new Promise (resolve) =>
            @resources.githubImporter.importProject(@.token, projectId, userBindings, keepExternalReference, isPrivate).then (response) =>
                @.importedProject = Immutable.fromJS(response.data)
                resolve(@.importedProject)

    getAuthUrl: (callbackUri) ->
        return new Promise (resolve) =>
            console.log(@resources)
            @resources.githubImporter.getAuthUrl(callbackUri).then (response) =>
                @.authUrl = response.data.url
                resolve(@.authUrl)

    authorize: (code) ->
        return new Promise (resolve) =>
            @resources.githubImporter.authorize(code).then (response) =>
                @.token = response.data.token
                resolve(@.token)

angular.module("taigaProjects").service("tgGithubImportService", GithubImportService)
