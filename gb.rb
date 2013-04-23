class GifboyPlugin < Plugin
  require 'rack'
  GIFBOY = "http://gif.1sheeps.com/index/upload"

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
    m.reply 'nigga you up to no good' and return if /mlue/ !~ m.source.user
    tags = params[:tags].map{|f| f.tr('_',' ').gsub(/[^\s[:alnum]]/,'')}.join "_"
    #validate regex url and gifness
    qs = build_query({:url => params[:uri],:tags => tags })
    m.reply qs if /mlue/ !~ m.source.user && m.private?
    begin
      bot.httputil.head(GIFBOY+"?"+qs, :read_timeout => 60,:open_timeout => 60)
    rescue Exception => e
      File.open('/home/mlue/pluginlogs/gifboy.log','w'){|f| f.write e.to_s }
      m.reply "Failed - shilla's biscuit head"
      return
    end
    m.reply "OK!"
  end
end
plugin = GifboyPlugin.new
plugin.map 'gb :uri *tags', :action => 'post_image'
