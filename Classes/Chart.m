#import "Chart.h"

@interface Chart ()
-(void) fillContent;
-(BOOL) checkExtensionConnectWithType: (int) type;
-(BOOL) checkDirectionLinkWithStart: (CGPoint) startPoint  end:(CGPoint) endPoint type: (int) type;
-(void) resetExtension: (Tile *) start end: (Tile *) end type: (int) type;
@end

@implementation Chart
@synthesize level;
@synthesize ballTiles;

-(id) initWith: (Level *) alevel{
	self = [super init];
	self.level = alevel;
	
	content = [[NSMutableArray arrayWithCapacity: kRowCount ] retain];
	for (int i=0; i<kRowCount; i++) {
		NSMutableArray *row = [NSMutableArray arrayWithCapacity: kColumnCount];
		[content addObject: row];
	}
	startExtension = [[NSMutableArray arrayWithCapacity: 5] retain];
	endExtension = [[NSMutableArray arrayWithCapacity: 5] retain];
	[self fillContent];	

	return self;
}

-(void) dealloc{
	[super dealloc];
	[content release];
	[startExtension release];
	[endExtension release];
	[ballTiles release];
}

-(void) dismissTile: (Tile *) tile{
	CCSprite *sprite = tile.sprite;
	[sprite stopAllActions];
	sprite.scaleX = kDefaultScaleX;
	sprite.scaleY = kDefaultScaleY;
	
	
	CCSequence *someAction = [CCSequence actions:
							  [CCEaseBackIn actionWithAction:
							  [CCSpawn actions:
							   [CCMoveTo actionWithDuration: 0.7F position:ccp(55,160)],
							   [CCRotateBy actionWithDuration:0.7F angle:360.0F],
							   nil]],
							  [CCCallFuncN actionWithTarget: self selector: @selector(afterDimiss:)],
							  nil];
	[sprite runAction: someAction];
	[ballTiles removeObject: tile];
	tile.kind = -1;
	tile.sprite = nil;
}

-(void) fillContent{
	int count = [level ballCount];
	
	BOOL needRepair = count%2==1;
	BOOL centerFill = YES; 
	if (needRepair) {
		BOOL rawCenterNeedFill = [level fillWithColumn:kColumnCenter row:kRowCenter];
		if (rawCenterNeedFill) {
			centerFill = NO;
			count -= 1;
		}else {
			centerFill = YES;
			count += 1;
		}

	}

	
	ballTiles = [[NSMutableArray arrayWithCapacity: count] retain];
	int tempResult[count];
	
	
	NSMutableArray *indexArray = [NSMutableArray arrayWithCapacity: count];
	for (int i=0; i < count; i++, i++) {
		int number = i;
		if (i>=level.factor) {
			number = arc4random()%level.factor;
		}
		tempResult[i] = number;
		tempResult[i+1] = number;
		[indexArray addObject: [NSNumber numberWithInt :i]];
		[indexArray addObject: [NSNumber numberWithInt :i+1]];
	}
	
	for (int rowIndex = 0, spare = count;  rowIndex < kRowCount; rowIndex ++) {
		NSMutableArray *row = [content objectAtIndex: rowIndex];
		for (int columnIndex = 0;  columnIndex < kColumnCount;  columnIndex ++) {
			
			Tile *tile = nil;
			int contentValue = -1;
			if (needRepair && columnIndex == kColumnCenter && rowIndex == kRowCenter) {
				if (centerFill) {
					int index = arc4random()% spare;
					NSNumber *number = [indexArray objectAtIndex: index];
					int value = [number intValue];
					contentValue = tempResult[value];
					[indexArray removeObjectAtIndex: index];
					tile = [[Tile alloc] initWithX: columnIndex y: rowIndex kind: contentValue];
					[ballTiles addObject: tile];
					spare--;	
				}else {
					tile = [[Tile alloc] initWithX: columnIndex y: rowIndex kind:-1];
				}
			}
			else if (NO == [level fillWithColumn:columnIndex row:rowIndex]) {
				tile = [[Tile alloc] initWithX: columnIndex y: rowIndex kind:-1];
			}else {
				int index = arc4random()% spare;
				NSNumber *number = [indexArray objectAtIndex: index];
				int value = [number intValue];
				contentValue = tempResult[value];
				[indexArray removeObjectAtIndex: index];
				tile = [[Tile alloc] initWithX: columnIndex y: rowIndex kind: contentValue];
				[ballTiles addObject: tile];
				spare--;
			}
			[row addObject: tile];
			[tile release];
		}
	}
	
}

