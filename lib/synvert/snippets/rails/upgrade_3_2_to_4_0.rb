require 'securerandom'

def dynamic_finder_to_hash(node, prefix)
  fields = node.message.to_s[prefix.length..-1].split("_and_")
  fields.length.times.map { |i|
    fields[i] + ": " + node.arguments[i].to_s
  }.join(", ")
end

Synvert::Rewriter.new "Upgrade from rails 3.2 to rails 4.0" do
  gem_spec 'rails', '3.2.0'

  within_file 'config/application.rb' do
    # if defined?(Bundler)
    #   Bundler.require(*Rails.groups(:assets => %w(development test)))
    # end
    # => Bundler.require(:default, Rails.env)
    with_node type: 'if', condition: {type: 'defined?', arguments: {first: 'Bundler'}} do
      replace_with 'Bundler.require(:default, Rails.env)'
    end
  end

  within_file 'config/environments/production.rb' do
    # remove config.active_record.identity_map = true
    with_node type: 'send', receiver: {type: 'send', receiver: {type: 'send', message: 'config'}, message: 'active_record'}, message: 'identity_map=' do
      remove
    end
  end

  within_file 'app/models/**/*.rb' do
    # self.serialized_attributes => self.class.serialized_attributes
    with_node type: 'send', receiver: 'self', message: 'serialized_attributes' do
      replace_with 'self.class.serialized_attributes'
    end
  end

  within_file 'app/models/**/*.rb' do
    # scope :active, where(active: true) => scope :active, -> { where(active: true) }
    with_node type: 'send', receiver: nil, message: 'scope' do
      replace_with 'scope {{self.arguments.first}}, -> { {{self.arguments.last}} }'
    end
  end

  within_file 'test/unit/**/*.rb' do
    # ActiveRecord::TestCase => ActiveSupport::TestCase
    with_node type: 'const', to_s: 'ActiveRecord::TestCase' do
      replace_with 'ActiveSupport::TestCase'
    end
  end

  within_file 'app/**/*.rb' do
    # find_all_by_... => where(...)
    with_node type: 'send', message: /find_all_by_(.*)/ do
      hash_params = '{{find_all_by(self, "find_last_by_")}}'
      replace_with "{{self.receiver}}.where(#{hash_params})"
    end
  end

  within_file 'app/**/*.rb' do
    # find_last_by_... => where(...).last
    with_node type: 'send', message: /find_last_by_(.*)/ do
      hash_params = '{{dynamic_finder_to_hash(self, "find_last_by_")}}'
      replace_with "{{self.receiver}}.where(#{hash_params}).last"
    end
  end

  within_file 'app/**/*.rb' do
    # scoped_by_... => where(...)
    with_node type: 'send', message: /scoped_by_(.*)/ do
      hash_params = '{{dynamic_finder_to_hash(self, "scoped_by_")}}'
      replace_with "{{self.receiver}}.where(#{hash_params})"
    end
  end

  within_file 'app/**/*.rb' do
    # find_or_initialize_by_... => find_or_initialize_by(...)
    with_node type: 'send', message: /find_or_initialize_by_(.*)/ do
      hash_params = '{{dynamic_finder_to_hash(self, "find_or_initialize_by_")}}'
      replace_with "{{self.receiver}}.find_or_initialize_by(#{hash_params})"
    end
  end

  within_file 'app/**/*.rb' do
    # find_or_create_by_... => find_or_create_by(...)
    with_node type: 'send', message: /find_or_create_by_(.*)/ do
      hash_params = '{{dynamic_finder_to_hash(self, "find_or_create_by_")}}'
      replace_with "{{self.receiver}}.find_or_create_by(#{hash_params})"
    end
  end

  within_file 'config/initializers/wrap_parameters.rb' do
    # remove self.include_root_in_json = false
    with_node type: 'block', caller: {receiver: 'ActiveSupport', message: 'on_load', arguments: {first: ':active_record'}} do
      if_only_exist_node to_ast: Parser::CurrentRuby.parse('self.include_root_in_json = false') do
        remove
      end
    end
  end

  within_file 'config/initializers/secret_token.rb' do
    # insert Application.config.secret_key_base = '...'
    unless_exist_node type: 'send', message: 'secret_key_base=' do
      with_node type: 'send', message: 'secret_token=' do
        secret = SecureRandom.hex(64)
        insert_after "{{self.receiver}}.secret_key_base = '#{secret}'"
      end
    end
  end

  within_file 'config/**/*.rb' do
    # remove ActionController::Base.page_cache_extension => ActionController::Base.default_static_extension
    with_node type: 'send', message: 'page_cache_extension=' do
      replace_with 'ActionController::Base.default_static_extension = {{self.arguments}}'
    end
  end

  within_file 'config/routes.rb' do
    # Rack::Utils.escape('こんにちは') => 'こんにちは'
    with_node type: 'send', receiver: 'Rack::Utils', message: 'escape' do
      replace_with '{{self.arguments}}'
    end
  end

  within_file 'config/routes.rb' do
    # match "/" => "root#index" => get "/" => "root#index"
    with_node type: 'send', message: 'match' do
      replace_with 'get {{self.arguments}}'
    end
  end

  within_file 'config/**/*.rb' do
    with_node type: 'send', arguments: {any: 'ActionDispatch::BestStandardsSupport'} do
      remove
    end
  end

  within_file 'config/**/*.rb' do
    with_node type: 'send', message: 'best_standards_support=' do
      remove
    end
  end

  {'ActionController::Integration' => 'ActionDispatch::Integration',
   'ActionController::IntegrationTest' => 'ActionDispatch::IntegrationTest',
   'ActionController::PerformanceTest' => 'ActionDispatch::PerformanceTest',
   'ActionController::AbstractRequest' => 'ActionDispatch::Request',
   'ActionController::Request' => 'ActionDispatch::Request',
   'ActionController::AbstractResponse' => 'ActionDispatch::Response',
   'ActionController::Response' => 'ActionDispatch::Response',
   'ActionController::Routing' => 'ActionDispatch::Routing'}.each do |deprecated, favor|
    within_file '**/*.rb' do
      with_node to_s: deprecated do
        replace_with favor
      end
    end
  end
end
