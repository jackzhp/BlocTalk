//
//  Conversation.m
//  BlocTalk
//
//  Created by Jonathan on 9/28/16.
//  Copyright © 2016 Bloc. All rights reserved.
//

#import "Conversation.h"
#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import "User.h"
#import "Message.h"

@interface Conversation () {
    NSMutableArray *_messagesCache;
}

@end

@implementation Conversation

- (instancetype)initWithPeerID:(MCPeerID *)peerID andMessage:(Message *)message {
    self = [super init];
    
    if (self) {
        self.peerID = peerID;
        if (!self.messagesCache) {
        self.messagesCache = [NSMutableArray array];
        }
        [self addMessageToConversation:message];
    }
    
    return self;
}

- (void)addMessageToConversation:(Message *)message {
    [_messagesCache addObject:message];
}
@end
