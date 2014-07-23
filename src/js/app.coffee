'use strict'

AppCtrl = require "./controllers/app"

app = angular.module('MyProject', [])

app.controller "AppCtrl", ["$scope", "$timeout", AppCtrl]

$(document).ready () ->
  $("select").selecter()
