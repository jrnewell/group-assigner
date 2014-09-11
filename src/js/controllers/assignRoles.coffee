'use strict'

AssignRoles = ($scope, $timeout, ngDialog, shared) ->

  $scope.shared = shared
  notify = shared.notify

  $scope.assignRolesDiag = () ->
    isolate = $scope.$new(true)
    isolate.roles = $scope.newSim.roles

    resetAssignDiag = () ->
      isolate.assignment = {}
      isolate.unassignedRoles = _.difference(shared.roles, _.pluck(isolate.roles, "role"))

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

module.exports = AssignRoles
