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
# File: jira-import-project-form.controller.coffee
###

class JiraImportProjectFormController
    @.$inject = [
        "tgCurrentUserService"
    ]

    constructor: (@currentUserService) ->
        @.canCreatePublicProjects = @currentUserService.canCreatePublicProjects()
        @.canCreatePrivateProjects = @currentUserService.canCreatePrivateProjects()

        @.projectForm = @.project.toJS()

        @.projectForm.is_private = false
        @.projectForm.keepExternalReference = false
        @.projectForm.project_type = "scrum"
        @.projectForm.create_subissues = true

    saveProjectDetails: (project) ->
        @.onSaveProjectDetails({project: Immutable.fromJS(project)})

angular.module('taigaProjects').controller('JiraImportProjectFormCtrl', JiraImportProjectFormController)
