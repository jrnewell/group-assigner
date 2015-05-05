gulp = require "gulp"
gutil = require "gulp-util"
jade = require "gulp-jade"
coffee = require "gulp-coffee"
sourcemaps = require "gulp-sourcemaps"
rimraf = require "gulp-rimraf"
stylus = require "gulp-stylus"
nib = require "nib"
plumber = require "gulp-plumber"
gulpIf = require "gulp-if"
changed = require "gulp-changed"
runSequence = require "run-sequence"
liveReload = require "gulp-livereload"
browserify = require "browserify"
watchify = require "watchify"
source = require "vinyl-source-stream"
notify = require "gulp-notify"
prettyHrtime = require "pretty-hrtime"
_ = require "lodash"
constants = require "./constants"

{srcPaths, destPaths, shared, browserifyMain, jadeLocals} = constants

#
# vendor tasks
#

gulp.task "vendor-js", ->
  gulp.src _.map(srcPaths.vendors, (x) -> "#{x}/js/**/*.js")
  .pipe(changed(destPaths.scripts))
  .pipe(gulp.dest(destPaths.scripts))
  .pipe gulpIf(shared.isWatching, liveReload())

gulp.task "vendor-css", ->
  gulp.src _.map(srcPaths.vendors, (x) -> "#{x}/css/**/*.css")
  .pipe(changed(destPaths.stylesheets))
  .pipe(gulp.dest(destPaths.stylesheets))
  .pipe gulpIf(shared.isWatching, liveReload())

gulp.task "vendor-img", ->
  gulp.src _.map(srcPaths.vendors, (x) -> "#{x}/img/**/*")
  .pipe(changed(destPaths.images))
  .pipe(gulp.dest(destPaths.images))
  .pipe gulpIf(shared.isWatching, liveReload())

gulp.task "vendor-fonts", ->
  gulp.src _.map(srcPaths.vendors, (x) -> "#{x}/fonts/**/*")
  .pipe(changed(destPaths.fonts))
  .pipe(gulp.dest(destPaths.fonts))
  .pipe gulpIf(shared.isWatching, liveReload())

gulp.task "vendor", ["vendor-js", "vendor-css", "vendor-img", "vendor-fonts"]

#
# build src tasks
#

# scripts

gulp.task "web-workers", () ->
  return gulp.src(srcPaths.workers)
    .pipe(plumber())
    .pipe(changed(destPaths.workers, {extension: ".js"}))
    .pipe(sourcemaps.init())
    .pipe(coffee())
    .pipe(sourcemaps.write())
    .pipe(gulp.dest(destPaths.workers))
    .pipe gulpIf(shared.isWatching, liveReload())

gulp.task "browserify", () ->
  bOpts =
    entries: browserifyMain.entries
    extensions: [".js", ".coffee"]
    debug: true

  bundler = if shared.isWatching
  then watchify browserify _.extend(bOpts, watchify.args)
  else browserify bOpts

  handleErrors = () ->
    args = Array::slice.call(arguments)

    notify.onError(
      title: "Compile Error"
      message: '<%= error.message %>'
    ).apply(this, args)

    @emit "end"

  startTime = null
  startLog = () ->
    startTime = process.hrtime()
    gutil.log "Starting '#{gutil.colors.cyan 'bundle'}'..."

  endLog = () ->
    taskTime = process.hrtime(startTime)
    prettyTime = prettyHrtime(taskTime)
    gutil.log "Finished '#{gutil.colors.cyan 'bundle'}' in #{gutil.colors.magenta prettyTime}"

  bundle = () ->
    startLog()
    return bundler
      .bundle()
      .on 'error', handleErrors
      .pipe(plumber())
      .pipe source(browserifyMain.dest)
      .pipe gulp.dest(destPaths.scripts)
      .on "end", endLog
      .pipe gulpIf(shared.isWatching, liveReload())

  bundler.on "update", bundle if shared.isWatching

  return bundle()

gulp.task "scripts", ["web-workers", "browserify"]

# style sheets

gulp.task "stylus", ->
  gulp.src(srcPaths.stylus)
    .pipe(plumber())
    .pipe(changed(destPaths.stylesheets, {extension: ".css"}))
    .pipe(stylus({use: [nib()]}))
    .pipe(gulp.dest(destPaths.stylesheets))
    .pipe gulpIf(shared.isWatching, liveReload())

gulp.task "css", ->
  gulp.src(srcPaths.css)
    .pipe(plumber())
    .pipe(changed(destPaths.stylesheets))
    .pipe(gulp.dest(destPaths.stylesheets))
    .pipe gulpIf(shared.isWatching, liveReload())

gulp.task "stylesheets", ["stylus", "css"]

# templates

gulp.task "jade", ->
  gulp.src(srcPaths.jade)
    .pipe(plumber())
    .pipe(changed(destPaths.html, {extension: ".html"}))
    .pipe(jade(
      locals: jadeLocals
      pretty: true
    )).pipe(gulp.dest(destPaths.html))
    .pipe gulpIf(shared.isWatching, liveReload())

gulp.task "html", ->
  gulp.src(srcPaths.html)
    .pipe(plumber())
    .pipe(changed(destPaths.html))
    .pipe(gulp.dest(destPaths.html))
    .pipe gulpIf(shared.isWatching, liveReload())

gulp.task "templates", ["jade", "html"]

# assets

gulp.task "images", ->
  gulp.src(srcPaths.images)
    .pipe(plumber())
    .pipe(changed(destPaths.images))
    .pipe(gulp.dest(destPaths.images))
    .pipe gulpIf(shared.isWatching, liveReload())

gulp.task "fonts", ->
  gulp.src(srcPaths.fonts)
    .pipe(plumber())
    .pipe(changed(destPaths.fonts))
    .pipe(gulp.dest(destPaths.fonts))
    .pipe gulpIf(shared.isWatching, liveReload())

gulp.task "assets", ["images", "fonts"]

gulp.task "clean", ->
  gulp.src("build", read: false)
    .pipe(plumber())
    .pipe(rimraf())

gulp.task "build", (callback) ->
  runSequence "clean", ["vendor", "scripts", "stylesheets", "templates", "assets"], callback

module.exports = [
  "vendor-js"
  "vendor-css"
  "vendor-img"
  "vendor-img"
  "vendor"
  "scripts"
  "stylus"
  "css"
  "stylesheets"
  "jade"
  "html"
  "web"
  "images"
  "fonts"
  "assets"
  "clean"
  "build"
]
