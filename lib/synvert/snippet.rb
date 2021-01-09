require 'open-uri'
require 'json'

module Synvert
  # Manage synvert snippets.
  class Snippet
    # synchronize snippets from github.
    def self.sync
      snippets_path = Core::Configuration.instance.get :default_snippets_path
      if File.exist?(snippets_path)
        FileUtils.cd snippets_path
        system('git pull --rebase')
      else
        system("git clone https://github.com/xinminlabs/synvert-snippets.git #{snippets_path}")
      end
    end

    def self.fetch_core_version
      content = open('https://rubygems.org/api/v1/versions/synvert-core.json').read
      JSON.parse(content).first['number']
    end
  end
end
