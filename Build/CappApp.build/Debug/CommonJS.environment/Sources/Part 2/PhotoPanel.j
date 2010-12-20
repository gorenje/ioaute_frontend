@STATIC;1.0;I;16;AppKit/CPPanel.jt;4813;


objj_executeFile("AppKit/CPPanel.j", NO);


PhotoDragType = "PhotoDragType";

{var the_class = objj_allocateClassPair(CPPanel, "PhotoPanel"),
meta_class = the_class.isa;class_addIvars(the_class, [new objj_ivar("images")]);
objj_registerClassPair(the_class);
class_addMethods(the_class, [new objj_method(sel_getUid("init"), function $PhotoPanel__init(self, _cmd)
{ with(self)
{
    self = objj_msgSend(self, "initWithContentRect:styleMask:", CGRectMake(50.0, 50.0, 250.0, 360.0), CPHUDBackgroundWindowMask | CPClosableWindowMask | CPResizableWindowMask);

    if (self)
    {
        objj_msgSend(self, "setTitle:", "Photos");
        objj_msgSend(self, "setFloatingPanel:", YES);

        var contentView = objj_msgSend(self, "contentView"),
            bounds = objj_msgSend(contentView, "bounds");

        bounds.size.height -= 20.0;

        var photosView = objj_msgSend(objj_msgSend(CPCollectionView, "alloc"), "initWithFrame:", bounds);

        objj_msgSend(photosView, "setAutoresizingMask:", CPViewWidthSizable);
        objj_msgSend(photosView, "setMinItemSize:", CGSizeMake(100, 100));
        objj_msgSend(photosView, "setMaxItemSize:", CGSizeMake(100, 100));
        objj_msgSend(photosView, "setDelegate:", self);

        var itemPrototype = objj_msgSend(objj_msgSend(CPCollectionViewItem, "alloc"), "init");

        objj_msgSend(itemPrototype, "setView:", objj_msgSend(objj_msgSend(PhotoView, "alloc"), "initWithFrame:", CGRectMakeZero()));

        objj_msgSend(photosView, "setItemPrototype:", itemPrototype);

        var scrollView = objj_msgSend(objj_msgSend(CPScrollView, "alloc"), "initWithFrame:", bounds);

        objj_msgSend(scrollView, "setDocumentView:", photosView);
        objj_msgSend(scrollView, "setAutoresizingMask:", CPViewWidthSizable | CPViewHeightSizable);
        objj_msgSend(scrollView, "setAutohidesScrollers:", YES);

        objj_msgSend(objj_msgSend(scrollView, "contentView"), "setBackgroundColor:", objj_msgSend(CPColor, "whiteColor"));

        objj_msgSend(contentView, "addSubview:", scrollView);

        images = [ objj_msgSend(objj_msgSend(CPImage, "alloc"), "initWithContentsOfFile:size:", "Resources/sample.jpg", CGSizeMake(500.0, 430.0)),
                    objj_msgSend(objj_msgSend(CPImage, "alloc"), "initWithContentsOfFile:size:", "Resources/sample2.jpg", CGSizeMake(500.0, 389.0)),
                    objj_msgSend(objj_msgSend(CPImage, "alloc"), "initWithContentsOfFile:size:", "Resources/sample3.jpg", CGSizeMake(413.0, 400.0)),
                    objj_msgSend(objj_msgSend(CPImage, "alloc"), "initWithContentsOfFile:size:", "Resources/sample4.jpg", CGSizeMake(500.0, 375.0)),
                    objj_msgSend(objj_msgSend(CPImage, "alloc"), "initWithContentsOfFile:size:", "Resources/sample5.jpg", CGSizeMake(500.0, 375.0)),
                    objj_msgSend(objj_msgSend(CPImage, "alloc"), "initWithContentsOfFile:size:", "Resources/sample6.jpg", CGSizeMake(500.0, 375.0)) ];

        objj_msgSend(photosView, "setContent:", images);
    }

    return self;
}
},["id"]), new objj_method(sel_getUid("collectionView:dataForItemsAtIndexes:forType:"), function $PhotoPanel__collectionView_dataForItemsAtIndexes_forType_(self, _cmd, aCollectionView, indices, aType)
{ with(self)
{
    return objj_msgSend(CPKeyedArchiver, "archivedDataWithRootObject:", objj_msgSend(images, "objectAtIndex:", objj_msgSend(indices, "firstIndex")));
}
},["CPData","CPCollectionView","CPIndexSet","CPString"]), new objj_method(sel_getUid("collectionView:dragTypesForItemsAtIndexes:"), function $PhotoPanel__collectionView_dragTypesForItemsAtIndexes_(self, _cmd, aCollectionView, indices)
{ with(self)
{
    return [PhotoDragType];
}
},["CPArray","CPCollectionView","CPIndexSet"])]);
}

{var the_class = objj_allocateClassPair(CPImageView, "PhotoView"),
meta_class = the_class.isa;class_addIvars(the_class, [new objj_ivar("_imageView")]);
objj_registerClassPair(the_class);
class_addMethods(the_class, [new objj_method(sel_getUid("setSelected:"), function $PhotoView__setSelected_(self, _cmd, isSelected)
{ with(self)
{
    objj_msgSend(self, "setBackgroundColor:", isSelected ? objj_msgSend(CPColor, "grayColor") : nil);
}
},["void","BOOL"]), new objj_method(sel_getUid("setRepresentedObject:"), function $PhotoView__setRepresentedObject_(self, _cmd, anObject)
{ with(self)
{
    if (!_imageView)
    {
        _imageView = objj_msgSend(objj_msgSend(CPImageView, "alloc"), "initWithFrame:", CGRectInset(objj_msgSend(self, "bounds"), 5.0, 5.0));

        objj_msgSend(_imageView, "setImageScaling:", CPScaleProportionally);
        objj_msgSend(_imageView, "setAutoresizingMask:", CPViewWidthSizable | CPViewHeightSizable);

        objj_msgSend(self, "addSubview:", _imageView);
    }

    objj_msgSend(_imageView, "setImage:", anObject);
}
},["void","id"])]);
}

