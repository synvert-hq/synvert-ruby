# Parser::AST::Node monkey patch.
class Parser::AST::Node
  # Get name node of :class, :module, :def and :defs node.
  #
  # @return [Parser::AST::Node] name node.
  # @raise [Synvert::MethodNotSupported] if calls on other node.
  def name
    case self.type
    when :class, :module, :def
      self.children[0]
    when :defs
      self.children[1]
    else
      raise Synvert::MethodNotSupported.new "name is not handled for #{self.inspect}"
    end
  end

  # Get receiver node of :send node.
  #
  # @return [Parser::AST::Node] receiver node.
  # @raise [Synvert::MethodNotSupported] if calls on other node.
  def receiver
    if :send == self.type
      self.children[0]
    else
      raise Synvert::MethodNotSupported.new "receiver is not handled for #{self.inspect}"
    end
  end

  # Get message node of :send node.
  #
  # @return [Parser::AST::Node] mesage node.
  # @raise [Synvert::MethodNotSupported] if calls on other node.
  def message
    if :send == self.type
      self.children[1]
    else
      raise Synvert::MethodNotSupported.new "message is not handled for #{self.inspect}"
    end
  end

  # Get arguments node of :send, :block or :defined? node.
  #
  # @return [Array<Parser::AST::Node>] arguments node.
  # @raise [Synvert::MethodNotSupported] if calls on other node.
  def arguments
    case self.type
    when :send
      self.children[2..-1]
    when :block
      self.children[1].children
    when :defined?
      self.children
    else
      raise Synvert::MethodNotSupported.new "arguments is not handled for #{self.inspect}"
    end
  end

  # Get caller node of :block node.
  #
  # @return [Parser::AST::Node] caller node.
  # @raise [Synvert::MethodNotSupported] if calls on other node.
  def caller
    if :block == self.type
      self.children[0]
    else
      raise Synvert::MethodNotSupported.new "caller is not handled for #{self.inspect}"
    end
  end

  # Get body node of :begin or :block node.
  #
  # @return [Array<Parser::AST::Node>] body node.
  # @raise [Synvert::MethodNotSupported] if calls on other node.
  def body
    case self.type
    when :begin
      self.children
    when :block
      :begin == self.children[2].type ? self.children[2].children : [self.children[2]]
    else
      raise Synvert::MethodNotSupported.new "body is not handled for #{self.inspect}"
    end
  end

  # Get condition node of :if node.
  #
  # @return [Parser::AST::Node] condition node.
  # @raise [Synvert::MethodNotSupported] if calls on other node.
  def condition
    if :if == self.type
      self.children[0]
    else
      raise Synvert::MethodNotSupported.new "condition is not handled for #{self.inspect}"
    end
  end

  # Get keys node of :hash node.
  #
  # @return [Array<Parser::AST::Node>] keys node.
  # @raise [Synvert::MethodNotSupported] if calls on other node.
  def keys
    if :hash == self.type
      self.children.map { |child| child.children[0] }
    else
      raise Synvert::MethodNotSupported.new "keys is not handled for #{self.inspect}"
    end
  end

  # Get values node of :hash node.
  #
  # @return [Array<Parser::AST::Node>] values node.
  # @raise [Synvert::MethodNotSupported] if calls on other node.
  def values
    if :hash == self.type
      self.children.map { |child| child.children[1] }
    else
      raise Synvert::MethodNotSupported.new "keys is not handled for #{self.inspect}"
    end
  end

  # Get key node of hash :pair node.
  #
  # @return [Parser::AST::Node] key node.
  # @raise [Synvert::MethodNotSupported] if calls on other node.
  def key
    if :pair == self.type
      self.children.first
    else
      raise Synvert::MethodNotSupported.new "key is not handled for #{self.inspect}"
    end
  end

  # Get value node of hash :pair node.
  #
  # @return [Parser::AST::Node] value node.
  # @raise [Synvert::MethodNotSupported] if calls on other node.
  def value
    if :pair == self.type
      self.children.last
    else
      raise Synvert::MethodNotSupported.new "value is not handled for #{self.inspect}"
    end
  end

  # Get the source code of current node.
  #
  # @param instance [Synvert::Rewriter::Instance]
  # @return [String] source code.
  def source(instance)
    if self.loc.expression
      instance.current_source[self.loc.expression.begin_pos...self.loc.expression.end_pos]
    end
  end

  # Get the indent of current node.
  #
  # @return [Integer] indent.
  def indent
    self.loc.expression.column
  end

  # Recursively iterate all child nodes of current node.
  #
  # @yield [child] Gives a child node.
  # @yieldparam child [Parser::AST::Node] child node
  def recursive_children
    self.children.each do |child|
      if Parser::AST::Node === child
        yield child
        child.recursive_children { |c| yield c }
      end
    end
  end

  # Match current node with rules.
  #
  # @param instance [Synvert::Rewriter::Instance] used to get crrent source code.
  # @param rules [Hash] rules to match.
  # @return true if matches.
  def match?(instance, rules)
    flat_hash(rules).keys.all? do |multi_keys|
      if multi_keys.last == :any
        actual_values = actual_value(self, instance, multi_keys[0...-1])
        expected = expected_value(rules, multi_keys)
        actual_values.any? { |actual| match_value?(instance, actual, expected) }
      elsif multi_keys.last == :not
        actual = actual_value(self, instance, multi_keys[0...-1])
        expected = expected_value(rules, multi_keys)
        !match_value?(instance, actual, expected)
      else
        actual = actual_value(self, instance, multi_keys)
        expected = expected_value(rules, multi_keys)
        match_value?(instance, actual, expected)
      end
    end
  end

  # Get rewritten source code.
  # @example
  #   node.rewritten_source("create({{arguments}})") #=> "create(:post)"
  #
  # @param code [String] raw code.
  # @return [String] rewritten code, replace string in block {{ }} in raw code.
  # @raise [Synvert::MethodNotSupported] if string in block {{ }} does not support.
  def rewritten_source(code)
    code.gsub(/{{(.*?)}}/m) do
      evaluated = self.instance_eval $1
      case evaluated
      when Parser::AST::Node
        source = evaluated.loc.expression.source_buffer.source
        source[evaluated.loc.expression.begin_pos...evaluated.loc.expression.end_pos]
      when Array
        if evaluated.size > 0
          source = evaluated.first.loc.expression.source_buffer.source
          source[evaluated.first.loc.expression.begin_pos...evaluated.last.loc.expression.end_pos]
        end
      when String
        evaluated
      when NilClass
        'nil'
      else
        raise Synvert::MethodNotSupported.new "rewritten_source is not handled for #{evaluated.inspect}"
      end
    end
  end

