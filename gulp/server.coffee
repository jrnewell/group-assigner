gulp = require "gulp"
gutil = require "gulp-util"
plumber = require "gulp-plumber"
gopen = require "gulp-open"
constants = require "./constants"

{tlr, httpPort, httpURL, lrPort, watchPaths, shared} = constants

#
# server-related tasks
#

gulp.task "server", ["build"], (callback) ->
  connect = require("connect")
  http = require("http")
  server = connect().use(require("connect-livereload")(port: lrPort)).use(connect.static("./build"))
  http.createServer(server).listen httpPort, ->
    gutil.log "connect server listening on port " + httpPort
    callback()

gulp.task "watch", (callback) ->

  # set flag, so liveReload will function
  shared.isWatching = true

  # need to run this after the watch flag is set
  gulp.start "server"

  tlr.listen lrPort, ->
    gutil.log "tiny-lr server listening on port #{lrPort}"
    callback()

  gulp.watch watchPaths.stylus, ["stylus"]
  gulp.watch watchPaths.css,    ["css"]
  gulp.watch watchPaths.jade,   ["jade"]
  gulp.watch watchPaths.html,   ["html"]
  gulp.watch watchPaths.images, ["images"]
  gulp.watch watchPaths.fonts,  ["fonts"]

gulp.task "open", ->
  gulp.src("build/index.html")
    .pipe(plumber())
    .pipe gopen("", url: httpURL)

module.exports = [
  "server"
  "watch"
  "open"
]
