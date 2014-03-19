#-- vim:sw=2:et
#++
#
# :title: eric quote
#
# Author:: xx
#
#
# License:: GPL v2
class FriendCodePlugin < Plugin
  #API_URL = "http://www.iheartquotes.com/api/v1/random?format=html"
  API_URL = "http://en.wikipedia.org/wiki/Special:Random"

  def help(plugin, topic)
    ".fc all =>  pms entire list, .fc => gives you a random one, .fc set <code> sets your code"
  end
  def initialize
    super
    class << @registry
      def store(val)
        val.downcase
      end
      def restore(val)
        val.downcase
      end
    end
  end

  def chunk(string, size)
    string.nil? ? [''] : string.scan(/.{1,#{size}}/)
  end

  def fc_force_set(m,params)
    if /[\d\-]{12}/ =~ params[:num]
      @registry[params[:name].gsub(/[^[:alnum]]/,'')] = params[:num].gsub(/\-/,'')
      m.okay 
    end
  end

  def fc_set(m,params)
    if /[\d\-]{12}/ =~ params[:num]
      @registry[m.source.nick.downcase.gsub(/[^[:alnum]]/,'')] = params[:num].gsub(/\-/,'')
      m.okay 
    elsif /rand/ =~ m.source.nick.downcase.gsub(/[^[:alnum]]/,'')
      m.reply("Fuckin randy doesn't even own a ds")
    else 
      m.reply("That is not a valid friend code! Please don't use dashes")
    end
  end
  
  def fc_get(m,params)
    unless params[:num]
      rc = @registry.to_a
      unless rc.empty?
        rc = rc[rand(rc.size-1)]
        m.reply _("%{name} => %{fc}")  % {:name => rc[0].downcase, :fc => chunk(rc[1],4).join("-")}
      else
        m.reply "empty!"
      end
    else
      m.reply _("%{name} => %{fc}")  % {:name => params[:num].downcase, :fc => chunk(@registry[params[:num].downcase.gsub(/[^[:alnum]]/,'')],4).join("-")} if @registry.to_a.map{|f| f[0].downcase}.include? params[:num].downcase.gsub(/[^[:alnum]]/,'')
      m.reply _("no one by that name") unless @registry.to_a.map{|f| f[0].downcase}.include? params[:num].downcase.gsub(/[^[:alnum]]/,'')
    end
  end


  def fc_all(m,params)
    rc = @registry.to_a.sort_by{|f| f[0]}
    debug('set')
    msg = rc.map{|f| f[0].downcase+" => "+chunk(f[1],4).join("-")}.join(" || ")
    puts msg.inspect
    if !m.public?
      m.reply _(msg)
    else
      m.reply "please send this privately"
    end
  end
  
  def fc_des(m,params)
    if m.source.nick =~ /mlue/ && params[:name]
      @registry.delete params[:name] and m.okay if @registry.has_key? params[:name]
    elsif @registry.has_key? m.source.nick.downcase.gsub(/[^[:alnum]]/,'')
      @registry.delete m.source.nick.downcase.gsub(/[^[:alnum]]/,'')
      m.okay
    else
      m.reply "no such record"
    end
  end

end
plugin = FriendCodePlugin.new
plugin.map 'fc all', :action => 'fc_all'
plugin.map 'fc get [:num]', :action => 'fc_get'
plugin.map 'fc set :num', :action => 'fc_set'
plugin.map 'fc fset :name :num', :action => 'fc_force_set'
plugin.map 'fc destroy [:name]', :action => 'fc_des'
