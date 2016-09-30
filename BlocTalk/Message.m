//
//  Conversation.m
//  BlocTalk
//
//  Created by Jonathan on 9/27/16.
//  Copyright © 2016 Bloc. All rights reserved.
//

#import "Message.h"
#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import "User.h"
#import "DataManager.h"

@implementation Message

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    
    if (self) {
        // users are created first, so should have data in DataManager's users array
        self.user = [[DataManager sharedInstance] userForPeerID:dictionary[@"peerID"]];
//        self.peerID = dictionary[@"peerID"];
        self.timestamp = dictionary[@"timestamp"];
        self.text = dictionary[@"text"];
    }
    
    return self;
}

@end
