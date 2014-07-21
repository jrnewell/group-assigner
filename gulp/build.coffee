gulp = require "gulp"
jade = require "gulp-jade"
coffee = require "gulp-coffee"
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
_ = require "lodash"
constants = require "./constants"

{tlr, srcPaths, destPaths, shared, browserifyMain, jadeLocals} = constants

#
# vendor tasks
#

gulp.task "vendor-js", ->
  gulp.src _.map(srcPaths.vendors, (x) -> "#{x}/js/**/*.js")
  .pipe(changed(destPaths.scripts))
  .pipe(gulp.dest(destPaths.scripts))
  .pipe gulpIf(shared.isWatching, liveReload(tlr))

gulp.task "vendor-css", ->
  gulp.src _.map(srcPaths.vendors, (x) -> "#{x}/css/**/*.css")
  .pipe(changed(destPaths.stylesheets))
  .pipe(gulp.dest(destPaths.stylesheets))
  .pipe gulpIf(shared.isWatching, liveReload(tlr))

gulp.task "vendor-img", ->
  gulp.src _.map(srcPaths.vendors, (x) -> "#{x}/img/**/*")
  .pipe(changed(destPaths.images))
  .pipe(gulp.dest(destPaths.images))
  .pipe gulpIf(shared.isWatching, liveReload(tlr))

gulp.task "vendor-fonts", ->
  gulp.src _.map(srcPaths.vendors, (x) -> "#{x}/fonts/**/*")
  .pipe(changed(destPaths.fonts))
  .pipe(gulp.dest(destPaths.fonts))
  .pipe gulpIf(shared.isWatching, liveReload(tlr))

gulp.task "vendor", ["vendor-js", "vendor-css", "vendor-img", "vendor-fonts"]

#
# build src tasks
#

# scripts (browserify)

gulp.task "scripts", () ->
  bundleMethod = (if shared.isWatching then watchify else browserify)

  bundler = bundleMethod
    entries: browserifyMain.entries
    extensions: [".js", ".coffee"]

  handleErrors = () ->
    args = Array::slice.call(arguments)

    notify.onError(
      title: "Compile Error"
      message: '<%= error.message %>'
    ).apply(this, args)

    @emit "end"

  bundle = () ->
    return bundler
      .bundle {debug: true}
      .on 'error', handleErrors
      .pipe(plumber())
      .pipe source(browserifyMain.dest)
      .pipe gulp.dest(destPaths.scripts)
      .pipe gulpIf(shared.isWatching, liveReload(tlr))

  bundler.on "update", bundle if shared.isWatching

  return bundle()

# style sheets

gulp.task "stylus", ->
  gulp.src(srcPaths.stylus)
    .pipe(plumber())
    .pipe(changed(destPaths.stylesheets, {extension: ".css"}))
    .pipe(stylus({use: [nib()]}))
    .pipe(gulp.dest(destPaths.stylesheets))
    .pipe gulpIf(shared.isWatching, liveReload(tlr))

gulp.task "css", ->
  gulp.src(srcPaths.css)
    .pipe(plumber())
    .pipe(changed(destPaths.stylesheets))
    .pipe(gulp.dest(destPaths.stylesheets))
    .pipe gulpIf(shared.isWatching, liveReload(tlr))

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
    .pipe gulpIf(shared.isWatching, liveReload(tlr))

gulp.task "html", ->
  gulp.src(srcPaths.html)
    .pipe(plumber())
    .pipe(changed(destPaths.html))
    .pipe(gulp.dest(destPaths.html))
    .pipe gulpIf(shared.isWatching, liveReload(tlr))

gulp.task "templates", ["jade", "html"]

# assets

gulp.task "images", ->
  gulp.src(srcPaths.images)
    .pipe(plumber())
    .pipe(changed(destPaths.images))
    .pipe(gulp.dest(destPaths.images))
    .pipe gulpIf(shared.isWatching, liveReload(tlr))

gulp.task "fonts", ->
  gulp.src(srcPaths.fonts)
    .pipe(plumber())
    .pipe(changed(destPaths.fonts))
    .pipe(gulp.dest(destPaths.fonts))
    .pipe gulpIf(shared.isWatching, liveReload(tlr))

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
