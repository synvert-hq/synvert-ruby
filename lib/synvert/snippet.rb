# frozen_string_literal: true

module Synvert
  # Manage synvert snippets.
  class Snippet
    def initialize(snippets_path)
      @snippets_path = snippets_path
    end

    # synchronize snippets from github.
    def sync
      if File.exist?(@snippets_path)
        Dir.chdir(@snippets_path) do
          Kernel.system('git checkout . && git pull --rebase')
        end
      else
        Kernel.system("git clone https://github.com/xinminlabs/synvert-snippets-ruby.git #{@snippets_path}")
      end
    end
  end
end
