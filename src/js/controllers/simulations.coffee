'use strict'

SimulationsCtrl = ($scope, $timeout, $location, $routeParams, ngDialog, shared) ->

  $scope.shared = shared
  notify = shared.notify

  console.log "routeParams: "
  console.dir $routeParams

  $scope.sims = {}
  if $routeParams.simId?
    sim = shared.getSimulation($routeParams.simId)
    $scope.sims.selected = sim if sim?

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
      roles: []
    $scope.newSimName = ""

  resetNewSim()

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
    }

  $scope.addSimulation = () ->
    return if _.isEmpty($scope.newSimName) or shared.getSimulation($scope.newSimName)
    console.log "addSimulation: #{$scope.newSimName}"
    newSim = defaultSimlation $scope.newSimName
    shared.simulations.push newSim
    $scope.newSimName = ""
    $location.url "/simulations/#{newSim.name}"

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
    {groupSize, minSize, numGroups} = $scope.newSim
    console.log "changeMinSize: #{groupSize} #{minSize} #{numGroups}"

    minBottom = numGroups
    minTop = (numGroups * groupSize)
    $scope.newSim.minOptions = _.reduce([minBottom..minTop], (obj, num) ->
        obj[num] = shared.numToWord(num)
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

  $scope.$watch "newSim.groupSize", () ->
    return if _.isEmpty($scope.newSim.roles)
    $scope.newSim.roles = []
    $timeout () ->
      notify.warning "Role assignment has been cleared due to group size change. Please reassign roles."

  $scope.giveNamesToGroups = () ->
    ngDialog.open
      template: "js/templates/namesToGroups.html"
      className: 'ngdialog-theme-default'
      scope: $scope

module.exports = SimulationsCtrl
