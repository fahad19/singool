fs   = require 'fs'
util = require 'util'

class Underscore

  constructor: (@singool) ->

  run: (module, filename) =>
    source = fs.readFileSync filename, 'utf8'
    source = 'module.exports = _.template(' + util.inspect(source) + ');'
    module._compile source, filename

module.exports = Underscore