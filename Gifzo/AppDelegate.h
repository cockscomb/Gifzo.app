//
//  AppDelegate.h
//  Gifzo
//
//  Created by zat on 13/05/02.
//  Copyright (c) 2013年 zat. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DrawMouseBoxView.h"
#import "Recorder.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, DrawMouseBoxViewDelegate, RecorderDelegate>

@property Recorder *recorder;

@end
