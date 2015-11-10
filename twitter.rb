#-- vim:sw=2:et
#++
#
# :title: Twitter Status Update for rbot
#
# Author:: Carter Parks (carterparks) <carter@carterparks.com>
# Author:: Giuseppe "Oblomov" Bilotta <giuseppe.bilotta@gmail.com>
# Author:: NeoLobster <neolobster@snugglenets.com>
<<<<<<< HEAD
# Author:: Matthias Hecker <apoc@sixserv.org>
=======
>>>>>>> 81d3f215b2afb2d65832632ff9299032d429fe20
#
# Copyright:: (C) 2007 Carter Parks
# Copyright:: (C) 2007 Giuseppe Bilotta
#
# Users can setup their twitter username and password and then begin updating
# twitter whenever

<<<<<<< HEAD
require 'oauth'
require 'oauth2'
require 'yaml'
require 'json'

class TwitterPlugin < Plugin
  URL = 'https://api.twitter.com'

  Config.register Config::StringValue.new('twitter.key',
    :default => "BdCN4FCokm9hkf8sIDmIJA",
    :desc => "Twitter OAuth Consumer Key")

  Config.register Config::StringValue.new('twitter.secret',
    :default => "R4V00wUdEXlMr38SKOQR9UFQLqAmc3P7cpft7ohuqo",
    :desc => "Twitter OAuth Consumer Secret")

  Config.register Config::IntegerValue.new('twitter.status_count',
    :default => 1, :validate => Proc.new { |v| v > 0 && v <= 10},
    :desc => "Maximum number of status updates shown by 'twitter status'")

  Config.register Config::IntegerValue.new('twitter.timeline_status_count',
    :default => 3, :validate => Proc.new { |v| v > 0 && v <= 10},
    :desc => "Maximum number of status updates shown by 'twitter [home|mentions|retweets] status'")

  URL_PATTERN = %r{twitter\.com/([^/]+)(?:/status/(\d+))?}

  def twitter_filter(s)
    loc = Utils.check_location(s, URL_PATTERN)
    return nil unless loc
    matches = loc.first.match URL_PATTERN
    if matches[2] # status id matched
      id = matches[2]
      url = '/1.1/statuses/show/%s.json' % id
    else # no status id, get the latest status of that user
      user = matches[1]
      url = '/1.1/statuses/user_timeline.json?screen_name=%s&count=1&include_rts=true' % user
    end
    response = @app_access_token.get(url).body
    begin
      tweet = JSON.parse(response)
      tweet = tweet.first if tweet.instance_of? Array
      status = {
        :date => (Time.parse(tweet["created_at"]) rescue "<unknown>"),
        :id => (tweet["id_str"] rescue "<unknown>"),
        :text => (tweet["text"].ircify_html rescue "<error>"),
        :source => (tweet["source"].ircify_html rescue "<unknown>"),
        :user => (tweet["user"]["name"] rescue "<unknown>"),
        :user_nick => (tweet["user"]["screen_name"] rescue "<unknown>")
        # TODO other entries
      }
      status[:nicedate] = String === status[:date] ? status[:date] : Utils.timeago(status[:date])
      return {
        :title => "@#{status[:user_nick]}",
        :content => "#{status[:text]} (#{status[:nicedate]} via #{status[:source]})"
      }
    rescue
    end
  end
=======
begin
  require 'oauth'
rescue LoadError
  error "OAuth module could not be loaded, twits will not be submitted and protected twits will not be accessible"
end

require 'yaml'
require 'rexml/rexml'

class TwitterPlugin < Plugin
   Config.register Config::StringValue.new('twitter.key',
      :default => "",
      :desc => "Twitter OAuth Consumer Key")

   Config.register Config::StringValue.new('twitter.secret',
      :default => "",
      :desc => "Twitter OAuth Consumer Secret")

    Config.register Config::IntegerValue.new('twitter.status_count',
      :default => 1, :validate => Proc.new { |v| v > 0 && v <= 10},
      :desc => "Maximum number of status updates shown by 'twitter status'")

    Config.register Config::IntegerValue.new('twitter.friends_status_count',
      :default => 3, :validate => Proc.new { |v| v > 0 && v <= 10},
      :desc => "Maximum number of status updates shown by 'twitter friends status'")
>>>>>>> 81d3f215b2afb2d65832632ff9299032d429fe20

  def initialize
    super

<<<<<<< HEAD
=======
    @has_oauth = defined? OAuth

>>>>>>> 81d3f215b2afb2d65832632ff9299032d429fe20
    class << @registry
      def store(val)
        val
      end
      def restore(val)
        val
      end
    end
