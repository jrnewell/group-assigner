'use strict'

AppCtrl = require "./controllers/app"
selecter = require "./directives/selecter"
iCheck = require "./directives/iCheck"
laddaButton = require "./directives/laddaButton"
fileInput = require "./directives/fileInput"
storage = require "./services/storage"

app = angular.module("GroupAssigner", ["ngAnimate", "ngDialog"])

app.controller "AppCtrl", ["$scope", "$timeout", "ngDialog", "storage", AppCtrl]

app.directive "selecter", ["$timeout", selecter]
app.directive "iCheck", ["$timeout", iCheck]
app.directive "laddaButton", [laddaButton]
app.directive "fileInput", ["$parse", fileInput]

app.factory "storage", [storage]

# move to service
toastr.options =
  closeButton: false
  debug: false
  positionClass: "toast-top-right"
  onclick: null
  showDuration: 500
  hideDuration: 500
  timeOut: 2000
  extendedTimeOut: 1000
  showEasing: "swing"
  hideEasing: "swing"
  showMethod: "fadeIn"
  hideMethod: "fadeOut"

$('input').iCheck()
