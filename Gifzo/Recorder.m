//
//  Recorder.m
//  Gifzo
//
//  Created by uiureo on 13/05/08.
//  Copyright (c) 2013年 uiureo. All rights reserved.
//

#import "Recorder.h"

@implementation Recorder {
    AVCaptureSession *_captureSession;
    AVCaptureMovieFileOutput *_movieFileOutput;
    NSTimer *_timer;
}

- (void)screenRecording:(NSURL *)destPath cropRect:(NSRect)rect screen:(NSScreen *)screen
{
    _captureSession = [[AVCaptureSession alloc] init];

    _captureSession.sessionPreset = AVCaptureSessionPresetHigh;

    NSDictionary *screenDictionary = [screen deviceDescription];
    NSNumber *screenID = [screenDictionary objectForKey:@"NSScreenNumber"];

    CGDirectDisplayID displayID = [screenID unsignedIntValue];

    AVCaptureScreenInput *input = [[AVCaptureScreenInput alloc] initWithDisplayID:displayID];
    [input setCropRect:NSRectToCGRect(rect)];

    if ([_captureSession canAddInput:input]) {
        [_captureSession addInput:input];
    }

    _movieFileOutput = [[AVCaptureMovieFileOutput alloc] init];

    if ([_captureSession canAddOutput:_movieFileOutput]) {
        [_captureSession addOutput:_movieFileOutput];
    }

    [_captureSession startRunning];

    if ([[NSFileManager defaultManager] fileExistsAtPath:[destPath path]]) {
        NSError *err;
        if (![[NSFileManager defaultManager] removeItemAtPath:[destPath path] error:&err]) {
            NSLog(@"Error deleting existing movie %@", [err localizedDescription]);
        }
    }

    [_movieFileOutput startRecordingToOutputFileURL:destPath recordingDelegate:self];
}

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error
{
    [_captureSession stopRunning];
    _captureSession = nil;

    if (error) {
        NSLog(@"Did finish recording to %@ due to error %@", [outputFileURL description], [error description]);

        [NSApp terminate:nil];
    }

    [self.delegate didRecord:self outputFileURL:outputFileURL];
}

- (void)finishRecord
{
    NSLog(@"finish recording");

    [_movieFileOutput stopRecording];
}

@end
