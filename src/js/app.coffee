'use strict'

AppCtrl = require "./controllers/app"
selecter = require "./directives/selecter"

app = angular.module("GroupAssigner", ["ngDialog"])

app.controller "AppCtrl", ["$scope", "$timeout", "ngDialog", AppCtrl]

app.directive "selecter", ["$timeout", selecter]
