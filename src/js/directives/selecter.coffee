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
          console.log "selecter change: #{val} #{intVal} #{scope.selecterVal} #{idx}"
          return if intVal == scope.selecterVal
          console.log "jim"
          #scope.$apply (scope) ->
          $timeout () ->
            scope.selecterVal = intVal
          #$timeout () ->
          #scope.$emit "testing"
            if attrs.selecterChg?
              $timeout () -> scope.selecterChg()

      scope.$watch "selecterVal", (newVal, oldVal) ->
        console.log "newVal, oldVal: #{newVal} #{oldVal}"
        return unless scope.selecterVal?
        console.log "updating #{attrs.selecterVal}: #{scope.selecterVal}"
        inputEl.val(scope.selecterVal).trigger("change")

      if attrs.selecterOpts?
        scope.$watchCollection "selecterOpts", (obj, oldObj) ->
          console.log "old, oldObj: #{JSON.stringify(obj)} #{JSON.stringify(oldObj)}"
          return unless scope.selecterOpts?
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
  }

module.exports = selecter