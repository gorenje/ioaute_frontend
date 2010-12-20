@STATIC;1.0;I;27;AppKit/CPWindowController.jt;5795;objj_executeFile("AppKit/CPWindowController.j", NO);
var PhotoInspectorSharedInstance = nil;
{var the_class = objj_allocateClassPair(CPWindowController, "PhotoInspector"),
meta_class = the_class.isa;class_addIvars(the_class, [new objj_ivar("_paneLayer")]);
objj_registerClassPair(the_class);
class_addMethods(the_class, [new objj_method(sel_getUid("init"), function $PhotoInspector__init(self, _cmd)
{ with(self)
{
    var theWindow = objj_msgSend(objj_msgSend(CPPanel, "alloc"), "initWithContentRect:styleMask:", CGRectMake(0.0, 0.0, 225.0, 125.0), CPHUDBackgroundWindowMask | CPClosableWindowMask);
    self = objj_msgSendSuper({ receiver:self, super_class:objj_getClass("PhotoInspector").super_class }, "initWithWindow:", theWindow);
    if (self)
    {
        objj_msgSend(theWindow, "setTitle:", "Inspector");
        objj_msgSend(theWindow, "setLevel:", CPFloatingWindowLevel);
        objj_msgSend(theWindow, "setDelegate:", self);
        var contentView = objj_msgSend(theWindow, "contentView"),
            centerX = (CGRectGetWidth(objj_msgSend(contentView, "bounds")) - 135.0) / 2.0;
        scaleSlider = objj_msgSend(objj_msgSend(CPSlider, "alloc"), "initWithFrame:", CGRectMake(centerX, 13.0, 135.0, 16.0));
        objj_msgSend(scaleSlider, "setMinValue:", 50);
        objj_msgSend(scaleSlider, "setMaxValue:", 150);
        objj_msgSend(scaleSlider, "setValue:", 100);
        objj_msgSend(scaleSlider, "setTarget:", self);
        objj_msgSend(scaleSlider, "setAction:", sel_getUid("scale:"));
        objj_msgSend(contentView, "addSubview:", scaleSlider);
        var scaleStartLabel = objj_msgSend(self, "labelWithTitle:", "50%"),
            scaleEndLabel = objj_msgSend(self, "labelWithTitle:", "150%");
        objj_msgSend(scaleStartLabel, "setFrameOrigin:", CGPointMake(centerX - CGRectGetWidth(objj_msgSend(scaleStartLabel, "frame")), 10.0));
        objj_msgSend(scaleEndLabel, "setFrameOrigin:", CGPointMake(CGRectGetMaxX(objj_msgSend(scaleSlider, "frame")), 10.0));
        objj_msgSend(contentView, "addSubview:", scaleStartLabel);
        objj_msgSend(contentView, "addSubview:", scaleEndLabel);
        rotationSlider = objj_msgSend(objj_msgSend(CPSlider, "alloc"), "initWithFrame:", CGRectMake(centerX, 43.0, 135.0, 16.0));
        objj_msgSend(rotationSlider, "setMinValue:", 0);
        objj_msgSend(rotationSlider, "setMaxValue:", 360);
        objj_msgSend(rotationSlider, "setValue:", 0);
        objj_msgSend(rotationSlider, "setTarget:", self);
        objj_msgSend(rotationSlider, "setAction:", sel_getUid("rotate:"));
        objj_msgSend(contentView, "addSubview:", rotationSlider);
        var rotationStartLabel = objj_msgSend(self, "labelWithTitle:", "0\u00B0"),
            rotationEndLabel = objj_msgSend(self, "labelWithTitle:", "360\u00B0");
        objj_msgSend(rotationStartLabel, "setFrameOrigin:", CGPointMake(centerX - CGRectGetWidth(objj_msgSend(rotationStartLabel, "frame")), 40.0));
        objj_msgSend(rotationEndLabel, "setFrameOrigin:", CGPointMake(CGRectGetMaxX(objj_msgSend(rotationSlider, "frame")), 40.0));
        objj_msgSend(contentView, "addSubview:", rotationStartLabel);
        objj_msgSend(contentView, "addSubview:", rotationEndLabel);
    }
    return self;
}
},["id"]), new objj_method(sel_getUid("setPaneLayer:"), function $PhotoInspector__setPaneLayer_(self, _cmd, anPaneLayer)
{ with(self)
{
    if (_paneLayer == anPaneLayer)
        return;
    objj_msgSend(objj_msgSend(_paneLayer, "pageView"), "setEditing:", NO);
    _paneLayer = anPaneLayer;
    var page = objj_msgSend(_paneLayer, "pageView");
    objj_msgSend(page, "setEditing:", YES);
    if (_paneLayer)
    {
        var frame = objj_msgSend(page, "convertRect:toView:", objj_msgSend(page, "bounds"), nil),
            windowSize = objj_msgSend(objj_msgSend(self, "window"), "frame").size;
        objj_msgSend(objj_msgSend(self, "window"), "setFrameOrigin:", CGPointMake(CGRectGetMidX(frame) - windowSize.width / 2.0, CGRectGetMidY(frame)));
    }
}
},["void","PaneLayer"]), new objj_method(sel_getUid("scale:"), function $PhotoInspector__scale_(self, _cmd, aSender)
{ with(self)
{
    objj_msgSend(_paneLayer, "setScale:", objj_msgSend(aSender, "value") / 100.0);
}
},["void","id"]), new objj_method(sel_getUid("rotate:"), function $PhotoInspector__rotate_(self, _cmd, aSender)
{ with(self)
{
    objj_msgSend(_paneLayer, "setRotationRadians:", PI / 180 * objj_msgSend(aSender, "value"));
}
},["void","id"]), new objj_method(sel_getUid("labelWithTitle:"), function $PhotoInspector__labelWithTitle_(self, _cmd, aTitle)
{ with(self)
{
    var label = objj_msgSend(objj_msgSend(CPTextField, "alloc"), "initWithFrame:", CGRectMakeZero());
    objj_msgSend(label, "setStringValue:", aTitle);
    objj_msgSend(label, "setTextColor:", objj_msgSend(CPColor, "whiteColor"));
    objj_msgSend(label, "sizeToFit");
    return label;
}
},["CPTextField","CPString"]), new objj_method(sel_getUid("windowWillClose:"), function $PhotoInspector__windowWillClose_(self, _cmd, aSender)
{ with(self)
{
    objj_msgSend(self, "setPaneLayer:", nil);
}
},["void","id"])]);
class_addMethods(meta_class, [new objj_method(sel_getUid("sharedPhotoInspector"), function $PhotoInspector__sharedPhotoInspector(self, _cmd)
{ with(self)
{
    if (!PhotoInspectorSharedInstance)
        PhotoInspectorSharedInstance = objj_msgSend(objj_msgSend(PhotoInspector, "alloc"), "init");
    return PhotoInspectorSharedInstance;
}
},["PhotoInspector"]), new objj_method(sel_getUid("inspectPaneLayer:"), function $PhotoInspector__inspectPaneLayer_(self, _cmd, anPaneLayer)
{ with(self)
{
    var inspector = objj_msgSend(self, "sharedPhotoInspector");
    objj_msgSend(inspector, "setPaneLayer:", anPaneLayer);
    objj_msgSend(inspector, "showWindow:", self);
}
},["void","PaneLayer"])]);
}

