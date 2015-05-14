'use strict'

TranspiredCtrl = ($scope, $timeout, $location, $routeParams, ngDialog, shared) ->

  $scope.shared = shared
  notify = shared.notify

  $scope.addGame = () ->
    $scope.simulation.done.games.push []

  $scope.delGame = (game) ->
    _.pull($scope.simulation.done.games, game)

  $scope.addGroup = (game) ->
    game.push []
    if game.length > $scope.simulation.done.groupNames.length
      $scope.simulation.done.groupNames.push {name: "Group #{game.length}"}

  $scope.delGroup = (game, group) ->
    _.pull(game, group)

  $scope.giveNamesToGroups = () ->
    ngDialog.open
      template: "js/templates/dialogs/transpired/namesToGroups.html"
      className: 'ngdialog-theme-default'
      scope: $scope

  $scope.delStudent = (group, student) ->
    _.pull(group, student)

  findStudent = (name, remove = false) ->
    for game in $scope.simulation.done.games
      for group in game
        for student in group
          if student.name is name
            _.pull(group, student) if remove
            return student
    return null

  #TODO: without -> pull
  #TODO: absent students -> indexBy
  #TODO: iCheck / ngDialog bugs

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
    for student, inGroup of students
      studentsArray.push
        name: student
        inGroup: inGroup

    isolate.students = studentsArray
    dialog = ngDialog.open
      template: "js/templates/dialogs/transpired/assignStudents.html"
      className: 'ngdialog-theme-default'
      scope: isolate

    dialog.closePromise.then () ->
      oldStudentArray = _.pluck(group, "name")
      newStudentArray = _.pluck(_.filter(isolate.students, ((student) -> student.inGroup)), "name")
      removedStudents = _.difference(oldStudentArray, newStudentArray)
      addedStudents = _.difference(newStudentArray, oldStudentArray)

      _group = group[..]
      group.length = 0
      for student in _group
        group.push student unless removedStudents.indexOf(student.name) >= 0

      for studentName in addedStudents
        student = findStudent(studentName, true)
        student = {name: studentName} unless student?
        group.push student

      isolate.$destroy()
    , () ->
      isolate.$destroy()

  $scope.toggleRole = (student) ->
    return unless shared.roles.length > 0
    if student.role?
      idx = shared.roles.indexOf(student.role)
      if idx < 0
        student.role = shared.roles[0]
      else
        next = idx + 1 % student.role.length
        if next == 0
          delete student.role
        else
          student.role = shared.roles[next]
    else
      student.role = shared.roles[0]

  $scope.simulationIsNotDone = () ->
    $scope.simulation.isDone = false

module.exports = TranspiredCtrl