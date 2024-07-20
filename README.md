# MiniMaxOpenSDK-iOS-Demo
相关库依赖
1. minSdkVersion 13.0
2. VoiceActivityDetector
3. ObjectMapper
4. Alamofire, '5.0'
5. SwiftyJSON
6. Moya

# 能力支持
1. 创建 Assistant & Thread
2. 开始录音 & 开始说话后 vad 检测静音自动停止
3. 手动停止录音
4. 发送语音消息请求并播放返回音频
5. 手动停止语音消息请求

# SDK接入
1. 下载XCFramework
2. 集成framework于主工程
3. 在代码中引用MNMVoiceCallManager

# DEMO截图
![20240423-061443](https://github.com/leopardBaozi/MiniMaxOpenSDK-iOS-Demo/assets/167817290/4cc50fda-14f8-4eac-8378-1b525100de48)

# NMVoiceCallManager 使用
## SetUp
MMVoiceCallManager 初始化，需要在使用 MMVoiceCallManager 使用前调用。
```
    /// - Parameter context: api Key和Group ID
    /// - Parameter recordSampleRate: 采样率 8000/16000/32000/48000
    /// - Parameter vadVolume: 收音音量 30-100 ,默认 55
    /// - Parameter vadTimeout: 检测不到人声后 x ms 后停止录音，默认 1500 ms
    /// - Parameter vadMaxTime: vad 可录制的最长人声，单位 ms 默认 60_000 ms
    /// - Returns:  是否初始化成功
    public func setupAudioInfo(context: Context, recordSampleRate: Int, vadVolume: Int = 55, vadTimeout: Int = 1500, vadMaxTime: Int = 60000) -> Bool 
```

## createAssistant
创建一个 assistant，参数对齐开平官网参数。在子线程执行，返回可空，或抛出异常
```
    /// - Parameter assistantParams: 数据结构对齐请求的参数 https://api.minimax.chat/document/guides/Assistants/document/assistant?id=6586b86b4da4834fd75906f6
    /// - Parameter completion: 结果回调
    public func createAssistant(assistantParamsDic: [String : Any], _ completion: ((AssistantBean?) -> Void)?) 
```

## createThread
创建一个 thread ，参数对齐开平官网参数。返回结果包含数据和异常状态。
```
    /// - Parameter threadParamsDic: 数据结构对齐请求的参数 https://api.minimax.chat/document/guides/Assistants/document/assistant?id=6586b86b4da4834fd75906f6
    /// - Parameter completion: 结果回调
    public func createThread(threadParamsDic:  [String : Any], _ completion: ((ThreadBean?) -> Void)?) 
```

## startListen
开始监听，需要接入方提前申请录音权限，调用方法后，会打开录音机进行收音，并开启 vad 自动检测，检测到人声并且声音分贝高于 vadVolume 后开始录音，在收不到人声或者人声低于 vadVolume 持续 vadTimeout 毫秒后，会自动结束，通过complete返回结果和保存的URL。如果持续开启，最多可录制 vadMaxTime 毫秒的音频文件。
```
    /// - Parameter completion: 录音完成后回调。包括是否成功，错误和音频URL
    public func startListen(completion: @escaping (RecordError?, URL?) -> Void?) 
```

## stopListen
停止录音接口
```
    /// - Returns:  URL 音频保存的URL，如果出错则返回空
    public func stopListen() -> URL?
```

## sendMessage
发送语音并流式播放返回的语音消息。上传输入的文件类型目前支持mp3
```
    /// - Parameter streamParams: 参数参考开放平台文档
    /// - Parameter completion: 音频请求过程的结束回调
    public func sendMessage(streamParams: StreamParams, _ completion: ((Error?) ->Void)?) 
```

## cancelVoiceCall
取消语音通话的请求，如果正在播放回复的话，也会停止回复
```
    /// - Parameter threadId: 当前请求的threadId
    /// - Parameter completion: 请求结束回调，包括结果和错误状态
    public func cancelVoiceCallMsgAndStopPlay(threadId: String?, _ completion: ((Response?) -> Void)?)
```

## release
通常在页面退出等时机使用，用于清除一些录音过程中的缓存文件和关闭相关录音buffer
```
    public func release() 
```

## MNMVoiceCallPlayDelegate
发送语音后接受流式播放返回的语音消息的代理回调。
```
public protocol MNMVoiceCallPlayDelegate: NSObjectProtocol {
    /// 首次收到语音返回
    func audioMsgReceived()
    
    /// 语音开始播放
    func playStart()
    
    /// 语音结束播放
    func playEnd()
}
```

## MNMVoiceCallRecordDeleagate
录音功能开启后语的代理回调。
```
public protocol MNMVoiceCallRecordDeleagate: NSObjectProtocol {
    /// 开启录音的回调，达不到vad检测标准未开始收音
    func listenStart()
    
    /// 达到vad检测标准，开始收音写入数据回调
    func recordStart()
}
```
# 常见问题
1. SDK does not contain 'libarclite' at the path
这个路径: 缺少文件, 那么进入这个路径进行查看
/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/ 
lib/



我这个截图是修复后的内容, 报错的情况下没有arc文件夹,也没有libarclite_iphonesimulator.a文件,

1、新建arc文件夹

2、下载:https://github.com/diyxiaoshitou/Libarclite-Files-main中的libarclite_iphonesimulator.a

3、将下载下来的文件粘贴

到/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/arc下

重新运行后将修复这个问题


如果是真机调试运行会出现iPhone.a文件丢失
libarclite_iphoneos.a

1、新建arc文件夹

2、下载:https://github.com/diyxiaoshitou/Libarclite-Files-main中的libarclite_iphoneos.a

3、将下载下来的文件粘贴

到/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/arc下

重新运行后将修复这个问题
 


# 常见问题

1. [SDK does not contain 'libarclite' at the path](https://github.com/yuehuig/libarclite)
2. [Sandbox: rsync.samba (13105) deny(1) file-write-create, Flutter failed to write to a file](https://stackoverflow.com/questions/76590131/error-while-build-ios-app-in-xcode-sandbox-rsync-samba-13105-deny1-file-w)
3. clang: error: linker command failed with exit code 1 (use -v to see invocation)
    ```
    # 在podfile中添加
    post_install do |installer|
        installer.pods_project.targets.each do |target
            target.build_configurations.each do |config|
                config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
            end
        end
    end
    ```
4. 如果模拟器无法运行 需替换[MiniMaxOpenSDK-iOS-VoiceCallFramework](https://github.com/minimax-open-platfom/MiniMaxOpenSDK-iOS-VoiceCallFramework)中的xcframework
    


