'use strict'

laddaButton = () ->
  return {
    restrict: "E"
    replace: true
    transclude: true
    scope: {
      laddaClick: "&"
    }
    template: "<button class='ladda-button btn btn-block' data-color='{{laddaOpts.color}}' data-mode='{{laddaOpts.mode}}'><span class='ladda-label'></span></button>"

    link: (scope, element, attrs) ->
      scope.laddaOpts = $.extend({}, scope.$eval(attrs.laddaOpts))
      inputEl = $(element)
      ladda = Ladda.create(element[0])

      laddaApi =
        done: () -> ladda.stop()
        progress: (pct) -> ladda.setProgress pct

      inputEl.on 'click', (event) ->
        ladda.start()
        scope.laddaClick {event: event, ladda: laddaApi}
  }

module.exports = laddaButton
