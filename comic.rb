#-- vim:sw=2:et
#++
#
# :title: eric quote
#
# Author:: xx
#
#
# License:: GPL v2

class ComicPlugin < Plugin
  require 'RMagick'
  require 'pp'
  include Magick

  PATH="/var/www/serve.1sheeps.com/comics/"
  HEIGHT=1050
  WIDTH=400
  FONT_SIZE = 12
  PANELS = 6
  def help(plugin, topic)
    "COMIC!"
  end
  

  def comic(m,params)
    panels = params[:panels] || PANELS
    p("")
    p("PANELS ----"+params[:panels].inspect)
    p("PANELS ----"+panels.inspect)
    p("")
    panels = panels.to_i
    panels = 17 if panels > 17
    panels = 3 if panels < 3
    #    panels = panels+1
    height = 205*panels
    m.reply("hold on! Recharging!") and return if Time.now - File.mtime('/home/mlue/comicpid') < 15
    m.reply("hold up!") and return if (File.read('/home/mlue/comicpid').strip != "unlocked")
    File.open("/home/mlue/comicpid","w"){|f| f.write "locked"}
    ##puts `ps aux | grep '.*ruby.*comic'`
    %q{    status = `ps aux | grep '.*ruby.*comic' | wc | awk '{print $1}'`
    if status.to_i > 3
      #puts status
      abort("HEY WAIT")  
    end}
    m.reply "MAKING COMPIES!!"
    #puts status

    #BREAKPOINT

    msgs = [] 
