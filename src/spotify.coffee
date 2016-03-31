# Description
#   Returns metadata of Spotify links
#
# Commands:
#   <spotify link> - returns info about the link (track, artist, etc.)
#
# Notes:
#   Based on the defunct https://github.com/github/hubot-scripts/blob/master/src/scripts/spotify.coffee
#
# Author:
#   contolini

module.exports = (robot) ->
  robot.hear spotify.link, (msg) ->
    spotify.process msg.match[0]
    msg.http(spotify.uri msg.match[0]).get() (err, res, body) ->
      if res.statusCode is 200
        data = JSON.parse(body)
        msg.send spotify[data.type](data)

spotify =
  link: /// (
    ?: (http|https)://(open|play).spotify.com/(track|album|artist)/
     | spotify:(track|album|artist):
    ) \S+ ///

  process: (link) ->
    match = /// (
      ?: (http|https)://(open|play).spotify.com/(track|album|artist)/
       | spotify:(track|album|artist):
      ) (\S+) ///
    @type = match[3] or match[4]
    @id = match[5]
    return

  uri: (link) -> "https://api.spotify.com/v1/#{spotify.type}s/#{spotify.id}"

  track: (data) ->
    track = "#{data.artists[0].name} - #{data.name}"
    album = "(#{data.album.name})"
    "Track: #{track} #{album}"

  album: (data) ->
    "Album: #{data.artists[0].name} - #{data.name} (#{data.release_date})"

  artist: (data) ->
    "Artist: #{data.name}"

