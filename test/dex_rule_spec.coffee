require './test_helper'

describe "DexRule", =>
  describe ".build_from_api_params", =>
    context "with missing required params", =>
      it "uses defaults", =>
        rule = DexRule.build_from_api_params({})
        expect(rule.selector).to.equal('html')
        expect(rule.customKey).to.equal('html')
        expect(rule.extractFnName).to.equal('fromAll')
        expect(rule.innerText).to.equal(false)
        expect(rule.attributes).to.eql([])
        expect(rule.childRules).to.eql([])

    context "with unnested params", =>
      it "sets class attributes for these params", =>
        params = Fixtures.apiParams.allParams[0]
        rule = DexRule.build_from_api_params(params)
        expect(rule.selector).to.equal(params.s)
        expect(rule.customKey).to.equal(params.k)
        expect(rule.extractFnName).to.equal("fromLast")
        expect(rule.innerText).to.equal(true)
        expect(rule.attributes).to.equal(params.a)

    context "with nested params", =>
      it "recursively creates child rules", =>
        params = Fixtures.apiParams.nestedParams[0]
        rule = DexRule.build_from_api_params(params)
        expect(rule.childRules.length).to.equal(2)
        for i, childRule of rule.childRules
          expect(childRule instanceof DexRule).to.equal(true)
          expect(childRule.selector).to.equal("#{params.s} #{params.r[i].s}")
          expect(childRule.customKey).to.equal(params.r[i].k)

  describe "#asJSON", =>
    context "without nested params", =>
      it "returns a JSON representation of the rule", =>
        params = Fixtures.apiParams.allParams[0]
        rule = DexRule.build_from_api_params(params)
        rule.extractedInnerText = "Read"
        rule.extractedAttributes = {href: "/article-1"}

        expect(rule.asJSON()).to.eql(Fixtures.json.allParams)

    context "with nested params", =>
      it "recursively calls #asJSON on all children", =>
        params = Fixtures.apiParams.nestedParams[0]
        rule = DexRule.build_from_api_params(params)
        rule.childRules[0].extractedInnerText = "Article 0"
        rule.childRules[1].extractedInnerText = "Read"
        rule.childRules[1].extractedAttributes = {href: "/article-0"}
        expect(rule.asJSON()).to.eql(Fixtures.json.nestedParams)
