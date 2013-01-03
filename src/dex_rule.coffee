_ = require 'underscore'

class @DexRule
  # Attibutes:
  # selector (string): CSS selector to extract data from
  # customKey (string): Custom key to use in JSON output
  # extractFnName (string): Name of Dex extraction function
  # innerText (boolean): Whether or not to extract innerText
  # attributes (array): List of attributes to extract from tag
  constructor: (attributes = {}) ->
    @selector = attributes.selector || "html"
    if attributes.parentSelector?
      @selector = "#{attributes.parentSelector} #{@selector}"
    @customKey = attributes.customKey || @selector
    if attributes.extractFnName in ['fromAll', 'fromFirst', 'fromLast']
      @extractFnName = attributes.extractFnName
    else
      @extractFnName = 'fromAll'
    @innerText = attributes.innerText || false
    if attributes.attributes instanceof Array
      @attributes = attributes.attributes
    else
      @attributes = []

    # Recursively create child rules
    @childRules = []
    if attributes.rules instanceof Array
      for ruleParams in attributes.rules
        childRule = DexRule.build_from_api_params(ruleParams, @selector)
        @childRules.push(childRule)

    # Defined at a later time:
    @extractedAttributes = {}
    @extractedInnerText = null

  extractAll: (dex) =>
    @extract(dex)
    for childRule in @childRules
      childRule.extractAll(dex)

  extract: (dex) =>
    options =
      innerText: @innerText
      attributes: @attributes
    result = dex[@extractFnName](@selector, options)
    @extractedInnerText = result.innerText
    delete result.innerText
    @extractedAttributes = result

  asJSON: =>
    json = {}
    json[@customKey] = @extractedAttributes
    if @innerText?
      json[@customKey].innerText = @extractedInnerText
    if @childRules.length > 0
      for childRule in @childRules
        for i, childJSON of childRule.asJSON()
          console.log 0,0,0,i,1,1,1,childJSON
          _.extend json[@customKey][i], childJSON
    json

  @build_from_api_params: (params, parentSelector) ->
    extractType = {'a': 'All', 'f': 'First', 'l': 'Last'}[params.t]
    new DexRule
      parentSelector: parentSelector
      selector: params.s
      customKey: params.k
      extractFnName: "from#{extractType}"
      innerText: {'f': false, 't': true}[params.i]
      attributes: params.a
      rules: params.r
