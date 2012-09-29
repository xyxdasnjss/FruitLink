#import "MenuLayer.h"
#import "PlayLayer.h"
#import "HighScoresLayer.h"
#import "CreditsLayer.h"
#import "PauseLayer.h"

@interface SceneManager : NSObject {
}
+(void) goMenu;
+(void) goPlay;
+(void) goLost;
+(void) goHighScores;
+(void) goCredits;
+(void) goPause;
@end
