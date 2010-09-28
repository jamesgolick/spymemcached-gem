require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require "action_view"

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
    @cache.set("number", "1", 0, false)
    @cache.incr("number")
    @cache.get("number", false).should == "2"
  end

  it "increments keys by a set amount" do
    @cache.set("number", "1", 0, false)
    @cache.incr("number", 2)
    @cache.get("number", false).should == "3"
  end

  it "decrements keys" do
    @cache.set("number", "2", 0, false)
    @cache.decr("number")
    @cache.get("number", false).should == "1"
  end

  it "decrements keys by a set amount" do
    @cache.set("number", "2", 0, false)
    @cache.decr("number", 2)
    @cache.get("number", false).should == "0"
  end

  it "appends to keys" do
    @cache.set("appendtome", "a", 0, false)
    @cache.append("appendtome", "b")
    @cache.get("appendtome", false).should == "ab"
  end

  it "prepends to keys" do
    @cache.set("prependtome", "b", 0, false)
    @cache.prepend("prependtome", "a")
    @cache.get("prependtome", false).should == "ab"
  end

  it "returns boolean for prepend" do
    @cache.set("prependtome", "b", 0, false)
    @cache.prepend("prependtome", "a").should == true
  end

  it "returns boolean for append" do
    @cache.set("appendtome", "b", 0, false)
    @cache.append("appendtome", "a").should == true
  end

  it "multigets" do
    @cache.set("a", "b")
    @cache.set("b", "c")
    @cache.set("c", "d")
    @cache.multiget(["a", "b", "c"]).should == {
      "a" => "b",
      "b" => "c",
      "c" => "d"
    }
  end

  it "supports add" do
    @cache.add("a", "b").should == true
    @cache.get("a").should == "b"
    @cache.add("a", "b").should == false
  end

  it "supports expiry for add" do
    @cache.add("a", "b", 1).should == true
    sleep(2)
    @cache.get("a").should be_nil
  end

  it "supports deleting keys" do
    @cache.set("a", "b")
    @cache.del("a")
    @cache.get("a").should be_nil
  end

  it "returns boolean for deletes" do
    @cache.set("a", "b")
    @cache.del("a").should == true
  end

  it "correctly marshals and unmarshals objects" do
    @cache.set("a", {:a => "b"})
    @cache.get("a").should == {:a => "b"}
  end

  it "supports setting and getting keys without marshalling the data" do
    @cache.set("a", {:a => "b"}, 0, false)
    @cache.get("a", false).should == {:a => "b"}.to_s
  end
  
  it "supports adding keys without marshalling the data" do
    @cache.add("a", {:a => "b"}, 0, false)
    @cache.get("a", false).should == {:a => "b"}.to_s
  end

  # not sure exactly why, but ActionView::SafeBuffer
  # is the only repeatable instance of this bug that
  # I can find
  it "supports marshalling ActionView::SafeBuffers" do
    s = ActionView::SafeBuffer.new "<div class=\"story_2 clearfix\">\n    <a href=\"/users/4\"><img alt=\"\" class=\"\" height=\"35\" src=\"http:///avatar_missing_35x35.gif\" title=\"\" width=\"35\" /></a>"
    @cache.set("a", s)
    @cache.get("a").should == s
    @cache.multiget(["a"]).should == {"a" => s}
  end
end
