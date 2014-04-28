Synvert::Rewriter.new "ruby_new_hash_syntax" do
  description <<-EOF
Use ruby new hash syntax.

    {:foo => 'bar'} => {foo: 'bar'}
  EOF

  if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new("1.9.0")
    within_files '**/*.rb' do
      # {:foo => 'bar'} => {foo: 'bar'}
      within_node type: 'hash' do
        with_node type: 'pair' do
          if :sym == node.key.type
            new_key = node.key.source(self)[/:?(.*)/, 1]
            replace_with "#{new_key}: {{value}}"
          end
        end
      end
    end
  end
end
