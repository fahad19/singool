class Foo extends require('singool/model')

  schema:
    title:
      type: 'text'
      label: 'Title'
      validate:
        notEmpty:
          rule: 'notEmpty'
          message: 'Field cannot be empty.'
    description:
      type: 'textarea'
      label: 'Description'
    priority:
      type: 'select'
      label: 'Priority'
      empty: ' - Please choose one - '
      options:
        'high': 'High'
        'medium': 'Medium'
        'low': 'Low'      
      validate:
        notEmpty:
          rule: 'notEmpty'
          message: 'Field cannot be empty.'
    done:
      type: 'checkbox'
      label: 'Done?'
  
  defaults:
    title: null
    description: null
    #priority: 'medium'
    done: false
    comments: []

module.exports = Foo