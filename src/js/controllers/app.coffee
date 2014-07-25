'use strict'

AppCtrl = ($scope, $timeout) ->
  $scope.assignments = [{"name":"My Simulation","groupSize":2,"minSize":2,"groups":[{"side1":["B","D"],"side2":["F","G"]},{"side1":["E","C"],"side2":["A"]}]},{"name":"My Simulation2","groupSize":1,"minSize":2,"groups":[{"side1":["C","F"],"side2":["D"]},{"side1":["B"],"side2":["G"]},{"side1":["A"],"side2":["E"]}]},{"name":"My Simulation3","groupSize":3,"minSize":2,"groups":[{"side1":["E","D","G","C"],"side2":["F","B","A"]}]}]

  # $scope.students = (i.toString() for i in [1..30])
  # $scope.simulations = [
  #   {name: "My Simulation", groupSize: 2}, {name: "My Simulation2", groupSize: 2}, {name: "My Simulation3", groupSize: 3},
  #   {name: "My Simulation4", groupSize: 2}, {name: "My Simulation5", groupSize: 1}, {name: "My Simulation6", groupSize: 2},
  #   {name: "My Simulation7", groupSize: 2}, {name: "My Simulation8", groupSize: 2}, {name: "My Simulation9", groupSize: 2}]
  $scope.students = ["A", "B", "C", "D", "E", "F", "G"]
  $scope.simulations = [{name: "My Simulation", groupSize: 2, minSize: 2}, {name: "My Simulation2", groupSize: 1, minSize: 2}, {name: "My Simulation3", groupSize: 3, minSize: 2}]
  $scope.newSimGroupSize = "1"
  $scope.newSimMin = "2"

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
    return if newSimGroupSize < 1 or newSimGroupSize > 5
    console.log "addSimulation: #{$scope.newSimName} #{newSimGroupSize} #{newSimMin}"
    $scope.simulations.push
      name: $scope.newSimName
      groupSize: newSimGroupSize
      minSize: newSimMin
    $scope.newSimGroupSize = "1"
    $scope.newSimMin = "2"
    # shoud move to directive
    $timeout () ->
      $("#selector-simulator-groupSize").val("1").trigger("change")
    $scope.newSimName = ""

  $scope.delSimulation = (simulation) ->
    console.log "delSimulation: #{simulation}"
    $scope.simulations = _.without($scope.simulations, simulation)

  $scope.assignToGroups = () ->
    console.log "assignToGroups"
    # shoud move to directive
    el = document.getElementById("assignBtn")
    l = Ladda.create(el)
    l.start()

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
          l.stop()
        when "progress"
          l.setProgress data.progress
        else console.log "Unknown assigner command: #{JSON.stringify(data)}"


    , false)

    console.log "posting msg to worker"
    worker.postMessage
      cmd: "calculate"
      students: $scope.students
      simulations: $scope.simulations

module.exports = AppCtrl