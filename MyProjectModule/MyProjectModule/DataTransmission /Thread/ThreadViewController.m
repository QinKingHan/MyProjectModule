//
//  ThreadViewController.m
//  MyProjectModule
//
//  Created by 鑫鑫 on 2018/7/25.
//  Copyright © 2018年 xinxin. All rights reserved.
//

#import "ThreadViewController.h"
#import "NSTimerObserver.h"
#import "ThreadSafeContainer.h"
#import "MyProjectModule-Swift.h"

@interface ThreadViewController ()<TimerObserverDelegate>
{
    int _i;
}
@property (strong, nonatomic, nonnull) dispatch_queue_t coderQueue; // the queue to do image decoding

@end

@implementation ThreadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //请求依赖
    [self GCDGroup];
    [self semaphore];
    [self barrier];
    
    [self threadTestOne];
    
    [[SDTimerObserver sharedInstance] addTimerObserver:self];
    
}



-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{

    [[SDTimerObserver sharedInstance] removeTimerObserver:self];
    
    [self testSemaphone_process_delay];
    
    [self async0];
    [self async1];
    
}


#pragma mark 回调
- (void)timerCallBackWithTimer:(SDTimerObserver * _Nonnull)timer {
        _i++;
    NSLog(@"%@====%d",[self class],_i);
}


#pragma mark - 多线程线程学习
/** https://juejin.im/post/5e7db4046fb9a03c714b3776
 - GCD是同步还是异步情况会开启多线程?
   - 同步是不会开启新的线程的，异步才会开启新的线程。
     通过代码验证 同步 在 串行队列 和 并发队列 情况下会不会创建新的线程
*/
-(void)async0{
    dispatch_queue_t serialQueue = dispatch_queue_create("serialQueue", DISPATCH_QUEUE_SERIAL);
    dispatch_queue_t conQueue = dispatch_queue_create("conQueue", DISPATCH_QUEUE_CONCURRENT);

    NSLog(@"(1).=====%@",[NSThread currentThread]);
    // 串行同步
    dispatch_sync(serialQueue, ^{
      NSLog(@"(2).=====%@",[NSThread currentThread]);
    });
    // 并发同步
    dispatch_sync(conQueue, ^{
      NSLog(@"(3).=====%@",[NSThread currentThread]);
    });
    
//    (1).=====<NSThread: 0x2837f6f00>{number = 1, name = main}
//    (2).=====<NSThread: 0x2837f6f00>{number = 1, name = main}
//    (3).=====<NSThread: 0x2837f6f00>{number = 1, name = main}

}

/**
 二问：异步一定会开启新的线程吗。
 答：不会，异步在主队列里不会创建新的线程，在其他串行和并发队列都会创建新的子线程
 */
-(void)async1{
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    dispatch_queue_t serialQueue = dispatch_queue_create("serialQueueasync1", DISPATCH_QUEUE_SERIAL);
    dispatch_queue_t conQueue = dispatch_queue_create("conQueueasync1", DISPATCH_QUEUE_CONCURRENT);

    NSLog(@"(1).=====%@",[NSThread currentThread]);
    dispatch_async(serialQueue, ^{
      NSLog(@"(2).=====%@",[NSThread currentThread]);
    });
    dispatch_async(conQueue, ^{
      NSLog(@"(3).=====%@",[NSThread currentThread]);
    });
    dispatch_async(mainQueue, ^{
      NSLog(@"(4).=====%@",[NSThread currentThread]);
    });

//    (1).=====<NSThread: 0x2800a6f00>{number = 1, name = main}
//    (2).=====<NSThread: 0x2800ca5c0>{number = 3, name = (null)}
//    (3).=====<NSThread: 0x2800ca5c0>{number = 3, name = (null)}
//    (4).=====<NSThread: 0x2800a6f00>{number = 1, name = main}
    
    /**
     但是仔细看线程号 发现（2）和（3） 对应的 number 都是3 。 也就是这两个异步动作只创建了一个新的线程。按照常识来说不是应该创建两个不同线程吗？
     这儿就要从时间和空间谈到GCD对线程调度优化问题了。
     所以GCD会自动权衡根据任务分配合适的线程数，从而达到空间和时间的最优。
     这个问题的总结：

     同步：不具备开启线程的能力，一定串行执行任务
     异步：具有开启线程的能力，但是在主队列里不会开启新的线程。 如果在串行队列和并发队列里开启n个子线程，gcd优化之后未必会真的有n个子线程。
     */

}




#pragma mark - 多线程测试

