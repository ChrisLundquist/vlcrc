require 'spec_helper'

describe VLCRC::VLC do
  subject do
    vlc = VLCRC::VLC.new 'localhost', 4321
    vlc.launch
    sleep 0.5
    vlc.connect
    vlc
  end

  before { load_samples }
  after(:all) { subject.exit }

  it "connects to the socket (localhost:4321 for specs)" do
    subject.should be_connected
  end

  it "opens a media file and detects status properties" do
    @vid = @video_samples[0]
    subject.should_not be_playing
    subject.media = @vid
    subject.should be_playing
    subject.media.should == File.expand_path( @vid )
    subject.length.should be > 0
    subject.fps.should be > 0
    subject.position.should be > 0
  end

  it "restarts connection without issue" do
    subject.should be_connected
    subject.disconnect
    subject.should_not be_connected
    subject.connect
    subject.should be_connected
  end

  it "adds items to the playlist" do
    subject.playlist = @video_samples
    subject.playlist.map{ |i| i[1] }.each_with_index{ |path,i| path.should == @video_samples[i] }
    subject.playing = true
    subject.media.should == @video_samples[0]
  end

  it "can skip to the next item and back" do
    now_playing = subject.media
    subject.next
    subject.position.should be < 10
    subject.prev
    subject.position.should be < 10
    subject.media.should == now_playing
  end
   
  context "when setting the volume" do
    it "should let you set and get the value" do
      subject.volume = 0
      subject.volume.should be_zero
      subject.volume = 100
      subject.volume.should == 100
    end

    it "should let you increment and decrement it" do
      subject.volume = 0
      subject.volup(5)
      #subject.volume.should == 5 # FIXME VLC volup 1 means volume += 32, on a scale of 0..512
      subject.voldown(5)
      subject.volume.should == 0
    end
  end
end
