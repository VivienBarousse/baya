require ROOT + "/baya/configuration/file"

describe Baya::Configuration::File do

  subject do
    described_class.new("my_config_file.json")
  end

  before do
    ::File.stub(:open).and_return(mock(:file, :read => json))
  end

  let(:json) do
    "{}"
  end

  it "should try to open the file" do
    ::File.should_receive(:open).with("my_config_file.json")
    described_class.new("my_config_file.json")
  end

  context "with invalid JSON" do
    let(:json) do
      "d*f{hqou)r"
    end

    it "should raise an exception" do
      proc {
        described_class.new("my_config_file.json")
      }.should raise_exception
    end
  end

  context "with valid configuration" do
    let(:json) do
      <<-JSON
        {
          "root": "/my/root",
          "adapters": [
            {
              "type": "git",
              "mode": "archive",
              "config": {
                "origin": "ssh://example.com/foo/bar",
                "destination": "git/bar"
              }
            },
            {
              "type": "github",
              "mode": "archive",
              "config": {
                "user": "VivienBarousse",
                "destination": "github/VivienBarousse"
              }
            }
          ]
        }
      JSON
    end

    it "should parse the root folder correctly" do
      subject.root.should == "/my/root"
    end

    it "should detect the two adapters" do
      subject.adapters.count.should == 2
    end

    it "should detect the adapters types" do
      subject.adapters.map(&:type).should == ['git', 'github']
    end

    it "should detect the adapters modes" do
      subject.adapters.map(&:mode).should == ['archive', 'archive']
    end

    it "should detect the adapters configurations" do
      subject.adapters.map(&:config).should == [
        {
          'origin' => 'ssh://example.com/foo/bar',
          'destination' => 'git/bar'
        },
        {
          'user' => 'VivienBarousse',
          'destination' => 'github/VivienBarousse'
        }
      ]
    end
  end

end
