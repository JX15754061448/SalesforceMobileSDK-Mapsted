// RNTMapManager.m
#import <React/RCTViewManager.h>
#import "SalesforceMobileSDKMapsted-Swift.h"

@interface RNTMapstedUIManager : RCTViewManager
@end

@implementation RNTMapstedUIManager

RCT_EXPORT_MODULE(RNTMapUI)

- (UIView *)view
{
  return [[RNTMapstedNavigateView alloc] init];
}
RCT_EXPORT_VIEW_PROPERTY(propertyId, int)
RCT_EXPORT_VIEW_PROPERTY(unloadMap, BOOL)
RCT_EXPORT_VIEW_PROPERTY(onLoadCallback, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onSelectLocation, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onUnloadCallback, RCTBubblingEventBlock)


@end
