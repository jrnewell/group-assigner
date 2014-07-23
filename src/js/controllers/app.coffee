'use strict'

_ = require('lodash')

AppCtrl = ($scope, $timeout) ->
  $scope.message = "Hello World"

  $scope.students = ["testing"]
  $scope.simulations = [{name: "testing", max: 3}]
  $scope.newSimMax = "1"

  $scope.addStudent = () ->
    return if _.isEmpty($scope.newStudent) or _.contains($scope.students, $scope.newStudent)
    console.log "addStudent: #{$scope.newStudent}"
    $scope.students.push $scope.newStudent
    $scope.newStudent = ""

  $scope.delStudent = (student) ->
    console.log "delStudent: #{student}"
    $scope.students = _.without($scope.students, student)

  $scope.addSimulation = () ->
    return if _.isEmpty($scope.newSimName) or _.contains($scope.simulations, $scope.newSimName)
    newSimMax = parseInt($scope.newSimMax)
    return if newSimMax < 1 or newSimMax > 5
    console.log "addSimulation: #{$scope.newSimName} #{newSimMax}"
    $scope.simulations.push
      name: $scope.newSimName
      max: newSimMax
    $scope.newSimMax = "1"
    # shoud move to directive
    $timeout () ->
      $("#selector-simulator-max").val("1").trigger("change")
    $scope.newSimName = ""

  $scope.delSimulation = (simulation) ->
    console.log "delSimulation: #{simulation}"
    $scope.simulations = _.without($scope.simulations, simulation)

  $scope.assignToGroups = () ->
    target = document.getElementById("assignBtn")
    spinner = new Spinner().spin(target)
    #spinner = new Spinner().spin()
    #document.getElementById("assignBtn").appendChild(spinner.el)


module.exports = AppCtrl