<<<<<<< HEAD

    # setup the application authentication

    key = @bot.config['twitter.key']
    secret = @bot.config['twitter.secret']
    @client = OAuth2::Client.new(key, secret, 
                                :token_url => '/oauth2/token',
                                :site => URL)
    @app_access_token = @client.client_credentials.get_token

    debug "app access-token generated: #{@app_access_token.inspect}"

    @bot.register_filter(:twitter, :htmlinfo) { |s| twitter_filter(s) }
=======
  end

  def report_oauth_missing(m, failed_action)
    m.reply [failed_action, "I cannot authenticate to Twitter (OAuth not available)"].join(' because ')
>>>>>>> 81d3f215b2afb2d65832632ff9299032d429fe20
  end

  def report_key_missing(m, failed_action)
    m.reply [failed_action, "no Twitter Consumer Key/Secret is defined"].join(' because ')
  end

  def help(plugin, topic="")
<<<<<<< HEAD
    return "twitter status [nick] => show nick's (or your) status, use 'twitter [home/mentions/retweets] status' to show your timeline | twitter update [status] => updates your status on twitter | twitter authorize => Generates an authorization URL which will give you a PIN to authorize the bot to use your twitter account. | twitter pin [pin] => Finishes bot authorization using the PIN provided by the URL from twitter authorize. | twitter deauthorize => Makes the bot forget your Twitter account. | twitter actions [on|off] => enable/disable twitting of actions (/me does ...)"
  end

  # show latest status of a twitter user or the users timeline/mentions/retweets
  def get_status(m, params)
    nick = params[:nick] # (optional)
    type = params[:type] # (optional) home, mentions, retweets

    if @registry.has_key?(m.sourcenick + "_access_token")
      @access_token = YAML::load(@registry[m.sourcenick + "_access_token"])
      
      if not nick
        nick = @access_token.params[:screen_name]
      end
    elsif type
      m.reply "You are not authorized with Twitter. Please use 'twitter authorize' first to use this feature."
      return false
    end

    if not nick and not type
=======
    return "twitter status [nick] => show nick's (or your) status, use 'twitter friends status [nick]' to also show the friends' timeline | twitter update [status] => updates your status on twitter | twitter authorize => Generates an authorization URL which will give you a PIN to authorize the bot to use your twitter account. | twitter pin [pin] => Finishes bot authorization using the PIN provided by the URL from twitter authorize. | twitter deauthorize => Makes the bot forget your Twitter account. | twitter actions [on|off] => enable/disable twitting of actions (/me does ...)"
  end

  # update the status on twitter
  def get_status(m, params)
    friends = params[:friends]

    if @registry.has_key?(m.sourcenick + "_access_token")
      @access_token = YAML::load(@registry[m.sourcenick + "_access_token"])
      nick = params[:nick] || @access_token.params[:screen_name]
    else
      if friends
        if @has_oauth
          m.reply "You are not authorized with Twitter. Please use 'twitter authorize' first to use this feature."
        else
          report_oauth_missing(m, "I cannot retrieve your friends status")
        end
        return false
      end
      nick = params[:nick]
    end

    if not nick
>>>>>>> 81d3f215b2afb2d65832632ff9299032d429fe20
      m.reply "you should specify the username of the twitter to use, or identify using 'twitter authorize'"
      return false
    end

<<<<<<< HEAD
    # use the application-only authentication
    if not @access_token
      @access_token = @app_access_token
    end

    count = type ? @bot.config['twitter.timeline_status_count'] : @bot.config['twitter.status_count']
    user = URI.escape(nick)
    if not type
      url = "/1.1/statuses/user_timeline.json?screen_name=#{nick}&count=#{count}&include_rts=true"
    elsif type == 'retweets'
      url = "/1.1/statuses/retweets_of_me.json?count=#{count}&include_rts=true"
    else
      url = "/1.1/statuses/#{type || 'user'}_timeline.json?count=#{count}&include_rts=true"
    end
    response = @access_token.get(url).body
=======
    count = friends ? @bot.config['twitter.friends_status_count'] : @bot.config['twitter.status_count']
    user = URI.escape(nick)
    # receive the public timeline per default (this works even without an access_token)
    uri = "https://api.twitter.com/1/statuses/user_timeline.xml?screen_name=#{user}&count=#{count}&include_rts=true"
    if @has_oauth and @registry.has_key?(m.sourcenick + "_access_token")
        if friends
          #no change to count variable
          uri = "https://api.twitter.com/1/statuses/friends_timeline.xml?count=#{count}&include_rts=true"
        end
        response = @access_token.get(uri).body
    else
       response = @bot.httputil.get(uri, :cache => false)
    end
    debug response
>>>>>>> 81d3f215b2afb2d65832632ff9299032d429fe20

    texts = []

    if response
      begin
