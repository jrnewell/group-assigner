'use strict'

SimulationsCtrl = ($scope, $timeout, $location, $routeParams, ngDialog, shared) ->

  $scope.shared = shared
  notify = shared.notify

  defaultSimlation = (simName) ->
    return {
      name: simName
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
      roles: []
      absent: []
      isDone: false
    }

  # get possible selected simulation
  if $routeParams.simId?
    sim = shared.getSimulation($routeParams.simId)
    if sim?
      _.defaults sim, defaultSimlation($routeParams.simId)
      $scope.simulation = sim
      $scope.simRename = sim.name

  $scope.addSimulation = () ->
    return if _.isEmpty($scope.newSimName) or shared.getSimulation($scope.newSimName)
    console.log "addSimulation: #{$scope.newSimName}"
    newSim = defaultSimlation $scope.newSimName
    shared.simulations.push newSim
    $scope.newSimName = ""
    $location.url "/simulations/#{newSim.name}"

  $scope.renameSimulation = () ->
    return if $scope.simRename is $scope.simulation.name
    if _.isEmpty($scope.simRename) or shared.getSimulation($scope.simRename)
      $scope.simRename = sim.name
      $timeout () ->
        notify.failure "Invalid or duplicate simulation name"
      return

    console.log "renameSimulation: #{$scope.simRename}"
    $scope.simulation.name = $scope.simRename
    $location.url "/simulations/#{$scope.simulation.name}"

  $scope.addSimulation2 = () ->
    return if _.isEmpty($scope.newSimName) or _.contains(shared.simulations, $scope.newSimName)

    {groupSize, minSize, numGroups, groupNames, roles} = $scope.newSim
    minSize = numGroups if minSize < numGroups
    return if groupSize < 1 or groupSize > 5

    # populate unset group names
    resizeGroupNames()
    for groupName, index in groupNames
      groupNames.name = "Group #{index + 1}" unless groupName.name?

    roles = [] unless _.isArray(roles)
    console.log "addSimulation: #{$scope.newSimName} #{groupSize} #{minSize} #{numGroups} #{JSON.stringify(roles)}"
    shared.simulations.push
      name: $scope.newSimName
      groupSize: numGroups
      minSize: minSize
      numGroups: numGroups
      groupNames: groupNames
      roles: roles
    resetNewSim()
    updateLastProject()

  $scope.delSimulation = (simulation) ->
    console.log "delSimulation: #{simulation}"
    shared.simulations = _.without(shared.simulations, simulation)
    $location.url "/simulations"
    #updateLastProject()

  $scope.changeMinSize = () ->
    return unless $scope.simulation?
    {groupSize, minSize, numGroups} = $scope.simulation
    console.log "changeMinSize: #{groupSize} #{minSize} #{numGroups}"

    minBottom = numGroups
    minTop = (numGroups * groupSize)
    $scope.simulation.minOptions = _.reduce([minBottom..minTop], (obj, num) ->
        obj[num] = shared.numToWord(num)
        return obj
    , {})
    $scope.simulation.minSize = minBottom if minSize < minBottom
    $scope.simulation.minSize = minTop if minSize > minTop

  resizeGroupNames = () ->
    return unless $scope.simulation?
    {numGroups, groupNames} = $scope.simulation
    return if numGroups == groupNames.length
    console.log "simulation.numGroups changed: #{numGroups}"
    if numGroups < groupNames.length
      $scope.simulation.groupNames = groupNames[0..(numGroups - 1)]
    else if numGroups > groupNames.length
      $scope.simulation.groupNames = groupNames.concat ({name: null} for i in [1..(numGroups - groupNames.length)])
    console.log JSON.stringify($scope.simulation.groupNames)

  $scope.$watch "simulation.numGroups", resizeGroupNames

  $scope.$watch "simulation.groupSize", () ->
    return unless $scope.simulation?
    return if _.isEmpty($scope.simulation.roles)
    $scope.simulation.roles = []
    $timeout () ->
      notify.warning "Role assignment has been cleared due to group size change. Please reassign roles."

  $scope.giveNamesToGroups = () ->
    ngDialog.open
      template: "js/templates/dialogs/simulations/namesToGroups.html"
      className: 'ngdialog-theme-default'
      scope: $scope

  $scope.absentStudentsDiag = () ->
    isolate = $scope.$new(true)
    console.log "absentStudentsDiag"
    students = {}
    for student in $scope.simulation.absent
      students[student] = true
    for student in shared.students
      students[student] = false unless students[student]?
    studentsArray = []
    for student, absent of students
      studentsArray.push
        name: student
        absent: absent

    isolate.students = studentsArray
    dialog = ngDialog.open
      template: "js/templates/dialogs/simulations/absentStudents.html"
      className: 'ngdialog-theme-default'
      scope: isolate

    dialog.closePromise.then () ->
      $scope.simulation.absent = _.pluck(_.filter(isolate.students, ((student) -> student.absent)), "name")
      isolate.$destroy()
    , () ->
      isolate.$destroy()

  $scope.simulationIsDone = () ->
    unless $scope.simulation.done?
      $scope.simulation.done =
        games: []
        groupNames: []

    $scope.simulation.isDone = true

module.exports = SimulationsCtrl
