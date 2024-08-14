//
//  ViewController.swift
//  ExamplePod
//
//  Created by Jie on 2024/2/24.
//  Copyright © 2022. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import AVFoundation
import MinimaxOpenVoiceCallSDK

public enum VoiceCallStatus: Int {
    case none
    case denied
}

class ViewController : UIViewController {
    var voiceStatus: VoiceCallStatus = .none
    var url: URL?
    /// 填入有效的Group ID
    var currentGroupID: String = ONLINE_GROUP_ID
    /// 填入有效的Api key
    var currentApiKey: String = ONLINE_API_KEY
    var assistantId: String?
    var threadId: String?

    private lazy var apiKeyLabel : UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textAlignment = .left
        label.textColor = UIColor.gray
        let last10 = String(currentApiKey.suffix(10))
        label.text = "ApiKey(最后10位): \(last10)"
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    private lazy var groupIdLabel : UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textAlignment = .left
        label.textColor = UIColor.gray
        label.text = "Group ID: \(currentGroupID)"
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    private lazy var assistantLabel : UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textAlignment = .left
        label.textColor = UIColor.gray
        label.text = "Assistant ID:"
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    private lazy var threadLabel : UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textAlignment = .left
        label.textColor = UIColor.gray
        label.text = "Thread ID:"
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
//    
    private lazy var assistantButton : UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("创建assistant", for: .normal)
        button.setTitle("正在处理", for: .disabled)
        button.setTitleColor(UIColor.black, for: .normal)
        button.setTitleColor(UIColor.lightGray, for: .disabled)
        button.backgroundColor = UIColor.gray
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(handleAssistantCreation), for: .touchUpInside)
        return button
    }()
    
    private lazy var threadButton : UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("创建thread", for: .normal)
        button.setTitle("正在处理", for: .disabled)
        button.setTitleColor(UIColor.black, for: .normal)
        button.setTitleColor(UIColor.lightGray, for: .disabled)
        button.backgroundColor = UIColor.gray
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(handleThreadCreation), for: .touchUpInside)
        return button
    }()
    
    private lazy var recordButton : UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("开始录制", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.setTitleColor(UIColor.lightGray, for: .disabled)
        button.backgroundColor = UIColor.gray
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(handleVoiceCallStart), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    private lazy var stopButton : UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("停止录制", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.setTitleColor(UIColor.lightGray, for: .disabled)
        button.backgroundColor = UIColor.gray
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(handleVoiceCallStop), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    private lazy var sendButton : UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("文件发送", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.setTitleColor(UIColor.lightGray, for: .disabled)
        button.backgroundColor = UIColor.gray
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(handleVoiceCallMsgRequest), for: .touchUpInside)
        return button
    }()
    
    private lazy var uploadButton : UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("文件上传后发送", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.setTitleColor(UIColor.lightGray, for: .disabled)
        button.backgroundColor = UIColor.gray
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(handleVoiceCallUpload), for: .touchUpInside)
        return button
    }()
    
    private lazy var cancelButton : UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("停止播放", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.setTitleColor(UIColor.lightGray, for: .disabled)
        button.backgroundColor = UIColor.gray
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(cancelVoiceCall), for: .touchUpInside)
        return button
    }()
    
    private lazy var alertLabel : UILabel = {
        let label = UILabel()
        label.numberOfLines = 4
        label.textAlignment = .center
        label.textColor = UIColor.red
        label.text = "正在初始化..."
        label.font = UIFont.boldSystemFont(ofSize: 15)
        return label
    }()
    
    private lazy var asrLabel : UILabel = {
        let label = UILabel()
        label.numberOfLines = 4
        label.textAlignment = .center
        label.textColor = UIColor.gray
        label.text = ""
        label.font = UIFont.boldSystemFont(ofSize: 11)
        return label
    }()
    
    private var assisTextView: UITextField = {
        let textView = UITextField()
        textView.placeholder = "传入已有Assistant ID"
        textView.font = UIFont.systemFont(ofSize: 14)
        return textView
    }()
    
    private var threadTextView: UITextField = {
        let textView = UITextField()
        textView.placeholder = "传入已有Thread ID"
        textView.font = UIFont.systemFont(ofSize: 14)
        return textView
    }()
    
    func configUI() {
        view.addSubview(groupIdLabel)
        view.addSubview(apiKeyLabel)
        view.addSubview(assistantLabel)
        view.addSubview(threadLabel)
        view.addSubview(assisTextView)
        view.addSubview(threadTextView)
        
        view.addSubview(assistantButton)
        view.addSubview(threadButton)

        view.addSubview(recordButton)
        view.addSubview(stopButton)
        view.addSubview(sendButton)
        view.addSubview(uploadButton)
        view.addSubview(cancelButton)
        
        view.addSubview(alertLabel)
        view.addSubview(asrLabel)
        
        groupIdLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(60)
        }
        apiKeyLabel.snp.makeConstraints { make in
            make.top.equalTo(groupIdLabel.snp.bottom).offset(5)
            make.leading.equalToSuperview().offset(20)
        }
        assistantLabel.snp.makeConstraints { make in
            make.top.equalTo(apiKeyLabel.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
        }
        threadLabel.snp.makeConstraints { make in
            make.top.equalTo(assistantLabel.snp.bottom).offset(5)
            make.leading.equalToSuperview().offset(20)
        }
        assisTextView.snp.makeConstraints{make in
            make.height.equalTo(20)
            make.width.equalTo(200)
            make.leading.equalTo(assistantLabel.snp.trailing).offset(5)
            make.bottom.equalTo(assistantLabel.snp.bottom)
        }
        threadTextView.snp.makeConstraints{make in
            make.height.equalTo(20)
            make.width.equalTo(200)
            make.centerX.equalTo(assisTextView)
            make.bottom.equalTo(threadLabel.snp.bottom)
        }
        
        assistantButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.width.equalTo(200)
            make.centerY.equalToSuperview().offset(-50)
            make.centerX.equalToSuperview()
        }
        threadButton.snp.makeConstraints { make in
            make.top.equalTo(assistantButton.snp.bottom).offset(10)
            make.height.equalTo(50)
            make.width.equalTo(200)
            make.centerX.equalToSuperview()
        }
        
        recordButton.snp.makeConstraints { make in
            make.top.equalTo(threadButton.snp.bottom).offset(10)
            make.height.equalTo(50)
            make.width.equalTo(200)
            make.centerX.equalToSuperview()
        }
        stopButton.snp.makeConstraints { make in
            make.top.equalTo(recordButton.snp.bottom).offset(10)
            make.height.equalTo(50)
            make.width.equalTo(200)
            make.centerX.equalToSuperview()
        }
        sendButton.snp.makeConstraints { make in
            make.top.equalTo(stopButton.snp.bottom).offset(10)
            make.height.equalTo(50)
            make.width.equalTo(200)
            make.centerX.equalToSuperview()
        }
        uploadButton.snp.makeConstraints { make in
            make.top.equalTo(sendButton.snp.bottom).offset(10)
            make.height.equalTo(50)
            make.width.equalTo(200)
            make.centerX.equalToSuperview()
        }
        cancelButton.snp.makeConstraints { make in
            make.top.equalTo(uploadButton.snp.bottom).offset(10)
            make.height.equalTo(50)
            make.width.equalTo(200)
            make.centerX.equalToSuperview()
        }
        alertLabel.snp.makeConstraints { make in
            make.top.equalTo(threadLabel.snp.bottom).offset(70)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(20)
        }
        asrLabel.snp.makeConstraints { make in
            make.top.equalTo(alertLabel.snp.bottom).offset(30)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(10)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        MNMVoiceCallManager.shareInstance.recordDelegate = self
        MNMVoiceCallManager.shareInstance.playDelegate = self
        self.configUI()
        self.prepareMicrophonePermission()
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tap)
    }
    
    
    func updateUI(button: UIButton?, text: String) {
        alertLabel.text = text
        recordButton.isEnabled = false
        stopButton.isEnabled = false
        if recordButton == button {
            recordButton.isEnabled = true
        }
        if stopButton == button {
            stopButton.isEnabled = true
        }
    }
    
    @objc func handleVoiceCallStart() {
        MNMVoiceCallManager.shareInstance.startListen() { error, url in
            DispatchQueue.main.async {
                if let url = url {
                    self.updateUI(button: self.recordButton, text: "录音文件写入: \(url.path)")
                } else {
                    self.updateUI(button: self.recordButton, text: "录音失败: \(error?.rawValue)")
                }
                self.url = url
            }
        }
        self.updateUI(button: stopButton, text: "正在录制语音...")
    }
    
    @objc func handleVoiceCallStop() {
        let url = MNMVoiceCallManager.shareInstance.stopListen()
        if let url = url {
            self.url = url
            self.updateUI(button: recordButton, text: "录音文件写入: \(url.path)")
        } else{
            self.updateUI(button: recordButton, text: "录音文件写入失败")
        }
    }
    
    @objc func handleVoiceCallUpload() {
        let documentPicker = UIDocumentPickerViewController(documentTypes: ["public.item"], in: .import)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        present(documentPicker, animated: true, completion: nil)
    }
    
    @objc func handleAssistantCreation() {
        let dic: [String: Any] = [
            "model": "abab6-hailuo",
            "name": "新闻记者",
            "description": "新闻记者，用于咨询各类新闻",
            "instructions": "是一个新闻记者，擅长解答关于新闻的各类问题",
        ]
        MNMVoiceCallManager.shareInstance.createAssistant(assistantParamsDic: dic) { [weak self] model in
            if let model = model, model.base_resp?.status_code == 0 {
                self?.alertLabel.text = "Assistant创建成功: \(model.id ?? "")"
                self?.assistantId = model.id
            } else {
                self?.alertLabel.text = "Assistant创建失败: \(model?.base_resp?.status_msg ?? "")"
            }
        }
    }
    
    @objc func handleThreadCreation() {
        let dic: [String: Any] = [
            "metadata" : [
                "key1": "value1",
                "key2": "value2",
            ]
        ]
        MNMVoiceCallManager.shareInstance.createThread(threadParamsDic: dic) { [weak self] model in
            if let model = model, model.base_resp?.status_code == 0  {
                self?.alertLabel.text = "Thread创建成功: \(model.id ?? "")"
                self?.threadId = model.id
            } else {
                self?.alertLabel.text = "Thread创建失败: \(model?.base_resp?.status_msg ?? "")"
            }
            self?.threadButton.isEnabled = true
        }
    }
    
    func handleVoiceCallStatus() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            switch self.voiceStatus {
            case .none:
                /// 当前采用16000的采样率，60音量, 1500ms的延时结束和最大60000ms的录音时长
                let context = Context(apiKey: currentApiKey, groupId: currentGroupID)
                if MNMVoiceCallManager.shareInstance.setupAudioInfo(context: context, recordSampleRate: 16000, vadVolume: 60, vadTimeout: 1500, vadMaxTime: 60000) {
                    self.updateUI(button: recordButton, text: "运行正常")
                } else {
                    self.updateUI(button: nil, text: "录音初始化失败")
                }
                break
            case .denied:
                self.updateUI(button: nil, text: "麦克风权限授权失败")
                break
            }
        }
    }
    
    @objc func handleVoiceCallMsgRequest() {
        if let url = self.url {
            do {
                let audioData = try Data(contentsOf: url)
                let hexString = audioData.map { String(format: "%02x", $0) }.joined()
                if let id = threadTextView.text, id.isEmpty != true {
                    threadId = id
                }
                if threadId?.isEmpty != false {
                    alertLabel.text = "threadId不存在，先创建threadId"
                    return
                }
                if let id = assisTextView.text, id.isEmpty != true {
                    assistantId = id
                }
                if assistantId?.isEmpty != false {
                    alertLabel.text = "assistentId不存在，先创建assistentId"
                    return
                }
                let json: [String: Any] = [
                    "groupId" : currentGroupID,
                    "apiKey" : currentApiKey,
                    "params" : [
                        "stream": 2,
                        "thread_id": threadId,
                        "assistant_id": assistantId,
                        "messages" : [
                            [
                            "type": 2,
                            "role": "user",
                            "content":"\(hexString)"
                            ]
                        ],
                        "model": "abab6.5s-chat",
                        "t2a_option": [
                            "model": "speech-01",
                            "voice_id": "male-qn-qingse",
                          ],
                        "tools": [
                            ["type":"web_search"]
                        ]
                    ]
                ]
                if let params = StreamParams(JSON: json) {
                    self.updateUI(button: cancelButton, text: "开始发送请求......")
                    MNMVoiceCallManager.shareInstance.sendMessage(streamParams: params) { error in
                        if let error = error {
                            DispatchQueue.main.async {
                                if let err = error as? ResponseError {
                                    self.updateUI(button: self.recordButton, text: "请求发生错误, 错误码: \(err.errorCode)")
                                } else {
                                    self.updateUI(button: self.recordButton, text: "请求发生错误: \(error)")
                                }
                                
                            }
                        }
                    }
                }
            } catch {
                self.updateUI(button: recordButton, text: "读取文件失败")
            }
        } else {
            alertLabel.text = "文件不存在，先录制文件"
        }
    }
    
    @objc func cancelVoiceCall() {
        MNMVoiceCallManager.shareInstance.cancelVoiceCallMsgAndStopPlay(threadId: threadId) { _ in
        }
        self.updateUI(button: recordButton, text: "取消播放")
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func prepareMicrophonePermission() {
        let authStatus = AVCaptureDevice.authorizationStatus(for: .audio)
        if authStatus == .authorized {
            self.voiceStatus = .none
            self.handleVoiceCallStatus()
        } else {
            AVCaptureDevice.requestAccess(for: .audio) {[weak self] granted in
                if granted {
                    self?.voiceStatus = .none
                } else {
                    self?.voiceStatus = .denied
                }
                self?.handleVoiceCallStatus()
            }
        }
    }
}

