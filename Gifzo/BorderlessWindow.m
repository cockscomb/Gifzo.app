//
//  BorderlessWindow.m
//  Gifzo
//
//  Created by zat on 13/05/09.
//  Copyright (c) 2013年 zat. All rights reserved.
//

#import "BorderlessWindow.h"

@implementation BorderlessWindow

- (BOOL)canBecomeKeyWindow
{
    return YES;
}

- (BOOL)canBecomeMainWindow
{
    return YES;
}

@end
