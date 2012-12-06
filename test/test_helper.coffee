global.sinon = require 'sinon'
sinonChai = require "sinon-chai"
chai = require 'chai'
chai.use(sinonChai)
global.expect = chai.expect
global.$ = require 'jquery'

global.Dex = require('../src/dex').Dex
global.DexRule = require('../src/dex_rule').DexRule
global.DexRules = require('../src/dex_rules').DexRules

global.Fixtures =
  html:
    basic: "<h1>Hello <i>world</i></h1>"
    list: "
      <ul>
        <li name='item-1' class='item'>Item #1</li>
        <li name='item-2' class='item'>Item #2</li>
        <li name='item-3' class='item'>Item #3</li>
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
    articles: "
      <article title='Article 0'>
        <h1>Article 0</h1>
        <a href='/article-0'>Read</a>
      </article>
      <article title='Article 1'>
        <h1>Article 1</h1>
        <a href='/article-1'>Read</a>
      </article>"
  apiParams:
    allParams:
      [
        {
          s: 'article a'
          k: 'article_data'
          t: 'l'
          i: 't'
          a: ['href']
        }
      ]
    nestedParams:
      [
        {
          s: 'article'
          t: 'f'
          i: 'f'
          r:
            [
              {
                s: 'h1'
                k: 'article_title'
                i: 't'
              },
              {
                s: 'a'
                k: 'article_link'
                i: 't'
                a: ['href']
              }
            ]
        }
      ]
  json:
    allParams:
      {
        article_data:
          {
            innerText: "Read"
            href: "/article-1"
          }
      }
    nestedParams:
      {
        article:
          {
            children: {
              article_title:
                {
                  innerText: "Article 0"
                }
              article_link:
                {
                  innerText: "Read"
                  href: "/article-0"
                }
              }
          }
      }
