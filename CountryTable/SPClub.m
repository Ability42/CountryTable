//
//  SPClub.m
//  CountryTable
//
//  Created by Stepan Paholyk on 11/4/16.
//  Copyright © 2016 Stepan Paholyk. All rights reserved.
//

#import "SPClub.h"

@implementation SPClub

static NSString* names[] = {
    @"Barcelona", @"Real Madrid", @"Manchester City",
    @"Arsenal", @"Aston Villa", @"Norvich",
    @"Bayern M.", @"Borussia D.", @"Dinamo Kiev",
    @"Shakhtar D.", @"Karpaty Lviv", @"Man. United",
    @"Olimpic", @"Beshuktash", @"Atletiko M."
};


+ (SPClub*)randomClub
{
    SPClub *club = [[SPClub alloc] init];
    
    club.name = names[arc4random()%(sizeof(names)/sizeof(*names))];
    club.points = (float)(arc4random()%301 + 200) / 10;
    
    return club;
}
@end
