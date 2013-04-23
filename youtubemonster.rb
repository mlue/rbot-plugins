# Author:: Mathieu Lue <mathieu.lue@gmail.com>
# 
# License:: 
#
# Submit URLs to channel-specific tumblr accounts
#
# TODO: syllabic substitution


class YoutubeMonster < Plugin
  API_URL = "https://gdata.youtube.com/feeds/api/standardfeeds/US/most_discussed?time=today"
  LANG_KEY = "f7e750fec2972cf332b6cc1ee869965d"
  require 'nokogiri'
  def initialize
    super
    @data = [];
    @responded = false
  end

  def cleanupup
    @data = []
  end
  
  def help(plugin, topic)
      "Helps 1000 monkeys to write Shakespeare"
  end
  
  def unreplied(m)
    begin
      return
      #return unless 1 == rand(100)
      randomComment(m,[])
    rescue => err
      debug err.to_s+" jj "+$@.inspect
    end
  end
  
  def spoolEntries(content)
    contentXML = Nokogiri::XML(content)
    contentXML.remove_namespaces!
    comment_urls= (contentXML/'comments/feedLink').map{|f| f.attr 'href'}
    comment_urls.each do |f|
      req = Nokogiri::XML(@bot.httputil.get(f+"?max-results=50"))
      req.remove_namespaces!
      comments = (req/'feed/entry/content/text()').map(&:to_s).reject{|h| /vid/i  =~  h || /chan/i =~ h || /view/i =~ h || /subscribe/i =~ h || /youtube/i =~ h || /^[ -~]+$/i =~ h }
      @data.push *comments
    end    
    unless @data.empty?
      return @data.delete_at rand(@data.size-1)
    end
  end
  
  def randomComment(m, params)
    @responded = false;
    o = [('a'..'z'),('A'..'Z')].map{|i| i.to_a}.flatten
    string  =  (0...50).map{ o[rand(o.length)] }.join
    local_url = API_URL+string[1,2]
    x=0
    answer = nil
    unless @data.empty?
      debug "WE ARE IN HERE"
      cand = nil
      begin 
        cand = @data.delete_at(rand(@data.size-1)).gsub(/\n/,"")
        resp = JSON(@bot.httputil.get(("http://ws.detectlanguage.com/0.2/detect?q="+CGI.escape(cand)+"&key="+LANG_KEY)))
        debug resp.inspect
        if resp['data']['detections'].select{|g| g['language'] == "en" && g['isReliable'] && g['confidence'] > 0.7}.size >= 1
          File.open('/home/mlue/logs/pluginlogs/ym.log','a4'){|q| q.write "\n"+cand+"\n"+resp.inspect+"\n\n"}
          break
        else
          File.open('/home/mlue/logs/pluginlogs/ym.log','a'){|q| q.write "\n"+cand+"\n"+resp.inspect+"\n\n"}
        end
      rescue
        break
      end while true
      m.reply cand,{:nick => false,:forcenick => false, :to => :public} if cand
      @responded = true;
      return
    end
    begin 
      debug 'making request'
      page = @bot.httputil.get(API_URL)
      #debug page.inspect
      answer = spoolEntries(page)
      x = x+1
    rescue Exception => e
      error e.message
      warning e.backtrace.join("\n")
      answer = "failed"
    end #while answer.nil? && x < 5
    m.reply answer.gsub(/\n/,""),{:nick => false,:forcenick => false, :to => :public} unless @responded 
  end
end

plugin = YoutubeMonster.new
plugin.map 'ogniem',:action => 'randomComment', :private => true
