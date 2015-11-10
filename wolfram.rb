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
require 'rubygems'
require 'wolfram'
require 'pp'
class WolframPlugin < Plugin
  def initialize
    Wolfram.appid = "86KP7J-L2R5UYUYQ6"
    super
  end
  
  def reply(m, params)
    begin
      resp = Wolfram.fetch(params[:query].join(" "),{:format => "Plaintext"})
      if resp.count > 1
        m.reply resp.inspect 
      else
        m.reply 'I got nothin bro!'
      end  
    rescue Exception => e
      m.reply($@) and return if m.private?
      m.reply "Something went wrong!!"
    end
  end
end

plugin = WolframPlugin.new
plugin.map 'wr *query', :action => 'reply'
