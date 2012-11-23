_ = require 'underscore'
request = require 'request'
jsdom = require 'jsdom'
fs = require("fs")
jquery = fs.readFileSync("./vendor/jquery.js").toString()

class @Dex
  constructor: (@html, cb) ->
    jsdom.env
      html: @html
      src: jquery
      done: (err, window) =>
        if err?
          cb(err, null)
        else
          @$ = window.$
          cb(null, @)

  all: (selector) =>
    elements = @$(selector)
    if elements.length > 0
      elements
    else
      []

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

  scrape: (options, cb) ->
    defaults =
      method: 'GET'
      headers:
        'User-Agent': 'Mozilla/5.0 (compatible; Dex; +https://github.com/6/Dex)'
    request _.defaults(options, defaults), cb

  # TODO - make these methods synchronous if possible
  @build_from_html: (html, cb) ->
    new Dex(html, cb)

  @build_from_request: (options, cb) ->
    try
      Dex.prototype.scrape options, (err, res, body) ->
        if err?
          cb(err, null)
        else
          new Dex(body, cb)
    catch err
      cb(err, null)
