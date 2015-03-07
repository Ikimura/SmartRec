//
//  MGConferenceDatePicker.m
//  MGConferenceDatePicker
//
//  Created by Matteo Gobbi on 09/02/14.
//  Copyright (c) 2014 Matteo Gobbi. All rights reserved.
//

#import "MGConferenceDatePicker.h"
#import "MGConferenceDatePickerDelegate.h"

//Editable macros
#define TEXT_COLOR [UIColor colorWithRed:118.0f/255.0f green:118.0f/255.0f blue:118.0f/255.0f alpha:1.0f]
#define SELECTED_TEXT_COLOR [UIColor whiteColor]
#define LINE_COLOR [UIColor colorWithRed:191.0f/255.0f green:191.0f/255.0f blue:191.0f/255.0f alpha:1.0f]
#define SAVE_AREA_COLOR [UIColor colorWithWhite:0.95 alpha:1.0]
#define BAR_SEL_COLOR [UIColor colorWithRed:119.0f/255.0f green:222.0f/255.0f blue:182.0f/255.0f alpha:1.0f]

//Editable constants
static const float VALUE_HEIGHT = 50.0f;
static const float SV_DAYS_WIDTH = 155.0f;
static const float SV_HOURS_WIDTH = 55.0f;
static const float SV_MINUTES_WIDTH = 55.0f;
static const float SV_MERIDIANS_WIDTH = 55.0f;

//Editable values
float PICKER_HEIGHT = 324.0f;
float PICKER_WIDTH = 320.0f;

NSString *FONT_NAME = @"HelveticaNeue";
//NSString *NOW = @"Now";

//Static macros and constants
#define SELECTOR_ORIGIN (PICKER_HEIGHT/2.0-VALUE_HEIGHT/2.0)
#define BAR_SEL_ORIGIN_Y PICKER_HEIGHT/2.0-VALUE_HEIGHT/2.0


//Custom scrollView
@interface MGPickerScrollView ()

@property (nonatomic, strong) NSArray *arrValues;
@property (nonatomic, strong) UIFont *cellFont;
@property (nonatomic, assign, getter = isScrolling) BOOL scrolling;

@end


@implementation MGPickerScrollView

//Constants
const float LBL_BORDER_OFFSET = 8.0;