#    m.reply m.channel.to_s.gsub(/[^[:alnum:]]/,'')
    begin
      `tail -300 $(ls -alt ~/.irclogs/*/*/*#{m.channel.to_s.gsub(/[^[:alnum:]]/,'').downcase}* | tac | tail -1 | awk '{print $NF}') | tac`.split("\n").each{|f|
        if msgs.size >= panels
          break
        end
        if  f =~ /\*\s*\|\s*(\b[[:alnum:]]+\b)(.+)/
          nm = $1
          tmp = $2
          tmp = tmp.gsub(/^ *\| /,'').strip
          tmp = "*"+tmp
          next if tmp =~ /^ *\./ || tmp =~ /^ *\http[^\s]*$/ || (nm =~ /gerberb/ &&  (tmp.gsub(/[^[:alpha:]]/,'').size < 10 || tmp.gsub(/^ *\| /,'') =~ /^\d/)) || nm.gsub(/^ *\| /,'').strip =~ /^\-\-/ 
          nm.gsub!(/[^[:alnum:]]/,'')
          if msgs.last.class == Array

            #puts "MSG LAST FIRST FIRST -> "+msgs.last.first.first+" <--"+nm.strip
            if msgs.last.size < 2 && msgs.last.first.class == Array && msgs.last.first.first != nm.strip
              msgs.last << [nm.strip,tmp]
            else
              msgs  << [[nm.strip,tmp]] unless msgs.size >= panels
            end
          else
            #puts "FIRST"
            msgs  << [[nm.strip,tmp]]
          end
        elsif f =~ /<(.*?)>(.+)/
          nm = $1
          tmp = $2.gsub(/^ *\| /,'').strip
          next if tmp =~ /^ *\./ || tmp =~ /^ *\http[^\s]*$/ || (nm =~ /gerberb/ &&  (tmp.gsub(/[^[:alpha:]]/,'').size < 10 || tmp =~ /^\d/) || tmp =~ /\[/ || tmp =~ /^Today|Tomorrow/ || tmp =~  /Making COMPIES|has started/i) || nm.gsub(/^ *\| /,'').strip =~ /^\-\-/ || tmp.gsub(/[^[:alpha:]]/,'').size < 2
          nm.gsub!(/[^[:alnum:]]/,'')
          if msgs.last.class == Array

            #puts "MSG LAST FIRST FIRST -> "+msgs.last.first.first+" <--"+nm.strip
            if msgs.last.size < 2 && msgs.last.first.class == Array && msgs.last.first.first != nm.strip
              msgs.last << [nm.strip,tmp]
            else
              msgs  << [[nm.strip,tmp]] unless msgs.size >= panels
            end
          else
            #puts "FIRST"
            msgs  << [[nm.strip,tmp]]
          end

        end
      }
      ho = []
      msgs.each{|f| f.each{|g| ho << g}}
      ho.flatten!
      bo = []
      ho.each_with_index{|f,g| 
        if (g % 2 == 0)
          bo << f 
        end
      }
      pics =  Hash[*bo.uniq.zip(Dir[PATH+"assets/*"].shuffle).flatten]

      p pics.inspect

      #    msgs.pop
      img = Image.new WIDTH,height
      #pp pics
      vatos = {}
      pics.each{|f,g| vatos[f] = Image.read(g)}
      dst = Magick::Image.read("plasma:grey-grey") {self.size = WIDTH.to_s+"x200"}.first
      
      msgs.reverse!
      msgs.each_with_index {|msg,i| 
        msg.reverse! if msg.size > 1 
        #  chr = Image.read(PATH+'/assets/penguin2.png')
        chr = vatos[msg.first[0]]

        offset_y = i*205
        #pp "OFFSET Y --> "+offset_y.to_s
        #BG
        img = img.composite(dst, Magick::NorthWestGravity,0,offset_y,Magick::OverCompositeOp)
        image_offset_y =  offset_y + (200-chr.first.rows)
        #chr.first.destroy!
        #p "IMAGE OFFSET Y -->"+image_offset_y.to_s


        tt = "caption:"+msg.first[1].gsub(/\\/,'\\\\\\\\').gsub(/^ *\| /,'').strip
        text = Image.read(tt) do
          self.size = "180x"
          self.pointsize = FONT_SIZE
#          self.font = "/home/mlue/MS Mincho.ttf"
          self.background_color = 'none'
        end
        #first text
        img = img.composite(text[0],Magick::NorthWestGravity,10,offset_y+10,Magick::OverCompositeOp)
        text[0].destroy!

        
        #FIRST CHAR
        img = img.composite(chr.first, Magick::NorthWestGravity,0,image_offset_y,Magick::OverCompositeOp)
        


        if msg[1]
          #second text
          tt2 = "caption:"+msg[1][1].gsub(/\\/,'\\\\\\\\').gsub(/^ *\| /,'').strip
          p tt2
          text2 = Image.read(tt2) do
            self.size = "180x"
            self.pointsize = FONT_SIZE
#            self.font = "/home/mlue/MS Mincho.ttf"
            self.background_color = 'none'
          end
          img = img.composite(text2[0],Magick::NorthEastGravity,10,offset_y+10,Magick::OverCompositeOp)
          text2[0].destroy!
          #SECOND CHARACTER
          chr2 = vatos[msg[1][0]]
          image_offset_y =  offset_y + (200-chr2.first.rows)
          img = img.composite(chr2.first.flop, Magick::NorthEastGravity,0,image_offset_y,Magick::OverCompositeOp)
          #chr2.first.destroy!
        end
        GC.start
      }
      vatos.each{|f| f[1][0].destroy!}
      filename = (0...8).map { (65 + rand(26)).chr }.join
      img.write("/var/www/serve.1sheeps.com/comics/files/"+filename+".jpg"){
        self.compression = Magick::JPEGCompression
        self.quality = 80
      }
      img.destroy!
      dst.destroy!
      url = "http://serve.1sheeps.com/comics/files/"+filename+".jpg"
      m.reply url
      File.open("/home/mlue/comicpid","w"){|f| f.write 'unlocked'}
    rescue Exception => e
      p e.message
      File.open("/home/mlue/comicpid","w"){|f| f.write "unlocked"}
      File.open("/home/mlue/tmp/comicerror.log","w"){|f| f.write "#{e.backtrace.first}: #{e.message} (#{e.class})", e.backtrace.drop(1).map{|s| "\t#{s}"}}
      m.reply "sorry, I'm oom"
    end
  end
end

plugin = ComicPlugin.new
plugin.map 'comic [:panels]', :action => 'comic'
