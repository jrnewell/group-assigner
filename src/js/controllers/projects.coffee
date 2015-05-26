'use strict'

ProjectsCtrl = ($scope, $timeout, ngDialog, storage, shared) ->

  $scope.shared = shared
  notify = shared.notify

  #shared.lastProject()

  $scope.delProject = (name) ->
    storage.deleteProject(name)

  $scope.loadProjectDiag = () ->
    isolate = $scope.$new(true)
    isolate.projectList = storage.projectList()

    promise = ngDialog.openConfirm
      template: "js/templates/dialogs/projects/loadProject.html"
      className: 'ngdialog-theme-default'
      scope: isolate

    promise.then (name) ->
      return unless name?
      console.log "projectName: #{name}"
      shared.loadProject name
      notify.success "Project #{name} Loaded"
      shared.projectName = name
      isolate.$destroy()
    , () ->
      isolate.$destroy()

  #TODO: switch to saveProjectDiag method?
  $scope.loadProjectDiag2 = () ->
    isolate = $scope.$new(true)
    isolate.projectList = storage.projectList()
    ngDialog.open
      template: "js/templates/dialogs/projects/loadProject.html"
      className: 'ngdialog-theme-default'
      scope: isolate

  $scope.loadProjectDiagSelected2 = (name) ->
    shared.loadProject name
    notify.success "Project #{name} Loaded"
    shared.projectName = name

  $scope.saveProjectDiag = () ->
    promise = ngDialog.openConfirm
      template: "js/templates/dialogs/projects/saveProject.html"
      className: 'ngdialog-theme-default'
      scope: $scope

    promise.then (name) ->
      return unless name?
      console.log "projectName: #{name}"
      shared.saveProject name
      notify.success "Project #{name} Saved"

  $scope.importProject = (data) ->
    try
      project = angular.fromJson(data)
      return unless project?
      $timeout () ->
        shared.students = project.students
        shared.roles = project.roles
        shared.simulations = project.simulations
        shared.assignments = project.assignments
        shared.projectName = (if project.projectName then project.projectName else null)
        shared.isCalculating = false
        $timeout () ->
          notify.success (if project.projectName then "Project '#{project.projectName}' Imported" else "Project Imported")
    catch ex
      $timeout () ->
        notify.failure "Problem Importing Project"

  $scope.exportProject = () ->
    project =
      students: shared.students
      roles: shared.roles
      simulations: shared.simulations
      assignments: shared.assignments
    project.projectName = shared.projectName if shared.projectName

    blob = new Blob([angular.toJson(project)], { type: "text/plain;charset=utf-8" })
    saveAs blob, (if project.projectName? then "#{project.projectName}.json" else "project.json")

  $scope.newProject = () ->
    isolate = $scope.$new(true)
    isolate.confirmText = "Do you want to clear the current project?"
    promise = ngDialog.openConfirm
      template: "js/templates/dialogs/common/confirm.html"
      className: 'ngdialog-theme-default'
      scope: isolate

    promise.then () ->
      shared.projectName = null
      shared.students = []
      shared.roles = []
      shared.simulations = []
      shared.assignments = null
      shared.isCalculating = false

      notify.success "New Project Created"
      isolate.$destroy()
    , () ->
      isolate.$destroy()


module.exports = ProjectsCtrl
