//
//  Security.h
//  eBike
//
//  Created by Khaos Tian on 13-3-20.
//

#import <Foundation/Foundation.h>


@interface Security : NSObject {
    
}

+ (NSString *)getContentForName:(NSString *)name;
+ (void)setName:(NSString *)name WithContent:(NSString *)content;
+ (void)deleteKeyForName:(NSString *)name;

@end
