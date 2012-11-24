require './test_helper'

describe "Dex", =>
  describe ".build_from_html", =>
    context "with invalid HTML", =>
      it "returns an error", =>
        Dex.build_from_html "", (err, dex) =>
          expect(err).not.to.equal(null)
          expect(dex).to.equal(null)

        Dex.build_from_html undefined, (err, dex) =>
          expect(err).not.to.equal(null)
          expect(dex).to.equal(null)

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
        expect(@err).to.equal(null)

  describe ".build_from_request", =>
    context "if the URL is invalid", =>
      it "returns an error", =>
        scrapeStub = sinon.stub(Dex.prototype, 'scrape').throws(Error)
        Dex.build_from_request {url: "invalid-url"}, (err, dex) =>
          expect(err).not.to.equal(null)
          expect(dex).to.equal(null)
          scrapeStub.restore()

    context "if the URL is unreachable", =>
      it "returns an error", =>
        scrapeStub = sinon.stub(Dex.prototype, 'scrape').yields("an error", {}, null)
        Dex.build_from_request {url: "invalid-url"}, (err, dex) =>
          expect(err).not.to.equal(null)
          expect(dex).to.equal(null)
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
        expect(@err).to.equal(null)

  describe "finding by selector", =>
    beforeEach (done) =>
      Dex.build_from_html Fixtures.html.list, (err, @dex) =>
        done()

    describe "#all", =>
      it "returns all elements that match the selector", =>
        expect(@dex.all("li").length).to.equal(3)

      it "works with adjacent selectors", (done) =>
        Dex.build_from_html Fixtures.html.fieldset, (err, dex) =>
          expect(dex.all("label+input").length).to.equal(2)
          dex.all("label+input").each (i, el) =>
            expect($(el).attr("class")).to.equal(["username", "password"][i])
          done()

      it "returns an empty jQuery result object if no element matches the selector", =>
        expect(@dex.all("foo").each).to.exist
        expect(@dex.all("foo").length).to.equal(0)

      it "returns an empty jQuery result object for invalid selectors", =>
        expect(@dex.all("..invalid").each).to.exist
        expect(@dex.all("..invalid").length).to.equal(0)

    describe "#first", =>
      it "returns the first element that matches the selector", =>
        expect(@dex.first("li").text()).to.equal("Item #1")

      it "returns null if no element matches the selector", =>
        expect(@dex.first("foo")).to.equal(null)

    describe "#last", =>
      it "returns the last element that matches the selector", =>
        expect(@dex.last("li").text()).to.equal("Item #3")

      it "returns null if no element matches the selector", =>
        expect(@dex.last("foo")).to.equal(null)

  describe "extracting data by selector and options", =>
    beforeEach (done) =>
      @options =
        innerText: true
        attributes: ['name', 'class']
      Dex.build_from_html Fixtures.html.list, (err, @dex) =>
        done()

    describe "#fromAll", =>
      it "returns the data from all selectors for the specified options", =>
        results = @dex.fromAll("li", @options)
        expect(results.length).to.equal(3)
        for result in results
          expect(result.innerText).to.exist
          for attribute in @options.attributes
            expect(result[attribute]).to.exist

      it "works with adjacent selectors", (done) =>
        Dex.build_from_html Fixtures.html.fieldset, (err, dex) =>
          results = dex.fromAll("label+input", @options)
          expect(results.length).to.equal(2)
          for i, result of results
            expect(result.class).to.equal(["username", "password"][i])
          done()

      it "returns null for invalid attributes", =>
        @options.attributes.push('..invalid-attr')
        results = @dex.fromAll("li", @options)
        expect(results[0]['..invalid-attr']).to.equal(null)

      it "returns null for nonexistent attributes", =>
        @options.attributes.push('nonexistent-attr')
        results = @dex.fromAll("li", @options)
        expect(results[0]['nonexistent-attr']).to.equal(null)

    describe "#fromFirst", =>
      it "returns the data from the first selector for the specified options", =>
        result = @dex.fromFirst("li", @options)
        expect(result.innerText).to.equal("Item #1")
        expect(result.name).to.equal("item-1")
        expect(result.class).to.equal("item")

      it "returns null if no element matches the selector", =>
        expect(@dex.fromFirst("foo", @options)).to.equal(null)

    describe "#fromLast", =>
      it "returns the data from the last selector for the specified options", =>
        result = @dex.fromLast("li", @options)
        expect(result.innerText).to.equal("Item #3")
        expect(result.name).to.equal("item-3")
        expect(result.class).to.equal("item")

      it "returns null if no element matches the selector", =>
        expect(@dex.fromLast("foo", @options)).to.equal(null)
