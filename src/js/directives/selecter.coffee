'use strict'

selecter = ($timeout) ->
  return {
    restrict: "A"
    scope:
      selecterVal: "="
      selecterChg: "&"
      selecterOpts: "="

    link: (scope, element, attrs) ->
      inputEl = $(element)
      opts =
        cover: true
        callback: (val, idx) ->
          return unless val?
          intVal = parseInt(val)
          console.log "selecter change: #{intVal}"
          return if intVal == scope.selecterVal

          # TODO: do I need these nested timeouts?
          $timeout () ->
            scope.selecterVal = intVal
            if attrs.selecterChg?
              $timeout () -> scope.selecterChg()

      scope.$watch "selecterVal", (newVal, oldVal) ->
        return unless scope.selecterVal?
        console.log "updating #{attrs.selecterVal}: #{scope.selecterVal}"
        inputEl.val(scope.selecterVal).trigger("change")

      if attrs.selecterOpts?
        scope.$watchCollection "selecterOpts", (obj, oldObj) ->
          return unless scope.selecterOpts?
          return if _.isEmpty(scope.selecterOpts) and attrs.selecterNoBlank
          inputEl.selecter("destroy") if obj != oldObj
          console.log "updating #{attrs.selecterOpts}: #{JSON.stringify(scope.selecterOpts)}"
          inputEl.empty()
          _.each scope.selecterOpts, (key, val) ->
            $opt = $("<option></option>").attr("value", val).text(key)
            inputEl.append $opt
          inputEl.selecter(opts)
          $timeout () ->
            inputEl.val(scope.selecterVal).trigger("change")
      else
        $(document).ready () ->
          inputEl.selecter(opts)

      scope.$on "$destroy", () ->
        inputEl.selecter("destroy")
        inputEl.off()
  }

module.exports = selecter