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
  // return [[RCNMapViewTest alloc] initWithFrame:CGRectMake(0, 0, 320, 320)];
}
// RNTMapManager.m
// RCT_EXPORT_VIEW_PROPERTY(zoomEnabled, BOOL)
RCT_EXPORT_VIEW_PROPERTY(title, NSString)

@end