-(Tile *) get: (CGPoint) position{
	if (position.y < 0 || position.y >= [content count]) {
		return nil;
	}
	NSMutableArray *row = [content objectAtIndex: position.y];
	if (position.x < 0 || position.x >= [row count]) {
		return nil;
	}
	return [row objectAtIndex: position.x];
}

-(BOOL) isConnectStart: (Tile *) start end: (Tile *) end{
	if (start.kind != end.kind) {
		return NO;
	}
	[self resetExtension: start end: end type: horitional]; 
	if ([self checkExtensionConnectWithType: horitional]) {
		return YES;
	}else {
		[self resetExtension: start end: end type:vertical];
		return [self checkExtensionConnectWithType: vertical];
	}

}

-(BOOL) checkExtensionConnectWithType: (int) type{
	int extensionCount = [startExtension count];
	if (type == horitional) {
			for (int i=0; i< extensionCount; i++) {
			NSValue *eachStartValue = [startExtension objectAtIndex: i];
			CGPoint eachStartPoint = [eachStartValue CGPointValue];
			for (int j=0; j< extensionCount; j++) {
				NSValue *eachEndValue = [endExtension objectAtIndex: j];
				CGPoint eachEndPoint = [eachEndValue CGPointValue];
				if (eachStartPoint.x == eachEndPoint.x) {
					if ([self checkDirectionLinkWithStart: eachStartPoint end: eachEndPoint type: type]) {
						return YES;
					}
					break;
				}
			}
		}
		return NO;
	}else {
		for (int i=0; i< extensionCount; i++) {
			NSValue *eachStartValue = [startExtension objectAtIndex: i];
			CGPoint eachStartPoint = [eachStartValue CGPointValue];
			for (int j=0; j< extensionCount; j++) {
				NSValue *eachEndValue = [endExtension objectAtIndex: j];
				CGPoint eachEndPoint = [eachEndValue CGPointValue];
				if (eachStartPoint.y == eachEndPoint.y) {
					if ([self checkDirectionLinkWithStart: eachStartPoint end: eachEndPoint type: type]) {
						return YES;
					}
					break;
				}
			}
		}
		return NO;		
	}
}

-(BOOL) checkDirectionLinkWithStart: (CGPoint) startPoint  end:(CGPoint) endPoint type: (int) type{
	if (type == horitional) {
		if (startPoint.y == endPoint.y) {
			return YES;
		}
		int big = startPoint.y > endPoint.y ? startPoint.y : endPoint.y;
		int small = startPoint.y < endPoint.y ? startPoint.y : endPoint.y;
		if ((big-small) < 2) {
			return YES;
		}
		for (small++; small < big; small++) {
			CGPoint position = ccp(startPoint.x, small);
			Tile *valueTile = [self get: position];
			if (valueTile && valueTile.kind >= 0) {
				return NO;
			}
		}
		return YES;
		
	}else {
		if (startPoint.x == endPoint.x) {
			return YES;
		}
		int big = startPoint.x > endPoint.x ? startPoint.x : endPoint.x;
		int small = startPoint.x < endPoint.x ? startPoint.x : endPoint.x;
		if ((big-small) < 2) {
			return YES;
		}
		for (small++; small < big; small++) {
			CGPoint position = ccp(small, startPoint.y);
			Tile *valueTile = [self get: position];
			if (valueTile && valueTile.kind >= 0) {
				return NO;
			}
		}
		return YES;
	}

}

