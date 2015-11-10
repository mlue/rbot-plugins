# -*- coding: utf-8 -*-
class DongersPlugin < Plugin
  load "/home/mlue/scripts/lwl.rb"
  def initialize
    super
  end

  def help(plugin, topic)
    "STUPID MICHEAL"
  end
  
  def dongers(m,params)
    m.reply Bold+"༼ つ ◕_◕ ༽つ!MOLLY! ༼ つ ◕_◕ ༽"+Bold
  end
  
  def lanm(m,params)
    m.reply "Let's go lanm!!!"+Bold+"༼ つ ◕_◕ ༽つ"+("LanM").split("").map{|f| color(f)}.join("")+"༼ つ ◕_◕ ༽つ"+Bold
  end
  
end
plugin = DongersPlugin.new
plugin.map 'd', :action => 'dongers'
plugin.map 'lm', :action => 'lanm'
