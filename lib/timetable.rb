require "./lib/objson.rb"
require "json"

module Abema
  module Data
    class Timetable < Hash
      include ObJson
      def initialize arg
        if arg.class == Hash
          hash2tt arg
        else
          raise "no Hash error"
        end
      end
      
      def hash2tt hash
        hash.each do |k, v|
          if v.class == Hash
            v = Timetable.new v
          elsif v.class == Array # Enumerable?
            v = v.map do |i|
              if i.class == Hash
                Timetable.new i
              else
                i
              end
            end
          end
          self[k] = v
        end
      end
    end
  end
end
