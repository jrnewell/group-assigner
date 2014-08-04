'use strict'

AppCtrl = ($scope, $timeout, ngDialog, storage) ->

  $scope.assignments = [{"name":"My Simulation","groupSize":2,"minSize":2,"numGroups":2,"groupNames":[{"name":"Group 1"},{"name":"Group 2"}],"games":[[["C","F"],["D","E"]],[["G","B"],["A"]]]},{"name":"My Simulation2","groupSize":1,"minSize":2,"numGroups":2,"groupNames":[{"name":"Group 1"},{"name":"Group 2"}],"games":[[["D"],["F"]],[["C"],["B"]],[["G","A"],["E"]]]},{"name":"My Simulation3","groupSize":3,"minSize":2,"numGroups":2,"groupNames":[{"name":"Group 1"},{"name":"Group 2"}],"games":[[["G","C","B","F"],["D","A","E"]]]}]

  # $scope.students = (i.toString() for i in [1..30])
  # $scope.simulations = [
  #   {name: "My Simulation", groupSize: 2}, {name: "My Simulation2", groupSize: 2}, {name: "My Simulation3", groupSize: 3},
  #   {name: "My Simulation4", groupSize: 2}, {name: "My Simulation5", groupSize: 1}, {name: "My Simulation6", groupSize: 2},
  #   {name: "My Simulation7", groupSize: 2}, {name: "My Simulation8", groupSize: 2}, {name: "My Simulation9", groupSize: 2}]
  $scope.students = ["A", "B", "C", "D", "E", "F", "G"]
  $scope.simulations = [{name: "My Simulation", groupSize: 2, minSize: 2, numGroups: 2, groupNames: [{name: "Group 1"}, {name: "Group 2"}]}, {name: "My Simulation2", groupSize: 1, minSize: 2, numGroups: 2, groupNames: [{name: "Group 1"}, {name: "Group 2"}]}, {name: "My Simulation3", groupSize: 3, minSize: 2, numGroups: 2, groupNames: [{name: "Group 1"}, {name: "Group 2"}]}]
  $scope.isCalculating = false

  numbers = [ "Zero", "One", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight", "Nine", "Ten", "Eleven", "Twelve", "Thirteen", "Fourteen", "Fifteen", "Sixteen", "Seventeen", "Eighteen", "Nineteen", "Twenty"]

  saveProject = (name) ->
    project =
      students: $scope.students
      simulations: $scope.simulations
      assignments: $scope.assignments
    storage.saveProject name, project

  loadProject = (name) ->
    obj = storage.loadProject name
    return unless obj?
    $timeout () ->
      $scope.students = obj.project.students
      $scope.simulations = obj.project.simulations
      $scope.assignments = obj.project.assignments

  updateLastProject = () ->
    saveProject "_last"

  lastProject = () ->
    loadProject "_last"

  lastProject()

  $scope.delProject = (name) ->
    storage.deleteProject(name)
    $scope.projectList = storage.projectList()

  $scope.loadProjectDiag = () ->
    $scope.projectList = storage.projectList()
    ngDialog.open
      template: "/js/templates/loadProject.html"
      className: 'ngdialog-theme-default'
      scope: $scope

  $scope.loadProjectDiagSelected = (name) ->
    loadProject name
    toastr.success "Project #{name} Loaded"
    $scope.projectName = name

  $scope.saveProjectDiag = () ->
    promise = ngDialog.openConfirm
      template: "/js/templates/saveProject.html"
      className: 'ngdialog-theme-default'
      scope: $scope

    promise.then (data) ->
      return unless data?
      $scope.projectName = data
      console.log "projectName: #{data}"
      saveProject data
      toastr.success "Project #{data} Saved"

  $scope.importProjectDiag = () ->

  $scope.exportProject = () ->
    project =
      students: $scope.students
      simulations: $scope.simulations
      assignments: $scope.assignments
    project.projectName = $scope.projectName if $scope.projectName

    blob = new Blob([angular.toJson(project)], { type: "text/plain;charset=utf-8" })
    saveAs blob, (if project.projectName? then "#{project.projectName}.json" else "project.json")

  $scope.newProject = () ->
    isolate = $scope.$new(true)
    isolate.confirmText = "Do you want to clear the current project?"
    promise = ngDialog.openConfirm
      template: "/js/templates/confirm.html"
      className: 'ngdialog-theme-default'
      scope: isolate

    promise.then () ->
      $scope.students = []
      $scope.simulations = []
      $scope.assignments = null
      $scope.isCalculating = false
      delete $scope.projectName
      updateLastProject()
      toastr.success "New Project Created"
      isolate.$destroy()
    , () ->
      isolate.$destroy()

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
    updateLastProject()

  $scope.delStudent = (student) ->
    console.log "delStudent: #{student}"
    $scope.students = _.without($scope.students, student)
    updateLastProject()

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
    updateLastProject()

  $scope.delSimulation = (simulation) ->
    console.log "delSimulation: #{simulation}"
    $scope.simulations = _.without($scope.simulations, simulation)
    updateLastProject()

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

  $scope.assignToGroups = (ev, ladda) ->
    console.log "assignToGroups"

    $scope.isCalculating = true
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
            ladda.done()
            updateLastProject()
            scope.isCalculating = false

          $timeout () ->
            toastr.success "Calculation Finished"
          , 700
        when "progress"
          ladda.progress data.progress
          $scope.$apply (scope) ->
            scope.calculatingProgress = "Calculating (#{Math.floor(data.progress * 100)}%)"
        else console.log "Unknown assigner command: #{JSON.stringify(data)}"
    , false)

    worker.addEventListener('error', (err) ->
      ladda.done()
      $scope.isCalculating = false
      $timeout () ->
        toastr.error "Error Encountered while Calculating"
      , 700
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
    str = ""

    for assignment in $scope.assignments
      studentMap = {}
      for game, gameIdx in assignment.games
        for group, groupIdx in game
          for student in group
            studentMap[student] =
              gameIdx: gameIdx
              groupIdx: groupIdx

      numGames = assignment.games.length
      str += "#{assignment.name}\n,"
      for i in [1..numGames]
        str += "#{i},"
      str += "\n"

      _.each _.keys(studentMap).sort(), (student) ->
        {gameIdx, groupIdx} = studentMap[student]
        str += "#{student},"
        str += ((if i == gameIdx then assignment.groupNames[groupIdx].name else null) for i in [0..(numGames-1)]).join ","
        str += "\n"

      str += "\n"

    console.log str

    blob = new Blob([str], { type: "text/plain;charset=utf-8" })
    saveAs blob, "assignments.csv"

module.exports = AppCtrl
