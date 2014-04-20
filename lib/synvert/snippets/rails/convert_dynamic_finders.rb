Synvert::Rewriter.new "convert_rails_dynamic_finders" do
  description <<-EOF
It converts rails dynamic finders to arel syntax.

    find_all_by_... => where(...)
    find_by_... => where(...).first
    find_last_by_... => where(...).last
    scoped_by_... => where(...)
    find_or_initialize_by_... => find_or_initialize_by(...)
    find_or_create_by_... => find_or_create_by(...)
  EOF

  helper_method 'dynamic_finder_to_hash' do |prefix|
    fields = node.message.to_s[prefix.length..-1].split("_and_")
    if fields.length == node.arguments.length && :hash != node.arguments.first.type
      fields.length.times.map { |i|
        fields[i] + ": " + node.arguments[i].source(self)
      }.join(", ")
    else
      "{{arguments}}"
    end
  end

  within_files '**/*.rb' do
    # find_all_by_... => where(...)
    with_node type: 'send', message: /^find_all_by_/ do
      hash_params = dynamic_finder_to_hash("find_all_by_")
      if node.receiver
        replace_with "{{receiver}}.where(#{hash_params})"
      else
        replace_with "where(#{hash_params})"
      end
    end

    # find_by_... => where(...).first
    with_node type: 'send', message: /^find_by_/ do
      if :find_by_id == node.message
        if node.receiver
          replace_with "{{receiver}}.find({{arguments}})"
        else
          replace_with "find({{arguments}}"
        end
      elsif :find_by_sql != node.message
        hash_params = dynamic_finder_to_hash("find_by_")
        if node.receiver
          replace_with "{{receiver}}.where(#{hash_params}).first"
        else
          replace_with "where(#{hash_params}).first"
        end
      end
    end

    # find_last_by_... => where(...).last
    with_node type: 'send', message: /^find_last_by_/ do
      hash_params = dynamic_finder_to_hash("find_last_by_")
      if node.receiver
        replace_with "{{receiver}}.where(#{hash_params}).last"
      else
        replace_with "where(#{hash_params}).last"
      end
    end

    # scoped_by_... => where(...)
    with_node type: 'send', message: /^scoped_by_/ do
      hash_params = dynamic_finder_to_hash("scoped_by_")
      if node.receiver
        replace_with "{{receiver}}.where(#{hash_params})"
      else
        replace_with "where(#{hash_params})"
      end
    end

    # find_or_initialize_by_... => find_or_initialize_by(...)
    with_node type: 'send', message: /^find_or_initialize_by_/ do
      hash_params = dynamic_finder_to_hash("find_or_initialize_by_")
      if node.receiver
        replace_with "{{receiver}}.find_or_initialize_by(#{hash_params})"
      else
        replace_with "find_or_initialize_by(#{hash_params})"
      end
    end

    # find_or_create_by_... => find_or_create_by(...)
    with_node type: 'send', message: /^find_or_create_by_/ do
      hash_params = dynamic_finder_to_hash("find_or_create_by_")
      if node.receiver
        replace_with "{{receiver}}.find_or_create_by(#{hash_params})"
      else
        replace_with "find_or_create_by(#{hash_params})"
      end
    end
  end
end
