//
//  Conversation.h
//  BlocTalk
//
//  Created by Jonathan on 9/28/16.
//  Copyright © 2016 Bloc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class User, MCPeerID, JSQMessage, UIAlertController;

@interface Conversation : NSObject <NSCoding>

@property (nonatomic, strong) User *user;  // who conversation is with
@property (nonatomic, strong) NSArray *messages;
@property (nonatomic, assign) BOOL isArchived;

- (instancetype)initWithUser:(User *)user;

- (void)addMessage:(JSQMessage *)message;
- (void)removeMessage:(JSQMessage *)message;

- (UIAlertController *)getAlertController;

@end
