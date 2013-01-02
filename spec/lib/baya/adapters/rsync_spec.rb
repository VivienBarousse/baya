require ROOT + "/baya/adapters/rsync"

describe Baya::Adapters::Rsync do

  let(:config) do
    {
      'source' => 'user@example.com:/foo/bar',
      'destination' => 'my/dest'
    }
  end

  subject do
    described_class.new(config)
  end

  before do
    File.stub(:exist?)
    File.stub(:directory?)
    FileUtils.stub(:mkdir_p)
    Open3.stub(:popen3)
  end

  describe "#archive" do
    it "should call rsync to do the archive" do
      Open3.should_receive(:popen3).
        with(
          "rsync",
          "-az",
          "user@example.com:/foo/bar",
          "/my/root/my/dest"
        )
      subject.archive("/my/root")
    end

    context "when rsync returns successfuly" do
      before do
        Open3.stub(:popen3).and_yield(
          nil,
          nil,
          nil,
          stub(:popen3, :value => 0))
      end

      it "should complete successfuly" do
        proc {
          subject.archive("/my/root")
        }.should_not raise_exception
      end
    end

    context "when rsync fails miserably" do
      before do
        Open3.stub(:popen3).and_yield(
          nil,
          nil,
          nil,
          stub(:popen3, :value => 1))
      end

      it "should complete successfuly" do
        proc {
          subject.archive("/my/root")
        }.should raise_exception
      end
    end

    context "when the destination folder already exists" do
      before do
        File.stub(:exist?).and_return(true)
        File.stub(:directory?).and_return(true)
      end

      it "should still call rsync to do the archive" do
        Open3.should_receive(:popen3).with(
          "rsync",
          "-az",
          "user@example.com:/foo/bar",
          "/my/root/my/dest"
        )
        subject.archive("/my/root")
      end

      it "should not try to create the folder" do
        FileUtils.should_not_receive(:mkdir_p)
        subject.archive("/my/root")
      end
    end

    context "when the destination doesn't exist" do
      before do
        File.stub(:exist?).and_return(false)
        File.stub(:directory?).and_return(false)
      end

      it "should create the folder" do
        FileUtils.should_receive(:mkdir_p).with("/my/root/my/dest")
        subject.archive("/my/root")
      end
    end

    context "when the destination is not a folder" do
      before do
        File.stub(:exist?).and_return(true)
        File.stub(:directory?).and_return(false)
      end

      it "should raise an exception" do
        proc {
          subject.archive("/my/root")
        }.should raise_exception
      end

      it "should not try to create the folder" do
        FileUtils.should_not_receive(:mkdir_p)
        subject.archive("/my/root") rescue nil
      end

      it "should not call rsync" do
        Open3.should_not_receive(:popen3)
        subject.archive("/my/root") rescue nil
      end
    end
  end

end
