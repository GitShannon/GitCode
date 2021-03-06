describe "{{#with presenter}}...{{/with}}" do
  let(:global_helpers_providers) { [] }

  describe "#compile" do
    let(:post) { double("post") }
    let(:presenter) { IntegrationTest::Presenter.new(double("view_context"), post: post) }

    it "works scopes one level" do
      template = Curlybars.compile(<<-HBS)
        {{#with user}}
          {{avatar.url}}
        {{/with}}
      HBS

      expect(eval(template)).to resemble(<<-HTML)
        http://example.com/foo.png
      HTML
    end

    it "scopes two levels" do
      template = Curlybars.compile(<<-HBS)
        {{#with user}}
          {{#with avatar}}
            {{url}}
          {{/with}}
        {{/with}}
      HBS

      expect(eval(template)).to resemble(<<-HTML)
        http://example.com/foo.png
      HTML
    end

    it "allows empty with_template" do
      template = Curlybars.compile(<<-HBS)
        {{#with user}}{{/with}}
      HBS

      expect(eval(template)).to resemble("")
    end

    it "renders the else templte if the context is nil" do
      template = Curlybars.compile(<<-HBS)
        {{#with return_nil}}
          text
        {{else}}
          else
        {{/with}}
      HBS

      expect(eval(template)).to resemble(<<-HTML)
        else
      HTML
    end

    it "renders nothing if the context is nil and no else block is specified" do
      template = Curlybars.compile(<<-HBS)
        {{#with return_nil}}
          text
        {{/with}}
      HBS

      expect(eval(template)).to resemble("")
    end

    it "raises an exception if the parameter is not a context type object" do
      template = Curlybars.compile(<<-HBS)
        {{#with return_true}}{{/with}}
      HBS

      expect do
        eval(template)
      end.to raise_error(Curlybars::Error::Render)
    end
  end

  describe "#validate" do
    let(:presenter_class) { double(:presenter_class) }

    it "without errors" do
      dependency_tree = { a_presenter: {} }

      source = <<-HBS
        {{#with a_presenter}}{{/with}}
      HBS

      errors = Curlybars.validate(dependency_tree, source)

      expect(errors).to be_empty
    end

    it "with errors due to a leaf" do
      dependency_tree = { not_a_presenter: nil }

      source = <<-HBS
        {{#with not_a_presenter}}{{/with}}
      HBS

      errors = Curlybars.validate(dependency_tree, source)

      expect(errors).not_to be_empty
    end

    it "with errors due unallowed method" do
      dependency_tree = {}

      source = <<-HBS
        {{#with unallowed}}{{/with}}
      HBS

      errors = Curlybars.validate(dependency_tree, source)

      expect(errors).not_to be_empty
    end
  end
end
