#import "Game.h"
#import "Chart.h"
#import "SceneManager.h"
#import "LinkDelegate.h"
#import "Record.h"
#import "constants.h"
#import "BaseLayer.h"
#import "NameInputAlertViewDelegate.h"
#import "MusicHandler.h"

#define kScheduleInterval 0.5f
#define kTimeLabelTag 900
#define kScoreLabelTag 901
#define kComboTag 902
#define kComboNOTag 903
#define kStartHint 904
#define kMenuTag 905
@interface PlayLayer : BaseLayer<LinkDelegate>{
	Chart				*chart;
	Game				*game;
	Tile				*selectedTile;
	int					startHintIndex;
	NSArray				*startHintArray;
}
@end
