//
//  BaseModel.m
//  
//
//  Created by Stephen on 2/4/15. QQ:372809970
//  Copyright (c) 2015 Stephen. All rights reserved.
//

#import "ZLBaseModel.h"
#import "objc/runtime.h"

@implementation ZLBaseModel

- (id)initWithDictionary:(NSDictionary *)dict
{
    if(self = [super init]){
        
        unsigned int outCount = 0;
        objc_property_t *properties = class_copyPropertyList([self class], &outCount);
        
        @try {
            for (int i = 0; i < outCount; i++) {
                objc_property_t property = properties[i];
                NSString *key=[[NSString alloc] initWithCString:property_getName(property)
                                                       encoding:NSUTF8StringEncoding];
                id receiveds = [dict objectForKey:key];
                
                if ([receiveds isKindOfClass:[NSArray class]]) {
                    
                    NSMutableArray *items = [self getObjectArray:receiveds key:key];
                    if (items.count) [self setValue:items forKey:key];
                }else if([receiveds isKindOfClass:[NSDictionary class]]){
                    
                    id class = [self getObject:receiveds property:property];
                    if (class) [self setValue:class forKey:key];
                }else{
                    [self setValue:receiveds forKey:key];
                }
            }
        }
        @catch (NSException *exception) {
            NSLog(@"Exception: %@", exception);
            return nil;
        }
        @finally {
        }
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    
    if (self = [super init]) {
        unsigned int outCount = 0;
        objc_property_t *properties = class_copyPropertyList([self class], &outCount);
        
        @try {
            for (int i = 0; i < outCount; i++) {
                objc_property_t property = properties[i];
                NSString *key=[[NSString alloc] initWithCString:property_getName(property)
                                                       encoding:NSUTF8StringEncoding];
                id receiveds = [aDecoder decodeObjectForKey:key];
                
                if ([receiveds isKindOfClass:[NSArray class]]) {
                    
                    NSMutableArray *items = [self getObjectArray:receiveds key:key];
                    if (items.count) [self setValue:items forKey:key];
                }else if([receiveds isKindOfClass:[NSDictionary class]]){
                    
                    id class = [self getObject:receiveds property:property];
                    if (class) [self setValue:class forKey:key];
                }else{
                    [self setValue:receiveds forKey:key];
                }
            }
        }
        @catch (NSException *exception) {
            NSLog(@"Exception: %@", exception);
            return nil;
        }
        @finally {
        }
        free(properties);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    unsigned int outCount = 0;
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
    for (int i = 0; i < outCount; i++) {
        
        objc_property_t property = properties[i];
        NSString *key=[[NSString alloc] initWithCString:property_getName(property)
                                               encoding:NSUTF8StringEncoding];
        
        id receiveds=[self valueForKey:key];
        if (receiveds && key) {
            
            if ([receiveds isKindOfClass:[NSArray class]]) {
                
                NSMutableArray *items = [self getObjectArray:receiveds key:key];
                if (items.count) [aCoder encodeObject:items forKey:key];
            }else if([receiveds isKindOfClass:[NSDictionary class]]){
                
                id class = [self getObject:receiveds property:property];
                if (class) [aCoder encodeObject:class forKey:key];
            }else{
                [aCoder encodeObject:receiveds forKey:key];
            }
        }
    }
    free(properties);
    properties = NULL;
}

- (NSMutableArray *)getObjectArray:(id)receiveds key:(NSString *)key
{
    if (![receiveds count]) return nil;
    
    NSString *subClass = [self.subClssOfList valueForKey:key];
    if (!subClass.length) {
        NSLog(@"未找到‘%@’的'%@'数组子项对应的类名",[self class],key);
    }
    subClass = !subClass.length?key:subClass;
    Class cls = NSClassFromString(subClass);
    NSMutableArray *items = [[NSMutableArray alloc] init];
    for (id dic in (NSArray *)receiveds) {
        if([dic isKindOfClass:[NSDictionary class]]){
            id aClass = [[cls alloc] initWithDictionary:dic];
            if (aClass) [items addObject:aClass];
        }else{
            [items addObject:dic];
        }
    }
    return items;
}

- (id)getObject:(id)receiveds property:(objc_property_t)property
{
    if (![receiveds allKeys].count) return nil;
    
    const char * attributes = property_getAttributes(property);
    NSString *attr = [NSString stringWithUTF8String:attributes];
    NSArray *arr = [attr componentsSeparatedByString:@"\""];
    Class cls = NSClassFromString(arr[1]);
    id class = [[cls alloc] initWithDictionary:(NSDictionary *)receiveds];
    return class;
}
@end

