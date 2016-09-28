require 'spec_helper'

describe RustWatcher do
  it 'has a version number' do
    expect(RustWatcher::VERSION).not_to be nil
  end

  it 'responds to watch_binding' do
    rw = RustWatcher.new('some_path'){|op, path|}
    expect(rw.respond_to?(:watch_binding)).to eq(true)
  end
end
