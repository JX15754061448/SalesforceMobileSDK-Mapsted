//
//  ChangeViewBridge.m
//  AwesomeProject
//
//  Created by Jiaxiang Wang on 2023/11/15.
//

#import "ChangeViewBridge.h"
#import "AppDelegate.h"

@implementation ChangeViewBridge

RCT_EXPORT_MODULE(ChangeViewBridge);

RCT_EXPORT_METHOD(changeToMapView) {
  NSLog(@"RN binding - Native View - Loading MyViewController.swift");
  dispatch_async(dispatch_get_main_queue(), ^{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    //[appDelegate goToMapView];
  });
}
@end
