//
//  Recorder.m
//  Gifzo
//
//  Created by uiureo on 13/05/08.
//  Copyright (c) 2013年 uiureo. All rights reserved.
//

#import "Recorder.h"

@implementation Recorder

- (void)screenRecording:(NSURL *)destPath cropRect:(NSRect)rect screen:(NSScreen *)screen
{
    mSession = [[AVCaptureSession alloc] init];
    
    mSession.sessionPreset = AVCaptureSessionPresetHigh;
    
    NSDictionary* screenDictionary = [screen deviceDescription];
    NSNumber* screenID = [screenDictionary objectForKey:@"NSScreenNumber"];
    
    CGDirectDisplayID displayID = [screenID unsignedIntValue];

    AVCaptureScreenInput *input = [[AVCaptureScreenInput alloc] initWithDisplayID:displayID];
    [input setCropRect:NSRectToCGRect(rect)];
    
    if ([mSession canAddInput:input]) {
        [mSession addInput:input];
    }
    
    mMovieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
    
    if ([mSession canAddOutput:mMovieFileOutput]) {
        [mSession addOutput:mMovieFileOutput];
    }
    
    [mSession startRunning];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:[destPath path]])
    {
        NSError *err;
        if (![[NSFileManager defaultManager] removeItemAtPath:[destPath path] error:&err])
        {
            NSLog(@"Error deleting existing movie %@",[err localizedDescription]);
        }
    }
    
    [mMovieFileOutput startRecordingToOutputFileURL:destPath recordingDelegate:self];
}

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error
{
    [mSession stopRunning];
    mSession = nil;
    
    if (error)
    {
        NSLog(@"Did finish recording to %@ due to error %@", [outputFileURL description], [error description]);
        
        [NSApp terminate:nil];
    }
    
    [self.delegate didRecord:self outputFileURL:outputFileURL];
}

-(void)finishRecord
{
    NSLog(@"finish recording");
    
    [mMovieFileOutput stopRecording];
}

@end
