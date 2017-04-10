//
//  WXEventModule.m
//  t1
//
//  Created by zhj on 2017/2/24.
//  Copyright © 2017年 zhj. All rights reserved.
//

#import "WXEventModule.h"
#import "GuideViewController.h"
#import <WeexSDK/WeexSDK.h>

@implementation WXEventModule
@synthesize weexInstance;

WX_EXPORT_METHOD(@selector(getHight:callback:))

- (void)getHight:(NSString *)url callback:(WXModuleCallback)callback
{
    callback(@"30");
}

@end

