//
//  ViewController.m
//  CountryTable
//
//  Created by Stepan Paholyk on 11/3/16.
//  Copyright © 2016 Stepan Paholyk. All rights reserved.
//

#import "ViewController.h"
#import "SPCountry.h"
#import "SPClub.h"

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *countriesArray;


@end


@implementation ViewController

#pragma mark - Lazy

- (NSMutableArray*) countriesArray {
    if (!_countriesArray) {
        _countriesArray = [NSMutableArray array];
    }
    return _countriesArray;
}

#pragma mark - View

- (void)loadView
{
    [super loadView];
    
    CGRect tableFrame = self.view.bounds;
    tableFrame.origin = CGPointZero;
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:tableFrame style:UITableViewStyleGrouped];

    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    tableView.delegate = self;
    tableView.dataSource = self;
    
    [self.view addSubview:tableView];
    
    self.tableView = tableView;

    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.navigationItem.title = @"FC Clubs";
    
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                                                target:self
                                                                                action:@selector(editAction:)];
    self.navigationItem.rightBarButtonItem = editButton;
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                               target:self
                                                                               action:@selector(addAction:)];
    self.navigationItem.leftBarButtonItem = addButton;
    
    
    /***Test data***/
    for (int i = 0; i < arc4random() % 9 + 4; i++) {
        SPCountry *country = [[SPCountry alloc] init];
        country.name = [NSString stringWithFormat:@"Country #%d", i];
        
        NSMutableArray *arrayWithCurrentCountryClubs = [NSMutableArray array]; // for dynamic adding
        
        for (int i = 0; i < arc4random()%5 + 3; i++) {
            [arrayWithCurrentCountryClubs addObject:[SPClub randomClub]];
        }
        
        country.clubs = arrayWithCurrentCountryClubs;
        [self.countriesArray addObject:country];
    }
    
    [self.tableView reloadData];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (void)editAction:(UIBarButtonItem*)sender
{
    BOOL isEditing = self.tableView.editing;
    [self.tableView setEditing:!isEditing animated:YES];
    
    UIBarButtonSystemItem item = UIBarButtonSystemItemEdit;
    
    if (self.tableView.editing) {
        item = UIBarButtonSystemItemDone;
    }
    
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                                                target:self
                                                                                action:@selector(editAction:)];
    self.navigationItem.rightBarButtonItem = editButton;

}

- (void)addAction:(UIBarButtonItem*)sender
{
    SPCountry* country = [[SPCountry alloc] init];
    country.name = [NSString stringWithFormat:@"Country #%lu", [self.countriesArray count] + 1];
    country.clubs = @[[SPClub randomClub],[SPClub randomClub],[SPClub randomClub],[SPClub randomClub]];
    
    NSInteger newSectionIndex = 0;
    [self.countriesArray insertObject:country atIndex:newSectionIndex];
    
    [self.tableView beginUpdates];
    
    NSIndexSet *insertSectionSet = [NSIndexSet indexSetWithIndex:newSectionIndex];
    [self.tableView insertSections:insertSectionSet withRowAnimation:UITableViewRowAnimationFade];
    
    [self.tableView endUpdates];
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    });
}

#pragma mark - UITableViewDelegate

- (NSIndexPath*)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    return (proposedDestinationIndexPath.row == 0) ? sourceIndexPath : proposedDestinationIndexPath;
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (indexPath.row == 0) ? UITableViewCellEditingStyleInsert : UITableViewCellEditingStyleDelete;
}
    

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        SPCountry *country = [self.countriesArray objectAtIndex:indexPath.section];
        NSMutableArray *tmpArray = nil;
        
        if (country.clubs) {
            tmpArray = [NSMutableArray arrayWithArray:country.clubs];
        } else {
            tmpArray = [NSMutableArray array];
        }
        NSInteger newStudentIndex = 0;
        [tmpArray insertObject:[SPClub randomClub] atIndex:newStudentIndex];
        country.clubs = tmpArray;
        
        [tableView beginUpdates];
        
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForItem:newStudentIndex + 1 inSection:indexPath.section];
        [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        [tableView endUpdates];
        
    }
    
}

- (NSString*)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"Remove";
}


#pragma mark - UITableViewDataSource

// for deleting/inserting

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        SPCountry *country = [self.countriesArray objectAtIndex:indexPath.section];
        SPClub *club = [country.clubs objectAtIndex:indexPath.row];
        
        NSMutableArray *tmpArray = [NSMutableArray arrayWithArray:country.clubs];
        
        [tmpArray removeObject:club];
        country.clubs = tmpArray;
        
        [tableView beginUpdates];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        
        [tableView endUpdates];

    } // else if (editingStyle == UITableViewCellEditingStyleInsert)
}

// must have for moving rows in table view in edit mode
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    SPCountry *country = [self.countriesArray objectAtIndex:sourceIndexPath.section];
    SPClub *club = [country.clubs objectAtIndex:sourceIndexPath.row];
    
    NSMutableArray *tmpArray = [NSMutableArray arrayWithArray:country.clubs];
    
    if (sourceIndexPath.section == destinationIndexPath.section) {
        [tmpArray exchangeObjectAtIndex:sourceIndexPath.row withObjectAtIndex:destinationIndexPath.row];
        country.clubs = tmpArray;
    } else {
        [tmpArray removeObject:club];
        country.clubs = tmpArray;
        
        SPCountry *destinationCountry = [self.countriesArray objectAtIndex:destinationIndexPath.section];
        tmpArray = [NSMutableArray arrayWithArray:destinationCountry.clubs];
        [tmpArray insertObject:club atIndex:destinationIndexPath.row];
        destinationCountry.clubs = tmpArray;
    }
}

- (BOOL) tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.row > 0;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    SPCountry *country = [self.countriesArray objectAtIndex:section];
    return country.name;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.countriesArray count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    SPCountry *country = [self.countriesArray objectAtIndex:section];
    return [country.clubs count];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row == 0) {
        static NSString *addCellID = @"addCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:addCellID];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:addCellID];
        }
        cell.textLabel.text = @"Add new club";
        cell.textLabel.textAlignment = 1;
        cell.textLabel.textColor = [UIColor blueColor];
        return cell;
    } else {
     
        static NSString *cellID = @"cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                          reuseIdentifier:cellID];
        }
        
        SPCountry *country = [self.countriesArray objectAtIndex:indexPath.section];
        SPClub *club = [country.clubs objectAtIndex:indexPath.row];
        
        cell.textLabel.text = club.name;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d",club.points];
        
        if (club.points > 40) {
            cell.detailTextLabel.textColor = [UIColor greenColor];
        } else if (club.points >= 25) {
            cell.detailTextLabel.textColor = [UIColor purpleColor];
        } else {
            cell.detailTextLabel.textColor = [UIColor orangeColor];
        }
        
        return cell;

    }
}






















@end
