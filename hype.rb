class HypePlugin < Plugin
  def initialize
    @wl = Array.new(3)
    @allow_similar_matches = false

    super
  end

  def help(plugin, topic)
    "HYPE!"
  end

  def build_list(big_list,word_list)
    words = big_list.split("\n")
    word_list[0] = []
    word_list_index = 0
    words.each do |word|
      if (word == "----") 
        word_list_index = word_list_index+1
        word_list[word_list_index] = []
      else 
        word_list[word_list_index].push(word)
      end
    end
    return word_list
  end
  

  def generate_game_name(word_list)
    first_word = word_list[0][rand(word_list[0].length)]
    second_word = ""
    third_word = ""
    bad_match_list = Array.new

    if (first_word.index("^"))
      if (!@allow_similar_matches)
        bad_match_list = first_word.split("^")[1].split('|')    
      end
      first_word = first_word.split("^")[0] 
    end

    second_word_bad = true
    while (second_word_bad) do
      second_word = word_list[1][rand(word_list[1].length)]
      if second_word.index("^")
        if (!@allow_similar_matches) 
          bad_match_list.join(second_word.split('^')[1].split('|'))
        end
        second_word = second_word.split('^')[0]                           
      end

      if (second_word == first_word) 
        next
      end

      if (bad_match_list.index(second_word)) 
        next
      end
      second_word_bad = false
    end

    third_word_bad = true
    while (third_word_bad) 
      third_word = word_list[2][rand(word_list[2].length)]

      if third_word.index("^")
        if (!@allow_similar_matches) 
          bad_match_list.join(third_word.split('^')[1].split('|'))
        end
        third_word = second_word.split('^')[0]                           
      end

      if (third_word == first_word || third_word == second_word) 
        next
      end

      if (bad_match_list.index(third_word)) 
        next
      end
      third_word_bad = false
    end  
    first_word + " " + second_word + " " + third_word
  end
  
  def hype(m,params)
    begin
      m.reply "Eric is now hype for #{Bold}"+generate_game_name(build_list(File.read('/home/mlue/data/video_game_names.txt'),@wl))+"#{Bold}!"
      m.reply "Eric is no longer hype for #{Bold}"+generate_game_name(build_list(File.read('/home/mlue/data/video_game_names.txt'),@wl))+"#{Bold}"
    rescue Exception => e
      m.reply e.message if m.private?
    end
  end
end
plugin = HypePlugin.new
plugin.map 'hype', :action => 'hype'
