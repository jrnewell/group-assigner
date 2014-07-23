'use strict'

_ = require('lodash')

AppCtrl = ($scope, $timeout) ->
  $scope.message = "Hello World"

  $scope.students = ["A", "B", "C", "D", "E", "F", "G"]
  $scope.simulations = [{name: "My Simulation", max: 2}, {name: "My Simulation2", max: 1}, {name: "My Simulation3", max: 3}]
  $scope.newSimMax = "1"

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
    newSimMax = parseInt($scope.newSimMax)
    return if newSimMax < 1 or newSimMax > 5
    console.log "addSimulation: #{$scope.newSimName} #{newSimMax}"
    $scope.simulations.push
      name: $scope.newSimName
      max: newSimMax
    $scope.newSimMax = "1"
    # shoud move to directive
    $timeout () ->
      $("#selector-simulator-max").val("1").trigger("change")
    $scope.newSimName = ""

  $scope.delSimulation = (simulation) ->
    console.log "delSimulation: #{simulation}"
    $scope.simulations = _.without($scope.simulations, simulation)

  # main algorithm
  calculateGroups = () ->
    console.log "calculate!"

    # setup data structures
    studentQueues = {}
    for student in $scope.students
      queue = _.without($scope.students, student)
      studentQueues[student] =
        partners: _.shuffle(queue)
        opponents: _.shuffle(queue)

    studentChooseQueue = _.shuffle($scope.students)
    simulationOrder =  _.shuffle($scope.simulations)
    assignments = []

    # utility functions
    sendToBack = (array, item) ->
      _(array).without(item).push(item).value()

    incIdx = (array, idx) ->
      (idx + 1) % array.length

    for simulation in simulationOrder
      {name, max} = simulation
      assignment =
        name: name
        max: max
        groups: []
      assignments.push assignment

      studentsUnassigned = _.clone($scope.students)
      chooseIdx = 0
      while (studentsUnassigned.length > 0)
        console.log "while: #{chooseIdx} #{studentsUnassigned.length}"
        chooser = studentChooseQueue[chooseIdx]

        # skip this student if he is assigned already
        unless _.contains(studentsUnassigned, chooser)
          chooseIdx = incIdx studentChooseQueue, chooseIdx
          continue

        studentChooseQueue = sendToBack studentChooseQueue, chooser
        studentsUnassigned = _.without(studentsUnassigned, chooser)
        chooserQueues = studentQueues[chooser]
        side1 = [chooser]
        side2 = []

        assignToSide = (side, queue) ->
          groupSize = Math.min max, studentsUnassigned.length
          idx = 0
          while (side.length < groupSize)
            console.log "assignToSide: #{idx} #{side.length} #{groupSize}"
            student = queue[idx]

            # skip this student if he is assigned already
            unless _.contains(studentsUnassigned, student)
              idx = incIdx queue, idx
              continue

            side.push student
            idx = incIdx queue, idx
            #queue = sendToBack queue, student
            studentsUnassigned = _.without(studentsUnassigned, student)

          return queue

        chooserQueues.partners = assignToSide side1, chooserQueues.partners

        # get chooser's opponents
        if studentsUnassigned.length > 0
          oppIdx = 0
          oppQueue = chooserQueues.opponents
          opposer = oppQueue[oppIdx]
          while (!_.contains(studentsUnassigned, opposer))
            oppIdx = incIdx oppQueue, oppIdx
            opposer = oppQueue[oppIdx]
          #chooserQueues.opponents = sendToBack oppQueue, opposer

          side2.push opposer
          studentsUnassigned = _.without(studentsUnassigned, opposer)
          chooserQueues.opponents = assignToSide side2, studentQueues[opposer].partners

        # push teammates/opponents to the back of the queue
        updateQueue = (team1, team2) ->
          for student in team1
            teammates = _.without(team1, student)
            queue = studentQueues[student].partners
            for mate in teammates
              queue = sendToBack queue, mate
            studentQueues[student].partners = queue

            queue = studentQueues[student].opponents
            for opponent in team2
              queue = sendToBack queue, opponent
            studentQueues[student].opponents = queue

        updateQueue side1, side2
        updateQueue side2, side1

        assignment.groups.push
          side1: side1
          side2: side2

    $scope.assignments = JSON.stringify(assignments)
    console.log "done: #{$scope.assignments}"

  $scope.assignToGroups = () ->
    #el = document.getElementById("assignBtn")
    #l = Ladda.create(el)
    #l.start()
    calculateGroups()

module.exports = AppCtrl