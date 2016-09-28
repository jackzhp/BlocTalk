//
//  ConversationManager.m
//  BlocTalk
//
//  Created by Jonathan on 9/28/16.
//  Copyright © 2016 Bloc. All rights reserved.
//

#import "ConversationManager.h"
#import "Conversation.h"
#import "Message.h"
#import "User.h"


@implementation ConversationManager {
    NSMutableArray *_conversations;
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
        
        self.conversations = [NSMutableArray array];
    }
    
    return self;
}

- (void)addConversation:(Conversation *)conversation {
    [_conversations addObject:conversation];
}

@end
