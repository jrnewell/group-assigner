'use strict'

iCheck = ($timeout) ->
  return {
    restrict: "A"
    scope:
      iCheckVal: "="

    link: (scope, element, attrs) ->
      inputEl = $(element)
      opts =
        checkboxClass: "icheckbox_flat"
        radioClass: "iradio_flat"

      inputEl.on "ifChecked", (ev) ->
        console.log "ifChecked: #{attrs.iCheckVal}: true"
        $timeout () ->
          scope.iCheckVal = true

      inputEl.on "ifUnchecked", (ev) ->
        console.log "ifUnchecked: #{attrs.iCheckVal}: false"
        $timeout () ->
          scope.iCheckVal = false

      scope.$watch "iCheckVal", (newVal, oldVal) ->
        console.log "updating #{attrs.iCheckVal}: #{scope.iCheckVal}"
        inputEl.iCheck(if scope.iCheckVal then "check" else "uncheck")

      $(document).ready () ->
        inputEl.iCheck(opts)
  }

module.exports = iCheck