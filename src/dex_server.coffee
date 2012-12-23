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

    app.get '/', (req, res) =>
      if req.query.edit?
        # Render edit API endpoint form
        @handleEditRequest(req.query, res)
      else
        # Render JSONP API endpoint
        @handleApiRequest(req.query, res)

    app.post '/', (req, res) =>
      @handleApiRequest(req.params, res)

    console.log "Listening on localhost:#{@options.port}"
    app.listen(@options.port)

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
    @handleRequest params, (status, json) =>
      res.jsonp(status, json)

  handleEditRequest: (params, res) =>
    delete params.edit
    title = if Object.keys(params).length > 0 then "Edit API endpoint" else "Build a new API endpoint"
    console.log title, params
    @handleRequest params, (status, json) =>
      res.render 'edit', {title: title, params: params, json: json}

  handleRequest: (params, cb) =>
    url = _.str.trim(params.url)

    unless params.r?.length > 0
      cb(400, @errorJSON("No CSS selectors specified."))

    unless params.url?.match(/^http/)
      cb(400, @errorJSON("Invalid URL."))

    rules = DexRules.build_from_api_params(params.r)

    Dex.build_from_request {url: url, rules: rules}, (err, dex) =>
      if err?
        cb(400, @errorJSON(err))
      else
        try
          cb(200, dex.asJSON())
        catch err
          cb(500, @errorJSON("Internal server error."))

  errorJSON: (err) =>
    reason = JSON.stringify(err)
    {error: {reason: reason}}

new @DexServer # TODO remove
