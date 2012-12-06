require './test_helper'

describe "DexRules", =>
  describe ".build_from_api_params", =>
    it "returns a DexRules object with an array of DexRule objects", =>
      params = Fixtures.apiParams.allParams
      rules = DexRules.build_from_api_params(params)

      expect(rules instanceof DexRules).to.equal(true)
      expect(rules.rules.length).to.equal(1)

  describe "#asJSON", =>
    it "returns a JSON representation of the rules", =>
      rulesParams = Fixtures.apiParams.allParams
      rules = DexRules.build_from_api_params(rulesParams)
      rules.rules[0].extractedInnerText = "Read"
      rules.rules[0].extractedAttributes = {href: "/article-1"}

      expect(rules.asJSON()).to.eql([Fixtures.json.allParams])
