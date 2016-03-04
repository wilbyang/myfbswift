//
//  ViewController.swift
//  myfbswift
//
//  Created by YangBo on 03/03/16.
//  Copyright © 2016 Symbio. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController, FBSDKLoginButtonDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        if (FBSDKAccessToken.currentAccessToken() != nil) {
            self.userData()
            // User is already logged in, do work such as go to next view controller.
        }
        else
        {
            let loginView : FBSDKLoginButton = FBSDKLoginButton()
            self.view.addSubview(loginView)
            loginView.center = self.view.center
            loginView.readPermissions = ["public_profile", "email", "user_friends"]
            loginView.delegate = self
        }
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        print("User Logged In")
        
        if ((error) != nil){
            // Process error
        }
        else if result.isCancelled {
            // Handle cancellations
        }
        else {
            self.userData()
            // If you ask for multiple permissions at once, you
            // should check if specific permissions missing
            if result.grantedPermissions.contains("email") {
                // Do work
            }
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("User Logged Out")
    }
    func userData(){
        let params = ["fields": "email, picture, first_name, last_name, id"]
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: params)
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if ((error) != nil) {
                // Process error
                print("Error: \(error)")
            }
            else {
                print("fetched user: \(result)")
                let firstName : NSString = result.valueForKey("first_name") as! NSString
                let lastName : NSString = result.valueForKey("last_name") as! NSString
                let facebookId : NSString = result.valueForKey("id") as! NSString
                let email : NSString = result.valueForKey("email") as! NSString
                
                let url = NSURL(string: "http://localhost:8080/rest/v1/account/facebook-login");
                let request = NSMutableURLRequest(URL: url!)
                request.HTTPMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                
                let values = ["firstName":firstName, "lastName":lastName, "facebookId":facebookId, "email":email]
                
                request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(values, options: [])
                
                Alamofire.request(request)
                    .responseJSON { response in
                        print(response.request)  // original URL request
                        print(response.response) // URL response
                        print(response.data)     // server data
                        print(response.result)   // result of response serialization
                        
                        if let JSON = response.result.value {
                            print("JSON: \(JSON)")
                        }
                }
                
                
            }
        })
    }


}

