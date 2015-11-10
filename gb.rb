class GifboyPlugin < Plugin
  require 'rack'
  GIFBOY = "http://gif.1sheeps.com/"

  def bytesize(string)
    string.bytesize
  end

  def escape(s)
    s.to_s.gsub(/([^ a-zA-Z0-9_.-]+)/n) {
      '%'+$1.unpack('H2'*bytesize($1)).join('%').upcase
    }.tr(' ', '+')
  end

  def build_query(params)
    params.map { |k, v|
        if v.class == Array
          build_query(v.map { |x| [k, x] })
        else
          escape(k) + "=" + escape(v)
        end
    }.join("&")
    end

  def post_image(m,params)
    #debug m.source.methods.select{|f| /real/ =~ f }.inspect+" -> "+m.source.to_irc_user.to_s
    m.reply m.source.to_irc_user.to_s+'!, you up to no good' and return if ["mlue","dou","doo","shilla"].select{|x| Regexp.new(x,'i') =~ m.source.to_irc_user.to_s}.empty? || ["mathieu lue","alan",""].select{|x| Regexp.new(x,'i') =~ m.source.real_name.to_s.downcase}.empty?
    tags = params[:tags].map{|f| f.tr('_',' ').gsub(/[^\s[:alnum]]/,'')}.join "_"
    #validate regex url and gifness
    qs = build_query({:url => params[:uri],:tags => tags })
    m.reply qs if /mlue/ !~ m.source.user && m.private?
    begin
      resp = @bot.httputil.head(GIFBOY+"index/upload?"+qs, :read_timeout => 60,:open_timeout => 60)
    rescue Exception => e
      File.open('/home/mlue/pluginlogs/gifboy.log','w'){|f| f.write e.to_s }
      m.reply "Failed!"
      return
    end
    m.reply resp.message
  end
  
  def query_image(m,params)
    begin
      qs = @bot.httputil.get(GIFBOY+"tag/show.json?query="+URI.encode(params[:query].join(" ").gsub(/[^\s[:alnum]]/,'')),:read_timeout => 60,:open_timeout => 60)
      debug qs.inspect
      qs = JSON(qs)
      #results = qs.map{|f| "http://serve.1sheeps.com"+URI.encode(f["url"])}.join(" ")
      #results << " Only showing 5 of "+qs.size if qs.size > 5
      results = (qs.size > 0) ? "http://gif.1sheeps.com/tag/show/"+URI.encode(params[:query].join(" ").gsub(/[^\s[:alnum]]/,'')) : ""
      m.reply n_(_("There is %{bold}%{d}%{bold} result. "+results) % {:bold => Bold, :d => qs.count},_("There are %{bold}%{d}%{bold} results. "+results) % {:bold => Bold, :d => qs.count},qs.size)
    rescue Exception => e
      m.reply e.to_s+$@.to_s if /mlue/ =~ m.source.user
    end
  end
  
end
plugin = GifboyPlugin.new
plugin.map 'gb :uri *tags', :action => 'post_image'
plugin.map 'gif *query', :action => 'query_image'
