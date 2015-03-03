class UrbanPlugin < Plugin
  require 'nokogiri'
  URBAN = 'http://api.urbandictionary.com/v0/define?term='
  #'http://www.urbandictionary.com/define.php?term='

  def help( plugin, topic="")
    "urban [word] [n]: give the [n]th definition of [word] from urbandictionary.com. urbanday: give the word-of-the-day at urban"
  end

  def format_definition(total, num, word, desc, ex)
    "#{Bold}#{word} (#{num}/#{total})#{Bold}: " +
    desc.ircify_html(:limit => 300) + " " +
    "<i>#{ex}</i>".ircify_html(:limit => 100)
  end

  def get_def(m, word, n = 0)
#    n = n ? n.to_i : 1
#    p = (n-1)/7 + 1
#    u = URBAN + URI.escape(word)
#    u += '&page=' + p.to_s if p > 1
#    s = @bot.httputil.get(u)

    j = JSON(open('http://api.urbandictionary.com/v0/define?term='+URI.escape(word)).read)
    debug "XTC #{n}"
    n = n.to_i
    n = 1 if n < 1 
    definition = j["list"][ n-1 || 0]["definition"]    

    numpages= j["list"].size

    return m.reply Bold+word+Bold+" - ( Definition "+Bold+(n || 1).to_s+Bold+" of "+Bold+numpages.to_s+Bold+" ) - "+definition.ircify_html() #format_definition((p == numpages ? 20 : "#{(numpages-1)*7 + 1}+"), [])

    return m.reply("Couldn't get the urban dictionary definition for #{word}") if s.nil?
    
  end

  def urban(m, params)
    words = params[:words].to_s
    debug words.inspect
    if words.empty?
      resp = @bot.httputil.head('http://www.urbandictionary.com/random.php',
                               :max_redir => -1,
                               :cache => false)
      return m.reply("Couldn't get a random urban dictionary word") if resp.nil?
      if resp.code == "302" && (loc = resp['location'])
        words = URI.unescape(loc.match(/define.php\?term=(.*)$/)[1]) rescue nil
      end
    end
    debug 'entering getdef'
    get_def(m, words, params[:n])
  end

  def uotd(m, params)
    home = @bot.httputil.get("http://www.urbandictionary.com/daily.php")
    if home.nil?
      m.reply "Couldn't get the urban dictionary word of the day"
      return
    end
    home.match(%r{href="/define.php\?term=.*?">(.*?)<})
    wotd = $1
    debug "Urban word of the day: #{wotd}"
    if !wotd
      m.reply "Couldn't get the urban dictionary word of the day"
      return
    end
    get_def(m, wotd, 1)
  end
end

plugin = UrbanPlugin.new
plugin.map "urban *words :n", :requirements => { :n => /^-?\d+$/ }, :action => 'urban'
plugin.map "urban [*words]", :action => 'urban'
plugin.map "urbanday", :action => 'uotd'

