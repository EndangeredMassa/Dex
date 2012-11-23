global.sinon = require 'sinon'
sinonChai = require "sinon-chai"
chai = require 'chai'
chai.use(sinonChai)
global.expect = chai.expect

global.Dex = require('../src/dex').Dex

global.Fixtures =
  html:
    basic: "<h1>Hello <i>world</i></h1>"
    list: """
          <ul>
            <li>Item #1</li>
            <li>Item #2</li>
            <li>Item #3</li>
          </ul>
          """
