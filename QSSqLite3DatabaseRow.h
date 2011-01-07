//
//  SqLiteDatabaseResult.h
//  iVQ
//
//  Created by Mike Ho on 8/30/10.
//  Copyright 2010 Quasidea Development, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SqLite3DatabaseRow : NSObject {
	@protected
		NSDictionary * _dctRow;
}

-(id)initWithDictionary:(NSDictionary *)dctRow;
-(NSArray *)getColumnNamesAsArray;

-(id)getColumnWithKey:(NSString *)strKey;

-(NSData *)getColumnAsBlobWithKey:(NSString *)strKey;
-(NSString *)getColumnAsVarCharWithKey:(NSString *)strKey;
-(NSString *)getColumnAsCharWithKey:(NSString *)strKey;
-(NSInteger)getColumnAsIntegerWithKey:(NSString *)strKey;
-(float)getColumnAsFloatWithKey:(NSString *)strKey;
-(NSDate *)getColumnAsDateTimeWithKey:(NSString *)strKey;
-(NSDate *)getColumnAsDateWithKey:(NSString *)strKey;
-(NSDate *)getColumnAsTimeWithKey:(NSString *)strKey;
-(bool)getColumnAsBitWithKey:(NSString *)strKey;

@end