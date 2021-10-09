//
//  CurrencyListViewController.swift
//  Wire-iOS
//
//  Created by Hexamon on 2018/5/9.
//  Copyright © 2018年 Sheng Shi Technology Co., Ltd. All rights reserved.
//

import UIKit

class CurrencyViewController: UITableViewController {

    public var vcType: Int = 0 /// 0-钱包，1-服务器所有币种

    public var notShowCoin: Wallet? /// 因需求，此处不能展示已被选中的coin

    public var selected: ((Wallet) -> Void)?

     ///最初的数据源
    private var originCurrencies: [Wallet] = [] {
        didSet {
            if originCurrencies.count == 0 {
                configureNavigationItems()
            }
            dispalyCurrencies = originCurrencies.filter({ !$0.isHide})
        }
    }

    ///搜索关键字
    fileprivate var searchKey: String? {
        didSet {
            guard let key = searchKey else {
                dispalyCurrencies = originCurrencies.filter({ !$0.isHide })
                return
            }
            guard key != ""  else {
                dispalyCurrencies = originCurrencies.filter({ !$0.isHide })
                return
            }
            dispalyCurrencies = originCurrencies//.filter({ $0.type.contains(key) && $0.isSearchable })
        }
    }

    ///展示数据源
    fileprivate var dispalyCurrencies: [Wallet] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    private var closePageHander: ((String) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "conversion.transfer.currencyList.title".localized

        tableView.registerCell(CurrencyCell.self)
//        tableView.tableHeaderView = {
//            let header = WBSearchIconHeader(width: tableView.bounds.width)
//            header.mTextField.placeholder = "CurrenciesSearchTVC.placeholder".localized
//            NotificationCenter.default.addObserver(self, selector: #selector(textDidChange), name: Notification.Name.UITextFieldTextDidChange, object: header.mTextField)
//            return header
//        }()

        tableView.tableFooterView = UIView()
    }

    @objc func textDidChange(noti: Notification) {
        if let textField = noti.object as? UITextField {
            guard let key = textField.text else {
                self.searchKey = nil
                return
            }
            self.searchKey = key.uppercased()
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getCurentcys()
    }

    private func getCurentcys() {
        navigationController?.showLoadingView = true

        if vcType == 0 {
            ///钱包币种
            WalletService.wallets { [weak self] result in
                guard let `self` = self else { return }
                self.navigationController?.showLoadingView = false
                switch result {
                case .success(let wallets):
                    self.originCurrencies = wallets.filter {
                        return ($0.isHide == false && $0.type != self.notShowCoin?.type)
                    }
                case .failure(let error): HUD.error(error)
                }
            }
        } else {
            ///服务器所有币种
//            WalletService.supportCoins { [weak self] result in
//                guard let `self` = self else { return }
//                self.navigationController?.showLoadingView = false
//                switch result {
//                case .success(let wallets):
//                    self.originCurrencies = wallets.filter {
//                        return $0.id != self.notShowCoin?.type
//                    }
//                case .failure(let error): HUD.error(error)
//                }
//            }

        }

    }

    func configureNavigationItems() {
        let addButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addCurrency))
        addButtonItem.accessibilityIdentifier = "addCurrencyButton"
        navigationItem.rightBarButtonItem = addButtonItem
    }

    @objc private func addCurrency() {
//        navigationController?.pushViewController(WBSearchIconTVC(), animated: true)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dispalyCurrencies.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(CurrencyCell.self, for: indexPath)
        cell.data = dispalyCurrencies[indexPath.row]
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 61
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selected?(dispalyCurrencies[indexPath.row])
        closePageHander?(dispalyCurrencies[indexPath.row].type)
        navigationController?.popViewController(animated: true)
    }

    func whenSelectCurrency(_ hander: @escaping (String) -> Void) {
        self.closePageHander = hander
    }

}
