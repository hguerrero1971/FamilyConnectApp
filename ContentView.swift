//
//  ContentView.swift
//  FamilyConnect
//
//  Created by Hugo Guerrero on 10/29/23.
//

import SwiftUI
import Contacts
import ContactsUI


extension UserDefaults {
    var welcomeScreenShown: Bool {
        get {
            return (UserDefaults.standard.value(forKey: "welcomeScreenShown") as? Bool) ?? false
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "welcomeScreenShown")
        }
    }
}

class AppState: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var stayLoggedIn: Bool = false {
        didSet {
            UserDefaults.standard.set(stayLoggedIn, forKey: "stayLoggedIn")
        }
    }
    
    init() {
        self.stayLoggedIn = UserDefaults.standard.bool(forKey: "stayLoggedIn")
        if stayLoggedIn {
            // Restore other parts of logged in state (e.g., retrieve a token)
            // For this example, we'll simply set isLoggedIn to true
            self.isLoggedIn = true
        }
    }
    
    func logOut() {
        self.isLoggedIn = false
        if !stayLoggedIn {
            // Clear other parts of logged in state if the user doesn't want to stay logged in
        }
    }
}


class KeychainManager {
    private let keychain = KeychainSwift()
    private let keyUsername = "appUsernameKey"
    private let keyPassword = "appPasswordKey"

    func storeCredentials(username: String, password: String) {
        keychain.set(username, forKey: keyUsername)
        keychain.set(password, forKey: keyPassword)
    }

    func retrieveCredentials() -> (username: String?, password: String?) {
        let username = keychain.get(keyUsername)
        let password = keychain.get(keyPassword)
        return (username, password)
    }
}

struct ContentView: View {
    @ObservedObject var appState: AppState
    var body: some View {
        if UserDefaults.standard.welcomeScreenShown {
            if appState.isLoggedIn {
                MainAppDashboard()
            } else {
                LoginView(appState: appState)
            }
            
        } else {
            WelcomeScreen(appState: appState)
        }
    }
}


struct WelcomeScreen: View {
    @AppStorage("wecomeScreenShown")
    var wecomeScreenShown: Bool = false
    @State private var showingSignUpView = false
    @State private var showingLoginView = false
    @ObservedObject var appState: AppState
    
    var body: some View {
        VStack{
            Spacer()
            Image("FamilyConnect Tree")
                .resizable()
                .aspectRatio(contentMode: .fit)

           
            Text("Family Connect")
            .font(.title)
            .fontWeight(.bold)
            .padding()
            
            Spacer()
            Button(action: {
                            self.showingSignUpView = true  // This toggles the sheet to be presented
                        }) {
                            Text("Get Started")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.green)
                                .cornerRadius(10)
                        }
                    }
                    .sheet(isPresented: $showingSignUpView) {
                        MainAppDashboard()
                    }.padding()
                     .onAppear(perform: {UserDefaults.standard.welcomeScreenShown = true})
    }
        
}

struct SignUpView: View {
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var passwordConfirmation: String = ""
    @State private var showingSignUpView = false
    @State private var showingLoginView = false
    private let keychainManager = KeychainManager()
    @ObservedObject var appState: AppState

    var body: some View {
        VStack {
            Text("Sign Up")
                .font(.largeTitle)
                .padding(.bottom, 50)

            TextField("Username", text: $username)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(5.0)
                .padding(.bottom, 20)
                .textContentType(.username)

            TextField("Email", text: $email)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(5.0)
                .padding(.bottom, 20)
                .textContentType(.emailAddress) // this is for the keyboard to suggest email inputs

            SecureField("Password", text: $password)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(5.0)
                .padding(.bottom, 20)

            SecureField("Confirm Password", text: $passwordConfirmation)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(5.0)
                .padding(.bottom, 20)

            Button(action: signUp) {
                Text("Sign Up")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .cornerRadius(15.0)
            }
            Button(action: {
                            self.showingLoginView = true  // This toggles the sheet to be presented
            }) {
                        Text("Log In")
                    }
                    .sheet(isPresented: $showingLoginView) {
                        LoginView(appState: appState)  // This is the view that will be presented modally
                    }
            Text("You must first sign up or log in to use Family Connect Service")
        }
        .padding([.leading, .trailing], 27.5)
    }

