module Synvert
  module Utils
    class << self
      def format_url(url)
        convert_to_github_raw_url(url)
      end

      private

      def convert_to_github_raw_url(url)
        if url.include?('//github.com/')
          url = url.sub('//github.com/', '//raw.githubusercontent.com/').sub('/blob/', '/')
        end
        url
      end
    end
  end
end