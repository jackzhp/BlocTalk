//
//  Conversation.h
//  BlocTalk
//
//  Created by Jonathan on 9/27/16.
//  Copyright © 2016 Bloc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class User;

@interface Message : NSObject

@property (nonatomic, strong) User *fromUser;
@property (nonatomic, strong) User *toUser;
@property (nonatomic, strong) NSDate *timestamp;
@property (nonatomic, strong) NSString *text;

@end
