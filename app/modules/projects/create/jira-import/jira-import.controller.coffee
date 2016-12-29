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
# File: jira-import.controller.coffee
###

class JiraImportController
    constructor: (@jiraImportService, @confirm, @translate, @projectUrl, @location) ->
        @.step = 'autorization-jira'
        @.project = null
        taiga.defineImmutableProperty @, 'projects', () => return @jiraImportService.projects
        taiga.defineImmutableProperty @, 'members', () => return @jiraImportService.projectUsers

         #@.step = 'project-members-jira'
        @.startProjectSelector()

    startProjectSelector: () ->
        @.step = 'project-select-jira'
        @jiraImportService.fetchProjects()

    onSelectProject: (project) ->
        @.step = 'project-form-jira'
        @.project = project

    onSaveProjectDetails: (project) ->
        @.project = project
        @.step = 'project-members-jira'

        @jiraImportService.fetchUsers(@.project.get('id'))

    onSelectUsers: (users) ->
        loader = @confirm.loader('sdfdsfdsfjk dfksj')

        loader.start()
        loader.update('', @translate.instant('PROJECT.IMPORT.IN_PROGRESS.TITLE'), @translate.instant('PROJECT.IMPORT.IN_PROGRESS.DESCRIPTION'))

        projectType = @.project.get('project_type')
        if projectType == "issues" and @.project.get('create_subissues')
            projectType = "issues-with-subissues"

        @jiraImportService.importProject(
            @.project.get('id'),
            users,
            @.project.get('keepExternalReference'),
            @.project.get('is_private'),
            projectType
        ).then (project) =>
            loader.stop()
            @location.url(@projectUrl.get(project))

        return null

angular.module('taigaProjects').controller('JiraImportCtrl', [
    'tgJiraImportService',
    '$tgConfirm',
    '$translate',
    '$projectUrl',
    '$location',
    JiraImportController])
