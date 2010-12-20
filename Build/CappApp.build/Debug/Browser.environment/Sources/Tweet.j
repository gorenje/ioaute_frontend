@STATIC;1.0;I;21;Foundation/CPObject.jt;1653;

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

