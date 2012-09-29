#import "cocos2d.h"
#import "Level.h"
#import "User.h"
#import "Skill.h"

enum GameState {
	GameStateWin,
	GameStateLost,
	GameStatePlaying,
	GameStatePrepare,
	GameStatePause
};

@interface Game : NSObject {
	enum GameState state;
	Level *level;
	int score;
	float usedTime;
	int lastKind;
	int lastKindCount;
	int ballRetainCount;
	
	Skill *_bombSkill;
	Skill *_suffleSkill;
}

@property (nonatomic) enum GameState state;
@property (nonatomic, readonly) Level *level;
@property (nonatomic, readonly) int score;
@property (nonatomic, readonly) float usedTime;
@property (nonatomic, readonly) int lastKind;
@property (nonatomic, readonly) int lastKindCount;
@property (nonatomic, readonly) int ballRetainCount;
@property (nonatomic, retain) Skill *bombSkill;
@property (nonatomic, retain) Skill *suffleSkill;


-(void) notifyNewLink: (int) kind;
-(void) plusUsedTime: (float) delta;
@end
