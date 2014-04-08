Synvert::Rewriter.new "rspec_new_syntax" do
  description <<-EOF
It converts rspec code to new syntax, it calls all convert_rspec_* snippets.
  EOF

  add_snippet "convert_rspec_should_to_expect"
  add_snippet "convert_rspec_block_to_expect"
  add_snippet "convert_rspec_one_liner_expectation"
  add_snippet "convert_rspec_boolean_matcher"
  add_snippet "convert_rspec_be_close_to_be_within"
  add_snippet "convert_rspec_collection_matcher"
  add_snippet "convert_rspec_negative_error_expectation"
  add_snippet "convert_rspec_its_to_it"

  add_snippet "convert_rspec_stub_and_mock_to_double"
  add_snippet "convert_rspec_message_expectation"
  add_snippet "convert_rspec_method_stub"
end
