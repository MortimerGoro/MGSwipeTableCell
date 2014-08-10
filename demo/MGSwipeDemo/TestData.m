/*
 * MGSwipeTableCell is licensed under MIT licensed. See LICENSE.md file for more information.
 * Copyright (c) 2014 Imanol Fernandez @MortimerGoro
 */

#import "TestData.h"
#import "MGSwipeButton.h"

@implementation TestData


-(NSString *) title
{
    NSString * modeTitle;
    switch (_transition) {
        case MGSwipeTransition3D: modeTitle = @"3D"; break;
        case MGSwipeTransitionClipCenter: modeTitle = @"clip"; break;
        case MGSwipeTransitionDrag: modeTitle = @"drag"; break;
        case MGSwipeTransitionBorder: modeTitle = @"border"; break;
        case MGSwipeTransitionStatic: modeTitle = @"static";break;
    }
    modeTitle = [NSString stringWithFormat:@"%@ transition", modeTitle];
    NSString * buttons;
    if (_leftButtonsCount <= 0 && _rightButtonsCount <= 0) {
        return @"No buttons";
    }
    else if (_leftButtonsCount > 0 && _rightButtonsCount > 0) {
        buttons = [NSString stringWithFormat:@"%d left, %d right", _leftButtonsCount, _rightButtonsCount];
    }
    else if (_leftButtonsCount > 0) {
        buttons = [NSString stringWithFormat:@"%d left", _leftButtonsCount];
    }
    else {
        buttons = [NSString stringWithFormat:@"%d right", _rightButtonsCount];
    }
    
    return [NSString stringWithFormat:@"%@, %@", buttons, modeTitle];
}

-(NSString *) detailTitle
{
    return _leftExpandableIndex >=0 || _rightExpandableIndex >= 0 ? @"Expandable" : @"Not expandable";
}


+(NSMutableArray *) data
{
    NSMutableArray * tests = [NSMutableArray array];
    
    MGSwipeTransition transitions[] = {MGSwipeTransitionBorder, MGSwipeTransitionStatic, MGSwipeTransitionClipCenter, MGSwipeTransitionDrag, MGSwipeTransition3D};
    int numTransitions = sizeof(transitions)/sizeof(MGSwipeTransition);
    
    int buttonCombinations[] = {3,2, 2,1, 0,2, 2,0};
    int numCombinations = sizeof(buttonCombinations) / (sizeof(int) * 2);
    
    int expansionCombinations[] = {-1, -1,  0, 0};
    int numExpansions = sizeof(expansionCombinations)/ (sizeof(int) * 2);
    
    for (int i = 0; i < numCombinations; ++i) {
        for (int j = 0; j < numTransitions; ++j) {
            for (int z = 0; z < numExpansions; ++z) {
                TestData * data = [[TestData alloc] init];
                data.leftButtonsCount = buttonCombinations[2 * i];
                data.rightButtonsCount = buttonCombinations[2 * i + 1];
                data.transition = transitions[j];
                data.leftExpandableIndex =  data.leftButtonsCount ? expansionCombinations[2 * z] : -1;
                data.rightExpandableIndex = data.rightButtonsCount ? expansionCombinations[2 * z + 1] : -1;
                [tests addObject:data];
            }
        }
    }
    return tests;
}

@end