tlr = require("tiny-lr")()

# gulp source
srcPaths =
  coffee:   "src/js/**/*.coffee"
  js:       "src/js/**/*.js"
  stylus: [
            "src/css/**/*.styl"
            "!src/css/**/imports/*.styl"
  ]
  css:      "src/css/**/*.css"
  jade: [
            "src/**/*.jade"
            "!src/**/_*.jade"
            "!src/**/layouts/*.jade"
  ]
  html:     "src/**/*.html"
  images:   "src/img/**/*"
  fonts:    "src/fonts/**/*"
  vendors: [
            "vendor/angular"
            "vendor/bootflat"
            "vendor/bootstrap"
            "vendor/font-awesome"
            "vendor/jquery"
            "vendor/modernizr"
  ]

watchPaths =
  coffee: srcPaths.coffee
  js:     srcPaths.js
  stylus: srcPaths.stylus
  css:    srcPaths.css
  jade: [
          srcPaths.jade[0]
          "gulp/constants.coffee"
  ]
  html:   srcPaths.html
  images: srcPaths.images
  fonts:  srcPaths.fonts


# gulp destinations
destPaths =
  scripts:      "build/js"
  stylesheets:  "build/css"
  html:         "build"
  images:       "build/img"
  fonts:        "build/fonts"

browserifyMain =
  entries: [ "./src/js/app.coffee" ]
  dest: "app.js"

# jade locals
jadeLocals =
  stylesheets: [
    "bootstrap.css"
    "bootflat.css"
    "font-awesome.css"
    "app.css"
  ]
  scripts: [
    "jquery-2.1.1.js"
    "jquery.fs.selecter.min.js"
    "jquery.fs.stepper.min.js"
    "modernizr.js"
    "bootstrap.js"
    "icheck.min.js"
    "angular.js"
    "app.js"
  ]


# ports and address
httpPort = 8080
httpURL = "http://127.0.0.1:" + httpPort
lrPort = 35729

# copyright
headerText = "/***\n * \n * My Project 2014 - Copyright James Newell\n *\n ***/\n"

# shared vars
shared = isWatching: false

module.exports = {
  tlr: tlr
  srcPaths: srcPaths
  watchPaths: watchPaths
  destPaths: destPaths
  browserifyMain: browserifyMain
  jadeLocals: jadeLocals
  httpPort: httpPort
  httpURL: httpURL
  lrPort: lrPort
  headerText: headerText
  shared: shared
}