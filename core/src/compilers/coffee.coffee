cs = require 'coffee-script/lib/coffee-script/coffee-script'
fs = require 'fs'

class Coffee

  constructor: (@singool) ->

  run: (module, filename) =>
    source = fs.readFileSync filename, 'utf8'
    module._compile cs.compile(source), filename

module.exports = Coffee