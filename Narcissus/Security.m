//
//  Security.m
//  eBike
//
//  Created by Khaos Tian on 13-3-20.
//

#import "Security.h"
#include <Security/Security.h>

@implementation Security

static NSMutableDictionary *createBaseDictionary(NSString *server, NSString *account) 
{
	NSCParameterAssert(server);
    
	NSMutableDictionary *query = [[NSMutableDictionary alloc] init];
    
	[query setObject:(id)kSecClassInternetPassword forKey:(id)kSecClass];
	[query setObject:server forKey:(id)kSecAttrServer];
	if (account) [query setObject:account forKey:(id)kSecAttrAccount];
    
	return query;
}

+ (NSString *)getContentForName:(NSString *)name
{
    NSMutableDictionary *passwordQuery = createBaseDictionary(@"org.oltica.Megara", name);
    NSData *resultData = nil;
    
    [passwordQuery setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnData];
    [passwordQuery setObject:(id)kSecMatchLimitOne forKey:(id)kSecMatchLimit];
    
    OSStatus status = SecItemCopyMatching((CFDictionaryRef)passwordQuery, (CFTypeRef *)&resultData);
    NSString *password;
    if (status == noErr && resultData){
        password = [[NSString alloc] initWithData:resultData encoding:NSUTF8StringEncoding];
    }else{
        password = nil;
    }
    [resultData release];
    [passwordQuery release];
    return password;
}

+ (void)setName:(NSString *)name WithContent:(NSString *)content
{
    NSMutableDictionary *passwordEntry = createBaseDictionary(@"org.oltica.Megara", name);
    NSMutableDictionary *attributesToUpdate = [[NSMutableDictionary alloc] init];
    
    NSData *passwordData = [content dataUsingEncoding:NSUTF8StringEncoding];
    [attributesToUpdate setObject:passwordData forKey:(id)kSecValueData];
    
    OSStatus status = SecItemUpdate((CFDictionaryRef)passwordEntry, (CFDictionaryRef)attributesToUpdate);
    
    [attributesToUpdate release];
    
    if (status == noErr) {
        [passwordEntry release];
        return;
    }
    
    SecItemDelete((CFDictionaryRef)passwordEntry);
    
    [passwordEntry setObject:passwordData forKey:(id)kSecValueData];
    
    SecItemAdd((CFDictionaryRef)passwordEntry, NULL);
    
    [passwordEntry release];
}

+ (void)deleteKeyForName:(NSString *)name
{
    NSMutableDictionary *passwordEntry = createBaseDictionary(@"org.oltica.Megara", name);
    
    SecItemDelete((CFDictionaryRef)passwordEntry);

    [passwordEntry release];
}


@end
