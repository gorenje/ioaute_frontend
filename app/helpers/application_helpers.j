/*
 * All good things Javascript. All the various helpers that we require (i.e. those
 * things that aren't a method) can be defined here.
 */

function flickrSearchUrl(search_term)
{
  return ("http://www.flickr.com/services/rest/?"+
          "method=flickr.photos.search&tags="+encodeURIComponent(search_term)+
          "&media=photos&machine_tag_mode=any&per_page=20&"+
          "format=json&api_key=8407696a2655de1d93f068d273981f2b");
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
