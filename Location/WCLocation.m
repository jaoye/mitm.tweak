#import "WCLocation.h"

@implementation WCLocation

-(id)copyWithZone:(NSZone *) zone
{
    WCLocation *copy = [WCLocation new];
    copy.coordinate = self.coordinate;
    copy.altitude = self.altitude;
    copy.floor = self.floor;
    copy.horizontalAccuracy = self.horizontalAccuracy;
    copy.verticalAccuracy = self.verticalAccuracy;
    copy.timestamp = self.timestamp;
    copy.speed = self.speed;
    copy.course = self.course;
    return copy;
}

CGFloat randomizeValue(CGFloat value)
{
    return value - (value / 8) + arc4random_uniform(value/4);
}

-(void)randomize
{
    self.verticalAccuracy = randomizeValue(self.verticalAccuracy);
    self.horizontalAccuracy = randomizeValue(self.horizontalAccuracy);
    
    self.timestamp = [NSDate date];
    
    self.speed = randomizeValue(self.speed);
}

-(void)fuzzle:(CGPoint)vector speed:(float)speed
{
    self.coordinate = CLLocationCoordinate2DMake(self.coordinate.latitude - (vector.y * speed), self.coordinate.longitude + (vector.x * speed));
}

+(CGPoint)vectorWithScaleFactor:(CGPoint)vector
{
    CGFloat scale = sqrt(pow(vector.x, 2) + pow(vector.y, 2)) * (5500 + arc4random_uniform(1000));
    
    return CGPointMake(vector.x / scale, vector.y / scale);
}

@end