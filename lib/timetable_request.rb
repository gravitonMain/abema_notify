require "uri"
require "net/http"

require "./lib/timetable.rb"

module Abema
  class TimetableRequest
    def initialize bearer
      @bearer = bearer
    end
    
    def get dateFrom=nil, dateTo=nil
      dateFrom = time2str Time.now if dateFrom.nil?
      dateTo = dateFrom if dateTo.nil?
      url_str = "https://api.abema.io/v1/media?dateFrom=#{dateFrom}&dateTo=#{dateTo}"
      url = URI.parse(url_str)
      req = Net::HTTP::Get.new(url.request_uri)
      req["Authorization"] = @bearer
      res = Net::HTTP.start(url.host) do |http|
        http.request(req)
      end
      return Data::Timetable.new(JSON.parse(res.body))
    end
    
    def time2str time
      time.strftime "%Y%m%d"
    end
  end
end
