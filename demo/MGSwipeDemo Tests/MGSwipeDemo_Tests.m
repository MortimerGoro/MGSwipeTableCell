//
//  MGSwipeDemo_Tests.m
//  MGSwipeDemo Tests
//
//  Created by YPL on 14-9-4.
//  Copyright (c) 2014年 Imanol Fernandez Gorostizaga. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface MGSwipeDemo_Tests : XCTestCase

@end

@implementation MGSwipeDemo_Tests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

- (void)testArray{
    NSArray *arr = [NSArray arrayWithObjects:@"1",@"2",@"3", nil];
    XCTAssertTrue(false, @"%@",[[arr reverseObjectEnumerator] allObjects]);
}

@end
