#import "cocos2d.h"


typedef enum _TileMoveType {
	TileMove_NoMove = 0,
	TileMove_Up = 1,
	TileMove_Down = 2,
	TileMove_Left = 3,
	Tilemove_Right = 4,
	TileMove_Max = 5
} TileMoveType;

@interface Level : NSObject {
	int no;
	int factor;
	TileMoveType tileMoveType;
	int timeLimit;
	int tileCount;
	int ballCount;
}
@property (nonatomic) int no;
@property (nonatomic) int factor;
@property (nonatomic) TileMoveType tileMoveType;
@property (nonatomic) int timeLimit;
@property (nonatomic, readonly) int tileCount;
@property (nonatomic, readonly) int ballCount;

-(BOOL) fillWithColumn: (int) columnIndex row: (int) rowIndex;
-(int) ballCountRepaired;
@end

@interface LevelManager : NSObject {
}
+(Level *) get:(int) no;

@end;