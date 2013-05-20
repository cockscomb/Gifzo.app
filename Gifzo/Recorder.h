//
//  Recorder.h
//  Gifzo
//
//  Created by zat on 13/05/08.
//  Copyright (c) 2013年 zat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@class Recorder;

@protocol RecorderDelegate <NSObject>
- (void)didRecord:(Recorder *)record outputFileURL:(NSURL *)outputFileURL;
@end

@interface Recorder : NSObject <AVCaptureFileOutputRecordingDelegate> {
@private
    AVCaptureSession *mSession;
    AVCaptureMovieFileOutput *mMovieFileOutput;
    NSTimer *mTimer;
}

@property(weak) id <RecorderDelegate> delegate;

-(void)screenRecording:(NSURL *)destPath cropRect:(NSRect)rect screen:(NSScreen *)screen;
-(void)finishRecord;
@end
