//
//  SqLiteDatabaseResult.h
//  iVQ
//
//  Created by Mike Ho on 8/30/10.
//  Copyright 2010 Quasidea Development, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import <unistd.h>

#import "SqLite3Database.h"

@class SqLite3DatabaseRow;

@interface SqLite3DatabaseResult : NSObject {
	@protected
		NSMutableArray * _arrResults;
		SqLite3Database * _objDatabase;
		sqlite3_stmt * _objStatement;
		int _intPointer;
}

-(id)initWithStatement:(sqlite3_stmt *)objStatement Database:(SqLite3Database *)objDatabase;
-(SqLite3DatabaseRow *)getNextRow;

@end

@interface SqLite3DatabaseResult (private)

-(bool)isRowsExist;
-(id)getColumnDataAtColumnIndex:(NSInteger)intIndex;
-(NSString *)getColumnNameAtColumnIndex:(NSInteger)intIndex;
-(void)finalizeResult;

@end
