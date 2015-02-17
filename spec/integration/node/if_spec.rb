describe "if blocks" do
  let(:post) { double("post") }
  let(:presenter) { IntegrationTest::Presenter.new(double("view_context"), post: post) }

  it "returns positive branch when condition is true" do
    IntegrationTest::Presenter.stub(:allows_method?).with(:valid) { true }
    presenter.stub(:valid) { true }

    template = compile(<<-HBS.strip_heredoc)
      {{#if valid}}
        if_template
      {{/if}}
    HBS

    expect(eval(template)).to resemble(<<-HTML.strip_heredoc)
      if_template
    HTML
  end

  it "doesn't return positive branch when condition is false" do
    IntegrationTest::Presenter.stub(:allows_method?).with(:valid) { true }
    presenter.stub(:valid) { false }

    template = compile(<<-HBS.strip_heredoc)
      {{#if valid}}
        if_template
      {{/if}}
    HBS

    expect(eval(template)).to resemble(<<-HTML.strip_heredoc)
    HTML
  end

  it "works with nested `if blocks` (double positive)" do
    IntegrationTest::Presenter.stub(:allows_method?).with(:valid) { true }
    IntegrationTest::Presenter.stub(:allows_method?).with(:visible) { true }
    presenter.stub(:valid) { true }
    presenter.stub(:visible) { true }

    template = compile(<<-HBS.strip_heredoc)
      {{#if valid}}
        {{#if visible}}
          visible_template
        {{/if}}
        valid_template
      {{/if}}
    HBS

    expect(eval(template)).to resemble(<<-HTML.strip_heredoc)
      visible_template
      valid_template
    HTML
  end

  it "works with nested `if blocks` (positive and negative)" do
    IntegrationTest::Presenter.stub(:allows_method?).with(:valid) { true }
    IntegrationTest::Presenter.stub(:allows_method?).with(:visible) { true }
    presenter.stub(:valid) { true }
    presenter.stub(:visible) { false }

    template = compile(<<-HBS.strip_heredoc)
      {{#if valid}}
        {{#if visible}}
          visible_template
        {{/if}}
        valid_template
      {{/if}}
    HBS

    expect(eval(template)).to resemble(<<-HTML.strip_heredoc)
      valid_template
    HTML
  end

  describe "runs if-else statement" do
    it "renders the if_template" do
      IntegrationTest::Presenter.stub(:allows_method?).with(:return_true) { true }
      presenter.stub(:return_true) { true }

      template = compile(<<-HBS.strip_heredoc)
        {{#if return_true}}
          if_template
        {{else}}
          else_template
        {{/if}}
      HBS

      expect(eval(template)).to resemble(<<-HTML.strip_heredoc)
        if_template
      HTML
    end

    it "renders the else_template" do
      IntegrationTest::Presenter.stub(:allows_method?).with(:return_false) { true }
      presenter.stub(:return_false) { false }

      template = compile(<<-HBS.strip_heredoc)
        {{#if return_false}}
          if_template
        {{else}}
          else_template
        {{/if}}
      HBS

      expect(eval(template)).to resemble(<<-HTML.strip_heredoc)
        else_template
      HTML
    end
  end
end
