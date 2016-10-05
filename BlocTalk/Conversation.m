//
//  Conversation.m
//  BlocTalk
//
//  Created by Jonathan on 9/28/16.
//  Copyright © 2016 Bloc. All rights reserved.
//

#import "Conversation.h"
#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import "DataManager.h"
#import "User.h"
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
    }
    
    return self;
}

- (void)addMessage:(JSQMessage *)message {
    [_messages addObject:message];
    [[DataManager sharedInstance] saveData];
}

- (void)removeMessage:(JSQMessage *)message {
    [_messages removeObject:message];
    [[DataManager sharedInstance] saveData];
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
