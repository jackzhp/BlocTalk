//
//  Conversation.h
//  BlocTalk
//
//  Created by Jonathan on 9/28/16.
//  Copyright © 2016 Bloc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class User, Message, MCPeerID;

@interface Conversation : NSObject

//@property (nonatomic, strong) User *user;
@property (nonatomic, strong) MCPeerID *peerID;
@property (nonatomic, strong) NSArray *messagesCache;

//- (instancetype)initWithUser:(User *)user;
- (instancetype)initWithPeerID:(MCPeerID *)peerID andMessage:(Message *)message;

- (void)addMessageToConversation:(Message *)message;

@end
