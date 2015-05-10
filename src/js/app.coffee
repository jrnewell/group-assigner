'use strict'

AppCtrl = require "./controllers/app"
ProjectsCtrl = require "./controllers/projects"
AssignerCtrl = require "./controllers/assigner"
ResultsCtrl = require "./controllers/results"
SimulationsCtrl = require "./controllers/simulations"
StudentsCtrl = require "./controllers/students"
selecter = require "./directives/selecter"
iCheck = require "./directives/iCheck"
laddaButton = require "./directives/laddaButton"
fileInput = require "./directives/fileInput"
storage = require "./services/storage"
shared = require "./services/shared"

app = angular.module("GroupAssigner", ["ngRoute", "ngAnimate", "ngDialog"])

# routing
app.config ($routeProvider) ->
  $routeProvider
    .when "/",
      templateUrl: "js/templates/projects.html"
      controller: "ProjectsCtrl"
    .otherwise
      redirectTo: "/"

app.controller "AppCtrl", ["$scope", "$timeout", "shared", AppCtrl]
app.controller "ProjectsCtrl", ["$scope", "$timeout", "ngDialog", "storage", "shared", ProjectsCtrl]
app.controller "AssignerCtrl", ["$scope", "$timeout", "shared", AssignerCtrl]
app.controller "ResultsCtrl", ["$scope", "$timeout", "shared", ResultsCtrl]
app.controller "SimulationsCtrl", ["$scope", "$timeout", "ngDialog", "shared", SimulationsCtrl]
app.controller "StudentsCtrl", ["$scope", "$timeout", "shared", StudentsCtrl]

app.directive "selecter", ["$timeout", selecter]
app.directive "iCheck", ["$timeout", iCheck]
app.directive "laddaButton", [laddaButton]
app.directive "fileInput", ["$parse", fileInput]

app.factory "storage", [storage]
app.factory "shared", ["storage", shared]
