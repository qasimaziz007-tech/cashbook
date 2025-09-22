//
//  TransactionsViewController.swift
//  CashPro
//
//  Created on 2024
//  Copyright © 2024 Esthetics Auto. All rights reserved.
//

import UIKit
import CoreData

class TransactionsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var transactions: [Transaction] = []
    private var filteredTransactions: [Transaction] = []
    private let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupTableView()
        setupSearchController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadTransactions()
    }
    
    private func setupUI() {
        title = "Transactions"
        view.backgroundColor = Constants.Colors.background
        
        // Add navigation bar buttons
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addTransactionTapped)
        )
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "square.and.arrow.up"),
            style: .plain,
            target: self,
            action: #selector(exportTransactionsTapped)
        )
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "TransactionCell")
        
        // Add refresh control
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshTransactions), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search transactions..."
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    @objc private func addTransactionTapped() {
        showAddTransactionAlert()
    }
    
    @objc private func exportTransactionsTapped() {
        guard UserManager.shared.canExportData() else {
            showAlert(title: "Access Denied", message: "Only admin users can export data.")
            return
        }
        
        if let fileURL = ExportManager.shared.exportTransactionsToCSV(transactions) {
            ExportManager.shared.shareFile(fileURL, from: self)
        } else {
            showAlert(title: "Error", message: "Failed to export transactions.")
        }
    }
    
    @objc private func refreshTransactions() {
        loadTransactions()
        tableView.refreshControl?.endRefreshing()
    }
    
    private func loadTransactions() {
        transactions = CoreDataManager.shared.fetchTransactions()
        filterTransactions()
    }
    
    private func filterTransactions() {
        if searchController.isActive && !searchBarText.isEmpty {
            filteredTransactions = transactions.filter { transaction in
                return transaction.category?.lowercased().contains(searchBarText.lowercased()) == true ||
                       transaction.vendor?.lowercased().contains(searchBarText.lowercased()) == true ||
                       transaction.desc?.lowercased().contains(searchBarText.lowercased()) == true ||
                       transaction.transactionId?.lowercased().contains(searchBarText.lowercased()) == true
            }
        } else {
            filteredTransactions = transactions
        }
        
        tableView.reloadData()
    }
    
    private var searchBarText: String {
        return searchController.searchBar.text ?? ""
    }
    
    private func showAddTransactionAlert() {
        let alert = UIAlertController(title: "Add Transaction", message: "Enter transaction details", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Category"
        }
        
        alert.addTextField { textField in
            textField.placeholder = "Amount"
            textField.keyboardType = .decimalPad
        }
        
        alert.addTextField { textField in
            textField.placeholder = "Description (optional)"
        }
        
        let incomeAction = UIAlertAction(title: "Add Income", style: .default) { [weak self] _ in
            self?.createTransaction(type: .income, from: alert)
        }
        
        let expenseAction = UIAlertAction(title: "Add Expense", style: .destructive) { [weak self] _ in
            self?.createTransaction(type: .expense, from: alert)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(incomeAction)
        alert.addAction(expenseAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    private func createTransaction(type: Constants.TransactionType, from alert: UIAlertController) {
        guard let categoryField = alert.textFields?[0],
              let amountField = alert.textFields?[1],
              let descriptionField = alert.textFields?[2],
              let category = categoryField.text, !category.isEmpty,
              let amountText = amountField.text, !amountText.isEmpty,
              let amount = Decimal(string: amountText) else {
            showAlert(title: "Error", message: "Please fill in all required fields.")
            return
        }
        
        let context = CoreDataManager.shared.context
        let transaction = Transaction(context: context)
        
        transaction.id = UUID()
        transaction.date = Date()
        transaction.category = category
        transaction.amount = amount
        transaction.desc = descriptionField.text
        transaction.type = type.rawValue
        transaction.createdAt = Date()
        transaction.createdBy = UserManager.shared.getCurrentUsername()
        
        // Use default account (first one)
        let accounts = CoreDataManager.shared.fetchAccounts()
        if let firstAccount = accounts.first {
            transaction.account = firstAccount
        }
        
        CoreDataManager.shared.saveContext()
        loadTransactions()
        
        showAlert(title: "Success", message: "Transaction added successfully.")
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension TransactionsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredTransactions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionCell", for: indexPath)
        
        let transaction = filteredTransactions[indexPath.row]
        
        // Configure cell
        let amount = NSDecimalNumber(decimal: transaction.amount)
        let amountString = Constants.currencyFormatter.string(from: amount) ?? "0"
        
        if transaction.type == Constants.TransactionType.income.rawValue {
            cell.textLabel?.text = "+ \(amountString)"
            cell.textLabel?.textColor = Constants.Colors.success
        } else {
            cell.textLabel?.text = "- \(amountString)"
            cell.textLabel?.textColor = Constants.Colors.danger
        }
        
        let dateString = Constants.shortDateFormatter.string(from: transaction.date)
        cell.detailTextLabel?.text = "\(transaction.category ?? "") • \(dateString)"
        cell.detailTextLabel?.textColor = Constants.Colors.textSecondary
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension TransactionsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let transaction = filteredTransactions[indexPath.row]
        showTransactionDetails(transaction)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let transaction = filteredTransactions[indexPath.row]
        return UserManager.shared.canDeleteTransaction(transaction)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let transaction = filteredTransactions[indexPath.row]
            
            let alert = UIAlertController(title: "Delete Transaction", message: "Are you sure you want to delete this transaction?", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
                CoreDataManager.shared.delete(transaction)
                self?.loadTransactions()
            })
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            
            present(alert, animated: true)
        }
    }
    
    private func showTransactionDetails(_ transaction: Transaction) {
        let amount = NSDecimalNumber(decimal: transaction.amount)
        let amountString = Constants.currencyFormatter.string(from: amount) ?? "0"
        let dateString = Constants.dateFormatter.string(from: transaction.date)
        
        let message = """
        Amount: \(amountString)
        Category: \(transaction.category ?? "")
        Date: \(dateString)
        Account: \(transaction.account?.name ?? "")
        Description: \(transaction.desc ?? "None")
        Created by: \(transaction.createdBy ?? "")
        """
        
        let alert = UIAlertController(title: "Transaction Details", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UISearchResultsUpdating

extension TransactionsViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        filterTransactions()
    }
}