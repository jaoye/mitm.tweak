#import <CoreLocation/CoreLocation.h>

@interface WCLocation : NSObject

@property CLLocationCoordinate2D coordinate;
@property CLLocationDistance altitude;
@property (nonatomic, strong) CLFloor *floor;
@property CLLocationAccuracy horizontalAccuracy;
@property CLLocationAccuracy verticalAccuracy;
@property (nonatomic, strong) NSDate *timestamp;
@property CLLocationSpeed speed;
@property CLLocationDirection course;

-(id)copyWithZone:(NSZone *) zone;
-(void)randomize;
-(void)fuzzle:(CGPoint)vector speed:(float)speed;
+(CGPoint)vectorWithScaleFactor:(CGPoint)vector;

@end