//Configure the tableView
- (id)initWithFrame:(CGRect)frame andValues:(NSArray *)arrayValues
      withTextAlign:(NSTextAlignment)align andTextSize:(float)txtSize {
    
    if(self = [super initWithFrame:frame]) {
        [self setScrollEnabled:YES];
        [self setShowsVerticalScrollIndicator:NO];
        [self setUserInteractionEnabled:YES];
        [self setBackgroundColor:[UIColor clearColor]];
        [self setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [self setContentInset:UIEdgeInsetsMake(BAR_SEL_ORIGIN_Y, 0.0, BAR_SEL_ORIGIN_Y, 0.0)];
        
        _cellFont = [UIFont fontWithName:FONT_NAME size:txtSize];
        
        if(arrayValues)
            _arrValues = [arrayValues copy];
    }
    return self;
}


//Dehighlight the last cell
- (void)dehighlightLastCell {
    NSArray *paths = [NSArray arrayWithObjects:[NSIndexPath indexPathForRow:_tagLastSelected inSection:0], nil];
    [self setTagLastSelected:-1];
    [self beginUpdates];
    [self reloadRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationNone];
    [self endUpdates];
}

//Highlight a cell
- (void)highlightCellWithIndexPathRow:(NSUInteger)indexPathRow {
    [self setTagLastSelected:indexPathRow];
    NSArray *paths = [NSArray arrayWithObjects:[NSIndexPath indexPathForRow:_tagLastSelected inSection:0], nil];
    [self beginUpdates];
    [self reloadRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationNone];
    [self endUpdates];
}

@end


//Custom Data Picker
@interface MGConferenceDatePicker ()

//@property (nonatomic, strong) NSArray *arrMoments;
@property (nonatomic, strong) NSMutableArray *arrDays;
@property (nonatomic, strong) NSArray *arrHours;
@property (nonatomic, strong) NSArray *arrMinutes;
@property (nonatomic, strong) NSArray *arrMeridians;
@property (nonatomic, strong) NSArray *arrTimes;

@property (nonatomic, strong) MGPickerScrollView *svDays;
@property (nonatomic, strong) MGPickerScrollView *svHours;
@property (nonatomic, strong) MGPickerScrollView *svMins;
@property (nonatomic, strong) MGPickerScrollView *svMeridians;
@property (nonatomic, strong) NSDateFormatter *mainDateFormat;

@end


@implementation MGConferenceDatePicker

-(void)drawRect:(CGRect)rect {
    [self initialize];
    [self buildControl];
}

- (void)initialize {
    
    //Create array Moments and create the dictionary MOMENT -> TIME
    NSDate *firstDate = [NSDate date];
    _mainDateFormat = [[NSDateFormatter alloc] init];
    [_mainDateFormat setDateStyle:NSDateFormatterMediumStyle];
    [_mainDateFormat setDateFormat:@"ccc, d LLL y"];
    
    _arrDays = [[NSMutableArray alloc] init];
    [_arrDays addObject:[_mainDateFormat stringFromDate:firstDate]];
    for (int i = 1; i <= 7; i++) {
        NSDate *tempDate = [firstDate dateByAddingTimeInterval:i*60*60*24];
        NSString *stringDate = [_mainDateFormat stringFromDate:tempDate];
        [_arrDays addObject:stringDate];
    }
    
    _arrTimes = @[@"10:00 AM",
                  @"1:00 PM",
                  @"4:30 PM",
                  @"7:00 PM",
                  @"8:30 PM",
                  @"1:00 AM",
                  @"3:45 PM",
                  @"2:15 PM"
                  ];
    
    //Create array Meridians
    _arrMeridians = @[@"AM", @"PM"];
    
    //Create array Hours
    NSMutableArray *arrHours = [[NSMutableArray alloc] initWithCapacity:12];
    for(int i=1; i<=12; i++) {
        [arrHours addObject:[NSString stringWithFormat:@"%d", i]];
    }
    _arrHours = [NSArray arrayWithArray:arrHours];
    
    //Create array Minutes
    NSMutableArray *arrMinutes = [[NSMutableArray alloc] initWithCapacity:60];
    for(int i=0; i<60; i+=15) {
        [arrMinutes addObject:[NSString stringWithFormat:@"%@%d", (i == 0) ? @"0": @"", i]];
    }
    _arrMinutes = [NSArray arrayWithArray:arrMinutes];
    
    //Set the acutal date
    _selectedDate = [NSDate date];
}


- (void)buildControl {
    //Create a view as base of the picker
    UIView *pickerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, PICKER_WIDTH, PICKER_HEIGHT)];
    [pickerView setBackgroundColor:self.backgroundColor];
    
    //Create bar selector
    UIView *barSel = [[UIView alloc] initWithFrame:CGRectMake(0.0f, BAR_SEL_ORIGIN_Y, PICKER_WIDTH, VALUE_HEIGHT)];
    [barSel setBackgroundColor:BAR_SEL_COLOR];
    
    
    //Create the first column (moments) of the picker
    _svDays = [[MGPickerScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, SV_DAYS_WIDTH, PICKER_HEIGHT) andValues:[_arrDays copy] withTextAlign:NSTextAlignmentRight andTextSize:14.0f];
    _svDays.tag = 0;
    [_svDays setDelegate:self];
    [_svDays setDataSource:self];
    
    //Create the second column (hours) of the picker
    _svHours = [[MGPickerScrollView alloc] initWithFrame:CGRectMake(SV_DAYS_WIDTH, 0.0, SV_HOURS_WIDTH, PICKER_HEIGHT) andValues:_arrHours withTextAlign:NSTextAlignmentCenter  andTextSize:18.0f];
    _svHours.tag = 1;
    [_svHours setDelegate:self];
    [_svHours setDataSource:self];

    //Create the third column (minutes) of the picker
    _svMins = [[MGPickerScrollView alloc] initWithFrame:CGRectMake(_svHours.frame.origin.x+SV_HOURS_WIDTH, 0.0, SV_MINUTES_WIDTH, PICKER_HEIGHT) andValues:_arrMinutes withTextAlign:NSTextAlignmentCenter andTextSize:18.0f];
    _svMins.tag = 2;
    [_svMins setDelegate:self];
    [_svMins setDataSource:self];

    //Create the fourth column (meridians) of the picker
    _svMeridians = [[MGPickerScrollView alloc] initWithFrame:CGRectMake(_svMins.frame.origin.x+SV_MINUTES_WIDTH, 0.0, SV_MERIDIANS_WIDTH, PICKER_HEIGHT) andValues:_arrMeridians withTextAlign:NSTextAlignmentLeft andTextSize:16.0f];
    _svMeridians.tag = 3;
    [_svMeridians setDelegate:self];
    [_svMeridians setDataSource:self];
    
    //Create separators lines
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(SV_DAYS_WIDTH-1.0, 0.0, 1.0, PICKER_HEIGHT)];
    [line setBackgroundColor:LINE_COLOR];
    
    UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake(_svHours.frame.origin.x+SV_HOURS_WIDTH-1.0, 0.0, 1.0, PICKER_HEIGHT)];
    [line2 setBackgroundColor:LINE_COLOR];
    
    UIView *line3 = [[UIView alloc] initWithFrame:CGRectMake(_svMins.frame.origin.x+SV_MINUTES_WIDTH-1.0, 0.0, 1.0, PICKER_HEIGHT)];
    [line3 setBackgroundColor:LINE_COLOR];
    
    UIView *horizontalLine1 = [[UIView alloc] initWithFrame:CGRectMake(pickerView.frame.origin.x, pickerView.frame.origin.y, PICKER_WIDTH, 1.0f)];
    [horizontalLine1 setBackgroundColor:LINE_COLOR];
    
    UIView *horizontalLine2 = [[UIView alloc] initWithFrame:CGRectMake(pickerView.frame.origin.x, pickerView.frame.origin.y + PICKER_HEIGHT - 1.0f, PICKER_WIDTH, 1.0f)];
    [horizontalLine2 setBackgroundColor:LINE_COLOR];
    
    //Add pickerView
    [self addSubview:pickerView];
    
    //Add separator lines
    [pickerView addSubview:line];
    [pickerView addSubview:line2];
    [pickerView addSubview:line3];
    [pickerView addSubview:horizontalLine1];
    [pickerView addSubview:horizontalLine2];
    //Add the bar selector
    [pickerView addSubview:barSel];
    
    //Add scrollViews
    [pickerView addSubview:_svDays];
    [pickerView addSubview:_svHours];
    [pickerView addSubview:_svMins];
    [pickerView addSubview:_svMeridians];
    
    //Set the time to now
    [self setTime:@"NOW"];
    [self switchToDay:0];
    [self setUserInteractionEnabled:YES];
}



