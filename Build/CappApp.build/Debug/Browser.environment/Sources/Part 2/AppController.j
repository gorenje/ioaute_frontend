@STATIC;1.0;I;21;Foundation/CPObject.ji;10;PageView.ji;16;PhotoInspector.ji;12;PhotoPanel.jt;2099;objj_executeFile("Foundation/CPObject.j", NO);
objj_executeFile("PageView.j", YES);
objj_executeFile("PhotoInspector.j", YES);
objj_executeFile("PhotoPanel.j", YES);
{var the_class = objj_allocateClassPair(CPObject, "AppController"),
meta_class = the_class.isa;objj_registerClassPair(the_class);
class_addMethods(the_class, [new objj_method(sel_getUid("applicationDidFinishLaunching:"), function $AppController__applicationDidFinishLaunching_(self, _cmd, aNotification)
{ with(self)
{
    var theWindow = objj_msgSend(objj_msgSend(CPWindow, "alloc"), "initWithContentRect:styleMask:", CGRectMakeZero(), CPBorderlessBridgeWindowMask),
        contentView = objj_msgSend(theWindow, "contentView");
    objj_msgSend(contentView, "setBackgroundColor:", objj_msgSend(CPColor, "blackColor"));
    objj_msgSend(theWindow, "orderFront:", self);
    var bounds = objj_msgSend(contentView, "bounds"),
        pageView = objj_msgSend(objj_msgSend(PageView, "alloc"), "initWithFrame:", CGRectMake(CGRectGetWidth(bounds) / 2.0 - 200.0, CGRectGetHeight(bounds) / 2.0 - 200.0, 400.0, 400.0));
    objj_msgSend(pageView, "setAutoresizingMask:", CPViewMinXMargin | CPViewMaxXMargin | CPViewMinYMargin | CPViewMaxYMargin);
    objj_msgSend(contentView, "addSubview:", pageView);
    var label = objj_msgSend(objj_msgSend(CPTextField, "alloc"), "initWithFrame:", CGRectMakeZero());
    objj_msgSend(label, "setTextColor:", objj_msgSend(CPColor, "whiteColor"));
    objj_msgSend(label, "setStringValue:", "Double Click to Edit Photo");
    objj_msgSend(label, "sizeToFit");
    objj_msgSend(label, "setFrameOrigin:", CGPointMake(CGRectGetWidth(bounds) / 2.0 - CGRectGetWidth(objj_msgSend(label, "frame")) / 2.0, CGRectGetMinY(objj_msgSend(pageView, "frame")) - CGRectGetHeight(objj_msgSend(label, "frame"))));
    objj_msgSend(label, "setAutoresizingMask:", CPViewMinXMargin | CPViewMaxXMargin | CPViewMinYMargin | CPViewMaxYMargin);
    objj_msgSend(contentView, "addSubview:", label);
    objj_msgSend(objj_msgSend(objj_msgSend(PhotoPanel, "alloc"), "init"), "orderFront:", nil);
}
},["void","CPNotification"])]);
}

