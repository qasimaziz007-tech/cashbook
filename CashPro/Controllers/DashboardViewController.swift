//
//  DashboardViewController.swift
//  CashPro
//
//  Created on 2024
//  Copyright © 2024 Esthetics Auto. All rights reserved.
//

import UIKit

class DashboardViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var totalBalanceLabel: UILabel!
    @IBOutlet weak var todayIncomeLabel: UILabel!
    @IBOutlet weak var todayExpenseLabel: UILabel!
    @IBOutlet weak var recentTransactionsTableView: UITableView!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    private var recentTransactions: [Transaction] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        refreshDashboard()
    }
    
    private func setupUI() {
        title = "Dashboard"
        view.backgroundColor = Constants.Colors.background
        
        // Configure welcome label
        welcomeLabel.text = "Welcome, \(UserManager.shared.getCurrentUsername())"
        welcomeLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        welcomeLabel.textColor = Constants.Colors.textPrimary
        
        // Configure balance labels
        totalBalanceLabel.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        todayIncomeLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        todayExpenseLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        
        // Add refresh control
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshDashboard), for: .valueChanged)
        scrollView.refreshControl = refreshControl
    }
    
    private func setupTableView() {
        recentTransactionsTableView.delegate = self
        recentTransactionsTableView.dataSource = self
        recentTransactionsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "TransactionCell")
        recentTransactionsTableView.isScrollEnabled = false
    }
    
    @objc private func refreshDashboard() {
        loadDashboardData()
        scrollView.refreshControl?.endRefreshing()
    }
    
    private func loadDashboardData() {
        let coreDataManager = CoreDataManager.shared
        
        // Load total balance
        let totalBalance = coreDataManager.getTotalBalance()
        totalBalanceLabel.text = Constants.currencyFormatter.string(from: NSDecimalNumber(decimal: totalBalance))
        totalBalanceLabel.textColor = totalBalance >= 0 ? Constants.Colors.success : Constants.Colors.danger
        
        // Load today's transactions
        let todayTransactions = coreDataManager.getTodayTransactions()
        var todayIncome: Decimal = 0
        var todayExpense: Decimal = 0
        
        for transaction in todayTransactions {
            if transaction.type == Constants.TransactionType.income.rawValue {
                todayIncome += transaction.amount
            } else {
                todayExpense += transaction.amount
            }
        }
        
        todayIncomeLabel.text = "+ \(Constants.currencyFormatter.string(from: NSDecimalNumber(decimal: todayIncome)) ?? "0")"
        todayIncomeLabel.textColor = Constants.Colors.success
        
        todayExpenseLabel.text = "- \(Constants.currencyFormatter.string(from: NSDecimalNumber(decimal: todayExpense)) ?? "0")"
        todayExpenseLabel.textColor = Constants.Colors.danger
        
        // Load recent transactions (last 10)
        let allTransactions = coreDataManager.fetchTransactions()
        recentTransactions = Array(allTransactions.prefix(10))
        recentTransactionsTableView.reloadData()
        
        // Update table view height
        updateTableViewHeight()
    }
    
    private func updateTableViewHeight() {
        let height = CGFloat(recentTransactions.count * 60) // Estimated row height
        tableViewHeightConstraint.constant = height
        view.layoutIfNeeded()
    }
}

// MARK: - UITableViewDataSource

extension DashboardViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recentTransactions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionCell", for: indexPath)
        
        let transaction = recentTransactions[indexPath.row]
        
        // Configure cell
        cell.textLabel?.text = transaction.category
        cell.detailTextLabel?.text = Constants.dateFormatter.string(from: transaction.date)
        
        // Configure amount display
        let amount = NSDecimalNumber(decimal: transaction.amount)
        let amountString = Constants.currencyFormatter.string(from: amount) ?? "0"
        
        if transaction.type == Constants.TransactionType.income.rawValue {
            cell.textLabel?.text = "+ \(amountString) | \(transaction.category ?? "")"
            cell.textLabel?.textColor = Constants.Colors.success
        } else {
            cell.textLabel?.text = "- \(amountString) | \(transaction.category ?? "")"
            cell.textLabel?.textColor = Constants.Colors.danger
        }
        
        cell.detailTextLabel?.textColor = Constants.Colors.textSecondary
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension DashboardViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Navigate to transactions tab
        if let tabBarController = self.tabBarController {
            tabBarController.selectedIndex = 1 // Transactions tab
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}