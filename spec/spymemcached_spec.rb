require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'rubygems'
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
    @cache.set("number", "1", 0, true)
    @cache.incr("number")
    @cache.get("number", true).should == "2"
  end

  it "increments keys by a set amount" do
    @cache.set("number", "1", 0, true)
    @cache.incr("number", 2)
    @cache.get("number", true).should == "3"
  end

  it "decrements keys" do
    @cache.set("number", "2", 0, true)
    @cache.decr("number")
    @cache.get("number", true).should == "1"
  end

  it "decrements keys by a set amount" do
    @cache.set("number", "2", 0, true)
    @cache.decr("number", 2)
    @cache.get("number", true).should == "0"
  end

  it "appends to keys" do
    @cache.set("appendtome", "a", 0, true)
    @cache.append("appendtome", "b")
    @cache.get("appendtome", true).should == "ab"
  end

  it "prepends to keys" do
    @cache.set("prependtome", "b", 0, true)
    @cache.prepend("prependtome", "a")
    @cache.get("prependtome", true).should == "ab"
  end

  it "returns boolean for prepend" do
    @cache.set("prependtome", "b", 0, true)
    @cache.prepend("prependtome", "a").should == true
  end

  it "returns boolean for append" do
    @cache.set("appendtome", "b", 0, true)
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

  # not sure exactly why, but ActionView::SafeBuffer
  # is the only repeatable instance of this bug that
  # I can find
  it "supports marshalling ActionView::SafeBuffers" do
    s = ActionView::SafeBuffer.new "<div class=\"story_2 clearfix\">\n    <a href=\"/users/4\"><img alt=\"\" class=\"\" height=\"35\" src=\"http:///avatar_missing_35x35.gif\" title=\"\" width=\"35\" /></a>"
    @cache.set("a", s)
    @cache.get("a").should == s
    @cache.multiget(["a"]).should == {"a" => s}
  end

  it "supports configurable transcoders" do
    class NonsenseTranscoder < Spymemcached::RubyTranscoder
      def decode(data)
        "decoded"
      end

      def encode(object)
        Spymemcached::CachedData.new(0, "encoded".to_java_bytes, getMaxSize)
      end
    end

    @cache = Spymemcached.new(["localhost:11211"], NonsenseTranscoder.new)
    @cache.set("a", "b")
    @cache.get("a", true).should == "encoded"
    @cache.get("a").should == "decoded"
  end
end
