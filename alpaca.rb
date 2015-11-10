#-- vim:sw=2:et
#++
#
# :title: eric quote
#
# Author:: xx
#
#
# License:: GPL v2

class AlpacaPlugin < Plugin
  def help(plugin, topic)
      "The roundest head has something special to say to you"
  end
  
  def random(m, params)
    files = Dir['/home/mlue/.irclogs/*/p2p/#pants*']
    file = files[rand(files.size-1)]
    m.reply `grep -h '.*\?\(alpaca\|aplaca\).\{20,\}' #{file}   | shuf -n 1)"`
  end
end

plugin = AlpacaPlugin.new
plugin.map 'ap', :action => 'random'
