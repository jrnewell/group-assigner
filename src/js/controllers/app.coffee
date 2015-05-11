'use strict'

AppCtrl = ($scope, $timeout, $location, shared) ->

  $scope.shared = shared
  notify = shared.notify

  $scope.menuClass = (page) ->
    current = $location.path().substring(1)
    return (if page is current then "active" else "")

module.exports = AppCtrl
