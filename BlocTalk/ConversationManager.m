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
        [self registerForDataReceivedNotification];
    }
    
    return self;
}

- (void)registerForDataReceivedNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(processNewData:)
                                                 name:@"MPCHandlerDidReceiveDataNotification"
                                               object:nil];

}

- (void)processNewData:(NSNotification *)notification {
    
    NSDate *messageDate = [NSDate date];
    NSDictionary *messageDict = @{@"peerID" : notification.userInfo[@"peerID"], @"timestamp" : messageDate, @"text" : notification.userInfo[@"textData"]};
    Message *message = [[Message alloc] initWithDictionary:messageDict];
    Conversation *conversation = [[Conversation alloc] initWithPeerID:notification.userInfo[@"peerID"] andMessage:message];
    [self addConversation:conversation];
    
}

- (void)addConversation:(Conversation *)conversation {
    [_conversations addObject:conversation];
}

@end
