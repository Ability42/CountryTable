//
//  SPClub.h
//  CountryTable
//
//  Created by Stepan Paholyk on 11/4/16.
//  Copyright © 2016 Stepan Paholyk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SPClub : NSObject

@property (nonatomic) NSString *name;
@property (nonatomic) int points;

+ (SPClub*)randomClub;

@end
