@STATIC;1.0;I;21;Foundation/CPObject.ji;7;Tweet.jt;2417;objj_executeFile("Foundation/CPObject.j", NO);
objj_executeFile("Tweet.j", YES);
{var the_class = objj_allocateClassPair(CPObject, "RssController"),
meta_class = the_class.isa;class_addIvars(the_class, [new objj_ivar("_tableView"), new objj_ivar("_twitterUser"), new objj_ivar("_tweets")]);
objj_registerClassPair(the_class);
class_addMethods(the_class, [new objj_method(sel_getUid("applicationDidFinishLaunching:"), function $RssController__applicationDidFinishLaunching_(self, _cmd, aNotification)
{ with(self)
{
}
},["void","CPNotification"]), new objj_method(sel_getUid("awakeFromCib"), function $RssController__awakeFromCib(self, _cmd)
{ with(self)
{
  _tweets = objj_msgSend(CPArray, "arrayWithObjects:", nil);
}
},["void"]), new objj_method(sel_getUid("getFeed:"), function $RssController__getFeed_(self, _cmd, sender)
{ with(self)
{
  var userInput = objj_msgSend(_twitterUser, "stringValue");
  if (userInput!=="") {
    var request = objj_msgSend(CPURLRequest, "requestWithURL:", "http://search.twitter.com/search.json?q=" + encodeURIComponent(userInput)) ;
    twitterConnection = objj_msgSend(CPJSONPConnection, "connectionWithRequest:callback:delegate:", request, "callback", self) ;
  }
}
},["CPAction","id"]), new objj_method(sel_getUid("connection:didReceiveData:"), function $RssController__connection_didReceiveData_(self, _cmd, aConnection, data)
{ with(self)
{
    _tweets = objj_msgSend(Tweet, "initWithJSONObjects:", data.results);
    objj_msgSend(_tableView, "reloadData");
}
},["void","CPJSONPConnection","CPString"]), new objj_method(sel_getUid("connection:didFailWithError:"), function $RssController__connection_didFailWithError_(self, _cmd, aConnection, error)
{ with(self)
{
    alert(error) ;
}
},["void","CPJSONPConnection","CPString"]), new objj_method(sel_getUid("numberOfRowsInTableView:"), function $RssController__numberOfRowsInTableView_(self, _cmd, tableView)
{ with(self)
{
  return objj_msgSend(_tweets, "count");
}
},["int","CPTableView"]), new objj_method(sel_getUid("tableView:objectValueForTableColumn:row:"), function $RssController__tableView_objectValueForTableColumn_row_(self, _cmd, tableView, tableColumn, row)
{ with(self)
{
  if (objj_msgSend(tableColumn, "identifier")==="TwitterUserName") {
    return "@"+objj_msgSend(_tweets[row], "fromUser");
  } else {
    return objj_msgSend(_tweets[row], "text");
  }
}
},["id","CPTableView","CPTableColumn","int"])]);
}

