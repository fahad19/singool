fs   = require 'fs'
exec = require('child_process').exec

class Install

  constructor: (@singool) ->

  description: 'Download dependencies'

  dependencies: =>
    rootPath = @singool.rootPath()
    component = fs.readFileSync rootPath + '/component.json'
    dependencies = JSON.parse(component).dependencies
    dependencies

  run: =>
    cmd = 'cd ' + @singool.rootPath() + ' && ./node_modules/.bin/bower install'
    for pkg, ver of @dependencies()
      cmd += ' ' + pkg + '#' + ver

    console.log 'Running command: ' + cmd
    exec cmd, (error, stdout, stderr) =>
      if error then throw error

      if stdout
        console.log stdout
      else
        console.log stderr

module.exports = Install