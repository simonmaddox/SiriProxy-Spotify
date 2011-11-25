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
  def initialize(config)
    #if you have custom configuration options, process them here!
  end

  listen_for /(spotify|spotter five|spot of phi|spot fie|spot a fight|specify|spot if i|spotted by|stultify) play me some (.*)/i do |keyword, query|
    
    artist = URI.escape(query.strip)
	  
    results = JSON.parse(open("http://ws.spotify.com/search/1/track.json?q=#{artist}").read)
    
    if (results["tracks"].length > 1)
      track = results["tracks"][0]

      say "Playing #{track["name"]} by #{track["artists"][0]["name"]}"
      `open #{track["href"]}`
    else
      say "I could not find anything by #{matchData[1]}"
    end
    
    request_completed
  end
  
  listen_for /(spotify|spotter five|spot of phi|spot fie|spot a fight|specify|spot if i|spotted by|stultify) pause/i do
    
    commandSpotify("pause")
    say "Pausing Spotify..."
    
    request_completed
  end
  
  def commandSpotify(command)
    (`osascript -e 'tell application "Spotify"\n#{command}\nend'`).strip
  end
end
