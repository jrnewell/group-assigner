'use strict'

AppCtrl = require "./controllers/app"
selecter = require "./directives/selecter"
iCheck = require "./directives/iCheck"
laddaButton = require "./directives/laddaButton"
fileInput = require "./directives/fileInput"
storage = require "./services/storage"
shared = require "./services/shared"

app = angular.module("GroupAssigner", ["ngAnimate", "ngDialog"])

app.controller "AppCtrl", ["$scope", "$timeout", "ngDialog", "storage", "shared", AppCtrl]

app.directive "selecter", ["$timeout", selecter]
app.directive "iCheck", ["$timeout", iCheck]
app.directive "laddaButton", [laddaButton]
app.directive "fileInput", ["$parse", fileInput]

app.factory "storage", [storage]
app.factory "shared", [shared]
