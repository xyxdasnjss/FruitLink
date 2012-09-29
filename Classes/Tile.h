#import "cocos2d.h"

@interface Tile : NSObject {
	int x;
	int y;
	int kind;
	CCSprite *sprite;
}
@property (nonatomic, assign) CCSprite *sprite;
@property (nonatomic, readonly) int x;
@property (nonatomic, readonly) int y;
@property (nonatomic) int kind;

-(id) initWithX: (int) x y: (int) y kind: (int) kind;
-(void) moveTo: (Tile *) otherTile;
@end