private

  # Compare actual value with expected value.
  #
  # @param instance [Synvert::Rewriter::Instance] used to get source code.
  # @param actual [Object] actual value.
  # @param expected [Object] expected value.
  # @return [Integer] -1, 0 or 1.
  # @raise [Synvert::MethodNotSupported] if expected class is not supported.
  def match_value?(instance, actual, expected)
    case expected
    when Symbol
      if Parser::AST::Node === actual
        actual.source(instance) == ":#{expected}"
      else
        actual.to_sym == expected
      end
    when String
      if Parser::AST::Node === actual
        actual.source(instance) == expected || actual.source(instance)[1...-1] == expected
      else
        actual.to_s == expected
      end
    when Regexp
      if Parser::AST::Node === actual
        actual.source(instance) =~ Regexp.new(expected.to_s, Regexp::MULTILINE)
      else
        actual.to_s =~ Regexp.new(expected.to_s, Regexp::MULTILINE)
      end
    when Array
      actual.zip(expected).all? { |a, e| match_value?(instance, a, e) }
    when NilClass
      actual.nil?
    when Numeric
      if Parser::AST::Node === actual
        actual.children[0] == expected
      else
        actual == expected
      end
    when TrueClass
      :true == actual.type
    when FalseClass
      :false == actual.type
    when Parser::AST::Node
      actual == expected
    else
      raise Synvert::MethodNotSupported.new "#{expected.class} is not handled for match_value?"
    end
  end

  # Convert a hash to flat one.
  #
  # @example
  #   flat_hash(type: 'block', caller: {type: 'send', receiver: 'RSpec'})
  #     #=> {[:type] => 'block', [:caller, :type] => 'send', [:caller, :receiver] => 'RSpec'}
  # @param h [Hash] original hash.
  # @return flatten hash.
  def flat_hash(h, k = [])
    new_hash = {}
    h.each_pair do |key, val|
      if val.is_a?(Hash)
        new_hash.merge!(flat_hash(val, k + [key]))
      else
        new_hash[k + [key]] = val
      end
    end
    new_hash
  end

  # Get actual value from the node.
  #
  # @param node [Parser::AST::Node]
  # @param instance [Synvert::Rewriter::Instance]
  # @param multi_keys [Array<Symbol>]
  # @return [Object] actual value.
  def actual_value(node, instance, multi_keys)
    multi_keys.inject(node) { |n, key|
      if n
        key == :source ? n.send(key, instance) : n.send(key)
      end
    }
  end

  # Get expected value from rules.
  #
  # @param rules [Hash]
  # @param multi_keys [Array<Symbol>]
  # @return [Object] expected value.
  def expected_value(rules, multi_keys)
    multi_keys.inject(rules) { |o, key| o[key] }
  end
end
