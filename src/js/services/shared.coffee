'use strict'

shared = (storage) ->

  # defaults for now
  # _assignments = [{"name":"My Simulation","groupSize":2,"minSize":2,"numGroups":2,"groupNames":[{"name":"Group 1"},{"name":"Group 2"}],"games":[[[{name: "C"},{name: "F"}],[{name: "D"},{name: "E"}]],[[{name: "G"},{name: "B"}],[{name: "A"}]]]},{"name":"My Simulation2","groupSize":1,"minSize":2,"numGroups":2,"groupNames":[{"name":"Group 1"},{"name":"Group 2"}],"games":[[[{name: "D"}],[{name: "F"}]],[[{name: "C"}],[{name: "B"}]],[[{name: "G"},{name: "A"}],[{name: "E"}]]]},{"name":"My Simulation3","groupSize":3,"minSize":2,"numGroups":2,"groupNames":[{"name":"Group 1"},{"name":"Group 2"}],"games":[[[{name: "G"},{name: "C"},{name: "B"},{name: "F"}],[{name: "D"},{name: "A"},{name: "E"}]]]}]
  # _students = ["A", "B", "C", "D", "E", "F", "G"]
  # _simulations = [{name: "My Simulation", groupSize: 2, minSize: 2, numGroups: 2, groupNames: [{name: "Group 1"}, {name: "Group 2"}], roles: []}, {name: "My Simulation2", groupSize: 1, minSize: 2, numGroups: 2, groupNames: [{name: "Group 1"}, {name: "Group 2"}], roles: []}, {name: "My Simulation3", groupSize: 3, minSize: 2, numGroups: 2, groupNames: [{name: "Group 1"}, {name: "Group 2"}], roles: []}]
  # _roles = ["Client", "Lawyer"]

  _assignments = null
  _students = []
  _simulations = []
  _roles = []

  # translate whole number (up to 20) to a word
  _numbers = [ "Zero", "One", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight", "Nine", "Ten", "Eleven", "Twelve", "Thirteen", "Fourteen", "Fifteen", "Sixteen", "Seventeen", "Eighteen", "Nineteen", "Twenty"]
  numToWord = (num) ->
    return _numbers[num]

  # config toastr notifications
  toastr.options =
    closeButton: false
    debug: false
    positionClass: "toast-top-right"
    onclick: null
    showDuration: 500
    hideDuration: 500
    timeOut: 2000
    extendedTimeOut: 1000
    showEasing: "swing"
    hideEasing: "swing"
    showMethod: "fadeIn"
    hideMethod: "fadeOut"

  saveProject = (name) ->
    _shared.projectName = name
    project =
      students: _shared.students
      roles: _shared.roles
      simulations: _shared.simulations
      assignments: _shared.assignments
    storage.saveProject name, project

  loadProject = (name) ->
    obj = storage.loadProject name
    return unless obj?
    shared.students = obj.project.students
    shared.roles = obj.project.roles
    shared.simulations = obj.project.simulations
    shared.assignments = obj.project.assignments

  updateLastProject = () ->
    saveProject "_last"

  lastProject = () ->
    loadProject "_last"

  getSimulation = (name) ->
    _.find _shared.simulations, (sim) ->
      sim.name is name

  _shared =
    projectName: null
    students: _students
    roles: _roles
    simulations: _simulations
    assignments: _assignments
    isCalculating: false
    numToWord: numToWord
    notify:
      success: toastr.success
      info:    toastr.info
      warning: toastr.warning
      failure: toastr.error
    saveProject: saveProject
    loadProject: loadProject
    updateLastProject: updateLastProject
    lastProject: lastProject
    getSimulation: getSimulation

  return _shared

module.exports = shared