<<<<<<< HEAD
        tweets = JSON.parse(response)
        if tweets.class == Array
          tweets.each do |tweet|
            time = Time.parse(tweet['created_at'])
            now = Time.now
            # Sometimes, time can be in the future; invert the relation in this case
            delta = ((time > now) ? time - now : now - time)
            msg = tweet['text'] + " (#{Utils.secs_to_string(delta.to_i)} ago via #{tweet['source'].to_s})"
            author = ""
            if type
              author = tweet['user']['name'] + ": " rescue ""
            end
            texts << author+Utils.decode_html_entities(msg).ircify_html
          end
        else
          raise 'timeline response: ' + response
        end
        if type
=======
        rex = REXML::Document.new(response)
        rex.root.elements.each("status") { |st|
          # month, day, hour, min, sec, year = st.elements['created_at'].text.match(/\w+ (\w+) (\d+) (\d+):(\d+):(\d+) \S+ (\d+)/)[1..6]
          # debug [year, month, day, hour, min, sec].inspect
          # time = Time.local(year.to_i, month, day.to_i, hour.to_i, min.to_i, sec.to_i)
          time = Time.parse(st.elements['created_at'].text)
          now = Time.now
          # Sometimes, time can be in the future; invert the relation in this case
          delta = ((time > now) ? time - now : now - time)
          msg = st.elements['text'].to_s + " (#{Utils.secs_to_string(delta.to_i)} ago via #{st.elements['source'].to_s})"
          author = ""
          if friends
            author = Utils.decode_html_entities(st.elements['user'].elements['name'].text) + ": " rescue ""
          end
          texts << author+Utils.decode_html_entities(msg).ircify_html
        }
        if friends
>>>>>>> 81d3f215b2afb2d65832632ff9299032d429fe20
          # friends always return the latest 20 updates, so we clip the count
          texts[count..-1]=nil
        end
      rescue
        error $!
<<<<<<< HEAD
        if type
          m.reply "could not parse status for #{nick}'s timeline"
=======
        if friends
          m.reply "could not parse status for #{nick}'s friends"
>>>>>>> 81d3f215b2afb2d65832632ff9299032d429fe20
        else
          m.reply "could not parse status for #{nick}"
        end
        return false
      end
      if texts.empty?
        m.reply "No status updates!"
      else
        m.reply texts.reverse.join("\n")
      end
      return true
    else
<<<<<<< HEAD
      if type
        rep = "could not get status for #{nick}'s #{type} timeline"
=======
      if friends
        rep = "could not get status for #{nick}'s friends"
>>>>>>> 81d3f215b2afb2d65832632ff9299032d429fe20
        rep << ", try asking in private" unless m.private?
      else
        rep = "could not get status for #{nick}"
      end
      m.reply rep
      return false
    end
  end

  def deauthorize(m, params)
    if @registry.has_key?(m.sourcenick + "_request_token")
      @registry.delete(m.sourcenick + "_request_token")
    end
    if @registry.has_key?(m.sourcenick + "_access_token")
      @registry.delete(m.sourcenick + "_access_token")
    end
    m.reply "Done! You can reauthorize this account in the future by using 'twitter authorize'"
  end

  def authorize(m, params)
    failed_action = "we can't complete the authorization process"
<<<<<<< HEAD
=======
    unless @has_oauth
      report_oauth_missing(m, failed_action)
      return false
    end
>>>>>>> 81d3f215b2afb2d65832632ff9299032d429fe20

    #remove all old authorization data
    if @registry.has_key?(m.sourcenick + "_request_token")
      @registry.delete(m.sourcenick + "_request_token")
    end
    if @registry.has_key?(m.sourcenick + "_access_token")
      @registry.delete(m.sourcenick + "_access_token")
    end

    key = @bot.config['twitter.key']
    secret = @bot.config['twitter.secret']
    if key.empty? or secret.empty?
      report_key_missing(m, failed_action)
      return false
    end

    @consumer = OAuth::Consumer.new(key, secret, {
<<<<<<< HEAD
      :site => URL,
=======
      :site => "https://api.twitter.com",
>>>>>>> 81d3f215b2afb2d65832632ff9299032d429fe20
      :request_token_path => "/oauth/request_token",
      :access_token_path => "/oauth/access_token",
      :authorize_path => "/oauth/authorize"
    } )
    begin
      @request_token = @consumer.get_request_token
    rescue OAuth::Unauthorized
      m.reply _("My authorization failed! Did you block me? Or is my Twitter Consumer Key/Secret pair incorrect?")
      return false
    end
    @registry[m.sourcenick + "_request_token"] = YAML::dump(@request_token)
    m.reply "Go to this URL to get your authorization PIN, then use 'twitter pin <pin>' to finish authorization: " + @request_token.authorize_url
  end

  def pin(m, params)
     unless @registry.has_key?(m.sourcenick + "_request_token")
       m.reply "You must first use twitter authorize to get an authorization URL, which you can use to get a PIN for me to use to verify your Twitter account"
       return false
     end
     @request_token = YAML::load(@registry[m.sourcenick + "_request_token"])
     begin
       @access_token = @request_token.get_access_token( { :oauth_verifier => params[:pin] } )
     rescue
       m.reply "Error: There was a problem registering your Twitter account. Please make sure you have the right PIN. If the problem persists, use twitter authorize again to get a new PIN"
       return false
     end
     @registry[m.sourcenick + "_access_token"] = YAML::dump(@access_token)
     m.reply "Okay, you're all set"
  end

  # update the status on twitter
  def update_status(m, params)
