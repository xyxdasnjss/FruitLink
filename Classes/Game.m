#import "Game.h"


@implementation Game

@synthesize state;
@synthesize level;
@synthesize score;
@synthesize usedTime;
@synthesize lastKind;
@synthesize lastKindCount;
@synthesize ballRetainCount;
@synthesize bombSkill;
@synthesize suffleSkill;

-(id) init{
	self = [super init];
	
	level = [LevelManager get: [User nextLevel]];
	ballRetainCount = [level ballCountRepaired];
	state = GameStatePrepare;
	usedTime = [level timeLimit];
	score = 0;
	lastKind = -1;
	lastKindCount = 0;
	return self;
}

-(void) notifyNewLink: (int) kind{
	ballRetainCount -= 2;
	if (kind == lastKind) {
		lastKindCount += 1;
	}else {
		lastKind = kind;
		lastKindCount = 1;
	}
	score += lastKindCount * 50;
	
	if (ballRetainCount == 0) {
		state = GameStateWin;
	}
	
}
-(void) plusUsedTime: (float) delta{
	usedTime-= delta;
	if (usedTime <= 0) {
		state = GameStateLost;
	}
}

@end
