#import "NameInputAlertViewDelegate.h"

static NSObject<UIAlertViewDelegate> *instance = nil;

@implementation NameInputAlertViewDelegate

+(NSObject<UIAlertViewDelegate> *) instance{
	if (instance == nil) {
		instance = [[NameInputAlertViewDelegate alloc] init];
	}
	return instance;
}

-(id) retain{
	return self;
}


-(void) release{
}

-(id) autorelease{
	return self;
}


+(void) showWinView{
	NSString *title = @"Congratulation";
	NSString *message = @"type your name";
	UIView *view = [[CCDirector sharedDirector] openGLView];
	UIAlertView *alertView = [[UIAlertView alloc] 
							 initWithTitle:title 
							 message:message 
							 delegate:[NameInputAlertViewDelegate instance] 
							 cancelButtonTitle:@"Enter" 
							 otherButtonTitles:nil];
	[alertView autorelease];
	[view addSubview: alertView];
	[alertView show];
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
	UITextField *field = (UITextField *)[alertView viewWithTag:99];
	[User saveName:[field text]];
	
	Record *record = [Record createCurrentRecord];
	[Record trySaveTimeRecord:record];
	[Record trySaveScoreRecord:record];
	[record release];
	
	[SceneManager goHighScores];
}

- (void)willPresentAlertView:(UIAlertView *)alertView{
	CGRect frame = alertView.frame;
	frame.origin.y -= 70;
	frame.size.height += 30;
	alertView.frame = frame;
	for( UIView * view in alertView.subviews )
	{
		if( ![view isKindOfClass:[UILabel class]] )
		{
			if (view.tag==1)
			{
				CGRect btnFrame1 =CGRectMake(100, frame.size.height-75, 105, 40);
				view.frame = btnFrame1;
				
			}
		}
	}
	
	//加入自訂的label及UITextFiled
	UILabel *nameLabel=[[UILabel alloc] initWithFrame:CGRectMake( 30, 50,60, 30 )];;
	nameLabel.text=@"name";
	nameLabel.backgroundColor=[UIColor clearColor];
	nameLabel.textColor=[UIColor whiteColor];
	
	UITextField *nameValue = [[UITextField alloc] initWithFrame: CGRectMake( 85, 50,160, 30 )];   
	nameValue.placeholder = @"your name";
	nameValue.tag = 99;
	nameValue.borderStyle=UITextBorderStyleRoundedRect;
	
	
	[alertView addSubview:nameLabel];
	[alertView addSubview:nameValue];         
}

@end
