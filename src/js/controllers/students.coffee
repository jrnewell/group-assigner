'use strict'

StudentsCtrl = ($scope, $timeout, shared) ->

  $scope.shared = shared
  notify = shared.notify

  $scope.addStudent = () ->
    return if _.isEmpty($scope.newStudent) or _.contains(shared.students, $scope.newStudent)
    console.log "addStudent: #{$scope.newStudent}"
    shared.students.push $scope.newStudent
    $scope.newStudent = ""
    updateLastProject()

  $scope.delStudent = (student) ->
    console.log "delStudent: #{student}"
    shared.students = _.without(shared.students, student)
    updateLastProject()

  $scope.addRole = () ->
    return if _.isEmpty($scope.newRole) or _.contains(shared.roles, $scope.newRole)
    console.log "addRole: #{$scope.newRole}"
    shared.roles.push $scope.newRole
    $scope.newRole = ""
    updateLastProject()

  $scope.delRole = (role) ->
    console.log "delRole: #{role}"
    shared.roles = _.without(shared.roles, role)
    updateLastProject()

module.exports = StudentsCtrl
