class Singool

  constructor: (@singool) ->

  run: (module, filename) =>
    source = ''
    if filename.indexOf 'singool/config/index.singool' > -1
      content =
        theme: @singool.config.theme
        plugins: @singool.config.plugins
        test: @singool.config.test
      
      if @singool.config.test
        content.testCases = @singool.testCases()
      
      source = 'module.exports = ' + JSON.stringify(content) + ';'
    module._compile source, filename

module.exports = Singool