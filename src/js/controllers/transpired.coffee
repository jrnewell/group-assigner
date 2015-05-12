'use strict'

TranspiredCtrl = ($scope, $timeout, $location, $routeParams, ngDialog, shared) ->

  $scope.shared = shared
  notify = shared.notify

  $scope.simulationIsNotDone = () ->
    $scope.simulation.isDone = false

module.exports = TranspiredCtrl