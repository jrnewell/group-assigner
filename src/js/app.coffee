'use strict'

AppCtrl = require "./controllers/app"
ProjectsCtrl = require "./controllers/projects"
ResultsCtrl = require "./controllers/results"
SimulationsCtrl = require "./controllers/simulations"
StudentsCtrl = require "./controllers/students"
selecter = require "./directives/selecter"
iCheck = require "./directives/iCheck"
laddaButton = require "./directives/laddaButton"
fileInput = require "./directives/fileInput"
storage = require "./services/storage"
shared = require "./services/shared"

app = angular.module("GroupAssigner", ["ngAnimate", "ngDialog"])

app.controller "AppCtrl", ["$scope", "$timeout", "shared", AppCtrl]
app.controller "ProjectsCtrl", ["$scope", "$timeout", "ngDialog", "storage", "shared", ProjectsCtrl]
app.controller "ResultsCtrl", ["$scope", "$timeout", "shared", ResultsCtrl]
app.controller "SimulationsCtrl", ["$scope", "$timeout", "ngDialog", "shared", SimulationsCtrl]
app.controller "StudentsCtrl", ["$scope", "$timeout", "shared", StudentsCtrl]

app.directive "selecter", ["$timeout", selecter]
app.directive "iCheck", ["$timeout", iCheck]
app.directive "laddaButton", [laddaButton]
app.directive "fileInput", ["$parse", fileInput]

app.factory "storage", [storage]
app.factory "shared", ["storage", shared]
