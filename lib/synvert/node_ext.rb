class Parser::AST::Node
  def name
    if [:class, :def].include? self.type
      self.children[0]
    else
      raise NotImplementedError.new "name is not handled for #{self.inspect}"
    end
  end

  def receiver
    if :send == self.type
      self.children[0]
    else
      raise NotImplementedError.new "receiver is not handled for #{self.inspect}"
    end
  end

  def message
    if :send == self.type
      self.children[1]
    else
      raise NotImplementedError.new "message is not handled for #{self.inspect}"
    end
  end

  def arguments
    case self.type
    when :send
      self.children[2..-1]
    when :block
      self.children[1].children
    when :defined?
      self.children
    else
      raise NotImplementedError.new "arguments is not handled for #{self.inspect}"
    end
  end

  def caller
    if :block == self.type
      self.children[0]
    else
      raise NotImplementedError.new "caller is not handled for #{self.inspect}"
    end
  end

  def body
    if :block == self.type
      self.children[2]
    else
      raise NotImplementedError.new "body is not handled for #{self.inspect}"
    end
  end

  def condition
    if :if == self.type
      self.children[0]
    else
      raise NotImplementedError.new "condition is not handled for #{self.inspect}"
    end
  end

  def source(instance)
    if self.loc.expression
      instance.current_source[self.loc.expression.begin_pos...self.loc.expression.end_pos]
    end
  end

  def indent
    self.loc.expression.column
  end

  def recursive_children
    self.children.each do |child|
      if Parser::AST::Node === child
        yield child
        child.recursive_children { |c| yield c }
      end
    end
  end

  def grep_node(options)
    self.recursive_children do |child|
      return child if child.match?(options)
    end
  end

  def match?(instance, options)
    flat_hash(options).keys.all? do |multi_keys|
      if multi_keys.last == :any
        actual_values = actual_value(self, instance, multi_keys[0...-1])
        expected = expected_value(options, multi_keys)
        actual_values.any? { |actual| match_value?(instance, actual, expected) }
      else
        actual = actual_value(self, instance, multi_keys)
        expected = expected_value(options, multi_keys)
        match_value?(instance, actual, expected)
      end
    end
  end

  def rewritten_source(code)
    code.gsub(/{{(.*?)}}/m) do
      evaluated = self.instance_eval $1
      case evaluated
      when Parser::AST::Node
        source = evaluated.loc.expression.source_buffer.source
        source[evaluated.loc.expression.begin_pos...evaluated.loc.expression.end_pos]
      when Array
        source = evaluated.first.loc.expression.source_buffer.source
        source[evaluated.first.loc.expression.begin_pos...evaluated.last.loc.expression.end_pos]
      when String
        evaluated
      else
        raise NotImplementedError.new "rewritten_source is not handled for #{evaluated.inspect}"
      end
    end
  end

private

  def match_value?(instance, actual, expected)
    case expected
    when Symbol
      actual.to_sym == expected
    when String
      if Parser::AST::Node === actual
        actual.source(instance) == expected
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
    when Parser::AST::Node
      actual == expected
    else
      raise NotImplementedError.new "#{expected.class} is not handled for match_value?"
    end
  end

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

  def actual_value(node, instance, multi_keys)
    multi_keys.inject(node) { |n, key|
      if n
        key == :source ? n.send(key, instance) : n.send(key)
      end
    }
  end

  def expected_value(options, multi_keys)
    multi_keys.inject(options) { |o, key| o[key] }
  end
end
