'use strict'

AppCtrl = ($scope, $timeout, shared) ->

  $scope.shared = shared
  notify = shared.notify

module.exports = AppCtrl
