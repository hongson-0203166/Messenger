//
//  SearchResultViewController.swift
//  Messenger
//
//  Created by Phạm Hồng Sơn on 02/04/2024.
//

import UIKit
class SearchResultsViewController: UIViewController {
    public var completion:(([String:String])->Void)?
    var users = [[String:String]]()
    let searchResultsTableView:UITableView = {
       let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(searchResultsTableView)
        navigationController?.setNavigationBarHidden(true, animated: true)
        searchResultsTableView.dataSource = self
        searchResultsTableView.delegate = self
        configureConstrain()
        // Do any additional setup after loading the view.
    }
    func updateTableViewResults(users:[[String:String]]){
        DispatchQueue.main.async {
                self.users = users
            self.searchResultsTableView.reloadData()
        }
    }
    private func configureConstrain(){
        searchResultsTableView.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
        }
    }
}
extension SearchResultsViewController:UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = users[indexPath.row]["name"]
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        dismiss(animated: true) {
            self.completion?(self.users[indexPath.row])
        }
    }
}
    

