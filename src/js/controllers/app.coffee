'use strict'

AppCtrl = ($scope, $timeout, ngDialog, storage, shared) ->

  $scope.shared = shared
  notify = shared.notify

module.exports = AppCtrl
