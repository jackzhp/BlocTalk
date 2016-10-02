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

- (instancetype)initWithPeerID:(MCPeerID *)peerId messageText:(NSString *)text andTimestamp:(NSDate *)timestamp {
    self = [super init];
    
    if (self) {
        // users are created first, so should have data in DataManager's users array
        self.user = [[DataManager sharedInstance] userForPeerID:peerId];
        self.text = text;
        self.timestamp = timestamp;
    }
    
    return self;
}

- (instancetype)initWithUser:(User *)user messageText:(NSString *)text andTimestamp:(NSDate *)timestamp {
    self = [super init];
    
    if (self) {
        self.user = user;
        self.text = text;
        self.timestamp = timestamp;
    }
    
    return self;
}

#pragma mark - NSCoding

- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    
    if (self) {
        self.user = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(user))];
        self.text = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(text))];
        self.timestamp = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(timestamp))];
    }
    
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.user forKey:NSStringFromSelector(@selector(user))];
    [aCoder encodeObject:self.text forKey:NSStringFromSelector(@selector(text))];
    [aCoder encodeObject:self.timestamp forKey:NSStringFromSelector(@selector(timestamp))];
}


@end
