import UIKit

class ViewController: UIViewController {
    
    let APPLICATION_ID = "4E2E1A3D-FFCD-0343-FF47-1C589EC9B700"
    let API_KEY = "FA7EA74D-684C-9B00-FF57-36FE9F512200"
    let SERVER_URL = "https://api.backendless.com"
    let backendless = Backendless.sharedInstance()!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        backendless.hostURL = SERVER_URL
        backendless.initApp(APPLICATION_ID, apiKey: API_KEY)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
        
