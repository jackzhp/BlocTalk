//
//  ConversationManager.h
//  BlocTalk
//
//  Created by Jonathan on 9/28/16.
//  Copyright © 2016 Bloc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Conversation, User, MCPeerID;

@interface DataManager : NSObject

@property (nonatomic, strong) NSArray *conversations;
@property (nonatomic, strong) NSArray *users;

+ (instancetype)sharedInstance;
- (void)addConversation:(Conversation *)conversation;
- (void)addUser:(User *)user;

- (User *)userForPeerID:(MCPeerID *)peerID;
- (Conversation *)conversationForPeerId:(MCPeerID *)peerID;

@end
