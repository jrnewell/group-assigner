'use strict'

ProjectsCtrl = ($scope, $timeout, storage, shared) ->

  $scope.shared = shared
  notify = shared.notify

  shared.lastProject()

  $scope.delProject = (name) ->
    storage.deleteProject(name)

  $scope.loadProjectDiag = () ->
    isolate = $scope.$new(true)
    isolate.projectList = storage.projectList()
    ngDialog.open
      template: "js/templates/loadProject.html"
      className: 'ngdialog-theme-default'
      scope: isolate

  $scope.loadProjectDiagSelected = (name) ->
    loadProject name
    notify.success "Project #{name} Loaded"
    shared.projectName = name

  $scope.saveProjectDiag = () ->
    promise = ngDialog.openConfirm
      template: "js/templates/saveProject.html"
      className: 'ngdialog-theme-default'
      scope: $scope

    promise.then (data) ->
      return unless data?
      shared.projectName = data
      console.log "projectName: #{data}"
      saveProject data
      notify.success "Project #{data} Saved"

  $scope.importProject = (data) ->
    try
      project = angular.fromJson(data)
      return unless project?
      $timeout () ->
        shared.students = project.students
        shared.simulations = project.simulations
        shared.assignments = project.assignments
        shared.roles = project.roles
        shared.projectName = project.projectName if project.projectName
        $timeout () ->
          notify.success (if project.projectName then "Project '#{project.projectName}' Imported" else "Project Imported")
    catch ex
      $timeout () ->
        notify.error "Problem Importing Project"

  $scope.exportProject = () ->
    project =
      students: shared.students
      simulations: shared.simulations
      assignments: shared.assignments
      roles: shared.roles
    project.projectName = shared.projectName if shared.projectName

    blob = new Blob([angular.toJson(project)], { type: "text/plain;charset=utf-8" })
    saveAs blob, (if project.projectName? then "#{project.projectName}.json" else "project.json")

  $scope.newProject = () ->
    isolate = $scope.$new(true)
    isolate.confirmText = "Do you want to clear the current project?"
    promise = ngDialog.openConfirm
      template: "js/templates/confirm.html"
      className: 'ngdialog-theme-default'
      scope: isolate

    promise.then () ->
      shared.students = []
      shared.simulations = []
      shared.roles = []
      shared.assignments = null
      shared.isCalculating = false
      delete shared.projectName
      updateLastProject()
      notify.success "New Project Created"
      isolate.$destroy()
    , () ->
      isolate.$destroy()

  # TODO: put in different controller
  $scope.manageRolesDiag = () ->
    ngDialog.open
      template: "js/templates/manageRoles.html"
      className: 'ngdialog-theme-default'
      scope: $scope

  $scope.addRole = (newRoleName) ->
    return false if _.isEmpty(newRoleName) or _.contains(shared.roles, newRoleName)
    shared.roles.push newRoleName
    updateLastProject()
    return true

  $scope.delRole = (role) ->
    console.log "delRole: #{role}"
    shared.roles = _.without(shared.roles, role)
    updateLastProject()


module.exports = ProjectsCtrl
