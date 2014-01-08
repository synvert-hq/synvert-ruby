# coding: utf-8

shared_context "expect to convert" do
  it "expects to convert" do
    converter = described_class.new
    source_buffer = Parser::Source::Buffer.new filename
    source_buffer.source = source

    parser = Parser::CurrentRuby.new
    ast = parser.parse source_buffer

    expect(converter.rewrite(source_buffer, ast)).to eq expected_source
  end
end

shared_context "not expect to convert" do
  it "does not expect to convert" do
    converter = described_class.new
    source_buffer = Parser::Source::Buffer.new filename
    source_buffer.source = source

    parser = Parser::CurrentRuby.new
    ast = parser.parse source_buffer

    expect(converter.rewrite(source_buffer, ast)).to eq source
  end
end

shared_context "interesting file" do
  it "interests file" do
    converter = described_class.new
    expect(converter.interesting_files.any? { |file_pattern| filename =~ file_pattern }).to eq true
  end
end

shared_context "not interesting file" do
  it "does not interest file" do
    converter = described_class.new
    expect(converter.interesting_files.none? { |file_pattern| filename =~ file_pattern }).to eq true
  end
end
