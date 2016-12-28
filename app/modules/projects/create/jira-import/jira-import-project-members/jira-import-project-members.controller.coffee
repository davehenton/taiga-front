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
# File: jira-import-project-members.controller.coffee
###

class JiraImportProjectMembersController
    @.$inject = [
        'tgJiraImportService'
    ]

    constructor: (@jiraImportService) ->
        @.selectImportUserLightbox = false
        @.warningImportUsers = false
        @.selectedUsers = Immutable.List()
        @.cancelledUsers = Immutable.List()

    searchUser: (user) ->
        @.selectImportUserLightbox = true
        @.searchingUser = user

    beforeSubmitUsers: () ->
        if @.selectedUsers.size != @.members.size
            @.warningImportUsers = true
        else
            @.submit()

    confirmUser: (jiraUser, taigaUser) ->
        @.selectImportUserLightbox = false

        user = Immutable.Map()

        user = user.set('jiraUser', jiraUser)
        user = user.set('taigaUser', taigaUser)

        @.selectedUsers = @.selectedUsers.push(user)

    cleanUser: (member) ->
        @.cancelledUsers = @.cancelledUsers.push(member.get('id'))

    getSelectedMember: (member) ->
        return @.selectedUsers.find (it) ->
            return it.getIn(['jiraUser', 'id']) == member.get('id')

    isMemberSelected: (member) ->
        return !!@.getSelectedMember(member)

    getUser: (user) ->
        userSelected = @.getSelectedMember(user)

        if userSelected
            return userSelected.get('taigaUser')

        if !userSelected
            return user.get('user')

        return null

    submit: () ->
        users = Immutable.Map()

        @.selectedUsers.map (it) ->
            users = users.set(it.getIn(['jiraUser', 'id']), it.getIn(['taigaUser', 'id']))

        @.onSubmit({users: users})

angular.module('taigaProjects').controller('JiraImportProjectMembersCtrl', JiraImportProjectMembersController)
