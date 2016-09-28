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
    
    // Make a circular profile image
    self.profileImageView.layer.cornerRadius = 24;
    
    // these two lines remove the inset from the textview so it is easier to line things up in the cell
    CGFloat inset = self.conversationTextView.textContainer.lineFragmentPadding;
    self.conversationTextView.textContainerInset = UIEdgeInsetsMake(0, -inset, 0, -inset);
    
    // give a slightly rounded look to the cells
    self.layer.cornerRadius = 5;
}

@end
