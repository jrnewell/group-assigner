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

    randAssignments = () ->
      assignments = []
      for simulation in $scope.simulations
        {name, max} = simulation
        assignment =
          name: name
          max: max
          groups: []
        assignments.push assignment

        randShuffle = _.shuffle($scope.students)
        side1 = []
        side2 = []
        side = side1

        for student in randShuffle
          if (side.length >= max)
            if side is side1
              side = side2
            else
              assignment.groups.push
                side1: side1
                side2: side2
              side1 = []
              side2 = []
              side = side1

          side.push student

        # do we get the last group?
        if side1.length > 0 or side2.length > 0
          assignment.groups.push
            side1: side1
            side2: side2

      return assignments

    getRandomInt = (min, max) ->
       Math.floor(Math.random() * (max - min)) + min

    scoreAssignments = (assignments) ->
      # setup data structures
      partnerData = {}
      for student in $scope.students
        mates = _.without($scope.students, student)
        dataObj =
          partners: {}
          opponents: {}
        partnerData[student] = dataObj

        # initialize to zero
        for mate in mates
          dataObj.partners[mate] = 0
          dataObj.opponents[mate] = 0

      #console.log "partnerData: #{JSON.stringify(partnerData)}"

      for assignment in assignments
        for group in assignment.groups
          updatePartnerData = (side, opponents) ->
            for student in side
              dataObj = partnerData[student]
              mates = _.without(side, student)
              for mate in mates
                dataObj.partners[mate] += 1
              for opponent in opponents
                dataObj.partners[opponent] += 1

          updatePartnerData group.side1, group.side2
          updatePartnerData group.side2, group.side1

      #console.log "partnerData: #{JSON.stringify(partnerData)}"

      score = 0
      for student, dataObj of partnerData
        for partner, partnerVal of dataObj.partners
          score += (partnerVal ** 2) * 2
        for opponent, oppVal of dataObj.opponents
          score += (partnerVal ** 2)
      return score

    mutateAssignments = (assignments) ->
      for assignment in assignments
        mutations = getRandomInt 1, 50
        #console.log "mutations: #{mutations}"
        for i in [1..mutations]
          {groups} = assignment
          group1 = getRandomInt 0, groups.length
          side1 = (if getRandomInt 0, 2 == 0 then 'side1' else 'side2')
          leng1 = groups[group1][side1].length
          continue unless leng1 > 0
          idx1 = getRandomInt 0, leng1

          group2 = getRandomInt 0, groups.length
          side2 = (if getRandomInt 0, 2 == 0 then 'side1' else 'side2')
          leng2 = groups[group2][side2].length
          continue unless leng2 > 0
          idx2 = getRandomInt 0, leng2

          continue if group1 == group2 and side1 == side2 and idx1 == idx2
          swap1 = groups[group1][side1][idx1]
          swap2 = groups[group2][side2][idx2]
          continue unless swap1 and swap2
          groups[group1][side1][idx1] = swap2
          groups[group2][side2][idx2] = swap1

      return assignments

    progenate = (generation) ->
      scores = ({score: scoreAssignments(a), assignments: a} for a in generation)
      scores = _.sortBy(scores, 'score')
      preLeng = scores.length
      cutOff = scores[0..(Math.floor(scores.length * 0.2)-1)]
      progency = (s.assignments for s in cutOff)
      for i in [1..3]
        progency = progency.concat(mutateAssignments(s.assignments) for s in cutOff)

      while progency.length < preLeng
        progency.push randAssignments()

      return progency

    winningAssignment = (generation) ->
      scores = ({score: scoreAssignments(a), assignments: a} for a in generation)
      scores = _.sortBy(scores, 'score')
      return scores[0].assignments

    winner = null
    winnerScore = Number.MAX_VALUE
    checkForWinner = (generation) ->
      genWinner = winningAssignment(generation)
      genScore = scoreAssignments(genWinner)
      if genScore < winnerScore
        console.log "new winner: #{genScore}"
        winnerScore = genScore
        winner = genWinner

    # initialize with random assignments
    generation = (randAssignments() for i in [1..100])
    checkForWinner generation

    maxIterations = 100
    for iteration in [1..maxIterations]
      console.log "iteration: #{iteration}"
      generation = progenate generation
      checkForWinner generation

    console.log JSON.stringify(winner)
    console.log "winnerScore: #{winnerScore}"


  $scope.assignToGroups = () ->
    #el = document.getElementById("assignBtn")
    #l = Ladda.create(el)
    #l.start()
    calculateGroups()

module.exports = AppCtrl