-(void)threadTestOne{
    //1--   DISPATCH_QUEUE_SERIAL 串行  DISPATCH_QUEUE_CONCURRENT 并发
    _coderQueue =  dispatch_queue_create("com.hackemist.SDWebImageDownloaderOperationCoderQueue", DISPATCH_QUEUE_CONCURRENT);
    // 开启一个子线程
    dispatch_async(self.coderQueue, ^{
        
        sleep(1);
        [[NSThread currentThread] setName:@"1"];
        NSLog(@"1------%@", [NSThread currentThread]); // 打印当前线程
        
    });
    
    dispatch_async(self.coderQueue, ^{
        
        NSLog(@"2------%@", [NSThread currentThread]); // 打印当前线程
        
    });
    
    
    //2--  dispatch_get_global_queue 获取一个全局的队列  异步刷新
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"异步线程");
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"异步主线程");
        });
    });
}


// 控制处理延时  先提高再降低
-(void)testSemaphone_process_delay{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __block BOOL status = NO;
        for (int i = 0; i < 3; i++) {
            dispatch_semaphore_t dsema = dispatch_semaphore_create(0);
            
            [self simulateTime_consumingOperation:^(BOOL suc) {
                status = suc;
                dispatch_semaphore_signal(dsema);
            }];
            
            NSLog(@"status === %@",@(status).stringValue);

            // 等待处理结果 最多等20秒
            dispatch_semaphore_wait(dsema, dispatch_time(DISPATCH_TIME_NOW, 20 * NSEC_PER_SEC));
            
            NSLog(@"status === %@",@(status).stringValue);
            
            if (status)
            {
                // do Something
                break;
            }
        }
        
    });
    
}

// semaphone 控制线程数量 并发/做锁    先降低再提高
-(void)testDispatch_semaphone_Thread{
    //crate的value表示，最多几个资源可访问
    
    //设定的信号值为2，先执行两个线程，等执行完一个，才会继续执行下一个，保证同一时间执行的线程数不超过2。
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(2);
    
    //设定为3，就是不限制线程执行了，因为一共才只有3个线程
//    dispatch_semaphore_t semaphore = dispatch_semaphore_create(3);

    dispatch_queue_t quene = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    //任务1
    dispatch_async(quene, ^{
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        NSLog(@"run task 1");
        sleep(1);
        NSLog(@"complete task 1");
        dispatch_semaphore_signal(semaphore);
    });
    
    //任务2
    dispatch_async(quene, ^{
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        NSLog(@"run task 2");
        sleep(1);
        NSLog(@"complete task 2");
        dispatch_semaphore_signal(semaphore);
    });
    
    //任务3
    dispatch_async(quene, ^{
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        NSLog(@"run task 3");
        sleep(1);
        NSLog(@"complete task 3");
        dispatch_semaphore_signal(semaphore);
    });
}


// 死锁测试
-(void)lockTest{
    dispatch_queue_t myCustomQueue;
    myCustomQueue = dispatch_queue_create("com.example.MyCustomQueue", NULL);

    // 异步添加
    dispatch_async(myCustomQueue, ^{
        printf("做一些工作\n");
    });
     
    printf("第一个 block 可能还没有执行\n");

    // 同步添加
    dispatch_sync(myCustomQueue, ^{
        printf("做另外一些工作\n");
    });
    
    printf("两个 block 都已经执行完毕\n");

    dispatch_queue_t queue = dispatch_queue_create("com.demo.serialQueue", DISPATCH_QUEUE_SERIAL);
    NSLog(@"1"); // 主队列 - 任务1
    dispatch_async(queue, ^{
        NSLog(@"2"); // queue-任务2
        while (1) {
            // 死循环
        }
        dispatch_sync(queue, ^{
            NSLog(@"死锁"); // queue -任务3 要加到 queue中
        });
        NSLog(@"4"); // queue-任务4
    });
    NSLog(@"5"); // 主队列 - 任务5
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        NSLog(@"死锁"); // 任务2
    });

}


#pragma mark - GCDGroup
//1： dispatch_group_create dispatch_group_enter dispatch_group_leave

