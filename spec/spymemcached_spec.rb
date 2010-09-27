require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Spymemcached do
  before do
    @cache = Spymemcached.new(["localhost:11211"])
  end
  after { @cache.flush }

  it "sets and gets keys" do
    @cache.set("a", "b")
    @cache.get("a").should == "b"
  end

  it "returns nil for missing keys" do
    @cache.get("asdf").should be_nil
  end

  it "sets expiration on keys" do
    @cache.set("a", "b", 1)
    sleep(2)
    @cache.get("a").should be_nil
  end
end
