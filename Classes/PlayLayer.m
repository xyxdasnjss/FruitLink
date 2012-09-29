#import "PlayLayer.h"

extern CCLabel * ccLP(NSString * value, float fontSize, CGPoint pos);
@interface PlayLayer ()
-(void) initBallsSprite;
-(void) initNumberLabel;
-(void) initMenu;
-(void) showStartHint;
-(void) startHintCallback: (id) sender;
-(void) goNextLevel;
@end

@implementation PlayLayer

#pragma mark init part
-(id) init {
	if( (self=[super init] )) {
		game  = [[Game alloc] init];
		chart = [[Chart alloc] initWith: [game level]];

		
		Skill *bombSkill = [[Bomb alloc] initWithChart:chart linkDelegate:self];
		Skill *suffleSkill = [[Suffle alloc] initWithChart:chart linkDelegate:self];
		
		game.bombSkill = bombSkill;
		game.suffleSkill = suffleSkill;

		[game setState: GameStatePrepare];
		startHintIndex = 0;
		startHintArray = [NSArray arrayWithObjects:
							[NSString stringWithFormat:@"Level %d",[game.level no]],@"Ready",@"Go",nil];
		[startHintArray retain];
		
		self.isTouchEnabled = NO;
		[self initBallsSprite];
		[self initNumberLabel];
		[self initMenu];
	}
	
	return self;
}

-(void) initBallsSprite{
	for (int y=0; y<kRowCount; y++) {
		for (int x=0; x<kColumnCount; x++) {
			Tile *tile = [chart get: ccp(x,y)];
			int posX = (x-1)*kTileSize + kLeftPadding + kTileSize/2;
			int posY = (y-1)*kTileSize + kTopPadding + kTileSize/2;
			
			if (tile.kind < 0) {
				continue;
			}
			
			NSString *imageName = [NSString stringWithFormat: @"q%d.png", tile.kind];
			tile.sprite = [CCSprite spriteWithFile:imageName];
			tile.sprite.scaleX = kDefaultScaleX;
			tile.sprite.scaleY = kDefaultScaleY;
			tile.sprite.position = ccp(posX, posY);
			[self addChild: tile.sprite z: 3];
		}
	}
}

-(void) initNumberLabel{
	{
		CCLabel *scoreValueLabel = 	ccLP(@"0", 28.0f, ccp(50,225));
		[self addChild: scoreValueLabel z:1 tag:kScoreLabelTag];	
	}

	{
		int time = [game.level timeLimit];
		NSString *timeValueString = [NSString stringWithFormat: @"%d", time];
		CCLabel *timeValueLabel = 	ccLP(timeValueString, 28.0f, ccp(50,275));
		[self addChild: timeValueLabel z:1 tag:kTimeLabelTag];
	}
	
	{	
		
		CCLabel *timeLabel = ccLP(@"time", 28.0f, ccp(50,300));
		[self addChild:timeLabel];
	}
	
	{
		CCLabel *scoreLabel = ccLP(@"score", 28.0f, ccp(50,250));
		[self addChild:scoreLabel];
	}
	
}

-(void) initMenu{
	CCMenuItemFont *bombItem = [CCMenuItemFont itemFromString:@"Bomb" target:game.bombSkill selector: @selector(run:)];
	CCMenuItemFont *suffleItem = [CCMenuItemFont itemFromString:@"Suffle" target:game.suffleSkill selector: @selector(run:)];
	CCMenuItemFont *stopItem = [CCMenuItemFont itemFromString:@"Pause" target:self selector: @selector(goPause:)];
	
	game.bombSkill.assItem = bombItem;
	game.suffleSkill.assItem = suffleItem;
	
	CCMenu *menu = [CCMenu menuWithItems:bombItem, suffleItem, stopItem, nil];
	[menu alignItemsVerticallyWithPadding: -1];
	menu.position = ccp(-100,65);
	[self addChild:menu z: 2 tag: kMenuTag];
}

-(void) goPause: (id) sender{
	[SceneManager goPause];
}

#pragma mark inherit method
-(void) onEnterTransitionDidFinish{
	[super onEnterTransitionDidFinish];
	if(startHintArray){
		[self showStartHint];
	}
}

