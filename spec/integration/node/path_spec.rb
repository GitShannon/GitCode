describe "path expansion on presenters" do
  let(:post) { double("post") }
  let(:presenter) { IntegrationTest::Presenter.new(double("view_context"), post: post) }

  it "evaluates the methods chain call" do
    template = compile(<<-HBS.strip_heredoc)
      {{user.avatar.url}}
    HBS

    expect(eval(template)).to resemble(<<-HTML.strip_heredoc)
      http://example.com/foo.png
    HTML
  end

  it "raises when trying to call methods not implemented on context" do
    template = compile(<<-HBS.strip_heredoc)
      {{not_in_whitelist}}
    HBS

    expect do
      eval(eval(template))
    end.to raise_error(RuntimeError)
  end
end
