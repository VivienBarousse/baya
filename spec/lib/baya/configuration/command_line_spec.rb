require 'spec_helper'
require ROOT + '/baya/configuration/command_line'

describe Baya::Configuration::CommandLine do
  let(:args) do
    %w()
  end

  subject do
    described_class.new(args)
  end

  describe "--version" do
    it "should be false by default" do
      subject.version.should be_false
    end
    
    context "when the --version flag is given" do
      let(:args) do
        %w(--version)
      end

      it "should detect the flag" do
        subject.version.should be_true
      end
    end
  end

  describe "--help" do
    it "should be false by default" do
      subject.help.should be_false
    end
    
    context "when the --help flag is given" do
      let(:args) do
        %w(--help)
      end

      it "should detect the flag" do
        subject.help.should be_true
      end
    end

    context "when the -h flag is given" do
      let(:args) do
        %w(-h)
      end

      it "should detect the flag" do
        subject.help.should be_true
      end
    end
  end

  describe "--config" do
    %w{-c --config}.each do |opt|
      context "when the #{opt} option is given" do
        let(:args) do
          [opt, "./config_file.json"]
        end

        it "should return the config file" do
          subject.config.should == "./config_file.json"
        end
      end

      context "without a valid argument" do
        let(:args) do
          [opt]
        end

        it "should raise" do
          proc {
            described_class.new(args)
          }.should raise_exception
        end
      end
    end

    context "when no config is given" do
      it "should default to baya.json" do
        subject.config.should == "baya.json"
      end
    end
  end
end
