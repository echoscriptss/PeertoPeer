//
//  ViewController.swift
//  PeertoPeer
//
//  Created by Yogesh on 6/15/16.
//  Copyright © 2016 test. All rights reserved.
//

import UIKit
import MultipeerConnectivity
import MobileCoreServices
import AVFoundation
import MobileCoreServices
import AssetsLibrary
import AVKit

class ViewController: UIViewController, MCSessionDelegate, MCBrowserViewControllerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate
{
    @IBOutlet weak var btn_Host: UIButton!
    @IBOutlet weak var btn_Joinee:UIButton!

    
    let width:CGFloat = 130
    
    var peerID: MCPeerID!
    var mcSession: MCSession!
    var mcAdvertiserAssistant: MCAdvertiserAssistant!
    var picker:UIImagePickerController? = UIImagePickerController()
    var pickerJoinee:UIImagePickerController? = UIImagePickerController()
   
    let btn_Stop:UIButton = UIButton()
    let btn_Record:UIButton = UIButton()
    let FindMembers:UIButton = UIButton()
    let Close:UIButton = UIButton()
    let view_overLay:UIView  = UIView()
    let lbl_Message:UILabel = UILabel()

    
    let labelText:UILabel =  UILabel()
    let topview:UIView = UIView()
    let Close_Joinee:UIButton = UIButton()

