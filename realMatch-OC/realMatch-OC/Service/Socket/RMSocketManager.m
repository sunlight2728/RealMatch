//
//  RMSocketManager.m
//  realMatch-OC
//
//  Created by arceushs on 2019/6/23.
//  Copyright © 2019 qingting. All rights reserved.
//

#import "RMSocketManager.h"
#import "SocketRocket.h"
#import "SVProgressHUD.h"
#import "RMNetworkAPIHost.h"

@import SocketIO;

@interface RMSocketManager()
@property (nonatomic,strong) SocketManager* manager;

@end

@implementation RMSocketManager
{
    
    SRWebSocket* _webSocket;
}
+(instancetype)shared{
    static RMSocketManager* manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[RMSocketManager alloc]init];
    });
    return manager;
}

-(instancetype)init{
    if(self = [super init]){
        self.delegates = [NSMutableArray array];
    }
    return self;
}

-(NSString *)testStr{
#ifdef DEBUG
    return @"test";
#else
    BOOL currentEnviroment = [[NSUserDefaults standardUserDefaults] boolForKey:@"testEnviroment"];
    BOOL xcodeEnviroment = [[[[NSProcessInfo processInfo] environment] objectForKey:@"testEnviroment"] boolValue];
    if(!currentEnviroment && !xcodeEnviroment) {
        return @"production";
    }else{
        return @"test";
    }
#endif
}

-(void)connectWithUserId:(NSString*)userId{
    NSString* urlStr = [NSString stringWithFormat:@"%@/socket.io",RMNetworkAPIHost.apiHost];
    NSURL* url = [[NSURL alloc] initWithString:urlStr];
    
    _manager = [[SocketManager alloc] initWithSocketURL:url config:@{@"log": @YES, @"forceWebsockets": @YES,@"connectParams":@{@"userId":userId,@"env":[self testStr]}}];
    SocketIOClient* socket = _manager.defaultSocket;
    
    [socket on:@"connect" callback:^(NSArray* data, SocketAckEmitter* ack) {
        NSLog(@"socket connected");
        NSString* pushToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"global-pushToken"];
        if(userId){
            if([pushToken length] <=0){
                pushToken = @"";
            }
            [socket emit:@"login" with:@[@{@"userId":userId,@"pushToken":pushToken,@"env":[self testStr]}]];
        }
        
        [socket emit:@"offLineMsg" with:@[@{@"userId":userId,@"env":[self testStr]}]];
        
    }];
    
    
    [socket on:@"message" callback:^(NSArray* data, SocketAckEmitter* ack) {
        if([data[0] isKindOfClass:[NSDictionary class]]){
            RMMessageDetail* messageDetail = [[RMMessageDetail alloc]init:data[0]];
            if([[RMDatabaseManager shareManager] insertData:messageDetail]){
                NSArray<id<RMSocketManagerDelegate>>* copyDelegates = [self.delegates copy];
                for (id<RMSocketManagerDelegate> delegate in copyDelegates) {
                    if([delegate respondsToSelector:@selector(didReceiveMessage)]){
                        [delegate didReceiveMessage];
                    }
                }
            }
            
        }
    }];
    
    [socket on:@"offLineMsg" callback:^(NSArray *  data, SocketAckEmitter * ackl) {
        if([data[0] isKindOfClass:[NSDictionary class]]){
            NSDictionary* offlineMsgDict =(NSDictionary*)data[0];
            NSDictionary* messagesDict = offlineMsgDict[@"offlineMsgList"];
            NSArray* messageKeys = [messagesDict allKeys];
            for(NSString* key in messageKeys){
                NSArray* keyMessageArr = messagesDict[key];
                for(NSDictionary* messageDic in keyMessageArr){
                    if([messageDic isKindOfClass:[NSDictionary class]]){
                        NSString* fromUser =[NSString stringWithFormat:@"%ld", [messageDic[@"fromUser"] integerValue]];
                        NSString* toUser = [NSString stringWithFormat:@"%ld", [messageDic[@"toUser"] integerValue]];

                        NSDictionary* dict = @{@"fromUser":fromUser?:@"",
                                               @"toUser":toUser?:@"",
                                               @"msg":messageDic[@"msg"]?:@"",
                                               @"msg_type":messageDic[@"msg_type"]?:@"text",
                                               @"uploadId":messageDic[@"uploadId"]?:@(-1)
                                               };
                        
                        RMMessageDetail* messageDetail = [[RMMessageDetail alloc]init:dict];
                        if([[RMDatabaseManager shareManager] insertData:messageDetail]){
                            NSArray<id<RMSocketManagerDelegate>>* copyDelegates = [self.delegates copy];
                            for (id<RMSocketManagerDelegate> delegate in copyDelegates) {
                                if([delegate respondsToSelector:@selector(didReceiveMessage)]){
                                    [delegate didReceiveMessage];
                                }
                            }
                        }
                    }
                }
            }
            [socket emit:@"ackOffLineMsg" with:@[@{@"userId":userId,@"env":[self testStr]}]];
        }
    }];
    
    
    [socket connect];
}



-(void)messageSend:(RMMessageDetail*)message{
    __weak typeof(self) weakSelf = self;

    NSDictionary* dict = @{@"fromUser":message.fromUser,
                           @"toUser":message.toUser,
                           @"msg":message.msg,
                           @"msg_type":message.msgType,
                           @"env":[self testStr],
                           };
    [weakSelf.manager.defaultSocket emit:@"message" with:@[dict]];
   
}

-(void)addDelegate:(id<RMSocketManagerDelegate>)delegate{
    if([self.delegates containsObject:delegate])
        return;
    [self.delegates addObject:delegate];
}

-(void)removeDelegate:(id<RMSocketManagerDelegate>)delegate{
    [self.delegates removeObject:delegate];
}

-(void)disconnect:(NSString*)userId{
    [self.manager.defaultSocket emit:@"disconnect" with:@[@{@"userId":userId,@"env":[self testStr]}]];
//    [self.manager.defaultSocket disconnect];
}

//- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
//    NSLog(@"Websocket Connected");
//    //      如果需要发送数据到服务器使用下面代码
////    NSError *error;
////    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:@{@"id":@"chat",@"clientid":@"hxz",@"to":@""} options:NSJSONWritingPrettyPrinted error:&error];
////    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
////    [webSocket send:jsonString];
//    [webSocket send:@"dfasdfasdfasdfasdf"];
//}
//
//// 协议方法  接收消息
//- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
//    NSLog(@"接收的消息:%@", message);
//
//}

@end
