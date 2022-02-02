import Foundation

class LoginViewControllerImpl : LoginViewController {
    
    @Inject var xmppManager : XmppManagerImpl
    
    var mvpView : LoginView?

    func onAttach(mvpView : LoginView){
        self.mvpView = mvpView
        
        xmppManager.configure(serverIP: "10.10.10.10", xmppDomain: "domain.com")
    }
    
    func login(username : String, password : String) {
        xmppManager.connectAndLogin(username: username, password: password)
    }
    
}
