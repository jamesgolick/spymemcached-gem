require "spec"
require "active_support/cache/spymemcached_store"

describe "SpymemcachedStore" do
  before do
    @cache = ActiveSupport::Cache::SpymemcachedStore.new("localhost:11211")
  end
  after { @cache.clear }

  it "writes to and reads from cache" do
    @cache.write("a", "b")
    @cache.read("a")
  end

  it "supports expiry on write" do
    @cache.write("a", "b", :expires_in => 1)
    sleep(2)
    @cache.read("a").should be_nil
  end

  it "supports add via the unless_exist property" do
    @cache.write("a", "b")
    @cache.write("a", "c", :unless_exist => true)
    @cache.read("a").should == "b"
  end

  it "supports deleting keys" do
    @cache.write("a", "b")
    @cache.delete("a")
    @cache.read("a").should be_nil
  end

  it "supports exist?" do
    @cache.exist?("a").should == false
    @cache.write("a", "b")
    @cache.exist?("a").should == true
  end

  it "supports increment" do
    @cache.write("a", "1", :raw => true)
    @cache.increment("a")
    @cache.read("a", :raw => true).should == "2"
  end

  it "supports incrementing by a specific amount" do
    @cache.write("a", "1", :raw => true)
    @cache.increment("a", 2)
    @cache.read("a", :raw => true).should == "3"
  end

  it "supports decrement" do
    @cache.write("a", "1", :raw => true)
    @cache.decrement("a")
    @cache.read("a", :raw => true).should == "0"
  end

  it "supports decrementing by a specific amount" do
    @cache.write("a", "2", :raw => true)
    @cache.decrement("a", 2)
    @cache.read("a", :raw => true).should == "0"
  end

  it "supports :expires_in with a duration argument" do
    lambda { @cache.write("a", "2", :expires_in => 1.hour) }.should_not raise_error
  end
end
