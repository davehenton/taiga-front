###
# Copyright (C) 2014-2015 Taiga Agile LLC <taiga@taiga.io>
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
# File: jira-import.controller.spec.coffee
###

describe "JiraImportCtrl", ->
    $provide = null
    $controller = null
    mocks = {}

    _mockJiraImportService = ->
        mocks.jiraService = {
            fetchProjects: sinon.stub(),
            fetchUsers: sinon.stub(),
            importProject: sinon.stub()
        }

        $provide.value("tgJiraImportService", mocks.jiraService)

    _mockConfirm = ->
        mocks.confirm = {
            loader: sinon.stub()
        }

        $provide.value("$tgConfirm", mocks.confirm)

    _mockTranslate = ->
        mocks.translate = {
            instant: sinon.stub()
        }

        $provide.value("$translate", mocks.translate)

    _mockProjectUrl = ->
        mocks.projectUrl = {
            get: sinon.stub()
        }

        $provide.value("$projectUrl", mocks.projectUrl)

    _mockLocation = ->
        mocks.location = {
            url: sinon.stub()
        }

        $provide.value("$location", mocks.location)

    _mocks = ->
        module (_$provide_) ->
            $provide = _$provide_

            _mockJiraImportService()
            _mockConfirm()
            _mockTranslate()
            _mockProjectUrl()
            _mockLocation()

            return null

    _inject = ->
        inject (_$controller_) ->
            $controller = _$controller_

    _setup = ->
        _mocks()
        _inject()

    beforeEach ->
        module "taigaProjects"

        _setup()

    it "start project selector", () ->
        ctrl = $controller("JiraImportCtrl")
        ctrl.startProjectSelector()

        expect(ctrl.step).to.be.equal('project-select-jira')
        expect(mocks.jiraService.fetchProjects).have.been.called

    it "on select project reload projects", () ->
        project = Immutable.fromJS({
            id: 1,
            name: "project-name"
        })

        ctrl = $controller("JiraImportCtrl")
        ctrl.onSelectProject(project)

        expect(ctrl.step).to.be.equal('project-form-jira')
        expect(ctrl.project).to.be.equal(project)

    it "on save project details reload users", () ->
        project = Immutable.fromJS({
            id: 1,
            name: "project-name"
        })

        ctrl = $controller("JiraImportCtrl")
        ctrl.onSaveProjectDetails(project)

        expect(ctrl.step).to.be.equal('project-members-jira')
        expect(ctrl.project).to.be.equal(project)

        expect(mocks.jiraService.fetchUsers).have.been.called

    it "on select user init import", (done) ->
        users = Immutable.fromJS([
            {
                id: 0
            },
            {
                id: 1
            },
            {
                id: 2
            }
        ])

        loaderObj = {
            start: sinon.spy(),
            update: sinon.stub(),
            stop: sinon.spy()
        }

        projectResult = {
            id: 3,
            name: "name"
        }

        mocks.confirm.loader.returns(loaderObj)

        mocks.projectUrl.get.withArgs(projectResult).returns('project-url')

        ctrl = $controller("JiraImportCtrl")
        ctrl.project = Immutable.fromJS({
            id: 1,
            keepExternalReference: false
            is_private: true
        })


        mocks.jiraService.importProject.promise().resolve(projectResult)

        ctrl.startImport(users).then () ->
            expect(loaderObj.start).have.been.called
            expect(loaderObj.update).have.been.called
            expect(loaderObj.stop).have.been.called
            expect(mocks.location.url).have.been.calledWith('project-url')
            expect(mocks.jiraService.importProject).have.been.calledWith(1, users, false, true)

            done()
