describe "{{#unless}}...{{else}}...{{/unless}}" do
  describe "#compile" do
    let(:post) { double("post") }
    let(:presenter) { IntegrationTest::Presenter.new(double("view_context"), post: post) }

    it "renders the unless_template" do
      allow(presenter).to receive(:allows_method?).with(:condition) { true }
      allow(presenter).to receive(:condition) { false }

      template = Curlybars.compile(<<-HBS)
        {{#unless condition}}
          unless_template
        {{else}}
          else_template
        {{/unless}}
      HBS

      expect(eval(template)).to resemble(<<-HTML)
        unless_template
      HTML
    end

    it "renders the else_template" do
      allow(presenter).to receive(:allows_method?).with(:condition) { true }
      allow(presenter).to receive(:condition) { true }

      template = Curlybars.compile(<<-HBS)
        {{#unless condition}}
          unless_template
        {{else}}
          else_template
        {{/unless}}
      HBS

      expect(eval(template)).to resemble(<<-HTML)
        else_template
      HTML
    end

    it "allows empty else_template" do
      allow(presenter).to receive(:allows_method?).with(:valid) { true }
      allow(presenter).to receive(:valid) { false }

      template = Curlybars.compile(<<-HBS)
        {{#unless valid}}
          unless_template
        {{else}}{{/unless}}
      HBS

      expect(eval(template)).to resemble(<<-HTML)
        unless_template
      HTML
    end

    it "allows empty unless_template" do
      allow(presenter).to receive(:allows_method?).with(:valid) { true }
      allow(presenter).to receive(:valid) { true }

      template = Curlybars.compile(<<-HBS)
        {{#unless valid}}{{else}}
          else_template
        {{/unless}}
      HBS

      expect(eval(template)).to resemble(<<-HTML)
        else_template
      HTML
    end

    it "allows empty unless_template and else_template" do
      allow(presenter).to receive(:allows_method?).with(:valid) { true }
      allow(presenter).to receive(:valid) { false }

      template = Curlybars.compile(<<-HBS)
        {{#unless valid}}{{else}}{{/unless}}
      HBS

      expect(eval(template)).to resemble(<<-HTML)
      HTML
    end
  end

  describe "#validate" do
    let(:presenter_class) { double(:presenter_class) }

    it "validates with errors the condition" do
      allow(presenter_class).to receive(:dependency_tree) do
        {}
      end

      source = <<-HBS
        {{#unless condition}}{{else}}{{/unless}}
      HBS

      errors = Curlybars.validate(presenter_class, source)

      expect(errors).not_to be_empty
    end

    it "validates with errors the nested unless_template" do
      allow(presenter_class).to receive(:dependency_tree) do
        { condition: nil }
      end

      source = <<-HBS
        {{#unless condition}}
          {{unallowed_method}}
        {{else}}
        {{/unless}}
      HBS

      errors = Curlybars.validate(presenter_class, source)

      expect(errors).not_to be_empty
    end

    it "validates with errors the nested else_template" do
      allow(presenter_class).to receive(:dependency_tree) do
        { condition: nil }
      end

      source = <<-HBS
        {{#unless condition}}
        {{else}}
          {{unallowed_method}}
        {{/unless}}
      HBS

      errors = Curlybars.validate(presenter_class, source)

      expect(errors).not_to be_empty
    end
  end
end
