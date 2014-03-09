module ParserHelper
  def parse(code)
    Parser::CurrentRuby.parse code
  end
end
