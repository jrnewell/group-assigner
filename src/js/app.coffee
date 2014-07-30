'use strict'

AppCtrl = require "./controllers/app"
selecter = require "./directives/selecter"

app = angular.module('MyProject', [])

app.controller "AppCtrl", ["$scope", "$timeout", AppCtrl]

app.directive "selecter", ["$timeout", selecter]

# $(document).ready () ->
#   $("select").selecter()
