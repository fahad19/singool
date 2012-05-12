class Validator
  
  rules:
    notEmpty: /[^\s]+/m
  
  checkRule: (rule, value, options = null) ->
      if @rules[rule].test value
        true
      else
        false
  
module.exports = Validator