<<<<<<< HEAD
=======
    unless @has_oauth
      report_oauth_missing(m, "I cannot update your status")
      return false
    end

>>>>>>> 81d3f215b2afb2d65832632ff9299032d429fe20
    unless @registry.has_key?(m.sourcenick + "_access_token")
       m.reply "You must first authorize your Twitter account before tweeting."
       return false;
    end
    @access_token = YAML::load(@registry[m.sourcenick + "_access_token"])

<<<<<<< HEAD
    #uri = URL + '/statuses/update.json'
    status = params[:status].to_s

    if status.length > 140
=======
    uri = "https://api.twitter.com/statuses/update.json"
    msg = params[:status].to_s

    if msg.length > 140
>>>>>>> 81d3f215b2afb2d65832632ff9299032d429fe20
      m.reply "your status message update is too long, please keep it under 140 characters"
      return
    end

<<<<<<< HEAD
    response = @access_token.post('/1.1/statuses/update.json', { :status => status })
=======
    response = @access_token.post(uri, { :status => msg })
>>>>>>> 81d3f215b2afb2d65832632ff9299032d429fe20
    debug response

    reply_method = params[:notify] ? :notify : :reply
    if response.class == Net::HTTPOK
      m.__send__(reply_method, "status updated")
    else
<<<<<<< HEAD
      debug 'twitter update response: ' + response.body
      error = '?'
      begin
        json = JSON.parse(response.body)
        error = json['errors'].first['message'] || '?'
      rescue
      end
      m.__send__(reply_method, "could not update status: #{error}")
=======
      m.__send__(reply_method, "could not update status")
>>>>>>> 81d3f215b2afb2d65832632ff9299032d429fe20
    end
  end

  # ties a nickname to a twitter username and password
  def identify(m, params)
    @registry[m.sourcenick + "_username"] = params[:username].to_s
    @registry[m.sourcenick + "_password"] = params[:password].to_s
    m.reply "you're all set up!"
  end

  # update on ACTION if the user has enabled the option
<<<<<<< HEAD
  def ctcp_listen(m)
=======
  # Possible TODO: move the has_oauth check further down and alert
  # the user the first time we do not update because of the missing oauth
  def ctcp_listen(m)
    return unless @has_oauth
>>>>>>> 81d3f215b2afb2d65832632ff9299032d429fe20
    return unless m.action?
    return unless @registry[m.sourcenick + "_actions"]
    update_status(m, :status => m.message, :notify => true)
  end

  # show or toggle action twitting
  def actions(m, params)
    case params[:toggle]
    when 'on'
      @registry[m.sourcenick + "_actions"] = true
      m.okay
    when 'off'
      @registry.delete(m.sourcenick + "_actions")
      m.okay
    else
      if @registry[m.sourcenick + "_actions"]
        m.reply _("actions will be twitted")
      else
        m.reply _("actions will not be twitted")
      end
    end
  end
end

# create an instance of our plugin class and register for the "length" command
plugin = TwitterPlugin.new
plugin.map 'twitter update *status', :action => "update_status", :threaded => true
plugin.map 'twitter authorize', :action => "authorize", :public => false
plugin.map 'twitter deauthorize', :action => "deauthorize", :public => false
plugin.map 'twitter pin :pin', :action => "pin", :public => false
plugin.map 'twitter actions [:toggle]', :action => "actions", :requirements => { :toggle => /^on|off$/ }
plugin.map 'twitter status [:nick]', :action => "get_status", :threaded => true
<<<<<<< HEAD
plugin.map 'twitter :type [status] [:nick]', :action => "get_status", :requirements => { :type => /^(home|mentions|retweets)?$/ }, :threaded => true

=======
plugin.map 'twitter :friends [status] [:nick]', :action => "get_status", :requirements => { :friends => /^friends?$/ }, :threaded => true
>>>>>>> 81d3f215b2afb2d65832632ff9299032d429fe20