#pragma mark - Other methods

//Center the value in the bar selector
- (void)centerValueForScrollView:(MGPickerScrollView *)scrollView {
    
    //Takes the actual offset
    float offset = scrollView.contentOffset.y;
    
    //Removes the contentInset and calculates the prcise value to center the nearest cell
    offset += scrollView.contentInset.top;
    int mod = (int)offset%(int)VALUE_HEIGHT;
    float newValue = (mod >= VALUE_HEIGHT/2.0) ? offset+(VALUE_HEIGHT-mod) : offset-mod;
    
    //Calculates the indexPath of the cell and set it in the object as property
    NSInteger indexPathRow = (int)(newValue/VALUE_HEIGHT);
    
    //Center the cell
    [self centerCellWithIndexPathRow:indexPathRow forScrollView:scrollView];
}

//Center phisically the cell
- (void)centerCellWithIndexPathRow:(NSUInteger)indexPathRow forScrollView:(MGPickerScrollView *)scrollView {
    
    if(indexPathRow >= [scrollView.arrValues count]) {
        indexPathRow = [scrollView.arrValues count] - 1;
    }
    
    float newOffset = indexPathRow*VALUE_HEIGHT;
    
    //Re-add the contentInset and set the new offset
    newOffset -= BAR_SEL_ORIGIN_Y;
    
    [CATransaction begin];
    
    [CATransaction setCompletionBlock:^{
        
        if (![_svMins isScrolling] && ![_svHours isScrolling] && ![_svMeridians isScrolling]) {
//            [_saveButton setEnabled:YES];
            [_svDays setUserInteractionEnabled:YES];
            [_svDays setAlpha:1.0];
        }
        
        //Highlight the cell
        [scrollView highlightCellWithIndexPathRow:indexPathRow];
        
        [scrollView setUserInteractionEnabled:YES];
        [scrollView setAlpha:1.0];
    }];
    
    [scrollView setContentOffset:CGPointMake(0.0, newOffset) animated:YES];
    
    [CATransaction commit];
    
    //Automatic setting of the time
    if(scrollView == _svDays) {
        [self setTime:@"NOW"];
    }
}

