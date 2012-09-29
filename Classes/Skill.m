#import "Skill.h"


@implementation Skill
@synthesize assItem;
-(id) initWithChart: (Chart *) aChart linkDelegate: (id<LinkDelegate>) aLinkDelegate{
	self = [super init];
	linkDelegate = aLinkDelegate;
	chart = aChart;
	return self;
}
-(void) run: (id) sender{

	CCMenuItemImage *item = (CCMenuItemImage *)sender;
	
	CCMenu *menu = (CCMenu *)[item parent];

	CGPoint position = ccpAdd(item.position, menu.position);
	
	CCLayer *layer = (CCLayer *)linkDelegate;
	CCProgressTimer *timer = [CCProgressTimer progressWithFile:@"progress.png"];
	[item setIsEnabled: NO];
	CCSequence *action = [CCSequence actions:
		[CCProgressTo actionWithDuration:coldTimeMax percent:100.f],
		[CCCallFuncN actionWithTarget:self  selector:@selector(afterProgress:)],
	 nil];
	
	timer.type = kCCProgressTimerTypeHorizontalBarRL;
	timer.position = position;
	timer.percentage = 0.0f;
	[layer addChild: timer z:3];
	
	[timer runAction: action];
}

-(void) afterProgress: (id) node{
	CCLayer *layer = (CCLayer *)linkDelegate;
	[layer removeChild:node cleanup:YES];
	[assItem setOpacity:255];
	[assItem setIsEnabled: YES];
}
@end


@implementation Bomb
-(void) run: (id) sender{
	[super run: sender];
	int ballTilesCount = [chart.ballTiles count];
	if (ballTilesCount  < 2) {
		return;
	}

	int firstRandom = arc4random() % ballTilesCount;
	Tile *firstTile = [chart.ballTiles objectAtIndex: firstRandom];	

	for (int i=0; i< ballTilesCount; i++) {
		Tile *tile = [chart.ballTiles objectAtIndex: i];
		if (tile == firstTile) {
			continue;
		}
		if (tile.kind != firstTile.kind) {
			continue;
		}
		[linkDelegate ballConnectedA: firstTile B: tile];
		return;
	}
}
@end

@implementation Suffle
	-(void) run: (id) sender{
		[super run: sender];
		 int retainCount = [chart.ballTiles count];
		 if (retainCount  < 4) {
			 return;
		 }
		 
		 NSMutableArray *indexArray = [NSMutableArray arrayWithCapacity: retainCount];
		 for (int i=0; i<retainCount; i++) {
			 [indexArray addObject: [NSNumber numberWithInt:i]];
		 }
		 
		 while([indexArray count] > 0){
			 int firstRandom = arc4random() % [indexArray count];
			 int firstValue = [[indexArray objectAtIndex: firstRandom] intValue];
			 Tile *firstTile = (Tile *)[chart.ballTiles objectAtIndex: firstValue];
			 CCSprite *firstSprite = firstTile.sprite;
			 [indexArray removeObjectAtIndex: firstRandom];
			 int secondRandom = arc4random() % [indexArray count];
			 int secondValue = [[indexArray objectAtIndex: secondRandom] intValue]; 
			 [indexArray removeObjectAtIndex: secondRandom];
			 Tile *secondTile = [chart.ballTiles objectAtIndex: secondValue];
			 CCSprite *secondSprite = secondTile.sprite; 
			 
			 int kindTemp = firstTile.kind;
			 firstTile.kind = secondTile.kind;
			 secondTile.kind = kindTemp;

			 firstTile.sprite = secondSprite;
			 secondTile.sprite = firstSprite;
			 
			 [firstSprite runAction: [CCMoveTo actionWithDuration:1.0f position: secondSprite.position]];
			 [secondSprite runAction: [CCMoveTo actionWithDuration:1.0f position: firstSprite.position]];
		 }
		 
	 }
@end