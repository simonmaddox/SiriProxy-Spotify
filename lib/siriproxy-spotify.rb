require 'cora'
require 'siri_objects'

require 'open-uri'
require 'json'
require 'uri'

#######
# Control Spotify with your voice.
# Simply say "Spotify, play me some Nirvana"
######

class SiriProxy::Plugin::Spotify < SiriProxy::Plugin

  SPOTIFY_CHECK = '(spotify|spotter five|spot of phi|spot fie|spot a fight|specify|spot if i|spotted by|stultify)'

  def initialize(config)
    #if you have custom configuration options, process them here!
  end

  listen_for /#{SPOTIFY_CHECK} play(?: me some)? (.*)/i do |keyword, query|
    
    artist = URI.escape(query.strip)
	  
    results = JSON.parse(open("http://ws.spotify.com/search/1/track.json?q=#{artist}").read)
    
    if (results["tracks"].length > 1)
      track = results["tracks"][0]

      say "Playing #{track["name"]} by #{track["artists"][0]["name"]}"
      `open #{track["href"]}`
    else
      say "I could not find anything by #{query}"
    end
    
    request_completed
  end
  
  listen_for /#{SPOTIFY_CHECK} p(a|u).+/i do
    
    commandSpotify("pause")
    say "Pausing Spotify..."
    
    request_completed
  end
  
  listen_for /#{SPOTIFY_CHECK} play the (last|previous) (track|song)/i do
    # Sending this command once only goes to the beginning of the current track. So let's send it twice!
    commandSpotify("previous track")
    response = commandSpotify("previous track\n#{detailedNowPlayingCommand()}")
    say "Ok, playing #{response}"
    
    request_completed
  end
  
  listen_for /#{SPOTIFY_CHECK} play the next (track|song)/i do
    response = commandSpotify("next track\n#{detailedNowPlayingCommand()}")
    say "Ok, playing #{response}"
    
    request_completed
  end
  
  listen_for /#{SPOTIFY_CHECK} what (band|singer|artist|track|group|song) is this/i do
    response = commandSpotify("#{detailedNowPlayingCommand()}")
    say "Playing #{response}"
    
    request_completed
  end
  
  def detailedNowPlayingCommand()
		return "set nowPlaying to current track\nreturn \"\" & name of nowPlaying & \" by \" & artist of nowPlaying"
	end
  
  def commandSpotify(command)
    return (`osascript -e 'tell application "Spotify"\n#{command}\nend'`).strip
  end
end
