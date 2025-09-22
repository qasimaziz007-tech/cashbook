//
//  EmployeesViewController.swift
//  CashPro
//
//  Created on 2024
//  Copyright © 2024 Esthetics Auto. All rights reserved.
//

import UIKit

class EmployeesViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var employees: [Employee] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        checkAccess()
        loadEmployees()
    }
    
    private func setupUI() {
        title = "Employees"
        view.backgroundColor = Constants.Colors.background
        
        // Add navigation bar buttons
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addEmployeeTapped)
        )
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "square.and.arrow.up"),
            style: .plain,
            target: self,
            action: #selector(exportEmployeesTapped)
        )
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "EmployeeCell")
        
        // Add refresh control
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshEmployees), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    private func checkAccess() {
        if !UserManager.shared.canManageEmployees() {
            let accessDeniedView = createAccessDeniedView()
            view.addSubview(accessDeniedView)
            accessDeniedView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                accessDeniedView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                accessDeniedView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                accessDeniedView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                accessDeniedView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
            ])
            
            tableView.isHidden = true
            navigationItem.rightBarButtonItem = nil
            navigationItem.leftBarButtonItem = nil
        }
    }
    
    private func createAccessDeniedView() -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = Constants.Colors.cardBackground
        containerView.layer.cornerRadius = 12
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.1
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 4
        
        let iconImageView = UIImageView(image: UIImage(systemName: "lock.fill"))
        iconImageView.tintColor = Constants.Colors.textSecondary
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = "Access Restricted"
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        titleLabel.textColor = Constants.Colors.textPrimary
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let messageLabel = UILabel()
        messageLabel.text = "Only admin users can manage employees."
        messageLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        messageLabel.textColor = Constants.Colors.textSecondary
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(iconImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(messageLabel)
        
        NSLayoutConstraint.activate([
            iconImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 30),
            iconImageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 60),
            iconImageView.heightAnchor.constraint(equalToConstant: 60),
            
            titleLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            messageLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            messageLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            messageLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -30)
        ])
        
        return containerView
    }
    
    @objc private func addEmployeeTapped() {
        showAddEmployeeAlert()
    }
    
    @objc private func exportEmployeesTapped() {
        guard UserManager.shared.canExportData() else {
            showAlert(title: "Access Denied", message: "Only admin users can export data.")
            return
        }
        
        if let fileURL = ExportManager.shared.exportEmployeesToCSV(employees) {
            ExportManager.shared.shareFile(fileURL, from: self)
        } else {
            showAlert(title: "Error", message: "Failed to export employees.")
        }
    }
    
    @objc private func refreshEmployees() {
        loadEmployees()
        tableView.refreshControl?.endRefreshing()
    }
    
    private func loadEmployees() {
        employees = CoreDataManager.shared.fetchEmployees()
        tableView.reloadData()
    }
    
    private func showAddEmployeeAlert() {
        let alert = UIAlertController(title: "Add Employee", message: "Enter employee details", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Full Name"
        }
        
        alert.addTextField { textField in
            textField.placeholder = "Phone Number"
            textField.keyboardType = .phonePad
        }
        
        alert.addTextField { textField in
            textField.placeholder = "Salary (AED)"
            textField.keyboardType = .decimalPad
        }
        
        alert.addTextField { textField in
            textField.placeholder = "Designation (optional)"
        }
        
        let addAction = UIAlertAction(title: "Add Employee", style: .default) { [weak self] _ in
            self?.createEmployee(from: alert)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    private func createEmployee(from alert: UIAlertController) {
        guard let nameField = alert.textFields?[0],
              let phoneField = alert.textFields?[1],
              let salaryField = alert.textFields?[2],
              let designationField = alert.textFields?[3],
              let name = nameField.text, !name.isEmpty,
              let phone = phoneField.text, !phone.isEmpty,
              let salaryText = salaryField.text, !salaryText.isEmpty,
              let salary = Decimal(string: salaryText) else {
            showAlert(title: "Error", message: "Please fill in all required fields.")
            return
        }
        
        let context = CoreDataManager.shared.context
        let employee = Employee(context: context)
        
        employee.id = UUID()
        employee.name = name
        employee.phone = phone
        employee.salary = salary
        employee.designation = designationField.text
        employee.joinDate = Date()
        
        CoreDataManager.shared.saveContext()
        loadEmployees()
        
        showAlert(title: "Success", message: "Employee added successfully.")
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension EmployeesViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return employees.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EmployeeCell", for: indexPath)
        
        let employee = employees[indexPath.row]
        
        cell.textLabel?.text = employee.name
        cell.textLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        
        let salary = NSDecimalNumber(decimal: employee.salary)
        let salaryString = Constants.currencyFormatter.string(from: salary) ?? "0"
        
        var detailText = salaryString
        if let designation = employee.designation, !designation.isEmpty {
            detailText = "\(designation) • \(salaryString)"
        }
        
        cell.detailTextLabel?.text = detailText
        cell.detailTextLabel?.textColor = Constants.Colors.textSecondary
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension EmployeesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let employee = employees[indexPath.row]
        showEmployeeDetails(employee)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return UserManager.shared.canManageEmployees()
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let employee = employees[indexPath.row]
            
            let alert = UIAlertController(title: "Delete Employee", message: "Are you sure you want to delete \(employee.name ?? "this employee")?", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
                CoreDataManager.shared.delete(employee)
                self?.loadEmployees()
            })
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            
            present(alert, animated: true)
        }
    }
    
    private func showEmployeeDetails(_ employee: Employee) {
        let salary = NSDecimalNumber(decimal: employee.salary)
        let salaryString = Constants.currencyFormatter.string(from: salary) ?? "0"
        let joinDateString = Constants.dateFormatter.string(from: employee.joinDate)
        
        var message = """
        Name: \(employee.name ?? "")
        Phone: \(employee.phone ?? "")
        Salary: \(salaryString)
        Join Date: \(joinDateString)
        """
        
        if let designation = employee.designation, !designation.isEmpty {
            message += "\nDesignation: \(designation)"
        }
        
        if let email = employee.email, !email.isEmpty {
            message += "\nEmail: \(email)"
        }
        
        if let emiratesId = employee.emiratesId, !emiratesId.isEmpty {
            message += "\nEmirates ID: \(emiratesId)"
        }
        
        if let visaExpiry = employee.visaExpiry {
            let visaExpiryString = Constants.dateFormatter.string(from: visaExpiry)
            message += "\nVisa Expiry: \(visaExpiryString)"
        }
        
        let alert = UIAlertController(title: "Employee Details", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}