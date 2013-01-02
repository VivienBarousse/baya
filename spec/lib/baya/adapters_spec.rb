require ROOT + "/baya/adapters"

describe Baya::Adapters do
  describe "#from_name" do
    it "should know about the main adapters" do
      described_class.from_name('git').should == Baya::Adapters::Git
      described_class.from_name('github').should == Baya::Adapters::Github
      described_class.from_name('rsync').should == Baya::Adapters::Rsync
    end
  end
end
