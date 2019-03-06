//
//  OpenChannelsViewController.swift
//  ChatCamp Demo
//
//  Created by Tanmay Khandelwal on 10/02/18.
//  Copyright © 2018 iFlyLabs Inc. All rights reserved.
//

import UIKit
import ChatCamp
import SDWebImage
import MBProgressHUD

open class OpenChannelsViewController: UITableViewController {
    
    var channels: [CCPOpenChannel] = []
    fileprivate var loadingChannels = false
    var openChannelsQuery: CCPOpenChannelListQuery!
    lazy var messageLabel: UILabel = {
        let messageLabel = UILabel()
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        messageLabel.textColor = .black
        messageLabel.center = view.center
        messageLabel.text = "No Open Channels"
        
        return messageLabel
    }()
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        setupRefereshControl()

        openChannelsQuery = CCPOpenChannel.createOpenChannelListQuery()
        loadChannels()
    }
    
    fileprivate func setupTableView() {
        tableView.register(UINib(nibName: String(describing: ChatTableViewCell.self), bundle: Bundle(for: ChatTableViewCell.self)), forCellReuseIdentifier: ChatTableViewCell.string())
    }
    
    fileprivate func setupRefereshControl() {
        self.refreshControl = UIRefreshControl()
        guard let pullToRefreshControl = self.refreshControl else { return }
        pullToRefreshControl.addTarget(self, action:
            #selector(OpenChannelsViewController.handleRefresh(_:)),
                                       for: UIControl.Event.valueChanged)
        pullToRefreshControl.tintColor = UIColor(red: 48/255, green: 58/255, blue: 165/255, alpha: 1.0)
        tableView.addSubview(pullToRefreshControl)
    }
    
    fileprivate func loadChannels() {
        let progressHud = MBProgressHUD.showAdded(to: self.view, animated: true)
        progressHud.label.text = "Loading..."
        progressHud.contentColor = .black
        loadingChannels = true
        openChannelsQuery.load() { [weak self] (channels, error) in
            progressHud.hide(animated: true)
            if error == nil {
                if channels?.count == 0 && self?.channels.count == 0 {
                    guard let strongSelf = self else { return }
                    strongSelf.messageLabel.frame = strongSelf.view.bounds
                    strongSelf.view.addSubview(strongSelf.messageLabel)
                    strongSelf.view.bringSubviewToFront(strongSelf.messageLabel)
                    strongSelf.tableView.tableFooterView = UIView()
                } else {
                    self?.messageLabel.removeFromSuperview()
                    guard let channels = channels else { return }
                    self?.channels.append(contentsOf: channels)
                    
                    DispatchQueue.main.async {
                        self?.tableView.reloadData()
                        self?.loadingChannels = false
                    }
                }
                if self?.refreshControl?.isRefreshing ?? false {
                    self?.refreshControl?.endRefreshing()
                }
            } else {
                DispatchQueue.main.async {
                    self?.showAlert(title: "Can't Load Open Channels", message: "Unable to load Open Channels right now. Please try later.", actionText: "Ok")
                    self?.loadingChannels = false
                    if self?.refreshControl?.isRefreshing ?? false {
                        self?.refreshControl?.endRefreshing()
                    }
                }
            }
        }
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        openChannelsQuery = CCPOpenChannel.createOpenChannelListQuery()
        let progressHud = MBProgressHUD.showAdded(to: self.view, animated: true)
        progressHud.label.text = "Loading..."
        progressHud.contentColor = .black
        loadingChannels = true
        openChannelsQuery.load() { [weak self] (channels, error) in
            progressHud.hide(animated: true)
            if error == nil {
                if channels?.count == 0 {
                    guard let strongSelf = self else { return }
                    strongSelf.messageLabel.frame = strongSelf.view.bounds
                    strongSelf.view.addSubview(strongSelf.messageLabel)
                    strongSelf.view.bringSubviewToFront(strongSelf.messageLabel)
                    strongSelf.tableView.tableFooterView = UIView()
                } else {
                    self?.channels.removeAll()
                    self?.messageLabel.removeFromSuperview()
                    guard let channels = channels else { return }
                    self?.channels.append(contentsOf: channels)
                    
                    DispatchQueue.main.async {
                        self?.tableView.reloadData()
                        self?.loadingChannels = false
                    }
                }
                if self?.refreshControl?.isRefreshing ?? false {
                    self?.refreshControl?.endRefreshing()
                }
            } else {
                DispatchQueue.main.async {
                    self?.showAlert(title: "Can't Load Open Channels", message: "Unable to load Open Channels right now. Please try later.", actionText: "Ok")
                    self?.loadingChannels = false
                    if self?.refreshControl?.isRefreshing ?? false {
                        self?.refreshControl?.endRefreshing()
                    }
                }
            }
        }
    }
}

// MARK:- UITableViewDataSource
extension OpenChannelsViewController {
    override open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return channels.count
    }
    
    override open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ChatTableViewCell.string(), for: indexPath) as! ChatTableViewCell
        cell.nameLabel.centerYAnchor.constraint(equalTo: cell.centerYAnchor).isActive = true
        
        let channel = channels[indexPath.row]
        cell.messageLabel.isHidden = true
        cell.unreadCountLabel.isHidden = true
        cell.nameLabel.text = channel.getName()
        if let avatarUrl = channel.getAvatarUrl() {
            cell.avatarImageView?.sd_setImage(with: URL(string: avatarUrl), completed: nil)
        } else {
            cell.avatarImageView.setImageForName(string: channel.getName(), backgroundColor: nil, circular: true, textAttributes: nil)
        }
        
        return cell
    }
}

// MARK:- UITableViewDelegate
extension OpenChannelsViewController {
    
    override open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let userID = CCPClient.getCurrentUser().getId(), let username = CCPClient.getCurrentUser().getDisplayName() {
            let sender = Sender(id: userID, displayName: username)
            let channel = channels[indexPath.row]
            channel.join() { error in
                if error == nil {
                    print("Channel Joined")
                    let openChannelChatViewController = OpenChannelChatViewController(channel: channel, sender: sender)
                    self.navigationController?.pushViewController(openChannelChatViewController, animated: true)
                } else {
                    self.showAlert(title: "Error!", message: "Unable to join this open channel. Please try again.", actionText: "Ok")
                }
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK:- ScrollView Delegate Methods
extension OpenChannelsViewController {
    override open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if (tableView.indexPathsForVisibleRows?.contains([0, channels.count - 1]) ?? false) && !loadingChannels && channels.count >= 20 {
            loadChannels()
        }
    }
}