-(void) resetExtension: (Tile *) start end: (Tile *) end type: (int) type{
	[startExtension removeAllObjects];
	[endExtension removeAllObjects];
	
	
	NSMutableArray *startExtensionTemp = [[NSMutableArray alloc] initWithObjects: [NSValue valueWithCGPoint: ccp(start.x, start.y)], nil];
	NSMutableArray *endExtensionTemp = [[NSMutableArray alloc] initWithObjects: [NSValue valueWithCGPoint: ccp(end.x, end.y)], nil];
	if(type == horitional){
		for (int i=1;;i++) {
			if((start.x-i)<0){
				break;
			}
			Tile *valueTile = [self get:ccp(start.x-i, start.y)];
			if (valueTile && valueTile.kind>=0) {
				break;
			}
			NSValue *nsValue = [NSValue valueWithCGPoint: CGPointMake(start.x - i, start.y)];
			[startExtensionTemp addObject: nsValue];
		}
		for (int i=1;;i++) {
			if((start.x+i)>= kColumnCount){
				break;
			}
			Tile *valueTile = [self get:ccp(start.x + i, start.y)];
			if (valueTile && valueTile.kind>=0) {
				break;
			}
			NSValue *nsValue = [NSValue valueWithCGPoint: CGPointMake(start.x + i, start.y)];
			[startExtensionTemp addObject: nsValue];

		}
		
		for (int i=1;;i++) {
			if((end.x-i)<0){
				break;
			}
			Tile *valueTile = [self get: ccp(end.x-i, end.y)];
			if (valueTile && valueTile.kind>=0) {
				break;
			}
			NSValue *nsValue = [NSValue valueWithCGPoint: CGPointMake(end.x - i, end.y)];
			[endExtensionTemp addObject: nsValue];
		}
		for (int i=1;;i++) {
			if((end.x+i)>= kColumnCount){
				break;
			}
			Tile *valueTile = [self get:ccp(end.x + i, end.y)];
			if (valueTile && valueTile.kind>=0) {
				break;
			}
			NSValue *nsValue = [NSValue valueWithCGPoint: CGPointMake(end.x + i, end.y)];
			[endExtensionTemp addObject: nsValue];
		}
		
		int startCount = [startExtensionTemp count];
		int endCount= [endExtensionTemp count];
		
		BOOL find = NO;
		for (int i=0; i<startCount; i++,  find = NO) {
			NSValue *eachStartValue = [startExtensionTemp objectAtIndex: i];
			CGPoint eachStartPoint = [eachStartValue CGPointValue];
			for (int j=0; j<endCount; j++) {
				NSValue *eachEndValue = [endExtensionTemp objectAtIndex: j];
				CGPoint eachEndPoint = [eachEndValue CGPointValue];
				if (eachStartPoint.x == eachEndPoint.x) {
					find = YES;
					break;
				}
			}
			if (find) {
				[startExtension addObject: eachStartValue];
			}
		}
		
		find = NO;
		int resultStartCount = [startExtension count];
		for (int i=0; i<endCount; i++,  find = NO) {
			NSValue *eachEndValue = [endExtensionTemp objectAtIndex: i];
			CGPoint eachEndPoint = [eachEndValue CGPointValue];
			for (int j=0; j<resultStartCount; j++) {
				NSValue *eachStartValue = [startExtension objectAtIndex: j];
				CGPoint eachStartPoint = [eachStartValue CGPointValue];
				if (eachStartPoint.x == eachEndPoint.x) {
					find = YES;
					break;
				}
			}
			if (find) {
				[endExtension addObject: eachEndValue];
			}
		}
	}else {
		for (int i=1;;i++) {
			if((start.y-i)<0){
				break;
			}
			Tile *valueTile = [self get: ccp(start.x, start.y - i)];
			if (valueTile && valueTile.kind>=0){
				break;
			}
			NSValue *nsValue = [NSValue valueWithCGPoint: CGPointMake(start.x, start.y - i)];
			[startExtensionTemp addObject: nsValue];
		}
		for (int i=1;;i++) {
			if((start.y+i)>= kRowCount){
				break;
			}
			Tile *valueTile = [self get: ccp(start.x, start.y + i)];
			if (valueTile && valueTile.kind>=0){
				break;
			}
			NSValue *nsValue = [NSValue valueWithCGPoint: CGPointMake(start.x, start.y + i)];
			[startExtensionTemp addObject: nsValue];
			
		}
		
		for (int i=1;;i++) {
			if((end.y-i)<0){
				break;
			}
			Tile *valueTile = [self get:ccp(end.x, end.y-i)];
			if (valueTile && valueTile.kind>=0){
				break;
			}
			NSValue *nsValue = [NSValue valueWithCGPoint: CGPointMake(end.x, end.y - i)];
			[endExtensionTemp addObject: nsValue];
		}
		for (int i=1;;i++) {
			if((end.y+i)>= kRowCount){
				break;
			}
			Tile *valueTile = [self get: ccp(end.x, end.y+i)];
			if (valueTile && valueTile.kind>=0){
				break;
			}
			NSValue *nsValue = [NSValue valueWithCGPoint: CGPointMake(end.x, end.y + i)];
			[endExtensionTemp addObject: nsValue];
		}
		
		int startCount = [startExtensionTemp count];
		int endCount= [endExtensionTemp count];
		
		BOOL find = NO;
		for (int i=0; i<startCount; i++,  find = NO) {
			NSValue *eachStartValue = [startExtensionTemp objectAtIndex: i];
			CGPoint eachStartPoint = [eachStartValue CGPointValue];
			for (int j=0; j<endCount; j++) {
				NSValue *eachEndValue = [endExtensionTemp objectAtIndex: j];
				CGPoint eachEndPoint = [eachEndValue CGPointValue];
				if (eachStartPoint.y == eachEndPoint.y) {
					find = YES;
					break;
				}
			}
			if (find) {
				[startExtension addObject: eachStartValue];
			}
		}
		
		find = NO;
		int resultStartCount = [startExtension count];
		for (int i=0; i<endCount; i++,  find = NO) {
			NSValue *eachEndValue = [endExtensionTemp objectAtIndex: i];
			CGPoint eachEndPoint = [eachEndValue CGPointValue];
			for (int j=0; j<resultStartCount; j++) {
				NSValue *eachStartValue = [startExtension objectAtIndex: j];
				CGPoint eachStartPoint = [eachStartValue CGPointValue];
				if (eachStartPoint.y == eachEndPoint.y) {
					find = YES;
					break;
				}
			}
			if (find) {
				[endExtension addObject: eachEndValue];
			}
		}
		
		
	}
	[startExtensionTemp removeAllObjects];
	[startExtensionTemp release];
	[endExtensionTemp removeAllObjects];
	[endExtensionTemp release];
	
}

