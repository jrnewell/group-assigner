'use strict'

AppCtrl = ($scope, $timeout, ngDialog, storage, shared) ->

  $scope.shared = shared
  notify = shared.notify

  saveProject = (name) ->
    project =
      students: $scope.students
      simulations: $scope.simulations
      assignments: $scope.assignments
      roles: $scope.roles
    storage.saveProject name, project

  loadProject = (name) ->
    obj = storage.loadProject name
    return unless obj?
    $timeout () ->
      $scope.students = obj.project.students
      $scope.simulations = obj.project.simulations
      $scope.assignments = obj.project.assignments
      $scope.roles = obj.project.roles
    #updateLastProject()

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
      template: "js/templates/loadProject.html"
      className: 'ngdialog-theme-default'
      scope: $scope

  $scope.loadProjectDiagSelected = (name) ->
    loadProject name
    toastr.success "Project #{name} Loaded"
    $scope.projectName = name

  $scope.saveProjectDiag = () ->
    promise = ngDialog.openConfirm
      template: "js/templates/saveProject.html"
      className: 'ngdialog-theme-default'
      scope: $scope

    promise.then (data) ->
      return unless data?
      $scope.projectName = data
      console.log "projectName: #{data}"
      saveProject data
      toastr.success "Project #{data} Saved"

  $scope.importProject = (data) ->
    try
      project = angular.fromJson(data)
      return unless project?
      $timeout () ->
        $scope.students = project.students
        $scope.simulations = project.simulations
        $scope.assignments = project.assignments
        $scope.roles = project.roles
        $scope.projectName = project.projectName if project.projectName
        $timeout () ->
          toastr.success (if project.projectName then "Project '#{project.projectName}' Imported" else "Project Imported")
    catch ex
      $timeout () ->
        toastr.error "Problem Importing Project"

  $scope.exportProject = () ->
    project =
      students: $scope.students
      simulations: $scope.simulations
      assignments: $scope.assignments
      roles: $scope.roles
    project.projectName = $scope.projectName if $scope.projectName

    blob = new Blob([angular.toJson(project)], { type: "text/plain;charset=utf-8" })
    saveAs blob, (if project.projectName? then "#{project.projectName}.json" else "project.json")

  $scope.newProject = () ->
    isolate = $scope.$new(true)
    isolate.confirmText = "Do you want to clear the current project?"
    promise = ngDialog.openConfirm
      template: "js/templates/confirm.html"
      className: 'ngdialog-theme-default'
      scope: isolate

    promise.then () ->
      $scope.students = []
      $scope.simulations = []
      $scope.roles = []
      $scope.assignments = null
      shared.isCalculating = false
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
      roles: []
    $scope.newSimName = ""

  resetNewSim()

  $scope.manageRolesDiag = () ->
    ngDialog.open
      template: "js/templates/manageRoles.html"
      className: 'ngdialog-theme-default'
      scope: $scope

  $scope.addRole = (newRoleName) ->
    return false if _.isEmpty(newRoleName) or _.contains($scope.roles, newRoleName)
    $scope.roles.push newRoleName
    updateLastProject()
    return true

  $scope.delRole = (role) ->
    console.log "delRole: #{role}"
    $scope.roles = _.without($scope.roles, role)
    updateLastProject()

  $scope.assignRolesDiag = () ->
    isolate = $scope.$new(true)
    isolate.roles = $scope.newSim.roles

    resetAssignDiag = () ->
      isolate.assignment = {}
      isolate.unassignedRoles = _.difference($scope.roles, _.pluck(isolate.roles, "role"))

      maxVal = _.reduce(isolate.roles, (left, assign) ->
          return left - assign.val
      , $scope.newSim.groupSize)
      return isolate.roleValOpts = {} if maxVal == 0

      minVal = (if isolate.unassignedRoles.length > 1 then 1 else maxVal)

      isolate.roleValOpts = _.reduce([minVal..maxVal], (obj, num) ->
          obj[num] = shared.numToWord(num)
          return obj
      , {})

      isolate.initHide = false if isolate.initHide

      if isolate.unassignedRoles.length > 0
        isolate.assignment =
          role: 0
          val: minVal

    resetAssignDiag()

    console.log "isolate.roles: #{JSON.stringify(isolate.roles)}"
    console.log "isolate.unassignedRoles: #{JSON.stringify(isolate.unassignedRoles)}"

    isolate.showAssignment = () ->
      return (isolate.unassignedRoles.length > 0) && (_.keys(isolate.roleValOpts).length > 0)

    isolate.initHide = !isolate.showAssignment()

    isolate.assignRole = (assign) ->
      console.log "assignRole: #{assign.role}"
      return if _.isEmpty(assign) or _.contains(_.pluck(isolate.roles, "role"), assign.role)
      obj =
        role: isolate.unassignedRoles[assign.role]
        val: assign.val
        excess: !_.some(isolate.roles, "excess")
      isolate.roles.push obj
      resetAssignDiag()

      console.log "assign: #{JSON.stringify(assign)}"
      console.log "isolate.roles: #{JSON.stringify(isolate.roles)}"
      console.log "isolate.unassignedRoles: #{JSON.stringify(isolate.unassignedRoles)}"
      console.log "isolate.roleValOpts: #{JSON.stringify(isolate.roleValOpts)}"

    isolate.delRoleAssignemnt = (role) ->
      isolate.roles = _.reject(isolate.roles, {role: role})
      $scope.newSim.roles = isolate.roles
      resetAssignDiag()

      unless _.some(isolate.roles, "excess") || isolate.roles.length == 0
        isolate.roles[0].excess = true

      console.log "role: #{JSON.stringify(role)}"
      console.log "isolate.roles: #{JSON.stringify(isolate.roles)}"
      console.log "isolate.unassignedRoles: #{JSON.stringify(isolate.unassignedRoles)}"
      console.log "isolate.roleValOpts: #{JSON.stringify(isolate.roleValOpts)}"

    ngDialog.open
      template: "js/templates/assignRoles.html"
      className: 'ngdialog-theme-default'
      scope: isolate

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

    {groupSize, minSize, numGroups, groupNames, roles} = $scope.newSim
    minSize = numGroups if minSize < numGroups
    return if groupSize < 1 or groupSize > 5

    # populate unset group names
    resizeGroupNames()
    for groupName, index in groupNames
      groupNames.name = "Group #{index + 1}" unless groupName.name?

    roles = [] unless _.isArray(roles)
    console.log "addSimulation: #{$scope.newSimName} #{groupSize} #{minSize} #{numGroups} #{JSON.stringify(roles)}"
    $scope.simulations.push
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
      toastr.warning "Role assignment has been cleared due to group size change. Please reassign roles."

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
      shared.isCalculating = false
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
      template: "js/templates/namesToGroups.html"
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

module.exports = AppCtrl
