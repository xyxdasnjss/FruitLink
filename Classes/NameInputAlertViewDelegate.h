#import "Record.h"
#import "User.h"
#import "SceneManager.h"
@interface NameInputAlertViewDelegate : NSObject<UIAlertViewDelegate> {
}
+(NSObject<UIAlertViewDelegate> *) instance;
+(void) showWinView;
@end
