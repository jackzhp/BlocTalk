//
//  Conversation.h
//  BlocTalk
//
//  Created by Jonathan on 9/27/16.
//  Copyright © 2016 Bloc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class User, MCPeerID;

@interface Message : NSObject <NSCoding>

@property (nonatomic, strong) User *user;
//@property (nonatomic, strong) MCPeerID *peerID;
@property (nonatomic, strong) NSDate *timestamp;
@property (nonatomic, strong) NSString *text;

- (instancetype)initWithPeerID:(MCPeerID *)peerId messageText:(NSString *)text andTimestamp:(NSDate *)timestamp;
- (instancetype)initWithUser:(User *)user messageText:(NSString *)text andTimestamp:(NSDate *)timestamp;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
