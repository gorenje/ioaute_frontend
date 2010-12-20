@STATIC;1.0;I;16;AppKit/CALayer.ji;12;PhotoPanel.jt;7624;objj_executeFile("AppKit/CALayer.j", NO);
objj_executeFile("PhotoPanel.j", YES);
{var the_class = objj_allocateClassPair(CALayer, "PaneLayer"),
meta_class = the_class.isa;class_addIvars(the_class, [new objj_ivar("_rotationRadians"), new objj_ivar("_scale"), new objj_ivar("_image"), new objj_ivar("_imageLayer"), new objj_ivar("_pageView")]);
objj_registerClassPair(the_class);
class_addMethods(the_class, [new objj_method(sel_getUid("initWithPageView:"), function $PaneLayer__initWithPageView_(self, _cmd, anPageView)
{ with(self)
{
    self = objj_msgSendSuper({ receiver:self, super_class:objj_getClass("PaneLayer").super_class }, "init");
    if (self)
    {
        _pageView = anPageView;
        _rotationRadians = 0.0;
        _scale = 1.0;
        _imageLayer = objj_msgSend(CALayer, "layer");
        objj_msgSend(_imageLayer, "setDelegate:", self);
        objj_msgSend(self, "addSublayer:", _imageLayer);
    }
    return self;
}
},["id","PageView"]), new objj_method(sel_getUid("pageView"), function $PaneLayer__pageView(self, _cmd)
{ with(self)
{
    return _pageView;
}
},["PageView"]), new objj_method(sel_getUid("setBounds:"), function $PaneLayer__setBounds_(self, _cmd, aRect)
{ with(self)
{
    objj_msgSendSuper({ receiver:self, super_class:objj_getClass("PaneLayer").super_class }, "setBounds:", aRect);
    objj_msgSend(_imageLayer, "setPosition:", CGPointMake(CGRectGetMidX(aRect), CGRectGetMidY(aRect)));
}
},["void","CGRect"]), new objj_method(sel_getUid("setImage:"), function $PaneLayer__setImage_(self, _cmd, anImage)
{ with(self)
{
    if (_image == anImage)
        return;
    _image = anImage;
    if (_image)
        objj_msgSend(_imageLayer, "setBounds:", CGRectMake(0.0, 0.0, objj_msgSend(_image, "size").width, objj_msgSend(_image, "size").height));
    objj_msgSend(_imageLayer, "setNeedsDisplay");
}
},["void","CPImage"]), new objj_method(sel_getUid("setRotationRadians:"), function $PaneLayer__setRotationRadians_(self, _cmd, radians)
{ with(self)
{
    if (_rotationRadians == radians)
        return;
    _rotationRadians = radians;
    objj_msgSend(_imageLayer, "setAffineTransform:", CGAffineTransformScale(CGAffineTransformMakeRotation(_rotationRadians), _scale, _scale));
}
},["void","float"]), new objj_method(sel_getUid("setScale:"), function $PaneLayer__setScale_(self, _cmd, aScale)
{ with(self)
{
    if (_scale == aScale)
        return;
    _scale = aScale;
    objj_msgSend(_imageLayer, "setAffineTransform:", CGAffineTransformScale(CGAffineTransformMakeRotation(_rotationRadians), _scale, _scale));
}
},["void","float"]), new objj_method(sel_getUid("drawInContext:"), function $PaneLayer__drawInContext_(self, _cmd, aContext)
{ with(self)
{
    CGContextSetFillColor(aContext, objj_msgSend(CPColor, "grayColor"));
    CGContextFillRect(aContext, objj_msgSend(self, "bounds"));
}
},["void","CGContext"]), new objj_method(sel_getUid("imageDidLoad:"), function $PaneLayer__imageDidLoad_(self, _cmd, anImage)
{ with(self)
{
    objj_msgSend(_imageLayer, "setNeedsDisplay");
}
},["void","CPImage"]), new objj_method(sel_getUid("drawLayer:inContext:"), function $PaneLayer__drawLayer_inContext_(self, _cmd, aLayer, aContext)
{ with(self)
{
    var bounds = objj_msgSend(aLayer, "bounds");
    if (objj_msgSend(_image, "loadStatus") != CPImageLoadStatusCompleted)
        objj_msgSend(_image, "setDelegate:", self);
    else
        CGContextDrawImage(aContext, bounds, _image);
}
},["void","CALayer","CGContext"])]);
}
{var the_class = objj_allocateClassPair(CPView, "PageView"),
meta_class = the_class.isa;class_addIvars(the_class, [new objj_ivar("_borderLayer"), new objj_ivar("_rootLayer"), new objj_ivar("_paneLayer"), new objj_ivar("_isActive")]);
objj_registerClassPair(the_class);
class_addMethods(the_class, [new objj_method(sel_getUid("initWithFrame:"), function $PageView__initWithFrame_(self, _cmd, aFrame)
{ with(self)
{
    self = objj_msgSendSuper({ receiver:self, super_class:objj_getClass("PageView").super_class }, "initWithFrame:", aFrame);
    if (self)
    {
        _rootLayer = objj_msgSend(CALayer, "layer");
        objj_msgSend(self, "setWantsLayer:", YES);
        objj_msgSend(self, "setLayer:", _rootLayer);
        objj_msgSend(_rootLayer, "setBackgroundColor:", objj_msgSend(CPColor, "whiteColor"));
        _paneLayer = objj_msgSend(objj_msgSend(PaneLayer, "alloc"), "initWithPageView:", self);
        objj_msgSend(_paneLayer, "setBounds:", CGRectMake(0.0, 0.0, 400 - 2* 40.0, 400.0 - 2 * 40.0));
        objj_msgSend(_paneLayer, "setAnchorPoint:", CGPointMakeZero());
        objj_msgSend(_paneLayer, "setPosition:", CGPointMake(40.0, 40.0));
        objj_msgSend(_paneLayer, "setImage:", objj_msgSend(objj_msgSend(CPImage, "alloc"), "initWithContentsOfFile:size:", "Resources/sample.jpg", CGSizeMake(500.0, 430.0)));
        objj_msgSend(_rootLayer, "addSublayer:", _paneLayer);
        objj_msgSend(_paneLayer, "setNeedsDisplay");
        _borderLayer = objj_msgSend(CALayer, "layer");
        objj_msgSend(_borderLayer, "setAnchorPoint:", CGPointMakeZero());
        objj_msgSend(_borderLayer, "setBounds:", objj_msgSend(self, "bounds"));
        objj_msgSend(_borderLayer, "setDelegate:", self);
        objj_msgSend(_rootLayer, "addSublayer:", _borderLayer);
        objj_msgSend(_rootLayer, "setNeedsDisplay");
        objj_msgSend(self, "registerForDraggedTypes:", [PhotoDragType]);
    }
    return self;
}
},["id","CGRect"]), new objj_method(sel_getUid("setEditing:"), function $PageView__setEditing_(self, _cmd, isEditing)
{ with(self)
{
    objj_msgSend(_borderLayer, "setOpacity:", isEditing ? 0.5 : 1.0);
}
},["void","BOOL"]), new objj_method(sel_getUid("drawLayer:inContext:"), function $PageView__drawLayer_inContext_(self, _cmd, aLayer, aContext)
{ with(self)
{
    CGContextSetFillColor(aContext, _isActive ? objj_msgSend(CPColor, "blueColor") : objj_msgSend(CPColor, "whiteColor"));
    var bounds = objj_msgSend(aLayer, "bounds"),
        width = CGRectGetWidth(bounds),
        height = CGRectGetHeight(bounds);
    CGContextFillRect(aContext, CGRectMake(0.0, 0.0, width, 40.0));
    CGContextFillRect(aContext, CGRectMake(0.0, 40.0, 40.0, height - 2 * 40.0));
    CGContextFillRect(aContext, CGRectMake(width - 40.0, 40.0, 40.0, height - 2 * 40.0));
    CGContextFillRect(aContext, CGRectMake(0.0, height - 40.0, width, 40.0));
}
},["void","CALayer","CGContext"]), new objj_method(sel_getUid("mouseDown:"), function $PageView__mouseDown_(self, _cmd, anEvent)
{ with(self)
{
    if (objj_msgSend(anEvent, "clickCount") == 2)
        objj_msgSend(PhotoInspector, "inspectPaneLayer:", _paneLayer);
}
},["void","CPEvent"]), new objj_method(sel_getUid("setActive:"), function $PageView__setActive_(self, _cmd, isActive)
{ with(self)
{
    _isActive = isActive;
    objj_msgSend(_borderLayer, "setNeedsDisplay");
}
},["void","BOOL"]), new objj_method(sel_getUid("performDragOperation:"), function $PageView__performDragOperation_(self, _cmd, aSender)
{ with(self)
{
    objj_msgSend(self, "setActive:", NO);
    objj_msgSend(_paneLayer, "setImage:", objj_msgSend(CPKeyedUnarchiver, "unarchiveObjectWithData:", objj_msgSend(objj_msgSend(aSender, "draggingPasteboard"), "dataForType:", PhotoDragType)));
}
},["void","CPDraggingInfo"]), new objj_method(sel_getUid("draggingEntered:"), function $PageView__draggingEntered_(self, _cmd, aSender)
{ with(self)
{
    objj_msgSend(self, "setActive:", YES);
}
},["void","CPDraggingInfo"]), new objj_method(sel_getUid("draggingExited:"), function $PageView__draggingExited_(self, _cmd, aSender)
{ with(self)
{
    objj_msgSend(self, "setActive:", NO);
}
},["void","CPDraggingInfo"])]);
}

