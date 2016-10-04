//
//  ConnectedPeersTableViewController.m
//  BlocTalk
//
//  Created by Jonathan on 9/28/16.
//  Copyright © 2016 Bloc. All rights reserved.
//

#import "ConnectedPeersTableViewController.h"
#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import "MPCHandler.h"
#import "User.h"
#import "Conversation.h"
#include "ConversationDetailViewController.h"
#include "DataManager.h"

@interface ConnectedPeersTableViewController ()

@end

@implementation ConnectedPeersTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(peerDidChangeStateWithNotification:)
                                                 name:@"MPCHandlerDidChangeStateNotification"
                                               object:nil];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)peerDidChangeStateWithNotification:(NSNotification *)notification{
//    MCPeerID *peerID = [[notification userInfo] objectForKey:@"peerID"];
//    NSString *peerDisplayName = peerID.displayName;
//    MCSessionState state = [[[notification userInfo] objectForKey:@"state"] intValue];
//    
//    NSLog(@"peer %@:%@ (%ld)",peerID,peerDisplayName,(long)state);
//    if (state != MCSessionStateConnecting) {
//        if (state == MCSessionStateConnected) {
//            NSLog(@"Peer connected in TableViewController!");
//            [self.connectedPeers addObject:peerDisplayName];
//            //TODO: show alert to user with connnected peer's name?
//        }
//        else if (state == MCSessionStateNotConnected){
//            if ([self.connectedPeers count] > 0) {
//                NSLog(@"Peer NOT connected in TableViewController!");
//                NSUInteger indexOfPeer = [self.connectedPeers indexOfObject: peerDisplayName];
//                [self.connectedPeers removeObjectAtIndex:indexOfPeer];
//            }
//        }
//    }
        [self.tableView reloadData];

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSInteger numberOfRows = [MPCHandler sharedInstance].activePeers.count;
    NSLog(@"Tableview should have %ld rows", (long)numberOfRows);
    return numberOfRows;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PeerViewCell" forIndexPath:indexPath];
    
    // Configure the cell...
    User *user =[MPCHandler sharedInstance].activePeers[indexPath.row];
    cell.textLabel.text = user.userName;
    cell.detailTextLabel.text = [NSDate date].description;
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"showConversationDetailFromPeerList"]) {
        ConversationDetailViewController *conversationDetailVC = [segue destinationViewController];
        // figure out how to generate a unique senderID that is the same across reboots
        conversationDetailVC.senderId = self.user.userName;
        conversationDetailVC.senderDisplayName = self.user.userName;
        NSIndexPath *path = [self.tableView indexPathForCell:sender];
        User *user =[MPCHandler sharedInstance].activePeers[path.row];
        Conversation *conversation = [[DataManager sharedInstance] conversationForPeerId:user.peerID];
    
        if (!conversation) {
            conversation = [[Conversation alloc] initWithUser:user];
        }
        conversationDetailVC.conversation = conversation;
    }

}


@end
