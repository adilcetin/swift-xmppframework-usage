import SwiftUI

let lightGreyColor = Color(red: 239.0/255.0, green: 243.0/255.0, blue: 244.0/255.0, opacity: 1.0)

struct LoginView: View {
    
    @Inject private var loginViewController: LoginViewController
    
    init() {
        loginViewController.onAttach(mvpView: self)
    }
    
    @State var username: String = ""
    @State var password: String = ""
    
    var body: some View {
        Image("appIcon")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 250, height: 250)
                        .clipped()
                        .padding(.bottom, 30)
        
        TextField("Username", text: $username)
            .padding()
            .background(lightGreyColor)
            .cornerRadius(10)
            .padding(20)
       
        SecureField("Password", text: $password)
             .padding()
             .background(lightGreyColor)
             .cornerRadius(10)
             .padding(20)
        
        Button(action: {
            loginViewController.login(username: username, password: password)
        }) {
            HStack {
                Text("Login")
                    .fontWeight(.semibold)
                    .font(.title)
            }
            .padding()
            .frame(minWidth: 0, maxWidth: .infinity)
            .foregroundColor(.white)
            .background(Color.green)
            .cornerRadius(10)
            .padding(.top, 50)
            .padding(20)
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