-(void)GCDGroup{
    
//    group = dispatch_group_create();
//    for (url in urlsToFetch) {
//        dispatch_group_enter(group);
//        dispatch_async(dispatch_get_global_queue(…), ^{
//            … fetch `url` synchronously …
//            dispatch_group_leave(group);
//        });
//    }
//    dispatch_group_wait(group, …);
    

    
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_group_enter(group);
    
    
    
    
    dispatch_group_async(group, dispatch_queue_create("com.dispatch.test", DISPATCH_QUEUE_CONCURRENT), ^{
        
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://www.baidu.com"]];
        NSURLSessionDownloadTask *task = [[NSURLSession sharedSession] downloadTaskWithRequest:request completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            // 请求完成，可以通知界面刷新界面等操作
            NSLog(@"第一步网络请求完成");
            
        }];
        [task resume];
        // 以下还要进行一些其他的耗时操作
        NSLog(@"耗时操作继续进行0");
    });
    
    dispatch_group_async(group, dispatch_queue_create("com.dispatch.test", DISPATCH_QUEUE_CONCURRENT), ^{
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://www.github.com"]];
        NSURLSessionDownloadTask *task = [[NSURLSession sharedSession] downloadTaskWithRequest:request completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            // 请求完成，可以通知界面刷新界面等操作
            NSLog(@"第二步网络请求完成");
            dispatch_group_leave(group);
            
        }];
        [task resume];
        // 以下还要进行一些其他的耗时操作
        NSLog(@"耗时操作继续进行1");
    });
    
    
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSLog(@"刷新界面等在主线程的操作");
    });
    
}

#pragma mark - 线程同步 --阻塞任务（dispatch_barrier）：
-(void)barrier {
    /* 创建并发队列 */
    dispatch_queue_t concurrentQueue = dispatch_queue_create("test.concurrent.queue", DISPATCH_QUEUE_CONCURRENT);
    /* 添加两个并发操作A和B，即A和B会并发执行 */
    dispatch_async(concurrentQueue, ^(){
        NSLog(@"OperationA");
    });
    dispatch_async(concurrentQueue, ^(){
        NSLog(@"OperationB");
    });
    /* 添加barrier障碍操作，会等待前面的并发操作结束，并暂时阻塞后面的并发操作直到其完成 */
    dispatch_barrier_async(concurrentQueue, ^(){
        NSLog(@"OperationBarrier!");
    });
    /* 继续添加并发操作C和D，要等待barrier障碍操作结束才能开始 */
    dispatch_async(concurrentQueue, ^(){
        NSLog(@"OperationC");
    });
    dispatch_async(concurrentQueue, ^(){
        NSLog(@"OperationD");
    });
}


#pragma mark - 线程同步 -- 信号量机制（dispatch_semaphore）

//    dispatch_semaphore_create：创建一个信号量（semaphore）
//    dispatch_semaphore_signal：信号通知，即让信号量+1
//    dispatch_semaphore_wait：等待，直到信号量大于0时，即可操作，同时将信号量-1

-(void)semaphore{
    //1.任务一：下载图片
    NSBlockOperation *operation1 = [NSBlockOperation blockOperationWithBlock:^{
        [self request_A];
    }];
    
    //2.任务二：打水印
    NSBlockOperation *operation2 = [NSBlockOperation blockOperationWithBlock:^{
        [self request_B];
    }];
    
    //3.任务三：上传图片
    NSBlockOperation *operation3 = [NSBlockOperation blockOperationWithBlock:^{
        [self request_C];
    }];
    
    //4.设置依赖
    [operation2 addDependency:operation1];      //任务二依赖任务一
    [operation3 addDependency:operation2];      //任务三依赖任务二
    
    //5.创建队列并加入任务
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperations:@[operation3, operation2, operation1] waitUntilFinished:NO];
}

-(void)request_A{
//1    创建
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://www.cocoachina.com"]];
    NSURLSessionDownloadTask *task = [[NSURLSession sharedSession] downloadTaskWithRequest:request completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        //2 计数+1操作
        dispatch_semaphore_signal(sema);
        
        NSLog(@"第一步网络请求完成");
        
    }];
    
    [task resume];
    
    //3 若计数为0则一直等待
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    
}
-(void)request_B{
    
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://www.github.com"]];
    NSURLSessionDownloadTask *task = [[NSURLSession sharedSession] downloadTaskWithRequest:request completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_semaphore_signal(sema);
        
        NSLog(@"第二步网络请求完成");
        
    }];
    [task resume];
    
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    
}
-(void)request_C{
    
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://www.baidu.com"]];
    NSURLSessionDownloadTask *task = [[NSURLSession sharedSession] downloadTaskWithRequest:request completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_semaphore_signal(sema);
        
        NSLog(@"第三步网络请求完成");
        
    }];
    [task resume];
    
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    
}

#pragma mark - NSOperation 和 NSOperationQueue


@end
