//
//  ViewController.swift
//  PhidgetApp
//
//  Created by Cristina Lopez on 2018-11-13.
//  Copyright © 2018 Cristina Lopez. All rights reserved.
//

import UIKit
import Phidget22Swift

class ViewController: UIViewController {

    let allQuestions = QuestionBank()
    var pickedAnswer : Bool = false
    var questionNumber : Int = 0
    var score : Int = 0
    var isReady : Bool = true
    
    
    //for phidget
    let buttonArray = [DigitalInput(), DigitalInput()]
    let ledArray = [DigitalOutput(), DigitalOutput()]
    
    
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var isAnswerCorrectOrWrongLabel: UILabel!
    @IBOutlet weak var playerWhoPressedFirst: UILabel!
    
    func attach_handler(sender: Phidget){
        do{
            
            let hubPort = try sender.getHubPort()
            
            if(hubPort == 0){
                print("Button 0 Attached")
            }
            else if (hubPort == 1){
                print("Button 1 Attached")
            }
            else if (hubPort == 2){
                print("LED 2 Attached")
            }
            else{
                print("LED 3 Attached")
            }
            
        } catch let err as PhidgetError{
            print("Phidget Error " + err.description)
        } catch{
            //catch other errors here
        }
    }
    
    func state_change_button0(sender:DigitalInput, state:Bool){
        do{
            if(state == true){
                print("Red Button Pressed")
                
                if(isReady == true){
                    print("Red Button Pressed")
                    try ledArray[0].setState(true)
                    isReady = false
                    DispatchQueue.main.async {
                    self.playerWhoPressedFirst.text = "Red!"
                    }
                    
//                pickedAnswer = true
//                checkAnswer()
//                nextQuestion()
//                updateUI()
                }
                else {
                    pickedAnswer = true
                    checkAnswer()
                    nextQuestion()
                    isReady = true
                    try ledArray[0].setState(false)
                }
                
                
            }
            else{
                print("Button Not Pressed")
                
            }
        } catch let err as PhidgetError {
            print("Phidget Error " + err.description)
        } catch{
            //catch other errors here
        }
    }
    
    func state_change_button1(sender:DigitalInput, state:Bool){
        do{
            if(state == true){
                
                if(isReady == true){
                    print("Green Button Pressed")
                    try ledArray[1].setState(true)
                    isReady = false
                    DispatchQueue.main.async {
                    self.playerWhoPressedFirst.text = "Green!"
                    }
                }
                
                else{ // THIS RUNS IF ISREADY IS FALSE
                    pickedAnswer = false
                    checkAnswer()
                    nextQuestion()
                    isReady = true
                    try ledArray[1].setState(false)
                }
                
                
            }
            else{
                print("Button Not Pressed")
                
            }
        } catch let err as PhidgetError {
            print("Phidget Error " + err.description)
        } catch{
            //catch other errors here
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let firstQuestion = allQuestions.list[0]
        questionLabel.text = firstQuestion.questionText
        
        updateUI()
        
        do {
            //enable server
            try Net.enableServerDiscovery(serverType: .deviceRemote)
            
            //address, add handler, open digital BUTTONS
            for i in 0..<buttonArray.count{
                try buttonArray[i].setDeviceSerialNumber(528040)
                try buttonArray[i].setHubPort(i)
                try buttonArray[i].setIsHubPortDevice(true)
                let _ = buttonArray[i].attach.addHandler(attach_handler)
                try buttonArray[i].open()
            }
            
            
            //address, add handler, open LEDs
            for i in 0..<ledArray.count{
                try ledArray[i].setDeviceSerialNumber(528040)
                try ledArray[i].setHubPort(i+2)
                try ledArray[i].setIsHubPortDevice(true)
                let _ = ledArray[i].attach.addHandler(attach_handler)
                try ledArray[i].open()
            }
            
            let _ = buttonArray[0].stateChange.addHandler(state_change_button0)
            let _ = buttonArray[1].stateChange.addHandler(state_change_button1)
            
            
            
        } catch let err as PhidgetError {
            print("Phidget Error " + err.description)
        } catch {
            //other errors here
        }
    }


    func updateUI() {
        DispatchQueue.main.async {
            self.scoreLabel.text = "Score: \(self.score)"
        }
    }
    
    
    func nextQuestion() {
        
        if questionNumber <= 12 {
            DispatchQueue.main.async {
                self.questionLabel.text = self.allQuestions.list[self.questionNumber].questionText
            }
            updateUI()
        }
        else {
            
            let alert = UIAlertController(title: "Great job!", message: "You have finished the quiz! Do you want to start over?", preferredStyle: .alert)
            
            let restartAction = UIAlertAction (title: "Restart", style: .default, handler: { (UIAlertAction) in
                self.startOver()
            })
            
            
            alert.addAction(restartAction)
            
            present(alert, animated: true, completion: nil)
        }
    }
    
    
    func checkAnswer() {
        
        if(questionNumber < 12 ){
            
            let correctAnswer = allQuestions.list[questionNumber].answer
        
            if correctAnswer == pickedAnswer {
            
//            ProgressHUD.showSuccess("Correct!")
                DispatchQueue.main.async {
                self.isAnswerCorrectOrWrongLabel.text = "Correct!"
            }
                score = score + 1
    }
            
            else {
//            ProgressHUD.showError("Wrong!")
                DispatchQueue.main.async {
                    self.isAnswerCorrectOrWrongLabel.text = "Wrong!"
                }
        }
        
       
                questionNumber += 1
                print(questionNumber)
        }

    }
    
    
    func startOver() {
        
        score = 0
        questionNumber = 0
        nextQuestion()
        
    }
    
    
    
}



