_ = require 'underscore'
request = require 'request'
jsdom = require 'jsdom'
fs = require("fs")
jquerySrc = fs.readFileSync("./vendor/jquery.js").toString()

class @Dex
  constructor: (@html, cb) ->
    try
      jsdom.env
        html: @html
        src: jquerySrc
        done: (err, window) =>
          if err?
            cb(err, null)
          else
            @$ = window.$
            cb(null, @)
    catch err
      cb(err, null)

  all: (selector) =>
    try
      @$(selector)
    catch err
      @$([])

  first: (selector) =>
    elements = @all(selector)
    if elements.length > 0
      elements[0..0]
    else
      null

  last: (selector) =>
    elements = @all(selector)
    if elements.length > 0
      elements[-1..]
    else
      null

  fromAll: (selector, options = {}) =>
    results = []
    @all(selector).each (i, element) =>
      results.push(@_result(element, options))
    results

  fromFirst: (selector, options) =>
    @fromAll(selector, options)[0] || null

  fromLast: (selector, options) =>
    results = @fromAll(selector, options)
    results[results.length - 1] || null

  childGroups: (parentSelector = "html", childSelectors = []) =>
    results = []
    @all(parentSelector).each (i, element) =>
      childrenHash = {}
      for childSelector in childSelectors
        try
          $child = @$(element).find(childSelector)
          childrenHash[childSelector] = $child  if $child.length > 0
        catch err
      results.push(childrenHash)
    @$(results)

  fromChildGroups: (parentSelector, childSelectors, childSelectorOptions = {}) =>
    results = []
    @childGroups(parentSelector, childSelectors).each (i, children) =>
      result = {}
      for childSelector, $child of children
        result[childSelector] = @_result($child, childSelectorOptions[childSelector])
      results.push(result)
    results

  _scrape: (options, cb) ->
    defaults =
      method: 'GET'
      headers:
        'User-Agent': 'Mozilla/5.0 (compatible; Dex; +https://github.com/6/Dex)'
    request _.defaults(options, defaults), cb

  _result: (element, options) =>
    defaults =
      innerText: false
      attributes: []
    options = _.defaults(options, defaults)

    result = {}
    result.innerText = $.trim($(element).text())  if options.innerText
    for attribute in options.attributes
      value = $(element).attr(attribute)
      value = null  if $.trim(value) == ''
      result[attribute] = value
    result

  # TODO - make these methods synchronous if possible
  @build_from_html: (html, cb) ->
    new Dex(html, cb)

  @build_from_request: (options, cb) ->
    try
      Dex.prototype._scrape options, (err, res, body) ->
        if err?
          cb(err, null)
        else
          new Dex(body, cb)
    catch err
      cb(err, null)
