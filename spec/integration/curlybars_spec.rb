require 'spec_helper'
require 'curly_bars/lexer'
require 'curly_bars/parser'

class AvatarPresenter
  def initialize(avatar)
    @avatar = avatar
  end

  def url
    @avatar[:url]
  end
end

class UserPresenter
  def initialize(user)
    @user = user
  end

  def avatar
    avatar = @user[:avatar]
    AvatarPresenter.new(avatar)
  end
end

class PostShowPresenter
  def initialize
    @current_user = { avatar: { url: "http://foobar" } }
  end

  def user
    UserPresenter.new(@current_user)
  end

  def valid
    true
  end

  def visible
    true
  end

  def form(title)
    "ciao: #{title}"
  end
end

describe "integration" do
  let(:context) { PostShowPresenter.new }
  let(:presenter) { PostShowPresenter.new }

  it "runs if statement" do
    doc = "step1{{#if valid}}{{#if visible }} out{{/if}}stepX{{/if}}step2"
    lex = CurlyBars::Lexer.lex(doc)
    ruby_code = CurlyBars::Parser.parse(lex)

    rendered = eval(ruby_code)

    expect(rendered).to eq("step1 outstepXstep2")
  end

  it "runs comments" do
    doc = <<-HBS.strip_heredoc
      Ciao
      {{! This is a comment }}
      {{! 2 lines
        lines }}
      {{!
        And another one
        in
        3 lines
        }
      }}
      {{!--
        And this is the {{ test }} other style
        }}
      --}}
      Goodbye
    HBS

    lex = CurlyBars::Lexer.lex(doc)
    ruby_code = CurlyBars::Parser.parse(lex)
    rendered = eval(ruby_code)

    expect(rendered).to eq("Ciao\n\n\n\n\nGoodbye\n")
  end

  describe "dotted notation accessors" do
    it "evaluates the methods chain call" do
      doc = "{{ user.avatar.url }}"
      lex = CurlyBars::Lexer.lex(doc)

      ruby_code = CurlyBars::Parser.parse(lex)
      rendered = eval(ruby_code)

      expect(rendered).to eq("http://foobar")
    end

    it "raises when trying to call methods not implemented on context" do
      doc = "{{system}}"
      lex = CurlyBars::Lexer.lex(doc)
      ruby_code = CurlyBars::Parser.parse(lex)

      presenter = context

      expect{context.instance_eval(ruby_code)}.to raise_error(RuntimeError)
    end

    it "works with {{#with block version b" do
      doc = "{{#with user}}Hello {{avatar.url}}{{/with}}"

      lex = CurlyBars::Lexer.lex(doc)
      ruby_code = CurlyBars::Parser.parse(lex)
      rendered = eval(ruby_code)

      expect(rendered).to eq("Hello http://foobar")
    end

    it "works with 2 nested {{#with blocks" do
      doc = "{{#with user}}Hello {{#with avatar}}{{url}}{{/with}}{{/with}}"

      lex = CurlyBars::Lexer.lex(doc)
      ruby_code = CurlyBars::Parser.parse(lex)
      rendered = eval(ruby_code)

      expect(rendered).to eq("Hello http://foobar")
    end

#class="red" foo="bar"
    it "render a block helper" do
      doc = <<-HBS.strip_heredoc
        {{#  form "new_post" }}
          lorem ipsum
        {{/form}}
      HBS

      lex = CurlyBars::Lexer.lex(doc)
      ruby_code = CurlyBars::Parser.parse(lex)
      rendered = eval(ruby_code)

      expect(rendered).to eq("ciao: new_post\n")
    end
  end
end
