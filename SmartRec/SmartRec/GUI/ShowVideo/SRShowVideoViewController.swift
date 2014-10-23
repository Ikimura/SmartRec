//
//  SRShowVideoViewController.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 10/22/14.
//  Copyright (c) 2014 con.epam.evnt. All rights reserved.
//

import UIKit
import MediaPlayer

class SRShowVideoViewController: SRCommonViewController {
    
    @IBOutlet weak var moviePlayerView: UIView!
    var moviePlayer: MPMoviePlayerController!;
    var fileURL: NSURL!;

    override func viewDidLoad() {
        super.viewDidLoad()
        
        moviePlayer =  MPMoviePlayerController(contentURL: fileURL);

        moviePlayer.view.frame = UIScreen.mainScreen().bounds;
        view.addSubview(moviePlayer.view);
        moviePlayer.setFullscreen(true, animated: true)
        moviePlayer.prepareToPlay();
        moviePlayer.controlStyle = .Fullscreen;
        moviePlayer.shouldAutoplay = false;
                
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "moviePlayBackDidFinish:", name: MPMoviePlayerPlaybackDidFinishNotification, object: moviePlayer);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "moviePlayBackDidChangeState:", name: MPMoviePlayerPlaybackStateDidChangeNotification, object: moviePlayer);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func moviePlayBackDidFinish(notification: NSNotification) {
        if let player = notification.object as? MPMoviePlayerController {
            NSLog("Stop");

            self.dismissViewControllerAnimated(true, completion: { () -> Void in

            })
        }
    }
    
    func moviePlayBackDidChangeState(notification: NSNotification) {
        if let player = notification.object as? MPMoviePlayerController {
            NSLog("Pause/Play/Stop");
        }
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: MPMoviePlayerPlaybackDidFinishNotification, object: moviePlayer)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
