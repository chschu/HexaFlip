//
//  JCSFlipMainMenuController.m
//  Flip
//
//  Created by Christian Schuster on 17.09.12.
//  Copyright (c) 2012 Christian Schuster. All rights reserved.
//

#import "JCSFlipMainMenuController.h"

@implementation JCSFlipMainMenuController

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
}

#pragma mark UITableViewDataModel

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rows;
    if (section == 0) {
        rows = 1;
    } else if (section == 1) {
        // TODO ask core data about the number of active games
        rows = 4;
    } else if (section == 2) {
        rows = 1;
    } else {
        NSAssert(false, @"illegal section number");
    }
    return rows;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *title;
    if (section == 0) {
        title = nil;
    } else if (section == 1) {
        title = @"Active Games";
    } else if (section == 2) {
        title = @"Build Info";
    } else {
        NSAssert(false, @"illegal section number");
    }
    return title;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier;
    NSInteger section = indexPath.section;
    if (section == 0) {
        identifier = @"NewGameCell";
    } else if (section == 1) {
        identifier = @"ExistingGameCell";
    } else if (section == 2) {
        identifier = @"BuildInfoCell";
    } else {
        NSAssert(false, @"illegal section number");
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (section == 0) {
        // TODO configure cell
    } else if (section == 1) {
        // TODO configure cell
    } else if (section == 2) {
        NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
        cell.textLabel.text = [NSString stringWithFormat:@"Version %@", [info objectForKey:@"CFBundleShortVersionString"]];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"Build %@", [info objectForKey:@"CFBundleVersion"]];
    }
    
    return cell;
}

@end
