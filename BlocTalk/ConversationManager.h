//
//  ConversationManager.h
//  BlocTalk
//
//  Created by Jonathan on 9/28/16.
//  Copyright © 2016 Bloc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Conversation;

@interface ConversationManager : NSObject

@property (nonatomic, strong) NSArray *conversations;

+ (instancetype)sharedInstance;
- (void)addConversation:(Conversation *)conversation;

@end
