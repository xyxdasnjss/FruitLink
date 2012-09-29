#import "CreditsLayer.h"


@implementation CreditsLayer
-(id) init{
	self = [super init];
	if (!self) {
		return nil;
	}
	
	CCSprite *bg = [CCSprite spriteWithFile: @"backgroud.png"];
	bg.position = ccp(240,160);
	[self addChild: bg z: 0];
	
	
	CCMenuItemFont *back = [CCMenuItemFont itemFromString:@"back" target:self selector: @selector(back:)];
	CCMenu *menu = [CCMenu menuWithItems: back, nil];
	menu.position = ccp(240, 70);
	[self addChild: menu];
	return self;
}

-(void) back: (id) sender{
	[SceneManager goMenu];
}

@end
