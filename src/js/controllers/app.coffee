'use strict'

AppCtrl = ($scope, $timeout, ngDialog) ->

  $scope.assignments = [{"name":"My Simulation","groupSize":2,"minSize":2,"numGroups":2,"groupNames":[{"name":"Group 1"},{"name":"Group 2"}],"games":[[["C","F"],["D","E"]],[["G","B"],["A"]]]},{"name":"My Simulation2","groupSize":1,"minSize":2,"numGroups":2,"groupNames":[{"name":"Group 1"},{"name":"Group 2"}],"games":[[["D"],["F"]],[["C"],["B"]],[["G","A"],["E"]]]},{"name":"My Simulation3","groupSize":3,"minSize":2,"numGroups":2,"groupNames":[{"name":"Group 1"},{"name":"Group 2"}],"games":[[["G","C","B","F"],["D","A","E"]]]}]

  # $scope.students = (i.toString() for i in [1..30])
  # $scope.simulations = [
  #   {name: "My Simulation", groupSize: 2}, {name: "My Simulation2", groupSize: 2}, {name: "My Simulation3", groupSize: 3},
  #   {name: "My Simulation4", groupSize: 2}, {name: "My Simulation5", groupSize: 1}, {name: "My Simulation6", groupSize: 2},
  #   {name: "My Simulation7", groupSize: 2}, {name: "My Simulation8", groupSize: 2}, {name: "My Simulation9", groupSize: 2}]
  $scope.students = ["A", "B", "C", "D", "E", "F", "G"]
  $scope.simulations = [{name: "My Simulation", groupSize: 2, minSize: 2, numGroups: 2, groupNames: [{name: "Group 1"}, {name: "Group 2"}]}, {name: "My Simulation2", groupSize: 1, minSize: 2, numGroups: 2, groupNames: [{name: "Group 1"}, {name: "Group 2"}]}, {name: "My Simulation3", groupSize: 3, minSize: 2, numGroups: 2, groupNames: [{name: "Group 1"}, {name: "Group 2"}]}]

  numbers = [ "Zero", "One", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight", "Nine", "Ten", "Eleven", "Twelve", "Thirteen", "Fourteen", "Fifteen", "Sixteen", "Seventeen", "Eighteen", "Nineteen", "Twenty"]

  resetNewSim = () ->
    $scope.newSim =
      groupSize: 1
      minSize: 2
      minOptions:
        2: "Two"
        3: "Three"
        4: "Four"
      numGroups: 2
      groupNames: [
        {name: null}
        {name: null}
      ]
    $scope.newSimName = ""

  resetNewSim()

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

    {groupSize, minSize, numGroups, groupNames} = $scope.newSim
    minSize = numGroups if minSize < numGroups
    return if groupSize < 1 or groupSize > 5

    # populate unset group names
    resizeGroupNames()
    for groupName, index in groupNames
      groupNames.name = "Group #{index + 1}" unless groupName.name?

    console.log "addSimulation: #{$scope.newSimName} #{groupSize} #{minSize} #{numGroups}"
    $scope.simulations.push
      name: $scope.newSimName
      groupSize: numGroups
      minSize: minSize
      numGroups: numGroups
      groupNames: groupNames
    resetNewSim()

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

  $scope.changeMinSize = () ->
    {groupSize, minSize, numGroups} = $scope.newSim
    console.log "changeMinSize: #{groupSize} #{minSize} #{numGroups}"

    minBottom = numGroups
    minTop = (numGroups * groupSize)
    $scope.newSim.minOptions = _.reduce([minBottom..minTop], (obj, num) ->
        obj[num] = numbers[num]
        return obj
    , {})
    $scope.newSim.minSize = minBottom if minSize < minBottom
    $scope.newSim.minSize = minTop if minSize > minTop

  resizeGroupNames = () ->
    {numGroups, groupNames} = $scope.newSim
    return if numGroups == groupNames.length
    console.log "newSim.numGroups changed: #{numGroups}"
    if numGroups < groupNames.length
      $scope.newSim.groupNames = groupNames[0..(numGroups - 1)]
    else if numGroups > groupNames.length
      $scope.newSim.groupNames = groupNames.concat ({name: null} for i in [1..(numGroups - groupNames.length)])
    console.log JSON.stringify($scope.newSim.groupNames)

  $scope.$watch "newSim.numGroups", resizeGroupNames

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
          $scope.$apply (scope) ->
            scope.assignments = data.assignments
            scope.calculatingProgress = null
          l.stop()
          $timeout () ->
            toastr.success "Calculation Finished"
          , 500
        when "progress"
          l.setProgress data.progress
          $scope.$apply (scope) ->
            scope.calculatingProgress = "Calculating (#{Math.floor(data.progress * 100)}%)"
        else console.log "Unknown assigner command: #{JSON.stringify(data)}"
    , false)

    worker.addEventListener('error', (err) ->
      l.stop()
      $scope.$apply (scope) ->
        scope.calculatingProgress = null
      $timeout () ->
        toastr.error "Error Encountered while Calculating"
      , 500
      console.error "Error: #{err.message}"
    , false)

    console.log "posting msg to worker"
    worker.postMessage
      cmd: "calculate"
      students: $scope.students
      simulations: $scope.simulations

  $scope.giveNamesToGroups = () ->
    ngDialog.open
      template: "/js/templates/namesToGroups.html"
      className: 'ngdialog-theme-default'
      scope: $scope

  $scope.downloadAssigments = () ->
    console.log "downloadAssigments"
    csvInput = "testing"

    blob = new Blob([csvInput], { type: "text/plain;charset=utf-8" })
    saveAs blob, "results.txt"

module.exports = AppCtrl
