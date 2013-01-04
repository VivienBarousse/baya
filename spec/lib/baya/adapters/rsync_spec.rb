require 'spec_helper'
require ROOT + "/baya/adapters/rsync"

describe Baya::Adapters::Rsync do

  let(:config) do
    {
      'source' => 'user@example.com:/foo/bar',
      'destination' => 'my/dest'
    }
  end

  let(:rsync_out) do
    "OUT1\nOUT2"
  end

  let(:rsync_err) do
    "ERR1\nERR2"
  end

  subject do
    described_class.new(config)
  end

  before do
    File.stub(:exist?)
    File.stub(:directory?)
    FileUtils.stub(:mkdir_p)
    FileUtils.stub(:rmtree)
    Open3.stub(:popen3)
    STDOUT.stub(:puts)
    STDERR.stub(:puts)
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

    context "when the verbose option is given" do
      before do
        config['verbose'] = true
      end

      it "should call rsync with the right options" do
        Open3.should_receive(:popen3).
          with(
            "rsync",
            "-azv",
            "user@example.com:/foo/bar",
            "/my/root/my/dest"
          )
        subject.archive("/my/root")
      end
    end

    context "when rsync returns successfuly" do
      before do
        Open3.stub(:popen3).and_yield(
          nil,
          rsync_out,
          rsync_err,
          stub(:popen3, :value => 0))
      end

      it "should complete successfuly" do
        proc {
          subject.archive("/my/root")
        }.should_not raise_exception
      end

      it "should copy STDOUT over" do
        STDOUT.should_receive(:puts).with(/OUT1/)
        STDOUT.should_receive(:puts).with(/OUT2/)
        subject.archive("/my/root")
      end

      it "should copy STDERR over" do
        STDERR.should_receive(:puts).with(/ERR1/)
        STDERR.should_receive(:puts).with(/ERR2/)
        subject.archive("/my/root")
      end
    end

    context "when rsync fails miserably" do
      before do
        Open3.stub(:popen3).and_yield(
          nil,
          rsync_out,
          rsync_err,
          stub(:popen3, :value => 1))
      end

      it "should not complete successfuly" do
        proc {
          subject.archive("/my/root")
        }.should raise_exception
      end

      it "should copy STDOUT over" do
        STDOUT.should_receive(:puts).with(/OUT1/)
        STDOUT.should_receive(:puts).with(/OUT2/)
        subject.archive("/my/root") rescue nil
      end

      it "should copy STDERR over" do
        STDERR.should_receive(:puts).with(/ERR1/)
        STDERR.should_receive(:puts).with(/ERR2/)
        subject.archive("/my/root") rescue nil
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

    context "under Ruby 1.8" do
      before do
        # Ruby 1.8 yields only 3 arguments to popen3 instead of 4
        Open3.stub(:popen3).and_yield(
          nil,
          rsync_out,
          rsync_err,
          nil)
      end

      it "should not fail" do
        proc {
          subject.archive("/my/root")
        }.should_not raise_exception
      end
    end
  end

  describe "#backup" do
    let(:now) do
      Time.now
    end

    let(:current) do
      now.strftime("%Y%m%d%H%M%S")
    end

    let(:previous) do
      []
    end

    before do
      now && Time.stub(:now).and_return(now)
      Dir.stub(:[]).and_return(previous)
    end

    context "when doing the first backup" do
      let(:previous) do
        []
      end

      it "should call rsync to do the sync" do
        Open3.should_receive(:popen3).with(
          "rsync",
          "-az",
          "--delete",
          "user@example.com:/foo/bar",
          "/my/root/my/dest/#{current}"
        )
        subject.backup("/my/root")
      end

      context "when the verbose option is given" do
        before do
          config['verbose'] = true
        end

        it "should call rsync to do the sync" do
          Open3.should_receive(:popen3).with(
            "rsync",
            "-az",
            "--delete",
            "user@example.com:/foo/bar",
            "/my/root/my/dest/#{current}",
            "-v"
          )
          subject.backup("/my/root")
        end
      end
    end

    context "with any subsequent backup" do
      let(:previous) do
        [
          "/my/root/my/dest/20130101",
          "/my/root/my/dest/20130102"
        ]
      end

      it "should call rsync to do the sync" do
        Open3.should_receive(:popen3).with(
          "rsync",
          "-az",
          "--delete",
          "user@example.com:/foo/bar",
          "/my/root/my/dest/#{current}",
          "--link-dest=/my/root/my/dest/20130102"
        )
        subject.backup("/my/root")
      end
    end

    context "when the destination folder doesn't exist" do
      it "should try to create it" do
        FileUtils.should_receive(:mkdir_p).with("/my/root/my/dest/#{current}")
        subject.backup("/my/root")
      end

      it "should still call rsync" do
        Open3.should_receive(:popen3)
        subject.backup("/my/root")
      end
    end

    context "when the destination folder already exists" do
      before do
        File.stub(:exist?).and_return(true)
        File.stub(:directory?).and_return(true)
      end

      it "should not try to create it" do
        FileUtils.should_not_receive(:mkdir_p)
        subject.backup("/my/root")
      end

      it "should still call rsync" do
        Open3.should_receive(:popen3)
        subject.backup("/my/root")
      end

      context "and it's a file, not a folder" do
        before do
          File.stub(:directory?).and_return(false)
        end

        it "should not try to create it" do
          FileUtils.should_not_receive(:mkdir_p)
          subject.backup("/my/root") rescue nil
        end

        it "shoud not call rsync" do
          Open3.should_not_receive(:popen3)
          subject.backup("/my/root") rescue nil
        end

        it "should raise" do
          proc {
            subject.backup("/my/root")
          }.should raise_exception
        end
      end

      context "when rsync completes successfuly" do
        before do
          Open3.stub(:popen3).and_yield(
            nil,
            rsync_out,
            rsync_err,
            stub(:popen3, :value => 0)
          )
        end

        it "should complete successfuly" do
          subject.backup("/my/root")
        end

        it "should copy STDOUT over" do
          STDOUT.should_receive(:puts).with(/OUT1/)
          STDOUT.should_receive(:puts).with(/OUT2/)
          subject.archive("/my/root")
        end

        it "should copy STDERR over" do
          STDERR.should_receive(:puts).with(/ERR1/)
          STDERR.should_receive(:puts).with(/ERR2/)
          subject.archive("/my/root")
        end
      end

      context "when rsync fails miserably" do
        before do
          Open3.stub(:popen3).and_yield(
            nil,
            rsync_out,
            rsync_err,
            stub(:popen3, :value => 1)
          )
        end

        it "should raise" do
          proc {
            subject.backup("/my/root")
          }.should raise_exception
        end

        it "should copy STDOUT over" do
          STDOUT.should_receive(:puts).with(/OUT1/)
          STDOUT.should_receive(:puts).with(/OUT2/)
          subject.archive("/my/root") rescue nil
        end

        it "should copy STDERR over" do
          STDERR.should_receive(:puts).with(/ERR1/)
          STDERR.should_receive(:puts).with(/ERR2/)
          subject.archive("/my/root") rescue nil
        end
      end
    end

    context "when the maximum number of backups to keep is specified" do
      before do
        config['keepBackups'] = 3
      end

      context "and backups need to be deleted" do
        let(:previous) do
          [
            "/my/root/my/dest/20130101",
            "/my/root/my/dest/20130102",
            "/my/root/my/dest/20130103",
            "/my/root/my/dest/20130104"
          ]
        end

        it "should remove the two oldest folders" do
          FileUtils.should_receive(:rmtree).with("/my/root/my/dest/20130101")
          FileUtils.should_receive(:rmtree).with("/my/root/my/dest/20130102")
          subject.backup("/my/root")
        end
      end

      context "and no backups need to be deleted" do
        let(:previous) do
          [
            "/my/root/my/dest/20130101",
            "/my/root/my/dest/20130102"
          ]
        end

        it "should not remove any folder" do
          FileUtils.should_not_receive(:rmtree)
          subject.backup("/my/root")
        end
      end
    end

    context "under Ruby 1.8" do
      before do
        # Ruby 1.8 yields only 3 arguments to popen3 instead of 4
        Open3.stub(:popen3).and_yield(
          nil,
          rsync_out,
          rsync_err,
          nil)
      end

      it "should not fail" do
        proc {
          subject.backup("/my/root")
        }.should_not raise_exception
      end
    end
  end

end
