//
//  SqLite3Database.h
//  iVQ
//
//  Created by Mike Ho on 8/29/10.
//  Copyright 2010 Quasidea Development, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import <unistd.h>

#define SqLite3BusyRetryTimeout	20
#define SqLite3BusyRetryCount	5

#define SqLite3TypeBlob			1
#define SqLite3TypeVarChar		2
#define SqLite3TypeChar			3
#define SqLite3TypeInteger		4
#define SqLite3TypeDateTime		5
#define SqLite3TypeDate			6
#define SqLite3TypeTime			7
#define SqLite3TypeFloat		8
#define SqLite3TypeBit			9

@class SqLite3DatabaseResult;

@interface SqLite3Database : NSObject {
	@protected
		sqlite3 * _objDatabase;
}

-(id)initWithFile:(NSString *)strDbPath;
-(void)close;

- (NSInteger)errorCode;
- (NSString *)errorMessage;
- (NSInteger)lastInsertId;

-(SqLite3DatabaseResult *)query:(NSString *)strQuery, ...;
-(SqLite3DatabaseResult *)query:(NSString *)strQuery WithArguments:(NSArray *)arrArguments;

-(void)nonQuery:(NSString *)strQuery, ...;
-(void)nonQuery:(NSString *)strQuery WithArguments:(NSArray *)arrArguments;

-(void)commit;
-(void)rollback;
-(void)beginTransaction;
-(void)beginDeferredTransaction;

@end

@interface SqLite3Database (private)
- (bool)prepareSql:(NSString *)strSql WithStatement:(sqlite3_stmt **)objStatement;
- (void)bindObject:(id)objToBind AtColumnIndex:(int)intIndex ForStatement:(sqlite3_stmt *)objStatement;
@end
