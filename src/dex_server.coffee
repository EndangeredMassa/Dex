_ = require 'underscore'
_.str = require 'underscore.string'
express = require 'express'
lessMiddleware = require 'less-middleware'
coffeescript = require('connect-coffee-script')
connect = require 'connect'
{Dex} = require './dex'
{DexRules} = require './dex_rules'

# Override this method for custom config
exports.configExpressApp = (app) ->
  publicFolder = "#{__dirname}/public"
  app.configure ->
    app.set("views", "#{__dirname}/views")
    app.set("view engine", "jade")
    app.use lessMiddleware
      src:"#{__dirname}/styles"
      dest: publicFolder
      compress: true
    app.use coffeescript
     src: "#{__dirname}/coffeescripts"
     dest: publicFolder
    app.use(express.static(publicFolder))
    app.use(express.bodyParser())
    app.use(app.router)

class @DexServer
  constructor: (options = {}) ->
    defaults =
      port: process.env.PORT || 7000
    @options = _.defaults(options, defaults)
    app = express()
    exports.configExpressApp(app)

    app.get '/', (req, res) ->
      res.setHeader('Content-Type', 'text/plain')
      res.send("DexServer is up and running.")

    app.get '/api.json', (req, res) =>
      if req.query.edit?
        # Render edit API endpoint form
        @handleEditRequest(req.query, res)
      else
        # Render JSONP API endpoint
        @handleApiRequest(req.query, res)

    app.post '/api.json', (req, res) =>
      @handleApiRequest(req.params, res)

    console.log "Listening on localhost:#{@options.port}"
    app.listen(@options.port)

  renderError: (res, url, err) =>
    reason = JSON.stringify(err)
    json = {url: url, error: {reason: reason}}
    res.jsonp(400, json)

  # Parameters:
  # r[with index]:
  #   t: "a" (all), "f" (first), or "l" (last)
  #   s: <selector>
  #   k: <custom selector key> (optional)
  #   i: 0 (false, default) or 1 (true) for innerText option (optional)
  #   a[without index]:  <list of attributes> (optional)
  #   r[with index]: <list of child selectors> (optional, can be infinitely nested)
  handleApiRequest: (params, res) =>
    console.log "API request", params
    url = _.str.trim(params.url)

    unless params.r?.length > 0
      return @renderError(res, url, "No CSS selectors specified.")

    unless params.url?.match(/^http/)
      return @renderError(res, url, "Invalid URL.")

    rules = DexRules.build_from_api_params(params.r)

    Dex.build_from_request {url: url, rules: rules}, (err, dex) =>
      return @renderError(res, url, err)  if err?
      res.jsonp(200, dex.asJSON())

  handleEditRequest: (params, res) =>
    delete params.edit
    title = if Object.keys(params).length > 0 then "Edit API endpoint" else "Build a new API endpoint"
    console.log title, params
    res.render 'edit', {title: title}

new @DexServer # TODO remove