extension ViewController : MNMVoiceCallRecordDeleagate {
    func listenStart() {
        DispatchQueue.main.async {
            self.alertLabel.text = "录音开始监听"
        }
    }
    
    func recordStart() {
        DispatchQueue.main.async {
            self.alertLabel.text = "开始录制有效声音"
        }
    }
}


extension ViewController : MNMVoiceCallPlayDelegate {
    func onAsrTextReceived(asr: String) {
        DispatchQueue.main.async {
            self.asrLabel.text = asr
        }
    }
    
    func onReplyTextReceived(reply: String) {
        DispatchQueue.main.async {
            self.asrLabel.text = reply
        }
    }
    
    func audioMsgReceived() {
        DispatchQueue.main.async {
            self.updateUI(button: nil, text: "音频开始接收......")
        }
    }
    
    func playStart() {
        DispatchQueue.main.async {
            self.updateUI(button: nil, text: "音频开始播放......")
        }
    }
    
    func playEnd() {
        DispatchQueue.main.async {
            self.updateUI(button: self.recordButton, text: "音频播放结束")
        }
    }
    
    func onReplyTextEnd() {
        DispatchQueue.main.async {
            self.asrLabel.text = "字幕结束"
        }
    }
}

extension ViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let selectedFileURL = urls.first else {
            print("No file selected")
            return
        }
        print("Selected file URL: \(selectedFileURL)")
        self.url = selectedFileURL
        self.handleVoiceCallMsgRequest()
    }
}

