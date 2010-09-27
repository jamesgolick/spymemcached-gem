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

  it "increments keys" do
    @cache.set("number", "1")
    @cache.incr("number")
    @cache.get("number").should == "2"
  end

  it "increments keys by a set amount" do
    @cache.set("number", "1")
    @cache.incr("number", 2)
    @cache.get("number").should == "3"
  end

  it "decrements keys" do
    @cache.set("number", "2")
    @cache.decr("number")
    @cache.get("number").should == "1"
  end

  it "decrements keys by a set amount" do
    @cache.set("number", "2")
    @cache.decr("number", 2)
    @cache.get("number").should == "0"
  end

  it "appends to keys" do
    @cache.set("appendtome", "a")
    @cache.append("appendtome", "b")
    @cache.get("appendtome").should == "ab"
  end

  it "prepends to keys" do
    @cache.set("prependtome", "b")
    @cache.prepend("prependtome", "a")
    @cache.get("prependtome").should == "ab"
  end

  it "returns boolean for prepend" do
    @cache.set("prependtome", "b")
    @cache.prepend("prependtome", "a").should == true
  end

  it "returns boolean for append" do
    @cache.set("appendtome", "b")
    @cache.append("appendtome", "a").should == true
  end
end
