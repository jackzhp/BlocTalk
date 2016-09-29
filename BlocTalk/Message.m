//
//  Conversation.m
//  BlocTalk
//
//  Created by Jonathan on 9/27/16.
//  Copyright © 2016 Bloc. All rights reserved.
//

#import "Message.h"
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@implementation Message

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    
    if (self) {
        self.peerID = dictionary[@"peerID"];
        self.timestamp = dictionary[@"timestamp"];
        self.text = dictionary[@"text"];
    }
    
    return self;
}

@end
