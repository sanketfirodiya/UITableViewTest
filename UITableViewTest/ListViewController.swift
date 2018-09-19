//
//  ListViewController.swift
//  UITableViewTest
//
//  Created by Sanket Firodiya on 9/13/18.
//  Copyright © 2018 Superhuman. All rights reserved.
//

import UIKit

class ListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var shouldShowSection2 = false
    var isShowingSection2 = false

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 300 // large value to make the bug easy to spot
        tableView.register(UINib(nibName: "ListTableViewCell", bundle: nil), forCellReuseIdentifier: "ListTableViewCell")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Reload the tableView synchronously to reflect local data changes
        print("calling reload")
        tableView.reloadData()

        // In our app, we setup an observer that asynchronously gets updates to the data and reloads the tableView
        DispatchQueue.main.async {
            print("calling reload2")
            self.tableView.reloadData()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if tableView.numberOfRows(inSection: 1) > 0 {
            isShowingSection2 = false
            tableView.deleteRows(at: [IndexPath(row: 0, section: 1)], with: .fade)
        }
    }
}

extension ListViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 4 : (shouldShowSection2 && isShowingSection2 ? 1 : 0)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListTableViewCell", for: indexPath) as! ListTableViewCell
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        shouldShowSection2 = true
        navigationController?.pushViewController(DetailViewController(nibName: "DetailViewController", bundle: nil), animated: true)
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // We insert a cell here based on some logic in our app. Need to do this asynchrohously since we are currently in tableView's reload and inserting synchronously causes a crash in our app due to datasource/tableView mismatch.
        DispatchQueue.main.async {
            if self.shouldShowSection2 && !self.isShowingSection2 && indexPath.row == 0 && indexPath.section == 0 {
                print("calling insert")
                self.isShowingSection2 = true
                self.tableView.insertRows(at: [IndexPath(row: 0, section: 1)], with: .fade)
            }
        }
    }
}
