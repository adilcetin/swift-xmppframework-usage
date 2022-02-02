import Foundation
import XMPPFramework
import RxSwift
import CocoaLumberjack


class XMPPManagerImpl : NSObject {
    let loginStatusPublisher = PublishSubject<Bool>()
    
    var xmppStream: XMPPStream!
    var xmppDomain: String = ""
    var ownUsername: String = ""
    var ownPassword: String = ""
    
    func configure(serverIP : String, xmppDomain : String) {
    
        self.xmppDomain = xmppDomain;
        
        self.xmppStream = XMPPStream()
        self.xmppStream.startTLSPolicy = XMPPStreamStartTLSPolicy.allowed
        self.xmppStream.hostName = serverIP;
        self.xmppStream.hostPort = 5222;
        
        self.xmppStream.addDelegate(self, delegateQueue: DispatchQueue.main)
        
        DDLog.add(DDOSLogger.sharedInstance, with: DDLogLevel.all)      // for stanza logs
    }
    
    func connect() {
        if xmppStream == nil || self.xmppStream.isConnected {
            return
        }
        
       try! self.xmppStream.connect(withTimeout: XMPPStreamTimeoutNone)
    }
    
    func connectAndLogin(username : String, password: String) {
        
        if xmppStream == nil {
            print("XMPP Connection is not available. Try to reconfigure.")
            return
        }
        
        let userJIDString = username + "@" + xmppDomain
        let userJID = XMPPJID(string: userJIDString)
        xmppStream.myJID = userJID
        
        self.ownUsername = username
        self.ownPassword = password
        
        if self.xmppStream.isDisconnected {
            connect()
        }
        else {
            try! xmppStream.authenticate(withPassword: password)
        }
    }
    
    func disconnect() {
        if xmppStream == nil || self.xmppStream.isDisconnected {
            return
        }
        
        xmppStream.disconnect()
    }
    
    func sendPresenceToAllRosters(presenceType : String) {
        
        if xmppStream == nil || self.xmppStream.isDisconnected {
            print("XMPP Connection is not available. Try to reconfigure.")
            return
        }
        
        let xmppPresence = XMPPPresence(type: presenceType)

        // adding custom child
        let status = DDXMLElement.element(withName: "status", stringValue: "Hello I'm using own messagging app!") as! DDXMLElement
        xmppPresence.addChild(status)
        
        self.xmppStream.send(xmppPresence)
    }
    
    func sendChatMessage(messageBody: String, messageTitle : String, destinationJID: String) {
      
        let xmppMessage = XMPPMessage(type: "chat", to: XMPPJID(string: destinationJID))
       
        xmppMessage.addBody(messageBody)
        xmppMessage.addSubject(messageTitle)
      
        // adding custom child
        let messageSendTime = DDXMLElement.element(withName: "messageSendTime", stringValue: String(NSDate().timeIntervalSince1970)) as! DDXMLElement
        xmppMessage.addChild(messageSendTime)


        self.xmppStream.send(xmppMessage)
    }
    
    func getLoginStatusPublisher() -> PublishSubject<Bool> { return self.loginStatusPublisher }
}


extension XMPPManagerImpl: XMPPStreamDelegate {

    func xmppStreamDidConnect(_ stream: XMPPStream) {
        print("XMPP Stream: Connected")
        try! stream.authenticate(withPassword: ownPassword)
    }

    func xmppStreamDidAuthenticate(_ sender: XMPPStream) {
        print("XMPP Stream: Authenticated")
        loginStatusPublisher.onNext(true)
        sendPresenceToAllRosters("available")
    }
    

    func xmppStream(_ sender: XMPPStream, didNotAuthenticate error: DDXMLElement) {
        print("XMPP Wrong password or username")
        loginStatusPublisher.onNext(false)
    }
}