-(void) onEnter{
	[super onEnter];
	if (!startHintArray) {
		[self schedule:@selector(checkGameState) interval: kScheduleInterval];	
	}
}
-(void) onExit{
	[super onExit];
	[self unschedule:@selector(checkGameState)];
}

#pragma mark custom method
-(void) showStartHint{
	if (startHintIndex >= [startHintArray count]) {
		[self schedule:@selector(checkGameState) interval: kScheduleInterval];
		[startHintArray release];
		startHintArray = nil;
		[game setState:GameStatePlaying];
		self.isTouchEnabled = YES;
		CCNode *menu = [self getChildByTag:kMenuTag];
		[menu runAction:[CCMoveTo actionWithDuration:0.5F position:ccp(50,65)]];
	}else {
		NSString *hintText = [startHintArray objectAtIndex:startHintIndex];		
		
		CCLabel *label = ccLP(hintText, 30.0f, ccp(240,160));
		label.opacity = 170;
		CCAction *action = [CCSequence actions:
							[CCSpawn actions:
							 [CCScaleTo actionWithDuration:0.8f scaleX:2.5f scaleY:2.5f],
							 [CCSequence actions: 
							  [CCFadeTo actionWithDuration: 0.6f opacity:255],
							  [CCFadeTo actionWithDuration: 0.2f opacity:128],
							  nil],
							 nil],
							[CCCallFuncN actionWithTarget:self  selector:@selector(startHintCallback:)],
							nil
							];
		[self addChild:label z:5 tag: kStartHint];
		[label runAction: action];		
		startHintIndex++;
	}
}

-(void) startHintCallback: (id) sender{
	[self removeChild:sender cleanup:YES];
	[self showStartHint];
}

-(void) dealloc{
	[super dealloc];
	[game release];
	[chart release];
}


-(void) checkGameState{
	if (game.state == GameStateWin) {
		[self unschedule:@selector(checkGameState)];
		CCLabel *levelClear = ccLP(@"Level Clear", 28.0f, ccp(240, 160));
		levelClear.opacity = 60;
		[self addChild: levelClear z: 5];
		[levelClear runAction: [CCSequence actions:
							 [CCFadeTo actionWithDuration:0.5f opacity:244],
							 [CCDelayTime actionWithDuration:1.0f],
							 [CCCallFunc actionWithTarget:self selector:@selector(goNextLevel)],
							 nil]];
		return;
	}
	
	[game plusUsedTime:kScheduleInterval];
	if (game.state == GameStateLost) {
		[self unschedule:@selector(checkGameState)];
		
		CCLabel *timerUp = ccLP(@"Time Out", 28.0f, ccp(240, 160));
		timerUp.opacity = 60;
		[self addChild: timerUp z: 5];
		[timerUp runAction: [CCSequence actions:
							 [CCFadeTo actionWithDuration:0.5f opacity:244],
							 [CCDelayTime actionWithDuration:1.0f],
							 [CCCallFunc actionWithTarget:self selector:@selector(goNextLevel)],
							 nil]];
		 
		return;
	}else {
		NSString *timeString = [NSString stringWithFormat:@"%d", [game usedTime]];
		CCLabel *timeLabel = (CCLabel *)[self getChildByTag:kTimeLabelTag];
		[timeLabel setString:timeString];
	}
}

-(void) goNextLevel{
	if (GameStateLost == game.state) {
		[SceneManager goMenu];
	}else {
		[User saveScore: game.score + [User score]];
		[User saveWinedLevel: [game.level no]];
		[User saveUsedTime: game.usedTime];
		
		if([game.level no] == kMaxLevelNo){	
			[NameInputAlertViewDelegate showWinView];
		}else{
			[SceneManager goPlay];		
		}		
	}
}

