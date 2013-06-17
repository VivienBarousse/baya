require 'spec_helper'
require ROOT + '/baya/adapters/git'

describe Baya::Adapters::Git do
  before do
    ::Git.stub(:clone)
  end

  let(:config) do
    {
      'origin' => 'ssh://git.repo.that/doesnt/exist/',
      'destination' => 'my/destination'
    }
  end

  subject do
    described_class.new(config)
  end

  describe "::new" do
    context "with valid config" do
      it "should not raise anything" do
        proc {
          described_class.new(config)
        }.should_not raise_exception
      end
    end

    context "with invalid config" do
      context "because `origin` is missing" do
        before do
          config.delete('origin')
        end

        it "should raise something" do
          proc {
            described_class.new(config)
          }.should raise_exception
        end
      end

      context "because `destination` is missing" do
        before do
          config.delete('destination')
        end

        it "should raise something" do
          proc {
            described_class.new(config)
          }.should raise_exception
        end
      end
    end
  end

  describe "#archive" do
    context "when the folder doesn't already exist" do
      it "should git-clone in the right folder" do
        ::Git.should_receive(:clone).with(
          "ssh://git.repo.that/doesnt/exist/",
          "/my/imaginary/folder/my/destination",
          :bare => true
        )
        subject.archive("/my/imaginary/folder")
      end

      context "when the bare option is given" do
        context "and it is true" do
          before do
            config['bare'] = true
          end

          it "should pass the option as true" do
            ::Git.should_receive(:clone).with(
              "ssh://git.repo.that/doesnt/exist/",
              "/my/imaginary/folder/my/destination",
              :bare => true
            )
            subject.archive("/my/imaginary/folder")
          end
        end

        context "and it is false" do
          before do
            config['bare'] = false
          end

          it "should pass the option as false" do
            ::Git.should_receive(:clone).with(
              "ssh://git.repo.that/doesnt/exist/",
              "/my/imaginary/folder/my/destination",
              :bare => false
            )
            subject.archive("/my/imaginary/folder")
          end
        end
      end
    end

    context "when the repository has already been cloned" do
      let(:git) do
        mock(:git, :fetch => nil, :pull => nil)
      end

      before do
        ::Git.stub(:bare).and_return(git)
        ::Git.stub(:open).and_return(git)
        ::File.stub(:directory?).and_return(true)
      end

      it "should git-fetch the existing repository" do
        ::Git.should_receive(:bare).with("/my/imaginary/folder/my/destination")
        git.should_receive(:fetch)
        subject.archive("/my/imaginary/folder")
      end

      context "but it's not a bare repository" do
        before do
          git.stub(:fetch).and_raise(::Git::GitExecuteError.new)
        end

        it "should fallback on the open/pull strategy" do
          ::Git.should_receive(:open).with("/my/imaginary/folder/my/destination")
          git.should_receive(:pull)
          subject.archive("/my/imaginary/folder")
        end
      end
    end

    context "when the folder already exists but isn't a Git repository" do
      let(:bare_git) do
        b = mock(:bare_git)
        b.stub(:fetch).and_raise(::Git::GitExecuteError.new)
        b
      end

      before do
        ::Git.stub(:bare).and_return(bare_git)
        ::Git.stub(:open).and_raise(ArgumentError.new(""))
        ::File.stub(:directory?).and_return(true)
      end

      it "should raise an exception" do
        proc {
          subject.archive("/my/imaginary/folder")
        }.should raise_exception
      end
    end
  end
end
