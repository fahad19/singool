_       = require 'underscore'
fs      = require 'fs'
express = require 'express'
findit  = require 'findit'

class Singool
  
  config: {}
  
  jsPackage: null
  
  cssPackage: null

  _compilers: {}
  
  defaults:
    theme: null
    publicPath: null
    cssPath: null
    jsPath: null
    themesPath: null
    pluginsPath: null
    paths: []
    
    compress: false
    plugins: []
    vendors: []
    ignore: []
    compilers: {}
    test: false
    init: true
    cssFile: 'app.css'
    jsFile: 'app.js'
  
  constructor: (config) ->
    @config = _.defaults config, @defaults
    @compilers()
    @generators()

  generators: ->
    Css  = require './generators/css'
    @css = new Css @

    Js  = require './generators/js'
    @js = new Js @

    Layout  = require './generators/layout'
    @layout = new Layout @
  
  testCases: ->
    cases = []
    
    for i, path of @config.paths
      files = findit.sync path
      for j, file of files
        if /\/tests\/cases\//.test(file)
          testCase = file.replace path + '/', ''
          filename = _.last testCase.split('/')
          if filename.indexOf('.') != -1 or filename.indexOf('.') > 0
            extension = filename.substr(filename.lastIndexOf('.') + 1)
            cases.push testCase.replace '.' + extension, ''
    
    cases
  
  compilers: ->
    compilers = {}
    compilerFiles = fs.readdirSync module.id.replace _.last(module.id.split('/')), 'compilers/'
    for k, v of compilerFiles
      compilerName = v.replace '.js', ''
      if !compilerName then continue

      Compiler = require './compilers/' + compilerName
      @_compilers[compilerName] = new Compiler @
      compilers[compilerName] = @_compilers[compilerName].run

    @config.compilers = compilers
  
  build: (callback = false) ->
    @css.write()
    @js.write()
    @layout.write()

    if typeof callback == 'function'
      callback()
  
  createServer: (serveStatic = false) ->
    app = express.createServer()
    
    app.configure =>
      app.use express.static @config.publicPath
    
    app.get '/', (req, res) => 
      res.send @layout.generate()
    
    if !serveStatic
      app.get '/css/app.css', (req, res) =>
        @css.generate (source) ->
          res.header 'Content-Type', 'text/css'
          res.send source
    
      app.get '/js/app.js', (req, res) =>
        @js.generate (source) ->
          res.header 'Content-Type', 'application/x-javascript'
          res.send source
    
    app
  
  clear: ->
    @layout.clear()
    @js.clear()
    @css.clear()

  registerTasks: ->
    tasks = fs.readdirSync module.id.replace _.last(module.id.split('/')), 'tasks/'
    for k, taskFile of tasks
      taskName = taskFile.replace '.js', ''
      T = require './tasks/' + taskName
      t = new T @
      task taskName, t.description, t.run

module.exports = Singool