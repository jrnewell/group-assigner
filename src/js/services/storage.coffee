'use strict'

storage = () ->

  save = (key, obj) ->
    return unless obj?
    try
      localStorage.setItem key, angular.toJson(obj)
    catch err
      console.error "storage save error: #{err}"

  load = (key) ->
    try
      ret = localStorage.getItem key
      (if ret? then angular.fromJson(ret) else undefined)
    catch err
      console.error "storage load error: #{err}"
      return undefined

  remove = (key) ->
    localStorage.removeItem key

  clear = () ->
    localStorage.clear()

  saveProject = (name, project) ->
    obj = load name
    if obj
      obj.modified = moment().unix()
      obj.project = project
    else
      obj =
        name: name
        created: moment().unix()
        modified: moment().unix()
        project: project
    save name, obj
    addToProjectList name

  loadProject = (name) ->
    obj = load name
    return undefined unless obj?
    obj.created = moment.unix(obj.created)
    obj.modified = moment.unix(obj.modified)
    return obj

  deleteProject = (name) ->
    remove name
    removeFromProjectList name

  addToProjectList = (name) ->
    list = projectList()
    unless _.contains(list, name)
      list.push name
      save "_projectList", list

  removeFromProjectList = (name) ->
    list = projectList()
    list = _.without(list, name)
    save "_projectList", list

  projectList = () ->
    list = load "_projectList"
    return (if list? then list else [])

  return {
    saveProject: saveProject
    loadProject: loadProject
    deleteProject: deleteProject
    clearAll: clear
    projectList: projectList
  }

module.exports = storage