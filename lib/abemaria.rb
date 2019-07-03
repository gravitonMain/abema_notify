# -*- coding: utf-8 -*-
require "date"

require "./lib/timetable.rb"
require "./lib/timetable_request.rb"

class Abemaria
  def initialize bearer, channels: [], keywords: [], ignores: []
    @request = Abema::TimetableRequest.new bearer
    @channels = channels
    @keywords = keywords
    @ignores = ignores
    
    @schedules = getSchedules
  end
  
  def getSchedules from: Date.tomorrow, to: Date.tomorrow
    from_str = from.strftime "%Y%m%d"
    to_str = to.strftime "%Y%m%d"
    timetable = @request.get from_str, to_str
    @schedules = timetable.channelSchedules.select {|cs| @channels.any? {|c| cs.channelId.include? c}}
  end
  
  def self.showSlot slot
    Time.at(slot.startAt).strftime("%H:%M") +
      "～" +
      Time.at(slot.endAt).strftime("%H:%M") +
      "<https://abema.tv/channels/#{slot&.channelId}/slots/#{slot.id}|#{slot.title}>" + 
      (" keywords: #{slot.keywords.join(",")}" if slot["keywords"]).to_s
  end
  
  def self.show schedules
    schedules.map do |cs|
      channel = "<https://abema.tv/now-on-air/#{cs.first&.channelId}|#{cs.first&.channelId}>"
      slots = cs.map do |slot|
        showSlot slot
      end
      [channel, slots]
    end.delete_if{|e| e[1].empty?}.map do |e|
      "*#{e[0]}*\n" + e[1].map do |ee|
        "- #{ee}\n"
      end.join("")
    end.join("\n")
  end
  
  def newcomers
    @schedules.map do |ch|
      ch.slots.select do |slot|
        slot.mark["newcomer"] and not ignore?(slot)
      end
    end
  end
  
  def favorites
    @schedules.map do |ch|
      hits = []
      favs = ch.slots.select do |slot|
        hit = []
        any = @keywords.any? do |keyword|
          if (slot.to_s.include? keyword[:keyword] and not ignore?(slot))
            hit << keyword[:keyword]
            true
          else
            false
          end
        end
        hits << hit if not hit.empty?
        any
      end
      for i in 0...favs.size
        favs[i]["keywords"] = hits[i]
      end
      favs
    end
  end
  
  def ignore? slot
    @ignores.any? do |i|
      slot.to_s.include? i[:keyword]
    end
  end
end
