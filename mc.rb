#-- vim:sw=2:et
#++
#
# :title: World of Warcraft Realm Status plugin for rbot
#
# Author:: MrChucho (mrchucho@mrchucho.net)
# Copyright:: (C) 2006 Ralph M. Churchill
#
# Requires:: insatiable appetite for World of Warcraft

require 'json'
class MinecraftPlugin < Plugin
  USAGE="mc => list players on minecraft.webrender.net"
  COLORKEY = {"survival" => "5", "pvp" => "7", "creative" => "12"}
    def initialize
        super
        class << @registry
            def store(val)
                val
            end
            def restore(val)
                val
            end
        end
    end
    def help(plugin,topic="")
        USAGE
    end
    def usage(m,params={})
        m.reply USAGE
    end
    def get_players(m,params)
        begin
          get = @bot.httputil.get("http://minecraft.webrender.net/standalone/dynmap_survival.json", :cache => false)
          raise "unable to retrieve realm status" unless get
          json = JSON(get)
          activeWorlds = json['players'].map{|p| p['world']}.uniq
          m.reply "There are no players on at the moment!" and return if activeWorlds.empty?
          players = activeWorlds.map{|world| [world,json['players'].select{|p| p['world'] == world}]}
          m.reply players.map {|p| "#{p[1].size} Active Players on #{COLORKEY[p[0]] || "7"} #{p[0]} : #{p[1].map{|p1| p1['name']}.join(", ")}"}.join("\n")
        rescue Exception => err
          if m.source.user == "mlue" && m.private?
            m.reply $@
            m.reply err
          end
          m.reply "minecraft server is unavailable at the moment."
        end
    end
end
plugin = MinecraftPlugin.new
plugin.map 'mc', :action => :get_players
