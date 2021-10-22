# frozen_string_literal: true

require 'open-uri'
require 'json'
require 'fileutils'

module Synvert
  # Manage synvert snippets.
  class Snippet
    def self.fetch_core_version
      content = uri_open('https://rubygems.org/api/v1/versions/synvert-core.json').read
      JSON.parse(content).first['number']
    end

    def initialize(snippets_path)
      @snippets_path = snippets_path
    end

    # synchronize snippets from github.
    def sync
      if File.exist?(@snippets_path)
        FileUtils.cd @snippets_path
        Kernel.system('git checkout .; git pull --rebase')
      else
        Kernel.system("git clone https://github.com/xinminlabs/synvert-snippets-ruby.git #{@snippets_path}")
      end
    end

    def self.uri_open(url)
      Gem::Version.new(RUBY_VERSION) >= Gem::Version.new('2.5.0') ? URI.open(url) : open(url)
    end
  end
end
