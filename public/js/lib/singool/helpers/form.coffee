class FormHelper extends require('helper')
  
  templates:
    text: require 'singool/templates/form/text'
    textarea: require 'singool/templates/form/textarea'
    select: require 'singool/templates/form/select'
    radio: require 'singool/templates/form/radio'
    checkbox: require 'singool/templates/form/checkbox'
    object: require 'singool/templates/form/object'
    
    object_text: require 'singool/templates/form/object_text'
    object_textarea: require 'singool/templates/form/object_textarea'

  defaults:
    field:
      value: null
      class: ''
    form:
      tag: 'form'
      attributes:
        class: 'form-horizontal'
    submit:
      tag: 'button'
      attributes:
        type: 'submit'
        class: 'btn btn-primary'
    reset:
      tag: 'button'
      attributes:
        type: 'reset'
        class: 'btn'
  
  model: null
  
  extract: (form) ->
    attributes = {}
    for k, v of $(form).serializeArray()
      attributes[v.name] = v.value
    attributes
  
  create: (model, attributes = {}) ->
    attributes = _.defaults attributes, @defaults.form.attributes
    
    @model = model
    out = '<' + @defaults.form.tag
    if attributes
      for k, v of attributes
        out += " #{k}=\"#{v}\""
    out += '>'
    out
    
  end: () ->
    @model = null
    out = '</' + @defaults.form.tag + '>'
    out
  
  inputs: () ->
    out = ''
    for field, options of @model.schema
      options = _.clone(options);
      out += @input field, options
    out
  
  input: (field, options) ->
    _options = 
      type: 'text'
      label: field
      value: null
    if @model and @model.get field
      _options.value = @model.get field
    options = _.defaults options, _options
    out = @[options.type] field, options
    out
  
  text: (field, options) ->
    options = _.defaults options, @defaults.field
    out  = @templates.text
      field: field
      options: options
    out
  
  textarea: (field, options) ->
    options = _.defaults options, @defaults.field
    out  = @templates.textarea
      field: field
      options: options
    out
  
  select: (field, options) ->
    options = _.defaults options, @defaults.field
    out = @templates.select
      field: field
      options: options
    out
  
  radio: (field, options) ->
    options - _.defaults options, @defaults.field
    out = @templates.radio
      field: field
      options: options
    out

  checkbox: (field, options) ->
    options = _.defaults options, @defaults.field
    out = @templates.checkbox
      field: field
      options: options
    out

  object: (field, options) ->
    options = _.defaults options, @defaults.field
    out = @templates.object
      field: field
      options: options

    $out = $('<div></div>')
    $out.html out
    for objectField, fieldOptions of options.schema
      fieldOptions = _.defaults fieldOptions, @defaults.field
      if options.value? and typeof options.value[objectField] != 'undefined'
        fieldOptions.value = options.value[objectField]
      name = field + '.' + objectField
      $out.find('.controls-container').append @templates['object_' + fieldOptions.type]
        field: name
        options: fieldOptions

    out = $out.html()
    out
  
  submit: (label = 'Save', attributes = {}) ->
    attributes = _.defaults attributes, @defaults.submit.attributes
    out = @view.html.tag @defaults.submit.tag, label, attributes
    out
  
  reset: (label = 'Cancel', attributes = {}) ->
    attributes = _.defaults attributes, @defaults.reset.attributes
    out = @view.html.tag @defaults.reset.tag, label, attributes
    out
  
  showErrors: (form, model) ->
    @clearErrors form
    for field, errors of model.validationErrors
      controlGroup = $(form).find("*[name='#{field}']").parents('.control-group')
      controlGroup.addClass 'error'
      controls = $(form).find("*[name='#{field}']").parents('.controls')
        
      messages = []
      for error, message of errors
        messages.push message

      controls.find('.help-inline').html messages.join ' '
  
  clearErrors: (form) ->
    $(form).find('.error .help-inline').empty()
    $(form).find('.error').removeClass('error')
  
module.exports = FormHelper