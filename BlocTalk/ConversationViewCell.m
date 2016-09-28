//
//  ConversationViewCell.m
//  BlocTalk
//
//  Created by Jonathan on 9/27/16.
//  Copyright © 2016 Bloc. All rights reserved.
//

#import "ConversationViewCell.h"

@implementation ConversationViewCell

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.profileImageView.layer.cornerRadius = 24;
    
    CGFloat inset = self.conversationTextView.textContainer.lineFragmentPadding;
    self.conversationTextView.textContainerInset = UIEdgeInsetsMake(0, -inset, 0, -inset);
}

@end
