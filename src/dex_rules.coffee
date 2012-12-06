_ = require 'underscore'
{DexRule} = require './dex_rule'

class @DexRules
  constructor: (@rules) ->

  extractAll: (dex) =>
    for rule in @rules
      rule.extractAll(dex)

  asJSON: =>
    _.map @rules, (rule) =>
      rule.asJSON()

  @build_from_api_params: (params) ->
    rules = _.map params, (ruleParams) ->
      DexRule.build_from_api_params(ruleParams)
    new DexRules(rules)
