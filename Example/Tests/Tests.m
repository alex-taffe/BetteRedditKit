//
//  Tests.m
//  BetteRedditKit_Tests
//
//  Created by Alex Taffe on 6/2/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TOTPGenerator.h"
#import "MF_Base32Additions.h"
#import <BetteRedditKit/BRUser.h>

@interface Tests : XCTestCase

@end

@implementation Tests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


/**
 Make sure that we can properly create a user
 */
-(void)testUserCreation{
    BRUser *user = [[BRUser alloc] init];
    XCTAssertNotNil(user);
}

- (void)testLogin {
    BRUser *user = [[BRUser alloc] init];

    NSBundle *bundle = [NSBundle bundleForClass:[Tests class]];
    NSURL *url = [bundle URLForResource:@"testing-user" withExtension:@"plist"];
    NSDictionary *userDict = [[NSDictionary alloc] initWithContentsOfURL:url];

    user.username = userDict[@"mfaUsername"];

    XCTestExpectation *expectation = [self expectationWithDescription:@"Waiting for login expectation"];

    [user loginUserWithPassword:userDict[@"mfaPassword"] onComplete:^(bool didLogin, bool needsMFA, NSError *error) {
        XCTAssertTrue(needsMFA);
        XCTAssertFalse(didLogin);
        XCTAssertNil(error);

        NSString *secret = userDict[@"mfaSecret"];
        NSData *secretData =  [NSData dataWithBase32String:secret];

        NSInteger digits = 6;
        NSInteger period = 30;
        NSDate *now = [NSDate date];
        long timestamp = (long)[now timeIntervalSince1970];
        if(timestamp % 30 != 0){
            timestamp -= timestamp % 30;
        }

        TOTPGenerator *generator = [[TOTPGenerator alloc] initWithSecret:secretData algorithm:kOTPGeneratorSHA1Algorithm digits:digits period:period];

        NSString *pin = [generator generateOTPForDate:[NSDate dateWithTimeIntervalSince1970:timestamp]];
        NSString *finalPass = [[NSString alloc] initWithFormat:@"%@:%@", userDict[@"mfaPassword"], pin];

        [user loginUserWithPassword:finalPass onComplete:^(bool didLogin, bool needsMFA, NSError *error) {
            XCTAssertFalse(needsMFA);
            XCTAssertTrue(didLogin);
            XCTAssertNil(error);
            [expectation fulfill];
        }];


    }];

    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {

    }];
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}


@end
