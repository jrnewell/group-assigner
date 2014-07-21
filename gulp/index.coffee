gulp = require "gulp"
build = require "./build"
server = require "./server"
deploy = require "./deploy"

gulp.task "default", ["scripts", "stylesheets", "templates", "assets", "server", "watch"]

module.exports = gulp
