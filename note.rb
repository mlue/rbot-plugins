#++
#
# :title: Note plugin for rbot
#
# Author:: dmitry kim <dmitry dot kim at gmail dot com>
#
# Copyright:: (C) 200?-2009 dmitry 'jsn' kim
#
# License:: MIT license

class NotePlugin < Plugin
  Note = Struct.new('Note', :time, :from, :private, :text)

  def help(plugin, topic="")
    "note <nick> <string> => stores a note (<string>) for <nick>"
  end

  def pare_keys(keye)
    keye.downcase.gsub(Regexp.new('(?:_|\^)[^\^|\|]*$'),'')
  end
  
  def message(m)
    begin
      return unless @registry.has_key? pare_keys(m.sourcenick)
      pub = []
      priv = []
      @registry[pare_keys(m.sourcenick)].each do |n|
        s = "[#{n.time.strftime('%H:%M')}] <#{n.from}> #{n.text}"
        (n.private ? priv : pub).push s
      end
      if !pub.empty?
        @bot.say m.replyto, "#{m.sourcenick}, you have notes! " +
          pub.join(' ')
      end

      if !priv.empty?
        @bot.say m.sourcenick, "you have notes! " + priv.join(' ')
      end
      @registry.delete pare_keys(m.sourcenick)
    rescue Exception => e
      m.reply e.message
    end
  end

  def note(m, params)
    begin
      q = @registry[pare_keys(params[:nick])] || Array.new
      s = params[:string].to_s.strip
      raise 'cowardly discarding the empty note' if s.empty?
      qq = q.collect{|f| f.from == pare_keys(m.sourcenick)}
      if qq.size > 3
        debug __FILE__
        m.reply "Stop trying to spam notes you petrified rhinoceros pizzle"
        q.shift
        q.push Note.new(Time.now, pare_keys(m.sourcenick), m.private?, s)
        @registry[pare_keys(params[:nick])] = q
      else
        q.push Note.new(Time.now, pare_keys(m.sourcenick), m.private?, s)
        @registry[pare_keys(params[:nick])] = q
        m.okay
      end
    rescue Exception => e
      m.reply "error: #{e.message}"
    end
  end
end

NotePlugin.new.map 'note :nick *string'
