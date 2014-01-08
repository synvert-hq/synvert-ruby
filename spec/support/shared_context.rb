# coding: utf-8

shared_context "expect to convert" do
  it "expects to convert" do
    converter = described_class.new
    visitor = Synvert::CheckingVisitor.new(converters: [converter])
    expect(visitor.convert(filename, source)).to eq expected_source
  end
end

shared_context "not expect to convert" do
  it "does not expect to convert" do
    converter = described_class.new
    visitor = Synvert::CheckingVisitor.new(converters: [converter])
    expect(visitor.convert(filename, source)).to eq source
  end
end
