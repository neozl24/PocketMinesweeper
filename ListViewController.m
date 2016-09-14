//
//  ListViewController.m
//  PocketMinesweeper
//
//  Created by 钟立 on 16/9/6.
//  Copyright © 2016年 钟立. All rights reserved.
//

#import "ListViewController.h"
#import "InstructionViewController.h"
#import "RecordList.h"
#import "Record.h"

@interface ListViewController () {
    double version;
    NSMutableSet* selectedIndexPathSet;
}

@end

@implementation ListViewController {
    BOOL isStatusBarHidden;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    selectedIndexPathSet = [[NSMutableSet alloc] init];
    
    version = [[UIDevice currentDevice].systemVersion doubleValue];
    if (version >= 7.0) {
        self.tableView.estimatedRowHeight = 44.0;
        
    }
      
//    下面这一句如果只是加在init中，到了这一步又被自动改成YES了。
    self.navigationController.navigationBar.translucent = NO;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden {
    if (isStatusBarHidden == YES) {
        return YES;
    } else {
        return NO;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self performSelector:@selector(showStatusBar) withObject:nil afterDelay:0];
}

- (void)showStatusBar {
    isStatusBarHidden = NO;
    if (version >= 7.0) {
        [UIView animateWithDuration:0.5 animations:^{[self setNeedsStatusBarAppearanceUpdate];}];
    }
}

- (instancetype)init {
    self = [super initWithStyle:UITableViewStyleGrouped];
    isStatusBarHidden = YES;
    
    return self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if (section == 0) {
        return [[RecordList sharedList] allRecords].count;
    } else if (section == 1) {
        return 1;
    } else {
        return 1;
    }
}

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if ([selectedIndexPathSet containsObject:indexPath]) {
        return 70;
    } else {
        return 44;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell;
    
    if (indexPath.section == 0) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"RecordCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        NSArray* records = [[RecordList sharedList] allRecords];
        Record* record = records[indexPath.row];
        
        int usableLength = 16;
        int endIndex = 0;
        for (int i = 0; i < record.name.length; i++) {
            unichar c = [record.name characterAtIndex:i];
            if (c >= 0x4E00 && c <= 0x9FBF) {
                //当前字符为汉字
                usableLength -= 2;
            } else {
                usableLength -= 1;
            }
            
            if (usableLength < 0) {
                break;
            }
            endIndex += 1;
        }
        
        NSString* textToShow = @"";
        if (endIndex == record.name.length) {
            textToShow = record.name;
        } else {
            //Then, endIndex < record.name.length
            textToShow = [[record.name substringToIndex:endIndex ] stringByAppendingString:@"..."];
        }
        
        int ranking = (int)indexPath.row + 1;
        UILabel* nameLabel = [[UILabel alloc] init];
        nameLabel.text = [[NSString stringWithFormat:@"%d. ", ranking] stringByAppendingString:textToShow];
        nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [cell.contentView addSubview:nameLabel];
        
        UILabel* timeLabel = [[UILabel alloc] init];
        timeLabel.text = [NSString stringWithFormat:@"%.2f 秒", record.time];
        timeLabel.textColor = [UIColor colorWithWhite:0.4 alpha:1];
        timeLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [cell.contentView addSubview:timeLabel];
        
        UILabel* informationLabel = [[UILabel alloc] init];
        informationLabel.text = [NSString stringWithFormat:@"%d排%d列(%d颗雷)", record.rowNum, record.colNum, record.totalMines];
        
        informationLabel.font = [UIFont systemFontOfSize:13];
        informationLabel.textColor = [UIColor colorWithWhite:0.65 alpha:1];
        informationLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [cell.contentView addSubview:informationLabel];
        
        UILabel* dateLabel = [[UILabel alloc] init];
        dateLabel.text = record.date;
        dateLabel.font = [UIFont italicSystemFontOfSize:13];
        dateLabel.textColor = [UIColor colorWithWhite:0.65 alpha:1];
        dateLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [cell.contentView addSubview:dateLabel];
        
        
        NSLayoutConstraint* nameTextLeftConstraint =
        [NSLayoutConstraint constraintWithItem:nameLabel
                                     attribute:NSLayoutAttributeLeft
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:cell.textLabel
                                     attribute:NSLayoutAttributeLeft
                                    multiplier:1.0
                                      constant:0.0];
        cell.textLabel.text = @" "; //这一行很关键，给textLabel赋值之后，下面的约束才起作用
        [cell.contentView addConstraint:nameTextLeftConstraint];
        
        //不过cell的textLabel具体是怎么自动调整位置的，我至今也没有搞清楚
        
        NSLayoutConstraint* informationTextLeftConstraint =
        [NSLayoutConstraint constraintWithItem:informationLabel
                                     attribute:NSLayoutAttributeLeft
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:nameLabel
                                     attribute:NSLayoutAttributeLeft
                                    multiplier:1.0
                                      constant:0.0];
        [cell.contentView addConstraint:informationTextLeftConstraint];
        
        NSLayoutConstraint* timeTextRightConstraint =
        [NSLayoutConstraint constraintWithItem:timeLabel
                                     attribute:NSLayoutAttributeRight
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:cell.detailTextLabel
                                     attribute:NSLayoutAttributeRight
                                    multiplier:1.0
                                      constant:0.0];
        cell.detailTextLabel.text = @" ";
        [cell.contentView addConstraint:timeTextRightConstraint];

        NSLayoutConstraint* dateTextRightConstraint =
        [NSLayoutConstraint constraintWithItem:dateLabel
                                     attribute:NSLayoutAttributeRight
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:timeLabel
                                     attribute:NSLayoutAttributeRight
                                    multiplier:1.0
                                      constant:0.0];
        [cell.contentView addConstraint:dateTextRightConstraint];
        
        NSDictionary* nameMap = @{ @"nameLabel": nameLabel,
                                   @"timeLabel": timeLabel,
                                   @"informationLabel": informationLabel,
                                   @"dateLabel": dateLabel };

        NSArray* leftVerticalConstraints =
        [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-12-[nameLabel]-12-[informationLabel]"
                                                options:0
                                                metrics:nil
                                                  views:nameMap];
        [cell.contentView addConstraints:leftVerticalConstraints];
        
        NSArray* rightVerticalConstraints =
        [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-12-[timeLabel]-12-[dateLabel]"
                                                options:0
                                                metrics:nil
                                                  views:nameMap];
        [cell.contentView addConstraints:rightVerticalConstraints];
        
        if ([selectedIndexPathSet containsObject:indexPath] == NO) {
            informationLabel.hidden = YES;
            dateLabel.hidden = YES;
        }
        
        
    } else if (indexPath.section == 1) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"linkCell"];
        cell.textLabel.text = @"操作说明";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        
    } else if (indexPath.section == 2) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"simpleCell"];
        cell.textLabel.text = @"返回游戏";
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.textColor = [UIColor colorWithRed:0.18 green:0.57 blue:1.0 alpha:1.0];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if ([selectedIndexPathSet containsObject:indexPath] == NO) {
            [selectedIndexPathSet addObject:indexPath];
        } else if ([selectedIndexPathSet containsObject:indexPath] == YES) {
            [selectedIndexPathSet removeObject:indexPath];
        }
        
        [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationFade];
        
        
    } else if (indexPath.section == 1) {
        InstructionViewController* instructionViewController = [[InstructionViewController alloc] init];
        [self.navigationController pushViewController:instructionViewController animated:YES];
        
    } else if (indexPath.section == 2) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        [selectedIndexPathSet removeObject:indexPath];
        NSLog(@"%@",selectedIndexPathSet);
    }
}


@end
