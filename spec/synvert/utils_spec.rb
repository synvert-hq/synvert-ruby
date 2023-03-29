# frozen_string_literal: true

require 'spec_helper'

module Synvert
  RSpec.describe Utils do
    describe '.format_url' do
      it 'converts github url to github raw url' do
        url = 'https://github.com/xinminlabs/synvert-snippets-ruby/blob/main/lib/ruby/map_and_flatten_to_flat_map.rb'
        raw_url = 'https://raw.githubusercontent.com/xinminlabs/synvert-snippets-ruby/main/lib/ruby/map_and_flatten_to_flat_map.rb'
        expect(described_class.format_url(url)).to eq raw_url
      end
    end
  end
end
