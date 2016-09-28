//
//  User.h
//  BlocTalk
//
//  Created by Jonathan on 9/27/16.
//  Copyright © 2016 Bloc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class MCPeerID;

@interface User : NSObject

@property (nonatomic, strong) MCPeerID *peerID;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *profileImageName;

@end
