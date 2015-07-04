//
//  ZLBaseModel.h
//  
//
//  Created by Stephen on 2/4/15. QQ:372809970
//  Copyright (c) 2015 Stephen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZLBaseModel : NSObject<NSCoding>
/**
 *  you'd better to init if its subClass have datas list to be coded
 */
@property (nonatomic, strong) NSDictionary *subClssOfList;

- (id)initWithDictionary:(NSDictionary *)dict;
@end
