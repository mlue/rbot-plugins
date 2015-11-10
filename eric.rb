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
require 'english'

class EricPlugin < Plugin
  #API_URL = "http://www.iheartquotes.com/api/v1/random?format=html"
  API_URL = "http://en.wikipedia.org/wiki/Special:Random"

  def help(plugin, topic)
      "fetches a random eric fact"
  end
  
  def reply(content)
    b = (Nokogiri(content)/('.rbcontent/a')).text().gsub(/<br \/>/,'').gsub(/\-+/,' - ').gsub(/[^[:punct:][:alnum:]\- ]/,' ')
    c = b.split
    begin
      rnd = rand(c.size)-1
    end while c[rnd] =~ /(?:the|a|during|in|through|about|for|by|because|with)/i
    c[rnd] = "eric"
    c.join(" ")
  end
  
  def wikirand(content)
    
    b = (Nokogiri(content)/('title')).text().gsub(/\-+/,' - ').gsub(/[^[:punct:][:alnum:] ]/,' ')
    debug b
    c = b.sub(/(?:\s*\(.*\))?\s*\-\s*Wikipedia,\s*the\s*free\s*encyclopedia/,'').split
    debug 'size'
    return nil if c.reject{|f| f =~ /^\(.*\)$/}.size < 3
    x = 0
    begin
      rnd = rand(c.size)-1
      x = x+1
    end while c[rnd] =~ /^(?:the)|(?:a)|(?:of)$/i && x < 20
    if c[rnd] =~ /.{2,}ing/
      c[rnd] = "Ericing"
    else
      c[rnd] = c[rnd].singular == c[rnd] ? "Eric" : "Erics"
    end
    c.join(" ")
  end
  
  def random(m, params)
    x=0
    begin
      debug 'making request'
      page = @bot.httputil.get(API_URL)
      answer = wikirand(page)
      x = x+1
    rescue Exception => e
      error e.message
      warning e.backtrace.join("\n")
      answer = "failed"
    end while answer.to_s.empty? && x < 20
    m.reply answer
  end
end

plugin = EricPlugin.new
plugin.map 'e', :action => 'random'
