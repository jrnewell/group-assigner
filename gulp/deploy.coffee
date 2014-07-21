gulp = require "gulp"
rimraf = require "gulp-rimraf"
uglify = require "gulp-uglify"
concat = require "gulp-concat"
minifyCss = require "gulp-minify-css"
stripDebug = require "gulp-strip-debug"
plumber = require "gulp-plumber"
header = require "gulp-header"
replace = require "gulp-replace"
runSequence = require "run-sequence"
es = require "event-stream"
minMap = require "gulp-min-map"
imagemin = require "gulp-imagemin"
constants = require "./constants"

{headerText} = constants

#
# deploy (production)
#

gulp.task "deploy-clean", ->
  gulp.src(["release"], read: false)
    .pipe(plumber())
    .pipe(rimraf())

minFiles = {}

gulp.task "deploy-html", ->
  gulp.src("build/**/*.html")
    .pipe(plumber())
    .pipe(minMap(["js", "css"], minFiles))
    .pipe gulp.dest("release")

gulp.task "deploy-js", ->
  streams = []
  jsMinFiles = minFiles.js
  for minFile of jsMinFiles
    if jsMinFiles.hasOwnProperty(minFile)
      stream = gulp.src(jsMinFiles[minFile])
        .pipe(stripDebug())
        .pipe(uglify())
        .pipe(concat(minFile))
        .pipe(header(headerText, {}))
        .pipe gulp.dest("release")
      streams.push stream

  es.merge.apply es, streams

gulp.task "deploy-css", ->
  streams = []
  cssMinFiles = minFiles.css
  for minFile of cssMinFiles
    if cssMinFiles.hasOwnProperty(minFile)
      stream = gulp.src(cssMinFiles[minFile])
        .pipe(minifyCss())
        .pipe(concat(minFile))
        .pipe(header(headerText, {}))
        .pipe gulp.dest("release")
      streams.push stream

  es.merge.apply es, streams

gulp.task "deploy-fonts", ->
  gulp.src("build/fonts/**/*")
    .pipe(plumber())
    .pipe gulp.dest("release/fonts")

gulp.task "deploy-nonmin-images", ->
  gulp.src("build/img/**/*.!(png|jpg|jpeg|gif)")
    .pipe(plumber())
    .pipe gulp.dest("release/img")

gulp.task "deploy-min-images", ->
  gulp.src("build/img/**/*+(png|jpg|jpeg|gif)")
    .pipe(plumber())
    .pipe(imagemin())
    .pipe gulp.dest("release/img")

gulp.task "deploy-assets", ["deploy-fonts", "deploy-nonmin-images", "deploy-min-images"]

gulp.task "deploy", (callback) ->
  runSequence "deploy-clean", "deploy-html", ["deploy-js", "deploy-css"], "deploy-assets", callback

module.exports = [
  "deploy-clean"
  "deploy-html"
  "deploy-js"
  "deploy-css"
  "deploy-fonts"
  "deploy-nonmin-images"
  "deploy-min-images"
  "deploy-assets"
  "deploy"
]
