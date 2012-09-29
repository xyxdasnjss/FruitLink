#import "Chart.h"
#import "LinkDelegate.h"
#import "cocos2d.h"
#define coldTimeMax 10
@interface Skill : NSObject{
	Chart *chart;
	id <LinkDelegate> linkDelegate;
	CCMenuItemFont *assItem;
}
@property (nonatomic, assign) CCMenuItemFont *assItem;
-(id) initWithChart: (Chart *) aChart linkDelegate: (id<LinkDelegate>) aLinkDelegate;
-(void) run: (id) sender;
@end


@interface Bomb : Skill {
}
@end

@interface Suffle : Skill {

}
@end

