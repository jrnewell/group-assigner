'use strict'

AssignerCtrl = ($scope, $timeout, shared) ->

  $scope.shared = shared
  notify = shared.notify

  $scope.assignToGroups = (ev, ladda) ->
    console.log "assignToGroups"

    shared.isCalculating = true
    $scope.calculatingProgress = "Calculating (0%)"

    # use web worker
    worker = new Worker("js/workers/assigner.js")
    worker.addEventListener('message', (ev) ->
      data = ev.data
      switch data.cmd
        when "assignments"
          console.log "Recieved msg from web worker"
          console.log JSON.stringify(data.assignments)
          $scope.$apply (scope) ->
            shared.assignments = data.assignments
            ladda.done()
            #updateLastProject()
            shared.isCalculating = false

          $timeout () ->
            notify.success "Calculation Finished"
          , 700
        when "progress"
          ladda.progress data.progress
          $scope.$apply (scope) ->
            scope.calculatingProgress = "Calculating (#{Math.floor(data.progress * 100)}%)"
        else console.log "Unknown assigner command: #{JSON.stringify(data)}"
    , false)

    worker.addEventListener('error', (err) ->
      ladda.done()
      shared.isCalculating = false
      $timeout () ->
        notify.failure "Error Encountered while Calculating"
      , 700
      console.error "Error: #{err.message}"
    , false)

    console.log "posting msg to worker"
    console.dir shared.simulations
    worker.postMessage
      cmd: "calculate"
      students: shared.students
      simulations: shared.simulations

module.exports = AssignerCtrl