    func signUp() {
        // Here, add the action for the sign-up functionality.
        // This might include some form of validation and a request to a server.
        print("Sign-Up details: \(username), \(email), \(password)")
        keychainManager.storeCredentials(username: username, password: password)
    }
}

struct LoginView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var showingSignUpView = false
    @State private var showingLoginView = false
    @State private var authenticationFailed = false
    private let keychainManager = KeychainManager()
    @ObservedObject var appState: AppState

    var body: some View {
        VStack {
            Text("Login")
                .font(.largeTitle)
                .padding(.bottom, 50)

            TextField("Username", text: $username)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(5.0)
                .padding(.bottom, 20)
                .textContentType(.username)

            SecureField("Password", text: $password)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(5.0)
                .padding(.bottom, 20)
            
            Toggle(isOn: $appState.stayLoggedIn) {
                            Text("Stay Logged In")
                        }.padding()

            Button(action: login) {
                Text("Login")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .cornerRadius(15.0)
            }                        .sheet(isPresented: $appState.isLoggedIn) {
                MainAppDashboard()
        }
            
            Button(action: {
                            self.showingSignUpView = true  // This toggles the sheet to be presented
            }) {
                        Text("Sign Up")
                    }
                    .sheet(isPresented: $showingSignUpView) {
                        SignUpView(appState: appState)  // This is the view that will be presented modally
                    }
        }
        .padding([.leading, .trailing], 27.5)
    }


    func login() {
        // Here, add the action for the login functionality.
        // This could be a request to a server or some local authentication.
        print("Login details: \(username), \(password)")
        
        let storedCredentials = keychainManager.retrieveCredentials()
                if username == storedCredentials.username && password == storedCredentials.password {
                    print("Logged in successfully")
                    authenticationFailed = false
                    appState.isLoggedIn = true

                } else {
                    authenticationFailed = true
                    appState.isLoggedIn = false
                    print("Login Failed")
                }
    }
}

struct HomeView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Top Pane: Recent Contacts
                RecentContactsPane()
                
                // Middle Panes: Notifications and Search side by side
                HStack(spacing: 20) {
                    NotificationPane()
                        .frame(maxWidth: .infinity)
                    
                    SearchPane()
                        .frame(maxWidth: .infinity)
                }
                
                // Bottom Pane: AI Suggested Actions
                AISuggestedActionsList()
            }
            .padding()
        }
    }
}


struct RecentContactsPane: View {
    var body: some View {
        Text("Recent Contacts")
        // Populate with your recent contacts data
    }
}

struct NotificationPane: View {
    var body: some View {
        Text("Notifications")
        // Populate with your notifications data
    }
}

struct SearchPane: View {
    var body: some View {
        Text("Search")
        // Implement your search functionality
    }
}

struct AISuggestedActionsList: View {
    var body: some View {
        Text("AI Suggested Actions")
        // Populate with your AI-suggested actions data
    }
}



struct MainAppDashboard: View {
    @State private var selectedTab = 0
    
    // Define the colors
    let unselectedColor: Color = Color(red: 0.6, green: 0.4, blue: 0.2) // light brown
    let selectedColor: Color = .green
        
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)
            
            NotificationPane()
                .tabItem {
                    Label("Connections", systemImage: "app.connected.to.app.below.fill")
                }
                .tag(1)
            
            SearchPane()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
                .tag(2)
            
            AISuggestedActionsList()
                .tabItem {
                    Label("Messages", systemImage: "message.fill")
                }
                .tag(3)
            
            // Settings pane
            Text("Settings")
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(4)
        }.accentColor(.green)
    }
}

struct FamilyConnect_Previews: PreviewProvider {
    static var previews: some View {
        MainAppDashboard()
    }
}

