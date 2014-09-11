'use strict'

ResultsCtrl = ($scope, $timeout, shared) ->

  $scope.shared = shared
  notify = shared.notify

  # TODO: to directive
  $scope.getGroupClass = (game, index) ->
    switch game.length
      when 2 then (if (index == 0) then ["col-md-5", "col-md-offset-1"] else "col-md-5")
      when 3 then "col-md-4"
      when 4 then "col-md-3"
      else "col-md-12"

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
            scope.assignments = data.assignments
            ladda.done()
            updateLastProject()
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
        notify.error "Error Encountered while Calculating"
      , 700
      console.error "Error: #{err.message}"
    , false)

    console.log "posting msg to worker"
    worker.postMessage
      cmd: "calculate"
      students: shared.students
      simulations: shared.simulations


  $scope.downloadAssigments = () ->
    console.log "downloadAssigments"
    str = ""

    for assignment in shared.assignments
      studentMap = {}
      for game, gameIdx in assignment.games
        for group, groupIdx in game
          for student in group
            studentMap[student.name] =
              gameIdx: gameIdx
              groupIdx: groupIdx
              role: student.role

      numGames = assignment.games.length
      str += "#{assignment.name}\n,"
      for i in [1..numGames]
        str += "#{i},"
      str += "\n"

      _.each _.keys(studentMap).sort(), (student) ->
        {gameIdx, groupIdx, role} = studentMap[student]
        str += "#{student}#{(if role then ' (' + role + ')' else '')},"
        str += ((if i == gameIdx then assignment.groupNames[groupIdx].name else null) for i in [0..(numGames-1)]).join ","
        str += "\n"

      str += "\n"

    console.log str

    blob = new Blob([str], { type: "text/plain;charset=utf-8" })
    saveAs blob, "assignments.csv"


module.exports = ResultsCtrl
