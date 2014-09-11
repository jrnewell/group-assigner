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

module.exports = StudentsCtrl
