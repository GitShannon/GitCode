describe "{{#unless}}...{{/unless}}" do
  let(:global_helpers_providers) { [] }

  describe "#compile" do
    let(:post) { double("post") }
    let(:presenter) { IntegrationTest::Presenter.new(double("view_context"), post: post) }

    it "returns unless_template when condition is false" do
      allow(presenter).to receive(:allows_method?).with(:condition) { true }
      allow(presenter).to receive(:condition) { false }

      template = Curlybars.compile(<<-HBS)
        {{#unless condition}}
          unless_template
        {{/unless}}
      HBS

      expect(eval(template)).to resemble(<<-HTML)
        unless_template
      HTML
    end

    it "doesn't return unless_template when condition is true" do
      allow(presenter).to receive(:allows_method?).with(:condition) { true }
      allow(presenter).to receive(:condition) { true }

      template = Curlybars.compile(<<-HBS)
        {{#unless condition}}
          unless_template
        {{/unless}}
      HBS

      expect(eval(template)).to resemble("")
    end

    it "works with nested unless blocks (double negative)" do
      allow(presenter).to receive(:allows_method?).with(:first_condition) { true }
      allow(presenter).to receive(:allows_method?).with(:second_condition) { true }
      allow(presenter).to receive(:first_condition) { false }
      allow(presenter).to receive(:second_condition) { false }

      template = Curlybars.compile(<<-HBS)
        {{#unless first_condition}}
          {{#unless second_condition}}
            inner_unless_template
          {{/unless}}
            outer_unless_template
        {{/unless}}
      HBS

      expect(eval(template)).to resemble(<<-HTML)
        inner_unless_template
        outer_unless_template
      HTML
    end

    it "allows empty unless_template" do
      allow(presenter).to receive(:allows_method?).with(:valid) { true }
      allow(presenter).to receive(:valid) { true }

      template = Curlybars.compile(<<-HBS)
        {{#unless valid}}{{/unless}}
      HBS

      expect(eval(template)).to resemble("")
    end

    it "works with nested unless blocks (negative and positive)" do
      allow(presenter).to receive(:allows_method?).with(:first_condition) { true }
      allow(presenter).to receive(:allows_method?).with(:second_condition) { true }
      allow(presenter).to receive(:first_condition) { false }
      allow(presenter).to receive(:second_condition) { true }

      template = Curlybars.compile(<<-HBS)
        {{#unless first_condition}}
          {{#unless second_condition}}
            inner_unless_template
          {{/unless}}
          outer_unless_template
        {{/unless}}
      HBS

      expect(eval(template)).to resemble(<<-HTML)
        outer_unless_template
      HTML
    end

    it "allows usage of variables in condition" do
      template = Curlybars.compile(<<-HBS)
        {{#each two_elements}}
          {{#unless @first}}I am the second!{{/unless}}
        {{/each}}
      HBS

      expect(eval(template)).to resemble(<<-HTML)
        I am the second!
      HTML
    end
  end

  describe "#validate" do
    let(:presenter_class) { double(:presenter_class) }

    it "validates with errors the condition" do
      dependency_tree = {}

      source = <<-HBS
        {{#unless condition}}{{/unless}}
      HBS

      errors = Curlybars.validate(dependency_tree, source)

      expect(errors).not_to be_empty
    end

    it "validates with errors the nested template" do
      dependency_tree = { condition: nil }

      source = <<-HBS
        {{#unless condition}}
          {{unallowed_method}}
        {{/unless}}
      HBS

      errors = Curlybars.validate(dependency_tree, source)

      expect(errors).not_to be_empty
    end
  end
end
