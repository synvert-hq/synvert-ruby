Synvert::Rewriter.new "convert_dynamic_finders", "Convert dynamic finders" do
  helper_method 'dynamic_finder_to_hash' do |prefix|
    fields = node.message.to_s[prefix.length..-1].split("_and_")
    fields.length.times.map { |i|
      fields[i] + ": " + node.arguments[i].source(self)
    }.join(", ")
  end

  within_files '**/*.rb' do
    # find_all_by_... => where(...)
    with_node type: 'send', message: /find_all_by_(.*)/ do
      hash_params = dynamic_finder_to_hash("find_all_by_")
      replace_with "{{receiver}}.where(#{hash_params})"
    end
  end

  within_files '**/*.rb' do
    # find_by_... => where(...).first
    with_node type: 'send', message: /find_by_(.*)/ do
      hash_params = dynamic_finder_to_hash("find_by_")
      replace_with "{{receiver}}.where(#{hash_params}).first"
    end
  end

  within_files '**/*.rb' do
    # find_last_by_... => where(...).last
    with_node type: 'send', message: /find_last_by_(.*)/ do
      hash_params = dynamic_finder_to_hash("find_last_by_")
      replace_with "{{receiver}}.where(#{hash_params}).last"
    end
  end

  within_files '**/*.rb' do
    # scoped_by_... => where(...)
    with_node type: 'send', message: /scoped_by_(.*)/ do
      hash_params = dynamic_finder_to_hash("scoped_by_")
      replace_with "{{receiver}}.where(#{hash_params})"
    end
  end

  within_files '**/*.rb' do
    # find_or_initialize_by_... => find_or_initialize_by(...)
    with_node type: 'send', message: /find_or_initialize_by_(.*)/ do
      hash_params = dynamic_finder_to_hash("find_or_initialize_by_")
      replace_with "{{receiver}}.find_or_initialize_by(#{hash_params})"
    end
  end

  within_files '**/*.rb' do
    # find_or_create_by_... => find_or_create_by(...)
    with_node type: 'send', message: /find_or_create_by_(.*)/ do
      hash_params = dynamic_finder_to_hash("find_or_create_by_")
      replace_with "{{receiver}}.find_or_create_by(#{hash_params})"
    end
  end
end