-(void) ballConnectedA: (Tile *) aTile B: (Tile *) bTile{
	int fireKind = aTile.kind;
	{
		[chart dismissTile: aTile];
		[chart dismissTile: bTile];
	}
	[MusicHandler notifyConnect];
	
	int scorePrevious = game.score;
	[game notifyNewLink: fireKind];
	
	int kindCount =game.lastKindCount;
	int kind = game.lastKind;
	int scoreAdd = game.score - scorePrevious;
	
	NSString *scoreAddString = [NSString stringWithFormat:@"%d", scoreAdd];
	CCLabel *scoreAddLabel = ccLP(scoreAddString, 18.0f, ccp(55,160));
	scoreAddLabel.scaleX = 1.0f+kindCount/4;
	scoreAddLabel.scaleY = 1.0f+kindCount/4;
	[self addChild: scoreAddLabel z:1];
	CCAction *action = [CCSequence actions:
						[CCSpawn actions:
						 [CCMoveTo actionWithDuration: 1.0F position:ccp(55,225)],
						 [CCFadeOut actionWithDuration: 1.0F ],
						 nil],
						[CCCallFuncN actionWithTarget: self selector: @selector(scoreAddLabelActionDone:)],				
						nil];
	[scoreAddLabel runAction: action]; 
	
	if (kindCount==1) {
		CCSprite *previousComboSprite = (CCSprite *)[self getChildByTag: kComboTag];
		if (previousComboSprite) {
			[self removeChild: previousComboSprite cleanup: YES];
		}
		NSString *imageName = [NSString stringWithFormat:@"q%d.png", kind]; 
		CCSprite *comboSprite = [CCSprite spriteWithFile: imageName];
		
		comboSprite.scaleX = kDefaultScaleX*1.2;
		comboSprite.scaleY = kDefaultScaleY*1.2;
		comboSprite.tag = kComboTag;
		comboSprite.position = ccp(35,160);
		[self addChild: comboSprite z:1];
	}
	
	CCLabel *comboNoLabel = (CCLabel *)[self getChildByTag: kComboNOTag];
	if (!comboNoLabel) {
		comboNoLabel = ccLP(@"0", 24.0F, ccp(70,160));
		comboNoLabel.tag = kComboNOTag;
		[self addChild: comboNoLabel z:1];
	}
	[comboNoLabel setString: [NSString stringWithFormat:@"X %d", kindCount]];
	
	[chart packA: aTile B: bTile];	
}

- (void)ccTouchesBegan:(NSSet*)touches withEvent:(UIEvent*)event{
	UITouch* touch = [touches anyObject];
	CGPoint location = [touch locationInView: touch.view];
	location = [[CCDirector sharedDirector] convertToGL: location];

	
	int x = (location.x -kLeftPadding) / kTileSize + 1;
	int y = (location.y -kTopPadding) / kTileSize + 1;

	
	if (x == selectedTile.x && y== selectedTile.y) {
		return;
	}
	
	Tile *tile = [chart get: ccp(x,y)];
	if (!tile) {
		return;
	}
	
	if(tile.kind < 0){
		return;
	}
	if (selectedTile && [chart isConnectStart: tile end:  selectedTile]) {	
		[self ballConnectedA: selectedTile B:tile];
		selectedTile = nil;
	}else{
		
		CCSprite *sprite = tile.sprite;
		sprite.scaleX = kDefaultScaleX;
		sprite.scaleY = kDefaultScaleY;
		CCSequence *someAction = [CCSequence actions: 
								   [CCScaleBy actionWithDuration:0.5f scale:0.5f],
								   [CCScaleBy actionWithDuration:0.5f scale:2.0f],
								   [CCCallFuncN actionWithTarget:self selector:@selector(afterOneShineTrun:)],
								   nil];
		selectedTile = tile;
		[sprite runAction:someAction];
	}
}

//TODO rename
-(void) scoreAddLabelActionDone: (id) node{
	CCLabel *scoreLabel = (CCLabel *)[self getChildByTag: kScoreLabelTag];
	[scoreLabel setString: [NSString stringWithFormat:@"%d", game.score]];
		
}

//TODO  try another way
-(void)afterOneShineTrun: (id) node{
	if (selectedTile && node == selectedTile.sprite) {
		CCSprite *sprite = (CCSprite *)node;
		CCSequence *someAction = [CCSequence actions: 
								  [CCScaleBy actionWithDuration:0.5f scale:0.5f],
								  [CCScaleBy actionWithDuration:0.5f scale:2.0f],
								  [CCCallFuncN actionWithTarget:self selector:@selector(afterOneShineTrun:)],
								  nil];
		
		[sprite runAction:someAction];
	}
}
@end
