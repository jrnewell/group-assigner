'use strict'

fileInput = ($parse) ->
  return {
    restrict: "A"
    template: "<input type='file' class='hidden' /><div ng-transclude></div>"
    transclude: true
    scope: {
      onFileLoad: "&"
    }

    link: (scope, element, attrs) ->
      inputEl = $(element).children("input[type=file]")[0]
      _$inputEl = $(inputEl)
      _$element = $(element)

      _$inputEl.on "click", (ev) ->
        ev.stopPropagation()

      _$inputEl.on "change", (ev) ->
        file = inputEl.files[0]
        console.log "file choosen: " + file.name

        reader = new FileReader()
        reader.onloadend = (ev) ->
          scope.onFileLoad({data: this.result})

        reader.onerror = (err) ->
          console.error "FileReader Error: #{err}"

        reader.readAsText file

      _$element.on "click", (ev) ->
        ev.stopPropagation()
        inputEl.click()

      scope.$on "$destroy", () ->
        _$element.off()
        _$inputEl.off()
  }

module.exports = fileInput
