require 'spec_helper'
require ROOT + '/baya/adapters/github'

describe Baya::Adapters::Github do
  before do
    Curl.stub(:get)
  end

  let(:config) do
    {
      'user' => 'VivienBarousse',
      'destination' => 'my/destination'
    }
  end

  subject do
    described_class.new(config)
  end

  describe "::new" do
    context "with valid configuration" do
      context "with a user" do
        it "should not raise anything" do
          proc {
            described_class.new(config)
          }.should_not raise_exception
        end
      end

      context "with an organisation" do
        before do
          config.delete('user')
          config['org'] = 'songkick'
        end

        it "should not raise anything" do
          proc {
            described_class.new(config)
          }.should_not raise_exception
        end
      end
    end

    context "when the configuration is invalid" do
      context "when neither `user` or `org` is given" do
        before do
          config.delete('user')
        end

        it "should raise something" do
          proc {
            described_class.new(config)
          }.should raise_exception
        end
      end

      context "when both `user` or `org` are given" do
        before do
          config['org'] = 'songkick'
        end

        it "should raise something" do
          proc {
            described_class.new(config)
          }.should raise_exception
        end
      end

      context "`destination` is missing" do
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

  describe "#repos" do
    let(:repos) do
      <<-JSON
      [
        {
          "clone_url": "ssh://my.imaginart.repo/number/one"
        },
        {
          "clone_url": "ssh://my.imaginart.repo/number/two"
        }
      ]
      JSON
    end

    let(:curl_response) do
      mock(
        :body_str => repos,
        :response_code => 200
      )
    end

    context "with a user" do
      before do
        Curl.stub(:get).
             with('https://api.github.com/users/VivienBarousse/repos').
             and_return(curl_response)
      end

      it "should return the list of repositories" do
        subject.repos.should == [
          "ssh://my.imaginart.repo/number/one",
          "ssh://my.imaginart.repo/number/two"
        ]
      end
    end

    context "with an organisation" do
      before do
        config.delete('user')
        config['org'] = 'songkick'
        Curl.stub(:get).
             with('https://api.github.com/orgs/songkick/repos').
             and_return(curl_response)
      end

      it "should return the list of repositories" do
        subject.repos.should == [
          "ssh://my.imaginart.repo/number/one",
          "ssh://my.imaginart.repo/number/two"
        ]
      end
    end
  end

  describe "#archive" do
    before do
      subject.stub(:repos).and_return([
        "ssh://my.imaginart.repo/number/one",
        "ssh://my.imaginart.repo/number/two"
      ])
    end

    it "should clone the git repositories" do
      git1 = mock()
      git2 = mock()
      Baya::Adapters::Git.should_receive(:new).
                          with(
                            'origin' => "ssh://my.imaginart.repo/number/one",
                            'destination' => 'one').
                          and_return(git1)
      Baya::Adapters::Git.should_receive(:new).
                          with(
                            'origin' => "ssh://my.imaginart.repo/number/two",
                            'destination' => 'two').
                          and_return(git2)
      git1.should_receive(:archive).with('/my/root/folder/my/destination')
      git2.should_receive(:archive).with('/my/root/folder/my/destination')
      subject.archive('/my/root/folder')
    end
  end
end
