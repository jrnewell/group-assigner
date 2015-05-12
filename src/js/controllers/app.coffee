'use strict'

AppCtrl = ($scope, $timeout, $location, shared) ->

  $scope.shared = shared
  notify = shared.notify

  $scope.isActivePath = (page) ->
    current = $location.path().substring(1)
    return (if page is current or current.startsWith("#{page}/") then "active" else "")

module.exports = AppCtrl
