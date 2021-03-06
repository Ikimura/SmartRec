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
    var fileURLToShow: NSURL!;
    
    private var moviePlayer: MPMoviePlayerController!;

    override func viewDidLoad() {
        super.viewDidLoad()
        
        moviePlayer =  MPMoviePlayerController(contentURL: fileURLToShow);

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
        moviePlayer = nil;
        NSNotificationCenter.defaultCenter().removeObserver(self, name: MPMoviePlayerPlaybackDidFinishNotification, object: moviePlayer)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: MPMoviePlayerPlaybackStateDidChangeNotification, object: moviePlayer)
    }

}
