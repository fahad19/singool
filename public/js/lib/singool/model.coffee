Validator = require 'singool/utils/validator'

class Model extends Backbone.Model

  schema: {}
  
  validator: new Validator
  
  validationErrors: {}
  
  extract: (form) ->
    attr = {}
    fields = _.keys @schema
    for k, v of $(form).serializeArray()
      if _.indexOf fields, v.name > -1
        attr[v.name] = v.value
    
    $(form).find('input[type=checkbox][name]').not(':checked').each ->
      name = $(@).attr 'name'
      if _.indexOf fields, name > -1
        attr[name] = false
    
    out = {}
    for k, v of attr
      if k.indexOf('.') == -1
        out[k] = v
      else
        # TODO: primaryField? check if object, then continue
        field = _.first k.split('.')
        subField = _.last k.split('.')
        if !out[field]?
          out[field] = {}
        out[field][subField] = v

    out
  
  validate: (attributes) ->
    if !@validates attributes
      "Validation failed"
  
  validates: (attributes = null) ->
    if !attributes
      attributes = @attributes
    
    attributes = @getFlattenedAttributes attributes
    schema = @getFlattenedSchema()

    @validationErrors = {}
    for field, value of attributes
      if schema[field]?.validate?
        for ruleName, validation of schema[field].validate
          check = true
          if _.isRegExp validation.rule
            if !validation.rule.test value
              check = false
          else if _.isFunction validation.rule
            if !validation.rule value, attributes, @
              check = false
          else
            if !@validator.checkRule ruleName, value
              check = false
          
          if !check
            if !@validationErrors[field]?
              @validationErrors[field] = {}
            
            @validationErrors[field][ruleName] = validation.message
    
    if !_.isEmpty @validationErrors
      false
    else
      true

  getFlattenedAttributes: (attributes) ->
    out = {}
    for k, v of attributes
      if _.isObject(v)
        for objK, objV of v
          name = k + '.' + objK
          out[name] = objV
      else
        out[k] = v
    out

  getFlattenedSchema: ->
    out = {}
    for field, options of @schema
      if options.type == 'object'
        for objectField, fieldOptions of options.schema
          name = field + '.' + objectField
          out[name] = fieldOptions
      else
        out[field] = options
    out

module.exports = Model