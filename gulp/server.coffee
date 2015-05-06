gulp = require "gulp"
gutil = require "gulp-util"
plumber = require "gulp-plumber"
gopen = require "gulp-open"
liveReload = require "gulp-livereload"
events = require "events"
constants = require "./constants"


{httpPort, httpURL, lrPort, watchPaths, shared} = constants

#
# server-related tasks
#

notifier = new events.EventEmitter()

gulp.task "server", ["build"], (callback) ->
  connect = require("connect")
  serveStatic = require("serve-static")
  favicon = require('serve-favicon')
  http = require("http")
  server = connect().use(require("connect-livereload")(port: lrPort)).use(serveStatic("./build"))
  server.use(favicon('./build/img/favicon.ico'))
  http.createServer(server).listen httpPort, ->
    gutil.log "connect server listening on port " + httpPort
    notifier.emit('start')
    callback()

gulp.task "watch", (callback) ->

  # set flag, so liveReload will function
  shared.isWatching = true

  # need to run this after the watch flag is set
  gulp.start "server"

  # start tiny-lr server
  liveReload.listen port: lrPort, ->
    gutil.log "tiny-lr server listening on port #{lrPort}"
    callback()

  gulp.watch watchPaths.workers, ["web-workers"]
  gulp.watch watchPaths.stylus,  ["stylus"]
  gulp.watch watchPaths.css,     ["css"]
  gulp.watch watchPaths.jade,    ["jade"]
  gulp.watch watchPaths.html,    ["html"]
  gulp.watch watchPaths.images,  ["images"]
  gulp.watch watchPaths.fonts,   ["fonts"]

gulp.task "open", ->
  gulp.src("build/index.html")
    .pipe(plumber())
    .pipe gopen("", url: httpURL)

gulp.task "debug", ["watch"], (callback) ->
  notifier.on 'start', () ->
    gulp.start "open"
    callback()

module.exports = [
  "server"
  "watch"
  "open"
  "debug"
]
