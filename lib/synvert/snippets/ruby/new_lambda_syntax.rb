Synvert::Rewriter.new "ruby_new_lambda_syntax", "Ruby uses new lambda syntax" do
  if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new("1.9.0")
    within_files '**/*.rb' do
      # lambda { |a, b, c| a + b + c } => ->(a, b, c) { a + b + c }
      within_node type: 'block', caller: {type: 'send', message: 'lambda'} do
        if node.arguments.empty?
          replace_with "-> { {{body}} }"
        else
          replace_with "->({{arguments}}) { {{body}} }"
        end
      end
    end
  end
end
