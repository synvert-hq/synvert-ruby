Synvert::Rewriter.new 'group', 'name' do
  within_files 'app/controllers/**/*.rb' do
    with_node node_type: 'send', receiver: nil, message: 'render', arguments: { size: 1, '0': { node_type: 'hash', nothing_value: true } } do
      replace :message, with: 'head'
      goto_node 'arguments.0' do
        with_node node_type: 'hash', status_value: nil do
          replace_with ':ok'
        end
        with_node node_type: 'hash', status_value: { not: nil } do
          replace_with '{{status_source}}'
        end
      end
    end
  end
end
