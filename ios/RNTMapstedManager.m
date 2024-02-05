// RNTMapManager.m
#import <MapKit/MapKit.h>

#import <React/RCTViewManager.h>
#import "SalesforceMobileSDKMapsted-Swift.h"

@interface RNTMapstedManager : RCTViewManager
@end

@implementation RNTMapstedManager

RCT_EXPORT_MODULE(RNTMap)

- (UIView *)view
{
  // return [[MKMapView alloc] init];
  return [[RNTMapstedView alloc] init];
  //return [[RNTMapstedNavigateView alloc] init];
}
// RNTMapManager.m
RCT_EXPORT_VIEW_PROPERTY(propertyId, int)
RCT_EXPORT_VIEW_PROPERTY(unloadMap, BOOL)
RCT_EXPORT_VIEW_PROPERTY(onLoadCallback, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onSelectLocation, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onUnloadCallback, RCTBubblingEventBlock)
@end
