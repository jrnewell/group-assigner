'use strict'

AppCtrl = require "./controllers/app"
selecter = require "./directives/selecter"
laddaButton = require "./directives/laddaButton"

app = angular.module("GroupAssigner", ["ngAnimate", "ngDialog"])

app.controller "AppCtrl", ["$scope", "$timeout", "ngDialog", AppCtrl]

app.directive "selecter", ["$timeout", selecter]
app.directive "laddaButton", [laddaButton]

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
