//
//  DrawMouseBoxView.m
//  Gifzo
//
//  Created by uiureo on 13/05/02.
//  Copyright (c) 2013年 uiureo. All rights reserved.
//

#import "DrawMouseBoxView.h"

@implementation DrawMouseBoxView {
    NSPoint _mouseDownPoint;
    NSRect _selectionRect;
    BOOL _isSelecting, _selectionDidFinished, _selectionIsDragging;
    BOOL _globalKeySettled;
    EventHotKeyRef _hotKeyRef;
}

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent
{
    return YES;
}

- (BOOL)acceptsFirstResponder
{
    return YES;
}

#define ESC_KEY_CODE 53

- (void)keyDown:(NSEvent *)theEvent
{
    if ([theEvent keyCode] == ESC_KEY_CODE) {
        [NSApp terminate:nil];
    }

    if (!_isSelecting) return;

    [self recordButton:theEvent];
}

- (void)recordButton:(NSEvent *)event
{
    NSString *optionPlusR = @"®";

    if ([[event characters] isEqual:optionPlusR]) {
        [self recordKeyPressed];
    };
}

- (void)recordKeyPressed
{
    if (!_selectionDidFinished) {
        _selectionDidFinished = YES;
        [self display];
        [[self window] setIgnoresMouseEvents:YES];
        [[self window] invalidateCursorRectsForView:self];
    } else {
        UnregisterEventHotKey(_hotKeyRef);
    }

    [self.delegate startRecordingKeyDidPressedInView:self withRect:_selectionRect screen:self.screen];
}

- (void)registerHotKey
{
    EventTypeSpec eventTypeSpecList[] = {
            {kEventClassKeyboard, kEventHotKeyPressed}
    };

    InstallApplicationEventHandler(&hotKeyHandler, GetEventTypeCount(eventTypeSpecList),
    eventTypeSpecList, (__bridge void *) self, NULL);
    EventHotKeyID hotKeyID;
    hotKeyID.id = 0;
    hotKeyID.signature = 'r';
    UInt32 hotKeyCode = 15;  // r
    UInt32 hotKeyModifier = optionKey;


    RegisterEventHotKey(hotKeyCode, hotKeyModifier, hotKeyID,
            GetApplicationEventTarget(), 0, &_hotKeyRef);
}

OSStatus hotKeyHandler(EventHandlerCallRef nextHandler, EventRef theEvent, void *userData) {
    EventHotKeyID hotKeyID;
    GetEventParameter(theEvent, kEventParamDirectObject, typeEventHotKeyID, NULL,
            sizeof(hotKeyID), NULL, &hotKeyID);

    if (hotKeyID.signature == 'r') {
        id self = (__bridge id) userData;
        [self recordKeyPressed];
    }

    return noErr;
}

- (void)mouseDown:(NSEvent *)theEvent
{
    if (!_globalKeySettled) {
        [self registerHotKey];
    }

    _isSelecting = NO;
    _selectionIsDragging = YES;

    _mouseDownPoint = [theEvent locationInWindow];
}

- (void)mouseUp:(NSEvent *)theEvent
{
    if (!_selectionIsDragging) return;

    NSPoint mouseUpPoint = [theEvent locationInWindow];
    _selectionRect = NSMakeRect(
            MIN(_mouseDownPoint.x, mouseUpPoint.x),
            MIN(_mouseDownPoint.y, mouseUpPoint.y),
            MAX(_mouseDownPoint.x, mouseUpPoint.x) - MIN(_mouseDownPoint.x, mouseUpPoint.x),
            MAX(_mouseDownPoint.y, mouseUpPoint.y) - MIN(_mouseDownPoint.y, mouseUpPoint.y));

    [self setNeedsDisplayInRect:_selectionRect];

    _isSelecting = true;

}

- (void)mouseDragged:(NSEvent *)theEvent
{
    NSPoint curPoint = [theEvent locationInWindow];
    NSRect previousSelectionRect = _selectionRect;
    _selectionRect = NSMakeRect(
            MIN(_mouseDownPoint.x, curPoint.x),
            MIN(_mouseDownPoint.y, curPoint.y),
            MAX(_mouseDownPoint.x, curPoint.x) - MIN(_mouseDownPoint.x, curPoint.x),
            MAX(_mouseDownPoint.y, curPoint.y) - MIN(_mouseDownPoint.y, curPoint.y));

    [self setNeedsDisplayInRect:NSUnionRect(_selectionRect, previousSelectionRect)];
    _selectionIsDragging = YES;
}

- (void)drawRect:(NSRect)dirtyRect
{
    NSColor *transparentBlackColor = [NSColor colorWithDeviceRed:0.0 green:0.0 blue:0.0 alpha:0.5];
    [transparentBlackColor set];
    NSRectFill([self frame]);

    [[NSColor clearColor] set];
    NSRectFill(_selectionRect);

    if (_isSelecting || _selectionDidFinished) {
        [self drawPressKeyMessage];
    }

    if (_selectionDidFinished) {

        return;
    }

    [[NSColor whiteColor] set];
    NSFrameRectWithWidth(NSInsetRect(_selectionRect, 1, 1), 1);
}

- (void)drawPressKeyMessage
{
    NSColor *transparentBlackColor = [NSColor colorWithDeviceRed:0.0 green:0.0 blue:0.0 alpha:0.5];

    NSString *message = _selectionDidFinished ? @"Option+Rで収録終了" : @"Option+Rで収録開始";
    NSMutableAttributedString *pressKeyMessageString = [[NSMutableAttributedString alloc] initWithString:message];

    Float32 fontSize = 18.0;

    CGFloat boxWidth = fontSize * [pressKeyMessageString length] - 64.0, boxHeight = fontSize + 4.0;
    NSRect boxRect;

    if (_selectionDidFinished) {
        boxRect = NSMakeRect(NSMidX(_selectionRect) - boxWidth / 2.0, NSMaxY(_selectionRect) + boxHeight / 2.0, boxWidth, boxHeight);

    } else {
        boxRect = NSMakeRect(NSMidX(_selectionRect) - boxWidth / 2.0, NSMidY(_selectionRect) - boxHeight / 2.0, boxWidth, boxHeight);
    }

    NSRange messageRange = NSMakeRange(0, pressKeyMessageString.length);

    [pressKeyMessageString addAttribute:NSFontAttributeName value:[NSFont fontWithName:@"Helvetica" size:fontSize] range:messageRange];

    [pressKeyMessageString addAttribute:NSForegroundColorAttributeName value:[NSColor whiteColor] range:messageRange];

    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowOffset = CGSizeMake(1.0, 0.0);
    shadow.shadowColor = [NSColor whiteColor];
    shadow.shadowBlurRadius = 2.f;
    [pressKeyMessageString addAttribute:NSShadowAttributeName
                                  value:shadow
                                  range:messageRange];

    // テキスト背景の描画
    [transparentBlackColor set];
    [[NSColor whiteColor] setStroke];
    NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:NSInsetRect(boxRect, -4.0, -4.0) xRadius:4.0 yRadius:4.0];
    [path setLineWidth:2.0];
    [path stroke];
    [path fill];

    [pressKeyMessageString drawInRect:boxRect];
}

- (void)resetCursorRects
{
    if (_selectionDidFinished) return;
    [self addCursorRect:[self frame] cursor:[NSCursor crosshairCursor]];
}

@end
