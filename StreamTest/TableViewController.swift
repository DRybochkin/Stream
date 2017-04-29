//
//  ViewController.swift
//  StreamTest
//
//  Created by Dmitry Rybochkin on 01.04.17.
//  Copyright © 2017 Dmitry Rybochkin. All rights reserved.
//

import ObjectMapper
import RealmSwift
import UIKit

class TableViewController: UITableViewController {
    var indicator: UIActivityIndicatorView?

    //let dataManager = DataManager.sharedManager
    var items: [PlaceModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 40.0

        if navigationController != nil {
            let navController: UINavigationController = navigationController!

            let views = navController.navigationBar.subviews.filter { element in element is UIActivityIndicatorView }

            if !views.isEmpty {
                indicator = views[0] as? UIActivityIndicatorView
            } else {
                let navBarSize: CGSize = navController.navigationBar.bounds.size
                let origin: CGPoint = CGPoint(x: navBarSize.width / 2, y: navBarSize.height / 2 )
                indicator = UIActivityIndicatorView(frame: CGRect(x: origin.x, y: origin.y, width: 0, height: 0))
                indicator?.activityIndicatorViewStyle = .whiteLarge
                indicator?.color = UIColor.red
                navController.navigationBar.addSubview(indicator!)
            }
        }

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(dataDidLoad(_:)),
                                               name: NSNotification.Name.StreamTestDataDidLoad,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(dataWillLoad(_:)),
                                               name: NSNotification.Name.StreamTestDataWillLoad,
                                               object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(locationChanged),
                                               name: NSNotification.Name.StreamTestLocationUpdated, object: nil)

        loadDataAndUpdateUI()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func dataWillLoad(_ notification: Notification) {
        showIndicator()
    }

    func dataDidLoad(_ notification: Notification) {
        if let needUpdate = notification.object as? Bool {
            if needUpdate {
                loadDataAndUpdateUI()
            }
        }
        hideIndicator()
    }

    func locationChanged() {
        self.tableView.reloadData()
    }

    func loadDataAndUpdateUI() {
        //items = dataManager.getItems(PlaceModel.self)
        self.tableView.reloadData()
    }

    func showIndicator() {
        print("showIndicator")
        indicator?.isHidden = false
        indicator?.startAnimating()
    }

    func hideIndicator() {
        print("hideIndicator")
        indicator?.isHidden = true
        indicator?.stopAnimating()
    }

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.currentContext
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceTableViewCell",
                                                    for: indexPath) as? PlaceTableViewCell {
            if !items.isEmpty {
                cell.titleLabel.text = items[indexPath.row].calcTitle
                cell.addressLabel.text = items[indexPath.row].address
                cell.sheduleLabel.text = items[indexPath.row].calcSchedule
                cell.distanceLabel.text = items[indexPath.row].location?.distance
                print("==>", items[indexPath.row].toJSON())
            }
            return cell
        } else {
            assert(false, "Unknown cell type.")
        }

        return UITableViewCell()
    }

    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if tableView.contentOffset.y >= (tableView.contentSize.height - tableView.bounds.size.height) {
            print("scrollViewDidEndDragging load data")
            NotificationCenter.default.post(name: Notification.Name.StreamTestDataLoad, object: nil)
        }
    }
}
