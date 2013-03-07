_       = require 'underscore'
fs      = require 'fs'
stitch  = require 'stitch-extra'
uglify  = require 'uglify-js'

class Js
  
  config: null

  constructor: (@singool) ->
    @config = @singool.config
    @prepare()

  prepare: ->
    @ignore()
    @vendors()
    @compilers

  ignore: ->
    @config.ignore.push /\/vendors\//
    
    if !@config.test
      @config.ignore.push /\/tests\//
    
    availablePlugins = fs.readdirSync @config.pluginsPath
    for k, availablePlugin of availablePlugins
      if _.indexOf(@config.plugins, availablePlugin) == -1
        regex = new RegExp '/' + @config.pluginsPath + '/' + availablePlugin + '/', 'i'
        @config.ignore.push regex

  getVendorsByPath: (path) ->
    vendors = {}
    if fs.existsSync path + '/config/vendors.json'
      pathVendors = JSON.parse fs.readFileSync path + '/config/vendors.json', 'utf8'
      for k, pathVendor of pathVendors
        vendors[pathVendor] = path + '/vendors/' + pathVendor
    
    vendors

  vendors: ->
    for k, path of @config.paths
      @config.vendors = _.extend @getVendorsByPath(path), @config.vendors
      for l, plugin of @config.plugins
        @config.vendors = _.extend @getVendorsByPath(path + '/' + plugin), @config.vendors
    
    @config.vendors = _.extend @getVendorsByPath(@config.themesPath + '/' + @config.theme), @config.vendors
    
    vendorsByFilename = {};
    for k, v of @config.vendors
      filename = _.last v.split '/'
      vendorsByFilename[filename] = v
    
    if !@config.init and _.has(vendorsByFilename, 'init.js')
      delete vendorsByFilename['init.js']
    
    @config.vendors = _.values vendorsByFilename

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

  generate: (callback = false) ->
    pkg = stitch.createPackage
      dependencies: @config.vendors
      paths: @config.paths
      compilers: @config.compilers
      ignore: @config.ignore

    pkg.compile (err, source) =>
      if err then throw err

      if @config.compress
        jsp = uglify.parser
        pro = uglify.uglify

        ast = jsp.parse source
        ast = pro.ast_mangle ast
        ast = pro.ast_squeeze ast
        source = pro.gen_code ast

      if callback then callback source

  write: (path = null) ->
    if !path
      path = @config.jsPath + '/' + @config.jsFile
    @generate (source) =>
      fs.writeFileSync path, source
      console.log 'JS file written at: ' + path

  clear: ->
    file = @config.jsPath + '/' + @config.jsFile
    if fs.existsSync(file)
      fs.unlinkSync(file)
      console.log @config.jsFile + ' deleted'

module.exports = Js