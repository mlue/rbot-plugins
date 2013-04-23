#-- vim:sw=2:et
#++
#
# :title: eric quote
#
# Author:: xx
#
#
# License:: GPL v2

require 'nokogiri'
require 'json'



class StreamPlugin < Plugin
  API_URL = "http://api.justin.tv/api/stream/list.json"
  CHANNELS = {"#capcom" => ["topangatv","freida0914","teamsp00ky","gostunv","leveluplive"],"##gerber" => ["draskyll","blitzdota"]}

  def initialize
    super
    class << @registry
      def store(val)
        val
      end
      def restore(val)
        val
      end
    end
    
    @registry.set_default(0)
    @apiPingLoop = @bot.timer.add(300) do
      chans =  CHANNELS.select{|q| @bot.channels.map(&:name).include?(q[0])}
      debug chans
      return if chans.empty?
      chans.each do |chan,s|
        debug s.inspect
        streams = JSON(@bot.httputil.get(API_URL+"?channel="+s))
        unless streams.first.nil?
          @bot.say "mlue",s+" live - "+streams.first["title"]+" http://twitch.tv/"+s if Time.parse(streams.first["up_time"]).to_i > @registry[s].to_i
          @registry[s] = Time.parse(streams.first["up_time"]).to_i
        end
      end
    end
    
    def cleanup
      @bot.timer.stop
      @bot.timer.remove(@apiPingLoop)
    end
  end
end
  

plugin = StreamPlugin.new
