//
//  MessengeViewController.swift
//  Messenger
//
//  Created by Phạm Hồng Sơn on 24/03/2024.
//

import UIKit
import FirebaseAuth
import JGProgressHUD
import SnapKit
struct Conversation{
    let id:String
    let name:String
    let otherUserEmail:String
    let latestMessage:LatestMessage
}

struct LatestMessage{
    let date:String
    let text:String
    let isRead:Bool
}

class MessengeViewController: UIViewController {
    
    private var conversations = [Conversation]()
    
    private let searchController:UISearchController = {
       let search = UISearchController(searchResultsController: SearchResultsViewController())
        search.searchBar.searchBarStyle = .minimal
        search.searchBar.placeholder = "Search with @username"
        return search
    }()
    private let spinner  = JGProgressHUD(style: .dark)
    private let tableView :UITableView = {
        let tableView = UITableView()
        //tableView.isHidden = true
        tableView.register(ConversationTableViewCell.self, forCellReuseIdentifier: ConversationTableViewCell.identifier)
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Message"
            navigationController?.setNavigationBarHidden(false, animated: true)
       
        view.addSubview(tableView)
        tableView.tableHeaderView = searchController.searchBar
        searchController.searchResultsUpdater = self
        searchController.delegate = self
            searchController.hidesNavigationBarDuringPresentation = false
            searchController.searchBar.barTintColor = UIColor.white
            searchController.obscuresBackgroundDuringPresentation = false
//        fetConversations()
        setupTableView()
        startListeningForConversation()
       // exit()
    }
   
    func exit(){
        print("Thoát")
        do{
            try FirebaseAuth.Auth.auth().signOut()
            
        }catch is Error{
            print("Have error when signout")
        }
        userLogin()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        userLogin()
        
    }
    func showChat(with conversation : Conversation) {
        print("showChat \(conversation.otherUserEmail) và id: \(conversation.id)")
    
        let chatVC = ChatViewController(with: conversation.otherUserEmail, id: conversation.id)
        chatVC.title = conversation.name
        chatVC.isNewConversation = true
        navigationController?.pushViewController(chatVC, animated: true)
    }
    
    func userLogin(){
        if FirebaseAuth.Auth.auth().currentUser == nil{
            let vc = LoginViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true)
        }
    }
    
    func setupTableView(){
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalToSuperview()
        }
    }

    
    func startListeningForConversation(){
        guard let email = UserDefaults.standard.string(forKey: "email") as? String else{
            return
        }
        let safeEmail = DatabaseManager.shared.safeEmail(email: email)
        DatabaseManager.shared.getAllConversations(for: safeEmail) {[weak self] results in
            switch results{
            case.success(let conversations):
                guard !conversations.isEmpty else{
                    return
                }
                DispatchQueue.main.async {
                    //self?.tableView.isHidden = false
                    self?.conversations = conversations
                    print("conversation \(self?.conversations)")
                
                    self?.tableView.reloadData()
                }
                break
            case .failure( let error):
                print("Faild to get conversatoin: \(error)")
                break
            }
        }
    }
//    func fetConversations(){
//        DatabaseManager.shared.getAllUser { results in
//            switch results{
//            case.failure(let error):
//                print("Lỗi \(error)")
//            case .success(let results):
//                DispatchQueue.main.async {
//                    self.resultU = results
//                    self.tableView.reloadData()
//                }
//               
//            }
//        }
//    }
}
extension MessengeViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ConversationTableViewCell.identifier, for: indexPath) as! ConversationTableViewCell
        cell.configure(with: conversations[indexPath.row])
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.showChat(with: conversations[indexPath.row])
    }
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        90
    }
    
}
extension MessengeViewController:UISearchResultsUpdating,UISearchControllerDelegate{
    
    func updateSearchResults(for searchController: UISearchController) {
        title = ""
        guard let resultsController = searchController.searchResultsController as? SearchResultsViewController else{return}
        let searchText = searchController.searchBar.text
        if(searchText != ""){
            DatabaseManager.shared.getAllUser { results in
                switch results {
                case .failure(let err):
                    print("Lỗi không thể lấy ngừoi dùng \(err)")
                case .success(let result):
                    print("Danh sách ngừoi dùng:\(result)")
                    let resultUsers:[[String:String]] = result.filter {
                        guard let name = $0["name"]?.lowercased() as? String else{
                            return false
                        }
                        return name.contains(searchText?.lowercased() ?? "")
                        
                    }
                    
                    resultsController.updateTableViewResults(users: resultUsers)
                }
                
                resultsController.completion={user in
                    print("Chat with User:\(user)")
                    let chatVC = ChatViewController(with: user["email"] ?? "", id: "")
                        chatVC.title = user["name"] ?? ""
                        chatVC.isNewConversation = true
                    chatVC.navigationItem.largeTitleDisplayMode = .never
                    self.navigationController?.pushViewController(chatVC, animated: true)
                    
                }
            }
        }
        if !searchController.isActive {
                title = "Message"
            }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            title = "Message"
            //searchController.isActive = false
        }
    
}
