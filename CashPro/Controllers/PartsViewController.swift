//
//  PartsViewController.swift
//  CashPro
//
//  Created on 2024
//  Copyright © 2024 Esthetics Auto. All rights reserved.
//

import UIKit

class PartsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var parts: [Part] = []
    private let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupTableView()
        setupSearchController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadParts()
    }
    
    private func setupUI() {
        title = "Parts Management"
        view.backgroundColor = Constants.Colors.background
        
        // Add navigation bar buttons
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addPartTapped)
        )
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "square.and.arrow.up"),
            style: .plain,
            target: self,
            action: #selector(exportPartsTapped)
        )
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "PartCell")
        
        // Add refresh control
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshParts), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search parts..."
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    @objc private func addPartTapped() {
        showAddPartAlert()
    }
    
    @objc private func exportPartsTapped() {
        if let fileURL = ExportManager.shared.exportPartsToCSV(parts) {
            ExportManager.shared.shareFile(fileURL, from: self)
        } else {
            showAlert(title: "Error", message: "Failed to export parts.")
        }
    }
    
    @objc private func refreshParts() {
        loadParts()
        tableView.refreshControl?.endRefreshing()
    }
    
    private func loadParts() {
        parts = CoreDataManager.shared.fetchParts()
        tableView.reloadData()
    }
    
    private func showAddPartAlert() {
        let alert = UIAlertController(title: "Add Part", message: "Enter part details", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Part Name"
        }
        
        alert.addTextField { textField in
            textField.placeholder = "Part Number (optional)"
        }
        
        alert.addTextField { textField in
            textField.placeholder = "Price (AED)"
            textField.keyboardType = .decimalPad
        }
        
        alert.addTextField { textField in
            textField.placeholder = "Quantity"
            textField.keyboardType = .numberPad
        }
        
        alert.addTextField { textField in
            textField.placeholder = "Customer (optional)"
        }
        
        alert.addTextField { textField in
            textField.placeholder = "Vehicle (optional)"
        }
        
        alert.addTextField { textField in
            textField.placeholder = "Supplier (optional)"
        }
        
        let addAction = UIAlertAction(title: "Add Part", style: .default) { [weak self] _ in
            self?.createPart(from: alert)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    private func createPart(from alert: UIAlertController) {
        guard let nameField = alert.textFields?[0],
              let partNumberField = alert.textFields?[1],
              let priceField = alert.textFields?[2],
              let quantityField = alert.textFields?[3],
              let customerField = alert.textFields?[4],
              let vehicleField = alert.textFields?[5],
              let supplierField = alert.textFields?[6],
              let partName = nameField.text, !partName.isEmpty,
              let priceText = priceField.text, !priceText.isEmpty,
              let price = Decimal(string: priceText),
              let quantityText = quantityField.text, !quantityText.isEmpty,
              let quantity = Int32(quantityText) else {
            showAlert(title: "Error", message: "Please fill in all required fields.")
            return
        }
        
        let context = CoreDataManager.shared.context
        let part = Part(context: context)
        
        part.id = UUID()
        part.partName = partName
        part.partNumber = partNumberField.text
        part.price = price
        part.quantity = quantity
        part.customer = customerField.text
        part.vehicle = vehicleField.text
        part.supplier = supplierField.text
        
        CoreDataManager.shared.saveContext()
        loadParts()
        
        showAlert(title: "Success", message: "Part added successfully.")
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension PartsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return parts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PartCell", for: indexPath)
        
        let part = parts[indexPath.row]
        
        cell.textLabel?.text = part.partName
        cell.textLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        
        let price = NSDecimalNumber(decimal: part.price)
        let priceString = Constants.currencyFormatter.string(from: price) ?? "0"
        
        var detailText = "\(priceString) • Qty: \(part.quantity)"
        if let partNumber = part.partNumber, !partNumber.isEmpty {
            detailText = "\(partNumber) • \(detailText)"
        }
        
        cell.detailTextLabel?.text = detailText
        cell.detailTextLabel?.textColor = Constants.Colors.textSecondary
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension PartsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let part = parts[indexPath.row]
        showPartDetails(part)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let part = parts[indexPath.row]
            
            let alert = UIAlertController(title: "Delete Part", message: "Are you sure you want to delete \(part.partName ?? "this part")?", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
                CoreDataManager.shared.delete(part)
                self?.loadParts()
            })
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            
            present(alert, animated: true)
        }
    }
    
    private func showPartDetails(_ part: Part) {
        let price = NSDecimalNumber(decimal: part.price)
        let priceString = Constants.currencyFormatter.string(from: price) ?? "0"
        
        var message = """
        Part Name: \(part.partName ?? "")
        Price: \(priceString)
        Quantity: \(part.quantity)
        """
        
        if let partNumber = part.partNumber, !partNumber.isEmpty {
            message += "\nPart Number: \(partNumber)"
        }
        
        if let customer = part.customer, !customer.isEmpty {
            message += "\nCustomer: \(customer)"
        }
        
        if let vehicle = part.vehicle, !vehicle.isEmpty {
            message += "\nVehicle: \(vehicle)"
        }
        
        if let supplier = part.supplier, !supplier.isEmpty {
            message += "\nSupplier: \(supplier)"
        }
        
        let alert = UIAlertController(title: "Part Details", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UISearchResultsUpdating

extension PartsViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        // For simplicity, we're not implementing filtering here
        // In a full implementation, you would filter the parts array based on search text
        tableView.reloadData()
    }
}