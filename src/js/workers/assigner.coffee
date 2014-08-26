'use strict'

importScripts('../lodash.js');

# main algorithm
calculateGroups = (students, simulations) ->

  console.log "calculate!"

  randAssignments = () ->
    assignments = []
    for simulation in simulations
      {name, groupSize, minSize, numGroups, groupNames, roles} = simulation
      #console.log "sim roles: #{JSON.stringify(roles)}"
      assignment =
        name: name
        groupSize: groupSize
        minSize: minSize
        numGroups: numGroups
        groupNames: groupNames
        roles: roles
        games: []
      assignments.push assignment

      randShuffle = _.shuffle(students)
      groups = ([] for i in [1..numGroups])
      groupIdx = 0

      for student in randShuffle
        group = groups[groupIdx]
        group.push
          name: student
          role: null
        if (groupIdx == (numGroups - 1) and group.length == groupSize)
          assignment.games.push groups
          groups = ([] for i in [1..numGroups])
          groupIdx = 0
        else
          groupIdx = (groupIdx + 1) % numGroups

      numleftOvers = _.reduce(groups, ((sum, group) -> sum + group.length), 0)

      # do we get the last group?
      if numleftOvers > 0
        if (numleftOvers >= minSize)
          assignment.games.push groups
        else
          # disperse among other groups
          disperse = _.flatten(groups)
          dispIdx = 0
          gameIdx = assignment.games.length - 1
          groupIdx = 0
          while (dispIdx < disperse.length)
            assignment.games[gameIdx][groupIdx].push disperse[dispIdx]
            if groupIdx == assignment.games[gameIdx].length - 1
              groupIdx = 0
              gameIdx = (if gameIdx == 1 then assignment.games.length - 1 else gameIdx - 1)
            else
              groupIdx += 1

            dispIdx += 1

      # assign roles randomly
      continue unless roles.length > 0
      for game in assignment.games
        for group in game
          randRoles = _.shuffle(roles)
          roleIdx = 0
          numIdx = 0
          excessIdx = 0
          for student in group
            #console.log "role assignment: #{student.name} #{roleIdx} #{numIdx} #{excessIdx}"
            if roleIdx < randRoles.length
              role = randRoles[roleIdx]
              excessIdx = roleIdx if role.excess and excessIdx != roleIdx
              student.role = role.role
              #console.log "role assignment1: #{student.name} #{student.role}"
              numIdx += 1
              if numIdx >= role.val
                roleIdx += 1
                numIdx = 0
            else
              student.role = randRoles[excessIdx].role
              #console.log "role assignment2: #{student.name} #{student.role}"

    return assignments

  getRandomInt = (min, max) ->
     Math.floor(Math.random() * (max - min)) + min

  scoreAssignments = (assignments) ->
    # setup data structures
    partnerData = {}
    for student in students
      mates = _.without(students, student)
      dataObj =
        partners: {}
        opponents: {}
        roles: {}
      partnerData[student] = dataObj

      # initialize to zero
      for mate in mates
        dataObj.partners[mate] = 0
        dataObj.opponents[mate] = 0
      roles = _.union.apply(null, assignment.roles for assignment in assignments)
      #console.log "all roles: #{JSON.stringify(roles)}"
      for role in roles
        dataObj.roles[role.role] = 0

    #console.log "partnerData: #{JSON.stringify(partnerData)}"

    for assignment in assignments
      #console.log "assignment: #{JSON.stringify(assignment)}"
      for game in assignment.games
        updatePartnerData = (side, opponents) ->
          #console.log "side: #{JSON.stringify(side)}"
          for student in side
            #console.log "dataObj (#{student.name}): #{JSON.stringify(dataObj)}"
            dataObj = partnerData[student.name]
            mates = _.without(side, student)
            for mate in mates
              dataObj.partners[mate.name] += 1
            for opponent in opponents
              dataObj.partners[opponent.name] += 1

        for party in game
          opponents = _.without(game, party)
          for opponent in opponents
            updatePartnerData party, opponent
          for student in party
            dataObj.roles[student.role] += 1 if student.role

    #console.log "partnerData: #{JSON.stringify(partnerData)}"

    score = 0
    for student, dataObj of partnerData
      for partner, partnerVal of dataObj.partners
        score += (partnerVal ** 2) * 2
      for opponent, oppVal of dataObj.opponents
        score += (partnerVal ** 2)
      for role, roleVal of dataObj.roles
        score += (roleVal ** 2) * 3
    return score

  getRandomStudent = (assignment) ->
    {games} = assignment
    gameIdx = getRandomInt 0, games.length
    groupIdx = getRandomInt 0, games[gameIdx].length
    leng = games[gameIdx][groupIdx].length
    return null unless leng > 0
    studentIdx = getRandomInt 0, leng
    return {
      gameIdx: gameIdx
      groupIdx: groupIdx
      studentIdx: studentIdx
      student: games[gameIdx][groupIdx][studentIdx]
    }

  mutateAssignments = (assignments) ->
    for assignment in assignments
      {games} = assignment

      # mutate groups
      mutations = getRandomInt 1, 50
      #console.log "group mutations: #{mutations}"
      for i in [1..mutations]
        s1 = getRandomStudent assignment
        s2 = getRandomStudent assignment

        continue unless s1?.student?
        continue unless s2?.student?
        continue if s1.student == s2.student

        s1Name = s1.student.name
        s1.student.name = s2.student.name
        s2.student.name = s1Name

      # mutate roles
      continue unless assignment.roles.length > 0
      mutations = getRandomInt 1, 50
      #console.log "role mutations: #{mutations}"
      for i in [1..mutations]
        s1 = getRandomStudent assignment

        # get student in same group
        mates = _.without(games[s1.gameIdx][s1.groupIdx], s1)
        continue unless mates.length > 0
        studentIdx = getRandomInt 0, mates.length
        student2 = mates[studentIdx]

        continue unless s1?.student?
        continue unless student2?
        continue if s1.student == student2

        s1Role = s1.student.role
        s1.student.role = student2.role
        student2.role = s1Role

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
  #console.log "init: #{JSON.stringify(generation)}"
  checkForWinner generation

  maxIterations = 100
  for iteration in [1..maxIterations]
    #console.log "iteration: #{iteration}"
    self.postMessage
      cmd: "progress"
      progress: iteration / maxIterations

    generation = progenate generation
    checkForWinner generation

  #console.log JSON.stringify(winner)
  console.log "winnerScore: #{winnerScore}"

  self.postMessage
    cmd: "assignments"
    assignments: winner
  self.close()

# listen for messages
self.addEventListener('message', (ev) ->
  data = ev.data
  switch data.cmd
    when "calculate" then calculateGroups(data.students, data.simulations)
    else console.log "Unknown assigner command: #{JSON.stringify(data)}"
, false)
