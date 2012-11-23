require './test_helper'

describe "Dex", =>
  describe ".build_from_html", =>
    context "with invalid HTML", =>
      it "returns an error", =>
        Dex.build_from_html "", (err, dex) =>
          expect(err).not.to.equal(undefined)
          expect(dex).to.equal(undefined)

    context "with valid HTML", =>
      beforeEach (done) =>
        Dex.build_from_html Fixtures.html.basic, (@err, @dex) =>
          done()

      it "returns an instance of Dex with the HTML set", =>
        expect(@dex instanceof Dex).to.equal(true)
        expect(@dex.html).to.equal(Fixtures.html.basic)

      it "correctly parses HTML", =>
        expect(@dex.$('body').html()).to.equal(Fixtures.html.basic)

      it "does not return an error", =>
        expect(@err).to.equal(undefined)

  describe ".build_from_request", =>
    context "if the URL is invalid", =>
      it "returns an error", =>
        scrapeStub = sinon.stub(Dex.prototype, 'scrape').throws(Error)
        Dex.build_from_request {url: "invalid-url"}, (err, dex) =>
          expect(err).not.to.equal(undefined)
          expect(dex).to.equal(undefined)
          scrapeStub.restore()

    context "if the URL is unreachable", =>
      it "returns an error", =>
        scrapeStub = sinon.stub(Dex.prototype, 'scrape').yields("an error", {}, null)
        Dex.build_from_request {url: "invalid-url"}, (err, dex) =>
          expect(err).not.to.equal(undefined)
          expect(dex).to.equal(undefined)
          scrapeStub.restore()

    context "if the URL returns a response", =>
      beforeEach (done) =>
        @html = Fixtures.html.basic
        @scrapeStub = sinon.stub(Dex.prototype, 'scrape').yields(null, {}, @html)
        Dex.build_from_request {url: "valid-url"}, (@err, @dex) =>
          done()

      afterEach =>
        @scrapeStub.restore()

      it "returns an instance of Dex with the HTML set", =>
        expect(@dex instanceof Dex).to.equal(true)
        expect(@dex.html).to.equal(@html)

      it "correctly parses the HTML", =>
        expect(@dex.$('body').html()).to.equal(@html)

      it "does not return an error", =>
        expect(@err).to.equal(undefined)
