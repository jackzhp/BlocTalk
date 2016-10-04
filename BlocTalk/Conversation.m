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
#import <JSQMessages.h>

@interface Conversation () {
    NSMutableArray *_messages;
}

@end

@implementation Conversation

- (instancetype)initWithUser:(User *)user {
    self = [super init];
    
    if (self) {
        self.user = user;
        self.isArchived = NO;  // set default to no
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

#pragma mark - NSCoding

- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    
    if (self) {
        self.user = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(user))];
        self.messages = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(messages))];
        self.isArchived = [aDecoder decodeBoolForKey:NSStringFromSelector(@selector(isArchived))];
    }
    
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.user forKey:NSStringFromSelector(@selector(user))];
    [aCoder encodeObject:self.messages forKey:NSStringFromSelector(@selector(messages))];
    [aCoder encodeBool:self.isArchived forKey:NSStringFromSelector(@selector(isArchived))];
}


@end