-(void) packA: (Tile *) a B: (Tile *) b{
	if (level.tileMoveType == TileMove_NoMove) {
		return;
	}
	
	if (level.tileMoveType == TileMove_Left || level.tileMoveType == Tilemove_Right) {
		if (a.y ==b.y) {
			Tile *left = a.x > b.x ? b : a;
			Tile *right = a.x < b.x ? b : a;
			if (level.tileMoveType == TileMove_Left) {
				int movePart = 1;
				for (int x= left.x + 1; ; x++) {
					if (x == right.x) {
						movePart = 2;
						continue;
					};
					Tile *valueTile = [self get: ccp(x, left.y)];
					if (!valueTile || valueTile.kind == -1) {
						break;
					}
					[valueTile.sprite runAction: 	
					 [CCMoveBy actionWithDuration: 0.5F position:ccp(-movePart*(kTileSize),0)]];
					Tile *destTile = [self get:ccp(x-movePart, left.y)];
					[self moveA: valueTile B: destTile];
				}
				if (movePart == 1) {
					for (int x= right.x + 1; ; x++) {
						Tile *valueTile = [self get: ccp(x, right.y)];
						if (!valueTile || valueTile.kind == -1) {
							break;
						}
						[valueTile.sprite runAction: 	
						 [CCMoveBy actionWithDuration: 0.5F position:ccp(-movePart*(kTileSize),0)]];
						Tile *destTile = [self get:ccp(x-movePart, right.y)];
						[self moveA: valueTile B: destTile];			
					}
				}
			}else {
				int movePart = 1;
				for (int x= right.x - 1; ; x--) {
					if (x == left.x) {
						movePart = 2;
						continue;
					};
					Tile *valueTile = [self get: ccp(x, right.y)];
					if (!valueTile || valueTile.kind == -1) {
						break;
					}
					[valueTile.sprite runAction: 	[CCMoveBy actionWithDuration: 0.5F position:ccp(movePart*(kTileSize),0)]];
					Tile *destTile = [self get:ccp(x+movePart, right.y)];
					[self moveA: valueTile B: destTile];			
				}
				if (movePart == 1) {
					for (int x= left.x - 1; ; x--) {
						Tile *valueTile = [self get: ccp(x, left.y)];
						if (!valueTile || valueTile.kind == -1) {
							break;
						}
						[valueTile.sprite runAction: 	[CCMoveBy actionWithDuration: 0.5F position:ccp(movePart*(kTileSize),0)]];
						Tile *destTile = [self get:ccp(x+movePart, left.y)];
						[self moveA: valueTile B: destTile];
					}
				}
			}
		}else {
			int movePart = level.tileMoveType == TileMove_Left ? 1 : -1;
			for (int x= a.x + movePart; ; x+= movePart) {
				Tile *valueTile = [self get: ccp(x, a.y)];
				if (!valueTile || valueTile.kind == -1) {
					break;
				}
				[valueTile.sprite runAction: 	[CCMoveBy actionWithDuration: 0.5F position:ccp(-movePart*(kTileSize),0)]];
				Tile *destTile = [self get:ccp(x-movePart, a.y)];
				[self moveA: valueTile B: destTile];
			}
			for (int x= b.x + movePart; ; x+= movePart) {
				Tile *valueTile = [self get: ccp(x, b.y)];
				if (!valueTile || valueTile.kind == -1) {
					break;
				}
				[valueTile.sprite runAction: 	[CCMoveBy actionWithDuration: 0.5F position:ccp(-movePart*(kTileSize),0)]];
				Tile *destTile = [self get:ccp(x-movePart, b.y)];
				[self moveA: valueTile B: destTile];
			}
		}
		return;
	}
	if (level.tileMoveType == TileMove_Up || level.tileMoveType == TileMove_Down) {
		if (a.x ==b.x) {
			Tile *up = a.y > b.y ? a : b;
			Tile *down = a.y >b.y ? b : a;
			if (level.tileMoveType == TileMove_Up) {
				int movePart = 1;
				for (int y= up.y - 1; ; y--) {
					if (y == down.y) {
						movePart = 2;
						continue;
					};
					Tile *valueTile = [self get: ccp(up.x, y)];
					if (!valueTile || valueTile.kind == -1) {
						break;
					}
					[valueTile.sprite runAction: 	[CCMoveBy actionWithDuration: 0.5F position:ccp(0,movePart*(kTileSize))]];					
					Tile *destTile = [self get:ccp(up.x, y+movePart)];
					[self moveA: valueTile B: destTile];
				}
				if (movePart == 1) {
					for (int y = down.y - 1; ; y--) {
						Tile *valueTile = [self get: ccp(down.x, y)];
						if (!valueTile || valueTile.kind == -1) {
							break;
						}
						[valueTile.sprite runAction: 	[CCMoveBy actionWithDuration: 0.5F position:ccp(0,movePart*(kTileSize))]];
						Tile *destTile = [self get:ccp(down.x, y+movePart)];
						[self moveA: valueTile B: destTile];
					}
				}
			}else {
				int movePart = 1;
				for (int y= down.y + 1; ; y++) {
					if (y == up.y) {
						movePart = 2;
						continue;
					};
					Tile *valueTile = [self get: ccp(down.x, y)];
					if (!valueTile || valueTile.kind == -1) {
						break;
					}
					[valueTile.sprite runAction: 	[CCMoveBy actionWithDuration: 0.5F position:ccp(0,-movePart*(kTileSize))]];
					Tile *destTile = [self get:ccp(up.x, y-movePart)];
					[self moveA: valueTile B: destTile];
				}
				if (movePart == 1) {
					for (int y= up.x + 1; ; y++) {
						Tile *valueTile = [self get: ccp(up.x, y)];
						if (!valueTile || valueTile.kind == -1) {
							break;
						}
						[valueTile.sprite runAction: 	[CCMoveBy actionWithDuration: 0.5F position:ccp(0,-movePart*(kTileSize))]];
						Tile *destTile = [self get:ccp(up.x, y-movePart)];
						[self moveA: valueTile B: destTile];
					}
				}
			}
		}else {
			int movePart = level.tileMoveType == TileMove_Up ? -1 : 1;
			for (int y= a.y + movePart; ; y+= movePart) {
				Tile *valueTile = [self get: ccp(a.x, y)];
				if (!valueTile || valueTile.kind == -1) {
					break;
				}
				[valueTile.sprite runAction: 	[CCMoveBy actionWithDuration: 0.5F position:ccp(0,-movePart*(kTileSize))]];
				Tile *destTile = [self get:ccp(a.x, y-movePart)];
				[self moveA: valueTile B: destTile];
			}
			for (int y= b.y + movePart; ; y+=movePart) {
				Tile *valueTile = [self get: ccp(b.x, y)];
				if (!valueTile || valueTile.kind == -1) {
					break;
				}
				[valueTile.sprite runAction: 	[CCMoveBy actionWithDuration: 0.5F position:ccp(0,-movePart*(kTileSize))]];
				Tile *destTile = [self get:ccp(b.x, y-movePart)];
				[self moveA: valueTile B: destTile];
			}
		}
		return;
	}
}

-(void) moveA: (Tile *) a B: (Tile *) b{
	b.kind = [a kind];
	b.sprite = [a sprite];
	[a setKind: -1];
	[a setSprite: nil];
	[ballTiles removeObject:a];
	[ballTiles addObject:b];
}

-(void) afterDimiss: (id) node{
	CCNode *ccNode = (CCNode *)node;
	CCNode *parent = [ccNode parent];
	[parent removeChild: node cleanup: YES];
}
@end


