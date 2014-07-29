'use strict'

AppCtrl = ($scope, $timeout) ->

  $scope.assignments = [{"name":"My Simulation","groupSize":2,"minSize":2,"numGroups":2,"games":[[["F","A"],["D","G"]],[["B","C"],["E"]]]},{"name":"My Simulation2","groupSize":1,"minSize":2,"numGroups":2,"games":[[["A"],["C"]],[["E"],["G"]],[["F","B"],["D"]]]},{"name":"My Simulation3","groupSize":3,"minSize":2,"numGroups":2,"games":[[["G","B","F","C"],["D","A","E"]]]}]

  # $scope.students = (i.toString() for i in [1..30])
  # $scope.simulations = [
  #   {name: "My Simulation", groupSize: 2}, {name: "My Simulation2", groupSize: 2}, {name: "My Simulation3", groupSize: 3},
  #   {name: "My Simulation4", groupSize: 2}, {name: "My Simulation5", groupSize: 1}, {name: "My Simulation6", groupSize: 2},
  #   {name: "My Simulation7", groupSize: 2}, {name: "My Simulation8", groupSize: 2}, {name: "My Simulation9", groupSize: 2}]
  $scope.students = ["A", "B", "C", "D", "E", "F", "G"]
  $scope.simulations = [{name: "My Simulation", groupSize: 2, minSize: 2, numGroups: 2}, {name: "My Simulation2", groupSize: 1, minSize: 2, numGroups: 2}, {name: "My Simulation3", groupSize: 3, minSize: 2, numGroups: 2}]
  $scope.newSimGroupSize = "1"
  $scope.newSimMin = "2"
  $scope.newSimNumGroups = "2"

  $scope.addStudent = () ->
    return if _.isEmpty($scope.newStudent) or _.contains($scope.students, $scope.newStudent)
    console.log "addStudent: #{$scope.newStudent}"
    $scope.students.push $scope.newStudent
    $scope.newStudent = ""

  $scope.delStudent = (student) ->
    console.log "delStudent: #{student}"
    $scope.students = _.without($scope.students, student)

  $scope.addSimulation = () ->
    return if _.isEmpty($scope.newSimName) or _.contains($scope.simulations, $scope.newSimName)
    newSimGroupSize = parseInt($scope.newSimGroupSize)
    newSimMin = parseInt($scope.newSimMin)
    newSimNumGroups = parseInt($scope.newSimNumGroups)
    newSimMin = newSimNumGroups if newSimMin < newSimNumGroups
    return if newSimGroupSize < 1 or newSimGroupSize > 5
    console.log "addSimulation: #{$scope.newSimName} #{newSimGroupSize} #{newSimMin}"
    $scope.simulations.push
      name: $scope.newSimName
      groupSize: newSimGroupSize
      minSize: newSimMin
      numGroups: newSimNumGroups
    $scope.newSimGroupSize = "1"
    $scope.newSimMin = "2"
    $scope.newSimNumGroups = "2"
    # shoud move to directive
    $timeout () ->
      $("#selector-simulator-groupSize").val("1").trigger("change")
    $scope.newSimName = ""

  $scope.delSimulation = (simulation) ->
    console.log "delSimulation: #{simulation}"
    $scope.simulations = _.without($scope.simulations, simulation)

  # to directive?
  $scope.getGroupClass = (game, index) ->
    switch game.length
      when 2 then (if (index == 0) then ["col-md-5", "col-md-offset-1"] else "col-md-5")
      when 3 then "col-md-4"
      when 4 then "col-md-3"
      else "col-md-12"

  $scope.assignToGroups = () ->
    console.log "assignToGroups"
    # shoud move to directive
    el = document.getElementById("assignBtn")
    l = Ladda.create(el)
    l.start()

    $scope.calculatingProgress = "Calculating (0%)"

    # use web worker
    worker = new Worker("/js/workers/assigner.js")
    worker.addEventListener('message', (ev) ->
      data = ev.data
      switch data.cmd
        when "assignments"
          console.log "Recieved msg from web worker"
          console.log JSON.stringify(data.assignments)
          #$scope.assignments = JSON.stringify(data.assignments)
          $scope.$apply (scope) ->
            scope.assignments = data.assignments
            scope.calculatingProgress = null
          l.stop()
        when "progress"
          l.setProgress data.progress
          $scope.$apply (scope) ->
            scope.calculatingProgress = "Calculating (#{Math.floor(data.progress * 100)}%)"
        else console.log "Unknown assigner command: #{JSON.stringify(data)}"
    , false)

    worker.addEventListener('error', (err) ->
      l.stop()
      $scope.$apply (scope) ->
        scope.calculatingProgress = "Error Calculating"
      console.error "Error: #{err.message}"
    , false)

    console.log "posting msg to worker"
    worker.postMessage
      cmd: "calculate"
      students: $scope.students
      simulations: $scope.simulations

module.exports = AppCtrl