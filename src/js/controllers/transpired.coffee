'use strict'

TranspiredCtrl = ($scope, $timeout, $location, $routeParams, ngDialog, shared) ->

  $scope.shared = shared
  notify = shared.notify

  $scope.addGame = () ->
    $scope.simulation.done.games.push []

  $scope.delGame = (game) ->
    _.pull($scope.simulation.done.games, game)

  $scope.addGroup = (game) ->
    game.push [{name: "Jim"}]

  $scope.delGroup = (game, group) ->
    _.pull(game, group)

  $scope.delStudent = (group, student) ->
    _.pull(group, student)

  findStudent = (name) ->
    for game in $scope.simulation.done.games
      for group in game
        for student in group
          return student if student.name is name
    return null

  #TODO: without -> pull
  #TODO: absent students -> indexBy
  #TODO: absent students -> stacked icon

  $scope.addStudent = (group) ->
    isolate = $scope.$new(true)
    console.log "addStudent"
    students = {}
    for student in shared.students
      students[student] = false
    #games = $scope.simulation.done.games
    for student in group
      students[student.name] = true
    studentsArray = []
    for student, absent of students
      studentsArray.push
        name: student
        absent: absent

    isolate.students = studentsArray
    dialog = ngDialog.open
      template: "js/templates/absentStudents.html"
      className: 'ngdialog-theme-default'
      scope: isolate

    dialog.closePromise.then () ->
      oldStudentArray = _.pluck(group, "name")
      newStudentArray = _.pluck(_.filter(isolate.students, ((student) -> student.absent)), "name")
      removedStudents = _.difference(oldStudentArray, newStudentArray)
      addedStudents = _.difference(newStudentArray, oldStudentArray)

      _group = group[..]
      group.length = 0
      for student in _group
        group.push student unless removedStudents.indexOf(student.name) >= 0

      for studentName in addedStudents
        student = findStudent(studentName)
        student = {name: studentName} unless student?
        group.push student

      isolate.$destroy()
    , () ->
      isolate.$destroy()

  $scope.simulationIsNotDone = () ->
    $scope.simulation.isDone = false

module.exports = TranspiredCtrl