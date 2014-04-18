Synvert::Rewriter.new :check_syntax do
  description "just used to check if there are syntax errors."

  within_files "**/*.rb" do; end
end
