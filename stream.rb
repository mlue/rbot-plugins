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
  CHANNELS = {}#{"#capcom" => ["iplaywinner","madcatz","nycfurby","topangatv","freida0914","teamsp00ky","gostunv","leveluplive","armshouse","ogamingtv"],"##x" => ["draskyll","blitzdota","nycfurby","topangatv","freida0914","teamsp00ky","gostunv","leveluplive","massivelytv"]}

  def initialize

    super
    @data = @registry['0']
    @registry.set_default({})
    @apiPingLoop = @bot.timer.add(100) do
      chans =  CHANNELS.select{|q| @bot.channels.map(&:name).include?(q[0])}
      debug chans
      return if chans.empty?
      chans.each do |chan,s|
        debug s.inspect
        s.each do |channel|
          debug "KEY "+channel.inspect+" / VAL "+@data[channel].inspect
          streams = JSON(@bot.httputil.get(API_URL+"?channel="+channel))
          unless streams.first.nil?
            @bot.say chan,channel+" live - "+streams.first["title"]+" http://twitch.tv/"+channel if Time.parse(streams.first["up_time"]).to_i > @data[channel].to_i+10800
            debug "pushing "+Time.parse(streams.first["up_time"]).to_i.to_s+"to db"
            @data[channel] = Time.parse(streams.first["up_time"]).to_i
          end
        end
      end
    end
      

    
    def cleanup
      @bot.timer.remove(@apiPingLoop)
      #@registry['0'] = @data
      @registry.vanish
      super
    end
  end
end
  
  

#plugin = StreamPlugin.new
