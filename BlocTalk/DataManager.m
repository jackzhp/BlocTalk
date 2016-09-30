//
//  ConversationManager.m
//  BlocTalk
//
//  Created by Jonathan on 9/28/16.
//  Copyright © 2016 Bloc. All rights reserved.
//

#import "DataManager.h"
#import "Conversation.h"
#import "Message.h"
#import "User.h"
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@implementation DataManager {
    NSMutableArray *_conversations;
    NSMutableArray *_users;
}

+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    
    if (self) {
        
        self.conversations = [NSMutableArray arrayWithCapacity:1];
        self.users = [NSMutableArray arrayWithCapacity:1];
    }
    
    return self;
}

- (User *)userForPeerID:(MCPeerID *)peerID {
    for (User *user in self.users) {
        if ([user.peerID.displayName isEqualToString:peerID.displayName]) {
            return user;
        }
    }
    
    // user not found
    return nil;
}

- (Conversation *)conversationForPeerId:(MCPeerID *)peerID {
    for (Conversation *conversation in self.conversations) {
        if ([conversation.user.peerID.displayName isEqualToString:peerID.displayName]) {
            return conversation;
        }
    }
    
    // conversation not found
    return nil;
}

//- (void)addConversationWithDictionary:(NSDictionary *)dictionary andCompletionHandler:(void (^)(NSError *))block {
//    
//    NSDate *messageDate = [NSDate date];
//    NSDictionary *messageDict = @{@"peerID" : dictionary[@"peerID"], @"timestamp" : messageDate, @"text" : dictionary[@"textData"]};
//    Message *message = [[Message alloc] initWithDictionary:messageDict];
////    Conversation *conversation = [[Conversation alloc] initWithPeerID:dictionary[@"peerID"] andMessage:message];
////    [self addConversation:conversation];
//    
//    block(nil);
//}

- (void)addConversation:(Conversation *)conversation {
    [_conversations addObject:conversation];
}

@end
