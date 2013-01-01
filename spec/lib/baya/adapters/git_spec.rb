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
          "/my/imaginary/folder/my/destination"
        )
        subject.archive("/my/imaginary/folder")
      end
    end

    context "when the repository has already been cloned" do
      let(:git) do
        mock(:git, :pull => nil)
      end

      before do
        ::Git.stub(:open).and_return(git)
        ::File.stub(:directory?).and_return(true)
      end

      it "should git-pull the existing repository" do
        ::Git.should_receive(:open).with("/my/imaginary/folder/my/destination")
        git.should_receive(:pull)
        subject.archive("/my/imaginary/folder")
      end
    end

    context "when the folder already exists but isn't a Git repository" do
      before do
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
