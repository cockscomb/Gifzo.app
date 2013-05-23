//
//  DrawMouseBoxView.h
//  Gifzo
//
//  Created by uiureo on 13/05/02.
//  Copyright (c) 2013年 uiureo. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>

@class DrawMouseBoxView;

@protocol DrawMouseBoxViewDelegate <NSObject>
- (void)startRecordingKeyDidPressedInView:(DrawMouseBoxView *)view withRect:(NSRect)rect screen:(NSScreen *)screen;
@end

@interface DrawMouseBoxView : NSView

@property(weak) id <DrawMouseBoxViewDelegate> delegate;
@property NSScreen *screen;

@end
