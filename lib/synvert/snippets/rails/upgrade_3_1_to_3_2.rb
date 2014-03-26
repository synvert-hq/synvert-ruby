Synvert::Rewriter.new 'upgrade_rails_3_1_to_3_2', 'Upgrade rails from 3.1 to 3.2' do
  gem_spec 'rails', '3.1.0'

  within_file 'Gemfile' do
    # append
    # group :assets do
    #   gem 'sass-rails', '~> 3.2.3'
    #   gem 'coffee-rails', '~> 3.2.1'
    #   gem 'uglifier', '>=1.0.3'
    # end
    unless_exist_node type: 'block', caller: {type: 'send', message: 'group', arguments: [:assets]} do
      append """group :assets do
  gem 'sass-rails', '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>=1.0.3'
end"""
    end
  end

  within_file 'config/environments/development.rb' do
    # insert config.active_record.auto_explain_threshold_in_seconds = 0.5
    unless_exist_node type: 'send', receiver: {type: 'send', receiver: {type: 'send', message: 'config'}, message: 'active_record'}, message: 'auto_explain_threshold_in_seconds=' do
      insert 'config.active_record.auto_explain_threshold_in_seconds = 0.5'
    end
  end

  %w(config/environments/development.rb config/environments/test.rb).each do |file_pattern|
    within_file file_pattern do
      # insert config.active_record.mass_assignment_sanitizer = :strict
      unless_exist_node type: 'send', receiver: {type: 'send', receiver: {type: 'send', message: 'config'}, message: 'active_record'}, message: 'mass_assignment_sanitizer=' do
        insert 'config.active_record.mass_assignment_sanitizer = :strict'
      end
    end
  end

  todo <<-EOF
Rails 3.2 deprecates vendor/plugins and Rails 4.0 will remove them completely. While it's not strictly necessary as part of a Rails 3.2 upgrade, you can start replacing any plugins by extracting them to gems and adding them to your Gemfile. If you choose not to make them gems, you can move them into, say, lib/my_plugin/* and add an appropriate initializer in config/initializers/my_plugin.rb.
  EOF
end
