@STATIC;1.0;p;15;AppController.jt;742;@STATIC;1.0;I;21;Foundation/CPObject.ji;15;RssController.jt;678;objj_executeFile("Foundation/CPObject.j", NO);
objj_executeFile("RssController.j", YES);
{var the_class = objj_allocateClassPair(CPObject, "AppController"),
meta_class = the_class.isa;class_addIvars(the_class, [new objj_ivar("theWindow")]);
objj_registerClassPair(the_class);
class_addMethods(the_class, [new objj_method(sel_getUid("applicationDidFinishLaunching:"), function $AppController__applicationDidFinishLaunching_(self, _cmd, aNotification)
{ with(self)
{
}
},["void","CPNotification"]), new objj_method(sel_getUid("awakeFromCib"), function $AppController__awakeFromCib(self, _cmd)
{ with(self)
{
    objj_msgSend(theWindow, "setFullBridge:", YES);
}
},["void"])]);
}

p;6;main.jt;295;@STATIC;1.0;I;23;Foundation/Foundation.jI;15;AppKit/AppKit.ji;15;AppController.jt;209;objj_executeFile("Foundation/Foundation.j", NO);
objj_executeFile("AppKit/AppKit.j", NO);
objj_executeFile("AppController.j", YES);
main= function(args, namedArgs)
{
    CPApplicationMain(args, namedArgs);
}

p;15;RssController.jt;2473;@STATIC;1.0;I;21;Foundation/CPObject.ji;7;Tweet.jt;2417;objj_executeFile("Foundation/CPObject.j", NO);
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

p;7;Tweet.jt;1698;@STATIC;1.0;I;21;Foundation/CPObject.jt;1653;

objj_executeFile("Foundation/CPObject.j", NO);

{var the_class = objj_allocateClassPair(CPObject, "Tweet"),
meta_class = the_class.isa;class_addIvars(the_class, [new objj_ivar("fromUser"), new objj_ivar("text")]);
objj_registerClassPair(the_class);
class_addMethods(the_class, [new objj_method(sel_getUid("fromUser"), function $Tweet__fromUser(self, _cmd)
{ with(self)
{
return fromUser;
}
},["id"]),
new objj_method(sel_getUid("setFromUser:"), function $Tweet__setFromUser_(self, _cmd, newValue)
{ with(self)
{
fromUser = newValue;
}
},["void","id"]),
new objj_method(sel_getUid("text"), function $Tweet__text(self, _cmd)
{ with(self)
{
return text;
}
},["id"]),
new objj_method(sel_getUid("setText:"), function $Tweet__setText_(self, _cmd, newValue)
{ with(self)
{
text = newValue;
}
},["void","id"]), new objj_method(sel_getUid("initWithJSONObject:"), function $Tweet__initWithJSONObject_(self, _cmd, anObject)
{ with(self)
{
  self = objj_msgSendSuper({ receiver:self, super_class:objj_getClass("Tweet").super_class }, "init") ;

  if (self)
  {
    fromUser = anObject.from_user;
    text = anObject.text;
  }

  return self;
}
},["id","JSObject"])]);
class_addMethods(meta_class, [new objj_method(sel_getUid("initWithJSONObjects:"), function $Tweet__initWithJSONObjects_(self, _cmd, someJSONObjects)
{ with(self)
{
  var tweets = objj_msgSend(objj_msgSend(CPArray, "alloc"), "init");

  for (var i=0; i < someJSONObjects.length; i++) {
    var tweet = objj_msgSend(objj_msgSend(Tweet, "alloc"), "initWithJSONObject:", someJSONObjects[i]) ;
    objj_msgSend(tweets, "addObject:", tweet) ;
  };

  return tweets ;
}
},["CPArray","CPArray"])]);
}

e;