    //var videoURL:URL = URL()
    var videoURL: NSURL = NSURL()

    
    
    
    var FirstUrl:NSURL = NSURL()
    var SecondUrl:NSURL = NSURL()
    var mixComposition:AVMutableComposition = AVMutableComposition()
    var mplayer:AVPlayer = AVPlayer()
    var destinationPath:NSURL = NSURL()
    func createLayoutOfButtons(_ btn:UIButton)
    {
        btn.layer.cornerRadius = 90
        btn.layer.borderWidth = 2
        btn.layer.borderColor = UIColor.white.cgColor
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        createLayoutOfButtons(btn_Host)
        createLayoutOfButtons(btn_Joinee)
        
        peerID = MCPeerID(displayName: UIDevice.current.name)
        
        mcSession = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        mcSession.delegate = self
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID)
    {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress)
    {
        print (resourceName)
        print(peerID)
        print(progress)
    }
    
    
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?)
    {
        //print(localURL)
        self.destinationPath  =
            URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("movie.mov") as NSURL
        
        let fileManager: FileManager = FileManager.default
      
        
        
        let paths = NSSearchPathForDirectoriesInDomains(
            FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let documentsDirectory: AnyObject = paths[0] as AnyObject
        
        
        
        
        do{
            try fileManager.moveItem(at: localURL!, to: destinationPath as URL)
            
            let _:AVURLAsset = AVURLAsset.init(url: localURL!)
            
           
        }
        catch let error as NSError {
            print(error)
        }
        print("Did finish receiving resource")
        
        self.combineVideos(self.videoURL as URL, url2: destinationPath as URL)
        self.playRecordedVideo()
       
        
        print(resourceName)
        print(peerID)
        
    }
    
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController)
    {
        print("browserViewControllerDidFinish")
            //picker?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController)
    {
        dismiss(animated: true, completion: nil)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?)
    {
        
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState)
    {
        switch state {
        case MCSessionState.connected:
            print("Connected: \(peerID.displayName)")
            DispatchQueue.main.async(execute: {
                            self.StopIntractionDisbled()
           self.picker!.dismiss(animated: true, completion: nil)
            })
            

            
        case MCSessionState.connecting:
            print("Connecting: \(peerID.displayName)")
            
        case MCSessionState.notConnected:
            print("Not Connected: \(peerID.displayName)")
        }
    }
    
     func nearbyConnectionDataForPeer(_ peerID: MCPeerID, withCompletionHandler completionHandler: (Data, NSError?) -> Void)
     {
        
     }
    
    // Connect a peer to the session once connection data is received.
     func connectPeer(_ peerID: MCPeerID, withNearbyConnectionData data: Data)
     {
        
     }
    
    func openCameraToRecord()
    {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.camera))
        {
            
            DispatchQueue.main.async(execute: {
                
                print("captureVideoPressed and camera available.")
                
                //var imagePicker = UIImagePickerController()
                
                self.picker!.delegate = self
                self.picker!.sourceType = .camera;
                self.picker!.mediaTypes = [kUTTypeMovie  as String]
                self.picker!.allowsEditing = false
                
                self.setFramesForOverlayOnCamera()
                self.picker?.cameraOverlayView = self.view_overLay
                self.picker!.showsCameraControls = false
                
                self .present(self.picker!, animated: true, completion: nil)
            })
        }
    }
    
    func setFramesForOverlayOnCamera()
    {
        self.view_overLay.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.height)
        
        /////////////////////////////////
        self.lbl_Message.frame = CGRect(x: self.view_overLay.frame.width/2 - 80 , y: self.view_overLay.frame.height/2 - 150, width: 200, height: 200)
        self.lbl_Message.text = "Please select the member before recording"
        self.lbl_Message.textColor = UIColor.white
        self.lbl_Message.numberOfLines = 4
        
        //////////////////////////////////
        self.FindMembers.frame = CGRect(x: self.view_overLay.frame.size.width - self.width , y: 0, width: 130, height: 50)
        self.FindMembers.backgroundColor = UIColor.red
        self.FindMembers .addTarget(self, action: #selector(ViewController.Find), for: .touchUpInside)
        self.FindMembers .setTitle("Find Members", for: UIControlState())
        self.FindMembers.layer.cornerRadius = 25
        self.FindMembers.layer.borderWidth = 2.0
        self.FindMembers.layer.borderColor = UIColor.white.cgColor
        
        ///////////////////////////////////
        self.Close.frame = CGRect(x: 1, y: 0, width: 50, height: 50)
        self.Close.backgroundColor = UIColor.red
        self.Close .addTarget(self, action: #selector(ViewController.Cancel), for: .touchUpInside)
        self.Close .setTitle("X", for: UIControlState())
        self.Close.layer.cornerRadius = 25
        self.Close.layer.borderWidth = 2.0
        self.Close.layer.borderColor = UIColor.white.cgColor
        
        /////////////////////////////////
        self.btn_Record.frame = CGRect(x: self.view_overLay.frame.width/2 - 100 , y: self.view_overLay.frame.height-130, width: 100, height: 100)
        self.btn_Record.backgroundColor = UIColor.red
        self.btn_Record .addTarget(self, action: #selector(ViewController.Record), for: .touchUpInside)
        
        self.btn_Record.isUserInteractionEnabled = false
        
        self.btn_Record .setTitle("Record", for: UIControlState())
        self.btn_Record.layer.cornerRadius = 50
        self.btn_Record.layer.borderWidth = 2.0
        self.btn_Record.layer.borderColor = UIColor.white.cgColor
        
        //////////////////////////////////////
        self.btn_Stop.frame = CGRect(x: self.view_overLay.frame.width/2 + 30,  y: self.view_overLay.frame.height-101, width: 50, height: 50)
        self.btn_Stop.backgroundColor = UIColor.blue
        self.btn_Stop .addTarget(self, action: #selector(ViewController.Stop), for: .touchUpInside)
        self.btn_Stop .setTitle("Stop", for: UIControlState())
        
        
        //disableIntractionRecoerdAndStop()
        StopIntractionDisbled()
        
        self.btn_Stop.layer.cornerRadius = 25
        self.btn_Stop.layer.borderWidth = 2.0
        self.btn_Stop.layer.borderColor = UIColor.white.cgColor
        
        
        self.view_overLay .addSubview(self.btn_Record)
        self.view_overLay .addSubview(self.btn_Stop)
        self.view_overLay .addSubview(self.Close)
        self.view_overLay .addSubview(self.FindMembers)
        self.view_overLay.addSubview(lbl_Message)
    }
 
    func Cancel()
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    func Stop()
    {
        picker?.stopVideoCapture()
        StopIntractionDisbled()
        
        lbl_Message.text = "Recording stopped"
        
        let message:NSString = "Stop Video"
        let data:Data = message .data(using: String.Encoding.utf8.rawValue)!
        
        try! mcSession.send(data, toPeers: mcSession.connectedPeers, with: .reliable)
    }

    // MARK: Joinee receives info from host
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID)
    {
        let strMessage = NSString(data: data,encoding: String.Encoding.utf8.rawValue)
        print(strMessage!)
        
        if strMessage != nil
        {
            DispatchQueue.main.async(execute: {
                
                if strMessage == "Stop Video"
                {
                    self.pickerJoinee?.stopVideoCapture()
                    self.labelText.text = "Recording Stopped"
                    
                    
                    //self.dismissViewControllerAnimated(true, completion: nil)
                    
                }
                    
                   else if strMessage == "Send Video"
                    {
                        self.labelText.text = "Recording Stopped"

                        var err : NSError

                        self.mcSession.sendResource(at: self.videoURL as URL, withName: "Test", toPeer: peerID)
                        { (err) in
                            
                            print(self.videoURL.path)
                            print("Sending data %@",self.peerID.displayName)
                            
                        }
                    }
                else if strMessage == "Start Recording"
                {
                     self.clearTmpDirectory()
                    print("OOOO bhenchodo")
                    self.pickerJoinee?.startVideoCapture()
                    self.labelText.text = "Recording....."
                    self.Close_Joinee.isHidden = true
                }
                else if strMessage == "Close"
                {
                    print("Close call hua")
                    self.pickerJoinee!.dismiss(animated: true, completion: nil)
                }
                else
                {
                    
                }
                
            })
            
        }
        
//        if UIImage(data: data) != nil
//        {
//            dispatch_async(dispatch_get_main_queue()) { [unowned self] in
//                // do something with the image
//            }
//        }
    }
    
    func clearTmpDirectory()
    {
        do {
            let tmpDirectory = try FileManager.default.contentsOfDirectory(atPath: NSTemporaryDirectory())
            try tmpDirectory.forEach { file in
                let path = String.init(format: "%@%@", NSTemporaryDirectory(), file)
                try FileManager.default.removeItem(atPath: path)
            }
        } catch {
            print(error)
        }
    }
    
    func playRecordedVideo()
    {
        print("hloozz\(self.destinationPath)")
       
        
        let videoAsset = (AVAsset(url:self.destinationPath as URL))
        let playerItem = AVPlayerItem(asset: videoAsset)
        
        let player = AVPlayer(playerItem: playerItem)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        
        DispatchQueue.main.async(execute: {
                        
                        self.picker!.dismiss(animated: true, completion: nil)
                        let message:NSString = "Close"
                        let data:Data = message .data(using: String.Encoding.utf8.rawValue)!
                        
                        try! self.mcSession.send(data, toPeers: self.mcSession.connectedPeers, with: .reliable)
                        
                        self.present(playerViewController, animated: true)
                        {
                            playerViewController.player!.play()
                          
                        }
        })
    }
    
    func combineVideos(_ url1:URL,url2:URL)
    {
        
       // LINK: https://abdulazeem.wordpress.com/2012/04/02/video-manipulation-in-ios-resizingmerging-and-overlapping-videos-in-ios/
        
        
        
        
        let firstAsset:AVURLAsset = AVURLAsset.init(url: url1, options: nil)
        let secondAsset:AVURLAsset = AVURLAsset.init(url: url2, options: nil)

        
        //// adding asset to mutablecomposition
        
        
        let FirstTrack:AVMutableCompositionTrack = mixComposition .addMutableTrack(withMediaType: AVMediaTypeVideo, preferredTrackID: kCMPersistentTrackID_Invalid)
        
       try! FirstTrack .insertTimeRange(CMTimeRangeMake(kCMTimeZero, firstAsset.duration), of: firstAsset.tracks(withMediaType: AVMediaTypeVideo)[0], at: kCMTimeZero)
        
        
        let Secondtrack:AVMutableCompositionTrack = mixComposition .addMutableTrack(withMediaType: AVMediaTypeVideo, preferredTrackID: kCMPersistentTrackID_Invalid)
        
        try! Secondtrack .insertTimeRange(CMTimeRangeMake(kCMTimeZero, secondAsset.duration), of: secondAsset.tracks(withMediaType: AVMediaTypeVideo)[0], at: kCMTimeZero)
        
        
        
        
        let MainInstruction:AVMutableVideoCompositionInstruction = AVMutableVideoCompositionInstruction()
        MainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, firstAsset.duration)
        
        
        
        let FirstlayerInstruction:AVMutableVideoCompositionLayerInstruction = AVMutableVideoCompositionLayerInstruction.init(assetTrack: FirstTrack)
        
        let scale:CGAffineTransform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        let move:CGAffineTransform = CGAffineTransform(translationX: 0.7, y: 0.7)
        FirstlayerInstruction .setTransform(scale.concatenating(move), at: kCMTimeZero)
        
        
        
        let secondlayerInstruction:AVMutableVideoCompositionLayerInstruction = AVMutableVideoCompositionLayerInstruction.init(assetTrack: Secondtrack)
        
        let secondscale:CGAffineTransform = CGAffineTransform(scaleX: 1.2, y: 1.5)
        let secondmove:CGAffineTransform = CGAffineTransform(translationX: 0, y: 0)
        secondlayerInstruction .setTransform(secondscale.concatenating(secondmove), at: kCMTimeZero)
        
        MainInstruction.layerInstructions = [FirstlayerInstruction,secondlayerInstruction]
        
        /////////////
        
        
        
        let MainCompositionInst:AVMutableVideoComposition = AVMutableVideoComposition()
        
        MainCompositionInst.instructions = [MainInstruction]
        MainCompositionInst.frameDuration = CMTimeMake(1, 30)
        MainCompositionInst.renderSize = CGSize(width: 640, height: 480)
        
        
        /////////
        //AVPlayerItem * newPlayerItem = [AVPlayerItem playerItemWithAsset:mixComposition]
        let newPlayerItem: AVPlayerItem = AVPlayerItem.init(asset: mixComposition)
        
        
        
        newPlayerItem.videoComposition = MainCompositionInst
        
        self.mplayer = AVPlayer (playerItem: newPlayerItem)
        
        let playerViewController = AVPlayerViewController()
        playerViewController.player = self.mplayer
        
        
        DispatchQueue.main.async(execute: {
                        self.picker!.dismiss(animated: true, completion: nil)
                        let message:NSString = "Close"
                        let data:Data = message .data(using: String.Encoding.utf8.rawValue)!
                        try! self.mcSession.send(data, toPeers: self.mcSession.connectedPeers, with: .reliable)
                        

                        self.present(playerViewController, animated: true)
                        {
                            playerViewController.player!.play()
                            
                        }
        })
//        self.presentViewController(playerViewController, animated: true)
//        {
//            
//            let message:NSString = "Close"
//            let data:NSData = message .dataUsingEncoding(NSUTF8StringEncoding)!
//            
//            try! self.mcSession.sendData(data, toPeers: self.mcSession.connectedPeers, withMode: .Reliable)
//            self.picker!.dismissViewControllerAnimated(true, completion: nil)
//            playerViewController.player!.play()
//            
//        }
    }
    
    
    
    func Record()
    {
        clearTmpDirectory()
        if mcSession.connectedPeers.count>0
        {
        picker?.startVideoCapture()
        self.btn_Stop.isUserInteractionEnabled = true
        let message:NSString = "Start Recording"
        let data:Data = message .data(using: String.Encoding.utf8.rawValue)!
        self.lbl_Message.text = "Recording....."
        
       try! mcSession.send(data, toPeers: mcSession.connectedPeers, with: .reliable)
        
        StopIntractionEnabled()
        }
        
    }
    
    func StopIntractionEnabled()
    {
        self.btn_Stop.alpha = 1
        self.btn_Stop.isUserInteractionEnabled = true
        
        self.btn_Record.alpha = 0.3
        self.btn_Record.isUserInteractionEnabled = false
    }
    
    func StopIntractionDisbled()
    {
        self.btn_Stop.alpha = 0.3
        self.btn_Stop.isUserInteractionEnabled = false
        self.btn_Record.alpha = 1
        self.btn_Record.isUserInteractionEnabled = true
    }
    
    
    
    
    
    
    func Find()
    {
        joinSession()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
       // print(info[UIImagePickerControllerMediaURL] as? URL)
        videoURL = (info[UIImagePickerControllerMediaURL] as? URL)! as NSURL as NSURL
        
        
        
        let message:NSString = "Send Video"
        let data:Data = message .data(using: String.Encoding.utf8.rawValue)!
        
        try! mcSession.send(data, toPeers: mcSession.connectedPeers, with: .reliable)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        picker.dismiss(animated: true, completion: nil)
        print("picker cancel.")
    }
    
    func sendImage(_ img: UIImage)
    {
        if mcSession.connectedPeers.count > 0
        {
            if let imageData = UIImagePNGRepresentation(img)
            {
                do {
                    try mcSession.send(imageData, toPeers: mcSession.connectedPeers, with: .reliable)
                } catch let error as NSError {
                    let ac = UIAlertController(title: "Send error", message: error.localizedDescription, preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    present(ac, animated: true, completion: nil)
                }
            }
        }
    }
    
   
    
    @IBAction func JOIN(_ sender: AnyObject)
    {
          startHosting()
        openCameraForJoinee()
    }
    
    func openCameraForJoinee()
    {
    
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.camera))
    {
    
    DispatchQueue.main.async(execute: {
    
    print("captureVideoPressed and camera available.")
    
    
        self.pickerJoinee!.delegate = self
        self.pickerJoinee!.sourceType = .camera;
        self.pickerJoinee!.mediaTypes = [kUTTypeMovie  as String]
        self.pickerJoinee!.allowsEditing = false
    
        self.setFramesForJoineeView()
        
        self.pickerJoinee?.cameraOverlayView = self.topview
        self.pickerJoinee!.showsCameraControls = false
    
        self .present(self.pickerJoinee!, animated: true, completion: nil)
    })
    }
    }
    
    func setFramesForJoineeView()
    {
        self.topview.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 70)
        
        
        self.labelText.frame = CGRect(x: self.view.frame.size.width/2 - 80, y: 5, width: 200, height: 60)
        self.labelText.text = "Waiting for connection"
        self.labelText.textColor = UIColor.white
        
        self.Close_Joinee.frame = CGRect(x: 1, y: 0, width: 50, height: 50)
        self.Close_Joinee.backgroundColor = UIColor.red
        self.Close_Joinee .addTarget(self, action: #selector(ViewController.Cancel_Joinee), for: .touchUpInside)
        self.Close_Joinee .setTitle("X", for: UIControlState())
        self.Close_Joinee.isHidden = false
        
        self.Close_Joinee.layer.cornerRadius = 25
        self.Close_Joinee.layer.borderWidth = 2.0
        self.Close_Joinee.layer.borderColor = UIColor.white.cgColor
        
        self.topview.addSubview(self.Close_Joinee)
        self.topview .addSubview(self.labelText)
    }
    
    
    func Cancel_Joinee ()
    {
        mcAdvertiserAssistant.stop()
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func HOST(_ sender: AnyObject)
    {
        openCameraToRecord()
    }
    
    func startHosting()
    {
        mcAdvertiserAssistant = MCAdvertiserAssistant(serviceType: "hws-kb", discoveryInfo: nil, session: mcSession)
        mcAdvertiserAssistant.start()
    }
    
    func joinSession()

    {
        let mcBrowser = MCBrowserViewController(serviceType: "hws-kb", session: mcSession)
        mcBrowser.maximumNumberOfPeers = 1
        mcBrowser.delegate = self
        self.picker!.present(mcBrowser, animated: true, completion: nil)

    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

