global.sinon = require 'sinon'
sinonChai = require "sinon-chai"
chai = require 'chai'
chai.use(sinonChai)
global.expect = chai.expect
global.$ = require 'jquery'

global.Dex = require('../src/dex').Dex

global.Fixtures =
  html:
    basic: "<h1>Hello <i>world</i></h1>"
    list: "
      <ul>
        <li>Item #1</li>
        <li>Item #2</li>
        <li>Item #3</li>
      </ul>"
    fieldset: "
      <fieldset>
        <label class='username'>Username:</label>
        <input class='username'>
        <input class='not-adjacent-to-label'>
        <label class='not-adjacent-to-input'>N/A:</label>
        <label class='password'>Password:</label>
        <input class='password'>
      </fieldset>"
