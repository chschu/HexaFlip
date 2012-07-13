//
//  main.m
//  Flip
//
//  Created by Christian Schuster on 13.07.12.
//  Copyright Christian Schuster 2012. All rights reserved.
//

#import <UIKit/UIKit.h>

int main(int argc, char *argv[]) {
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    int retVal = UIApplicationMain(argc, argv, nil, @"AppController");
    [pool release];
    return retVal;
}