- (NSDate *)createDateWithFormat:(NSString *)format andDateString:(NSString *)dateString {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [formatter setLocale:locale];
    formatter.dateFormat = format;
    
    NSDate *tempDate = [_mainDateFormat dateFromString:_arrDays[_svDays.tagLastSelected]];
    
    return [formatter dateFromString:
            [NSString stringWithFormat:dateString,
             [self stringFromDate:tempDate withFormat:@"dd-MM-yyyy"],
             _arrHours[_svHours.tagLastSelected],
             _arrMinutes[_svMins.tagLastSelected],
             _arrMeridians[_svMeridians.tagLastSelected]]];
}

//Return a string from a date
- (NSString *)stringFromDate:(NSDate *)date withFormat:(NSString *)format {
    NSDateFormatter *formatter = [NSDateFormatter new];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [formatter setLocale:locale];
    [formatter setDateFormat:format];
    
    return [formatter stringFromDate:date];
}

//Set the time automatically
- (void)setTime:(NSString *)time {
    //Get the string
    NSString *strTime;
    if([time isEqualToString:@"NOW"]){
        strTime = [self stringFromDate:[NSDate date] withFormat:@"hh:mm a"];
    } else {
        strTime = (NSString *)time;
    }
    
    //Split
    NSArray *comp = [strTime componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" :"]];
    
    //Set the tableViews
    [_svHours dehighlightLastCell];
    [_svMins dehighlightLastCell];
    [_svMeridians dehighlightLastCell];
    
    //Center the other fields
    NSInteger index = 0;
    if ([comp[1] intValue] >= 15 && [comp[1] intValue] < 30) {
        index = 1;
    }else if ([comp[1] intValue] >= 30 && [comp[1] intValue] < 45) {
        index = 2;
    } else if ([comp[1] intValue] >= 45 && [comp[1] intValue] < 60) {
        index = 3;
    }
    [self centerCellWithIndexPathRow:([comp[0] intValue]%12) - 1 forScrollView:_svHours];
    [self centerCellWithIndexPathRow:index forScrollView:_svMins];
    [self centerCellWithIndexPathRow:[_arrMeridians indexOfObject:comp[2]] forScrollView:_svMeridians];
}

//Switch to the previous or next day
- (void)switchToDay:(NSInteger)dayOffset {
    //Calculate and save the new date
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *offsetComponents = [NSDateComponents new];
    
    //Set the offset
    [offsetComponents setDay:dayOffset];
    
    NSDate *newDate = [gregorian dateByAddingComponents:offsetComponents toDate:_selectedDate options:0];
    _selectedDate = newDate;
    
    //Show new date
}

- (void)setSelectedDate:(NSDate *)date {
    _selectedDate = date;
    [self switchToDay:0];
    
    NSString *strTime = [self stringFromDate:date withFormat:@"hh:mm a"];
    [self setTime:strTime];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [_svDays setUserInteractionEnabled:NO];
    [_svDays setAlpha:0.5];
    
    if (scrollView == _svDays) {
        [_svMins setUserInteractionEnabled:NO];
        [_svHours setUserInteractionEnabled:NO];
        [_svMeridians setUserInteractionEnabled:NO];
        
        [_svMins setAlpha:0.5];
        [_svHours setAlpha:0.5];
        [_svMeridians setAlpha:0.5];
    }
    
    if (![scrollView isDragging]) {
        NSLog(@"didEndDragging");
        [(MGPickerScrollView *)scrollView setScrolling:NO];
        [self centerValueForScrollView:(MGPickerScrollView *)scrollView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSLog(@"didEndDecelerating");
    [(MGPickerScrollView *)scrollView setScrolling:NO];
    [self centerValueForScrollView:(MGPickerScrollView *)scrollView];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    MGPickerScrollView *sv = (MGPickerScrollView *)scrollView;
    [sv setScrolling:YES];
    [sv dehighlightLastCell];
}

- (NSDate *)valueOfSelectedDate {
    NSDate *date = [self createDateWithFormat:@"dd-MM-yyyy hh:mm:ss a" andDateString:@"%@ %@:%@:00 %@"];
    return date;
}


#pragma - UITableViewDelegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    MGPickerScrollView *sv = (MGPickerScrollView *)tableView;
    return [sv.arrValues count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *identifier = @"reusableCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    MGPickerScrollView *sv = (MGPickerScrollView *)tableView;
    
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        [cell setBackgroundColor:[UIColor clearColor]];
        [cell.textLabel setFont:sv.cellFont];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    
    [cell.textLabel setTextColor:(indexPath.row == sv.tagLastSelected) ? SELECTED_TEXT_COLOR : TEXT_COLOR];
    [cell.textLabel setText:sv.arrValues[indexPath.row]];
    
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return VALUE_HEIGHT;
}

@end
