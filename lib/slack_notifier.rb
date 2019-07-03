require "slack-ruby-client"
require "thwait"

require "./lib/timer.rb"

class SlackNotifier
  def initialize token, channel: "#general"
    Slack.configure do |config|
      config.token = token
    end
    
    @client = Slack::Web::Client.new
    @channel = channel
    @reservations = []
  end
  
  def reserve at, text
    @reservations << Timer.new(at).run do
      @client.chat_postMessage(channel: @channel, text: text)
    end
  end
  
  def wait
    ThreadsWait.all_waits @reservations
  end
end
