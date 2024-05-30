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


class ConversationsViewController: UIViewController {
    
    private var conversations = [Conversation]()
    
    private let searchController: UISearchController = {
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
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
//        tableView.tableHeaderView = searchController.searchBar
        searchController.searchResultsUpdater = self
        searchController.delegate = self
            searchController.hidesNavigationBarDuringPresentation = false
            searchController.searchBar.barTintColor = UIColor.white
            searchController.obscuresBackgroundDuringPresentation = false
//        fetConversations()
        setupTableView()
        startListeningForCOnversations()
       exit()
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
//    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        userLogin()
    }
    func showConversation(with conversation : Conversation) {
        print("showConversation \(conversation.otherUserEmail) và id: \(conversation.id)")
    
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

    
    private func startListeningForCOnversations() {
            guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
                return
            }

            print("starting conversation fetch...")

        let safeEmail = DatabaseManager.shared.safeEmail(email: email)

            DatabaseManager.shared.getAllConversations(for: safeEmail, completion: { [weak self] result in
                switch result {
                case .success(let conversations):
                    print("successfully got conversation models")
                    guard !conversations.isEmpty else {
                        self?.tableView.isHidden = true
                       
                        return
                    }
                    
                    self?.tableView.isHidden = false
                    self?.conversations = conversations

                    DispatchQueue.main.async {
                        self?.tableView.reloadData()
                    }
                case .failure(let error):
                    self?.tableView.isHidden = true
                  
                    print("failed to get convos: \(error)")
                }
            })
        }

    
    private func createNewConversation(result: SearchResult) {
           let name = result.name
        let email = DatabaseManager.shared.safeEmail(email: result.email)

           // check in datbase if conversation with these two users exists
           // if it does, reuse conversation id
           // otherwise use existing code

           DatabaseManager.shared.conversationExists(iwth: email, completion: { [weak self] result in
               guard let strongSelf = self else {
                   return
               }
               switch result {
               case .success(let conversationId):
                   let vc = ChatViewController(with: email, id: conversationId)
                   vc.isNewConversation = false
                   vc.title = name
                   vc.navigationItem.largeTitleDisplayMode = .never
                   strongSelf.navigationController?.pushViewController(vc, animated: true)
               case .failure(_):
                   let vc = ChatViewController(with: email, id: nil)
                   vc.isNewConversation = true
                   vc.title = name
                   vc.navigationItem.largeTitleDisplayMode = .never
                   strongSelf.navigationController?.pushViewController(vc, animated: true)
               }
           })
       }
}
extension ConversationsViewController:UITableViewDelegate,UITableViewDataSource{
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
        self.showConversation(with: conversations[indexPath.row])
    }
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        90
    }
    
}
extension ConversationsViewController:UISearchResultsUpdating,UISearchControllerDelegate{
    
    func updateSearchResults(for searchController: UISearchController) {
        title = ""
        guard let resultsController = searchController.searchResultsController as? SearchResultsViewController else{return}
        let searchText = searchController.searchBar.text
        
        if(searchText != ""){
            DatabaseManager.shared.searchFriendToSendMessage { results in
                switch results {
                case .failure(let err):
                    print("Lỗi không thể lấy ngừoi dùng \(err)")
                    
                case .success(let result):
                    print("Danh sách ngừoi dùng:\(result)")
                    let resultUsers:[SearchResult] = result.filter {
                        guard let name = $0.name.lowercased() as? String else{
                            return false
                        }
                        return name.contains(searchText?.lowercased() ?? "")
                    }
                    resultsController.updateTableViewResults(users: resultUsers)
                }
                
                
                resultsController.completion={user in
                    print("Chat with User:\(user)")
                    let chatVC = ChatViewController(with: user.email, id: "")
                    chatVC.title = user.name
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
