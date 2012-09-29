#import "cocos2d.h"

static NSString *DEFAULT_FONT = @"Marker Felt";

CCLabel * ccL(NSString * value, float fontSize){
	return [CCLabel labelWithString:value fontName:DEFAULT_FONT fontSize:fontSize];
}

CCLabel * ccLP(NSString * value, float fontSize, CGPoint pos){
	CCLabel * result = [CCLabel labelWithString:value fontName:DEFAULT_FONT fontSize:fontSize];
	result.position = pos;
	return result;
}
