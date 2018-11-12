//
//  BRUser.h
//  AFNetworking
//
//  Created by Alex Taffe on 6/2/18.
//

#import <Foundation/Foundation.h>

@interface BRUser : NSObject

@property (strong, nonatomic) NSString *username;

-(void)loadUserDetails:(void (^)(void))onComplete;

@end
