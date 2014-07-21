# Gulp Starter Template

Starter project using the gulp build system to make single page apps for angular.js (or can be modified for any other front-end library).  Also includes local copies of the following
- Jquery
- Modernizr
- Bootstrap
- Font Awesome
- Bootflat

Uses the following tools and libraries
- Coffeescript
- Stylus
- Jade
- Browserify
- LiveReload

## Usage

Client code lives in the 'src' directory.  To build, run the task (the results are in the 'build' directory):

```shell
gulp build
```

To start up a connect.js server and rebuild file changes on the fly (use the LiveReload plugin in your browser), run the task:

```shell
gulp watch
```

To minify js/css files and optimize images, run the following task (the results are in the 'release' directory):

```shell
gulp deploy
```

## License

[MIT License](http://en.wikipedia.org/wiki/MIT_License)