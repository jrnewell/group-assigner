'use strict'

importScripts('../lodash.js');

# main algorithm
calculateGroups = (students, simulations) ->

  console.log "calculate!"

  randAssignments = () ->
    assignments = []
    for simulation in simulations
      {name, groupSize, minSize, numGroups, groupNames} = simulation
      assignment =
        name: name
        groupSize: groupSize
        minSize: minSize
        numGroups: numGroups
        groupNames: groupNames
        games: []
      assignments.push assignment

      randShuffle = _.shuffle(students)
      groups = ([] for i in [1..numGroups])
      groupIdx = 0

      for student in randShuffle
        group = groups[groupIdx]
        group.push student
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
      partnerData[student] = dataObj

      # initialize to zero
      for mate in mates
        dataObj.partners[mate] = 0
        dataObj.opponents[mate] = 0

    #console.log "partnerData: #{JSON.stringify(partnerData)}"

    for assignment in assignments
      for game in assignment.games
        updatePartnerData = (side, opponents) ->
          for student in side
            dataObj = partnerData[student]
            mates = _.without(side, student)
            for mate in mates
              dataObj.partners[mate] += 1
            for opponent in opponents
              dataObj.partners[opponent] += 1

        for party in game
          opponents = _.without(game, party)
          for opponent in opponents
            updatePartnerData party, opponent

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
        {games} = assignment
        game1 = getRandomInt 0, games.length
        group1 = getRandomInt 0, games[game1].length
        leng1 = games[game1][group1].length
        continue unless leng1 > 0
        idx1 = getRandomInt 0, leng1

        game2 = getRandomInt 0, games.length
        group2 = getRandomInt 0, games[game2].length
        leng2 = games[game2][group2].length
        continue unless leng2 > 0
        idx2 = getRandomInt 0, leng2

        continue if game1 == game2 and group1 == group2 and idx1 == idx2
        swap1 = games[game1][group1][idx1]
        swap2 = games[game2][group2][idx2]
        continue unless swap1 and swap2
        games[game1][group1][idx1] = swap2
        games[game2][group2][idx2] = swap1

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
