//
//  ChangeViewBridge.h
//  AwesomeProject
//
//  Created by Jiaxiang Wang on 2023/11/15.
//

#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>

NS_ASSUME_NONNULL_BEGIN

@interface ChangeViewBridge : NSObject <RCTBridgeModule>

- (void) changeToMapView;

@end

NS_ASSUME_NONNULL_END
