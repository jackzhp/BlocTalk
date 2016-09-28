//
//  Conversation.h
//  BlocTalk
//
//  Created by Jonathan on 9/28/16.
//  Copyright © 2016 Bloc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class User, Message;

@interface Conversation : NSObject

@property (nonatomic, strong) User *user;
@property (nonatomic, strong) NSArray *messages;

- (instancetype)initWithUser:(User *)user;

- (void)addMessageToConversation:(Message *)message;

@end
