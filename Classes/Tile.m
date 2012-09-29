#import "Tile.h"


@implementation Tile
@synthesize sprite;
@synthesize x;
@synthesize y;
@synthesize kind;

-(id) initWithX: (int) posX y: (int) posY kind: (int) tileKind{
	self = [super init];
	x = posX;
	y = posY;
	kind = tileKind;
	return self;
}

-(void) moveTo: (Tile *) otherTile{
	otherTile.kind = [self kind];
	otherTile.sprite = [self sprite];
	[self setKind: -1];
	[self setSprite: nil];
}
@end
