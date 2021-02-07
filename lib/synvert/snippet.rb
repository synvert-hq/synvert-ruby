# coding: utf-8
require 'open-uri'
require 'json'

module Synvert
  # Manage synvert snippets.
  class Snippet
    def initialize(snippets_path)
      @snippets_path = snippets_path
    end

    # synchronize snippets from github.
    def sync
      if File.exist?(@snippets_path)
        FileUtils.cd @snippets_path
        Kernel.system('git pull --rebase')
      else
        Kernel.system("git clone https://github.com/xinminlabs/synvert-snippets.git #{@snippets_path}")
      end
    end

    def fetch_core_version
      content = URI.open('https://rubygems.org/api/v1/versions/synvert-core.json').read
      JSON.parse(content).first['number']
    end
  end
end
