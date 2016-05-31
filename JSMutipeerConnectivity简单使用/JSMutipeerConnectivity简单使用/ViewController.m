//
//  ViewController.m
//  JSMutipeerConnectivity简单使用
//
//  Created by  江苏 on 16/5/31.
//  Copyright © 2016年 jiangsu. All rights reserved.
//

#import "ViewController.h"
#import <MultipeerConnectivity/MultipeerConnectivity.h>

//服务类型标识
#define SERVICE_TYPE @"JS"
//设备名字
#define DIVICE_NAME [UIDevice currentDevice].name

@interface ViewController ()<MCSessionDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,MCBrowserViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *showImageV;

/*连接会话*/
@property(strong,nonatomic)MCSession* session;

/**当前连接到的设备*/
@property(nonatomic,strong)MCPeerID* peerID;

/*注册广告*/
@property(strong,nonatomic)MCAdvertiserAssistant* assistant;

@end

@implementation ViewController


/*注册广告的懒加载*/
-(MCAdvertiserAssistant *)assistant
{
    if (_assistant==nil) {
        _assistant=[[MCAdvertiserAssistant alloc]initWithServiceType:SERVICE_TYPE discoveryInfo:nil session:self.session];
    }
    return _assistant;
}

/*当前连接到设备的懒加载*/
-(MCPeerID *)peerID
{
    if (_peerID==nil) {
        _peerID=[[MCPeerID alloc] initWithDisplayName:DIVICE_NAME];
    }
    return _peerID;
}


/*连接会话的懒加载*/
-(MCSession *)session
{
    if (_session==nil) {
        _session=[[MCSession alloc]initWithPeer:self.peerID];
        _session.delegate=self;
    }
    return _session;
}

//连接
- (IBAction)connectDevice:(id)sender {
    
    MCBrowserViewController* browser=[[MCBrowserViewController alloc]initWithServiceType:SERVICE_TYPE session:self.session];
    browser.delegate=self;
    [self presentViewController:browser animated:YES completion:nil];
    
    
    
}

//选图
- (IBAction)chooseImage:(id)sender {
    
    UIImagePickerController* imagePic=[[UIImagePickerController alloc]init];
    
    //如果相薄可用
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
        imagePic.sourceType=UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        imagePic.delegate=self;
        [self presentViewController:imagePic animated:YES completion:nil];
    }
    
}

//发送图片
- (IBAction)sendImage:(id)sender {
    
    if (!self.showImageV.image) {
        return;
    }
    
    //发送数据
    [self.session sendData:UIImagePNGRepresentation(self.showImageV.image) toPeers:@[self.peerID] withMode:MCSessionSendDataUnreliable error:nil];
    
}

//打开可以被搜索
- (IBAction)isCanBeFound:(UISwitch*)sender {
    if (sender.isOn) {
        
        //打开广告，进入可以被搜索状态
        [self.assistant start];
    }
}

#pragma mark--session的代理方法

//接收到数据时
-(void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID{
    
    if (data!=nil) {
        self.showImageV.image=[UIImage imageWithData:data];
    }
    
}

//状态改变时
-(void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state{
    
}



- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID{
    
}


- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress{
    
}

- (void)session:(MCSession *)session  didFinishReceivingResourceWithName:(NSString *)resourceName
fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(nullable NSError *)error{
    
}

#pragma mark--扫描设备的代
/**连接成功*/
-(void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController{
    
    [browserViewController dismissViewControllerAnimated:YES completion:nil];
    
}

/**退出连接*/
-(void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController{
    [browserViewController dismissViewControllerAnimated:YES completion:nil];
    
}

-(BOOL)browserViewController:(MCBrowserViewController *)browserViewController shouldPresentNearbyPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary<NSString *,NSString *> *)info{
    self.peerID=peerID;
    return YES;
}


#pragma mark--选择图片的代理
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    self.showImageV.image = info[UIImagePickerControllerOriginalImage];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end
