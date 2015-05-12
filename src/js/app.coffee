'use strict'

AppCtrl = require "./controllers/app"
ProjectsCtrl = require "./controllers/projects"
AssignerCtrl = require "./controllers/assigner"
AssignRolesCtrl = require "./controllers/assignRoles"
ResultsCtrl = require "./controllers/results"
SimulationsCtrl = require "./controllers/simulations"
StudentsCtrl = require "./controllers/students"
TranspiredCtrl = require "./controllers/transpired"
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
    .when "/project",
      templateUrl: "js/templates/project.html"
      controller: "ProjectsCtrl"
    .when "/students",
      templateUrl: "js/templates/students.html"
      controller: "StudentsCtrl"
    .when "/simulations/:simId?",
      templateUrl: "js/templates/simulations.html"
      controller: "SimulationsCtrl"
    .otherwise
      redirectTo: "/project"

app.controller "AppCtrl", ["$scope", "$timeout", "$location", "shared", AppCtrl]
app.controller "ProjectsCtrl", ["$scope", "$timeout", "ngDialog", "storage", "shared", ProjectsCtrl]
app.controller "AssignerCtrl", ["$scope", "$timeout", "shared", AssignerCtrl]
app.controller "AssignRolesCtrl", ["$scope", "$timeout", "ngDialog", "shared", AssignRolesCtrl]
app.controller "ResultsCtrl", ["$scope", "$timeout", "shared", ResultsCtrl]
app.controller "SimulationsCtrl", ["$scope", "$timeout", "$location", "$routeParams", "ngDialog", "shared", SimulationsCtrl]
app.controller "StudentsCtrl", ["$scope", "$timeout", "shared", StudentsCtrl]
app.controller "TranspiredCtrl", ["$scope", "$timeout", "$location", "$routeParams", "ngDialog", "shared", TranspiredCtrl]

app.directive "selecter", ["$timeout", selecter]
app.directive "iCheck", ["$timeout", iCheck]
app.directive "laddaButton", [laddaButton]
app.directive "fileInput", ["$parse", fileInput]

app.factory "storage", [storage]
app.factory "shared", ["storage", shared]

# simple filters
app.filter "escape", () ->
    window.encodeURIComponent
