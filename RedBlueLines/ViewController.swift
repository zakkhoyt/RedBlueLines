//
//  ViewController.swift
//  RedBlueLines
//
//  Created by Zakk Hoyt on 1/17/16.
//  Copyright © 2016 Zakk Hoyt. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var instructionsLabel: UILabel!
    @IBOutlet weak var rbView: RBView!
    @IBOutlet weak var highScoreLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    
    var highScore: Int = 0 {
        didSet{
            highScoreLabel.text = "High: \(highScore)"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let highScore = NSUserDefaults.standardUserDefaults().objectForKey("highScore") as? Int {
            self.highScore = highScore
            self.setScore(self.highScore)
        }
        
        rbView.gameStarted = {
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.instructionsLabel.alpha = 0
            })
            
            self.setScore(0)
        }
        
        rbView.gameScored =  {
            
            self.setScore(self.rbView.lines.count)
            
            if self.rbView.lines.count > self.highScore {
                self.highScore = self.rbView.lines.count
                NSUserDefaults.standardUserDefaults().setObject(self.rbView.lines.count, forKey: "highScore")
                NSUserDefaults.standardUserDefaults().synchronize()

            }
        }
        
        rbView.gameReset =  {
            self.setScore(0)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func resetButtonTouchUpInside(sender: AnyObject) {
        rbView.reset()
    }

    
    func setScore(score: Int) {
        scoreLabel.text = "Score: \(score)"
    }
    
}

