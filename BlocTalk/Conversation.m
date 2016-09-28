//
//  Conversation.m
//  BlocTalk
//
//  Created by Jonathan on 9/28/16.
//  Copyright © 2016 Bloc. All rights reserved.
//

#import "Conversation.h"
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
        self.messages = [NSArray array];
    }
    
    return self;
}

- (void)addMessageToConversation:(Message *)message {
    [_messages addObject:message];
}
@end
