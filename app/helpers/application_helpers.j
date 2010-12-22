/*
 * All good things Javascript. All the various helpers that we require (i.e. those
 * things that aren't a method) can be defined here.
 */
function flickrThumbUrlForPhoto(photo)
{
  return ("http://farm"+photo.farm+".static.flickr.com/"+photo.server+"/"+
          photo.id+"_"+photo.secret+"_m.jpg");
}

function flickrSearchUrl(search_term)
{
  // TODO: replace API key in the URL Request -- the api_key is stolen ....
  return ("http://www.flickr.com/services/rest/?"+
          "method=flickr.photos.search&tags="+encodeURIComponent(search_term)+
          "&media=photos&machine_tag_mode=any&per_page=20&"+
          "format=json&api_key=ca4dd89d3dfaeaf075144c3fdec76756");
}

function twitterSearchUrl(search_term)
{
  return "http://search.twitter.com/search.json?q=" + encodeURIComponent(search_term);
}

function twitterUrlForTweet(id_str)
{
  var api_version = "1"; /* make it obvious where the api version is to be found */
  return "http://api.twitter.com/" + api_version + "/statuses/show/" + id_str + ".json";
}
