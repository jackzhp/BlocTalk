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
    NSMutableArray *_messages;
}

@end

@implementation Conversation

- (instancetype)initWithUser:(User *)user {
    self = [super init];
    
    if (self) {
        self.user = user;
        if (!self.messages) {
        self.messages = [NSMutableArray arrayWithCapacity:1];
        }
//        [self addMessageToConversation:message];
    }
    
    return self;
}

- (void)addMessage:(Message *)message {
    [_messages addObject:message];
}

- (void)removeMessage:(Message *)message {
    [_messages removeObject:message];
}
@end
