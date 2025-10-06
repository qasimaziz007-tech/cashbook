//
//  SettingsViewController.swift
//  CashPro
//
//  Created on 2024
//  Copyright © 2024 Esthetics Auto. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var settingsSections: [SettingsSection] = []
    
    struct SettingsSection {
        let title: String
        let items: [SettingsItem]
    }
    
    struct SettingsItem {
        let title: String
        let subtitle: String?
        let icon: String
        let action: () -> Void
        let showDisclosure: Bool
        
        init(title: String, subtitle: String? = nil, icon: String, showDisclosure: Bool = true, action: @escaping () -> Void) {
            self.title = title
            self.subtitle = subtitle
            self.icon = icon
            self.action = action
            self.showDisclosure = showDisclosure
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupTableView()
        setupSettingsSections()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupSettingsSections() // Refresh sections in case user role changed
    }
    
    private func setupUI() {
        title = "Settings"
        view.backgroundColor = Constants.Colors.background
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SettingsCell")
        tableView.backgroundColor = Constants.Colors.background
        tableView.separatorStyle = .none
    }
    
    private func setupSettingsSections() {
        settingsSections = []
        
        // Account Section
        let currentUser = UserManager.shared.getCurrentUsername()
        let currentRole = UserManager.shared.getCurrentUserRole().displayName
        
        var accountItems: [SettingsItem] = [
            SettingsItem(
                title: "Current User",
                subtitle: "\(currentUser) (\(currentRole))",
                icon: "person.fill",
                showDisclosure: false,
                action: {}
            ),
            SettingsItem(
                title: "Change Password",
                icon: "key.fill",
                action: { [weak self] in
                    self?.showChangePasswordAlert()
                }
            )
        ]
        
        if UserManager.shared.canManageUsers() {
            accountItems.append(
                SettingsItem(
                    title: "Manage Users",
                    icon: "person.2.fill",
                    action: { [weak self] in
                        self?.showUserManagement()
                    }
                )
            )
        }
        
        settingsSections.append(SettingsSection(title: "Account", items: accountItems))
        
        // Data Management Section (Admin Only)
        if UserManager.shared.isCurrentUserAdmin() {
            let dataItems: [SettingsItem] = [
                SettingsItem(
                    title: "Backup All Data",
                    subtitle: "Export all app data",
                    icon: "square.and.arrow.down.fill",
                    action: { [weak self] in
                        self?.backupAllData()
                    }
                ),
                SettingsItem(
                    title: "Clear All Data",
                    subtitle: "Delete all transactions and data",
                    icon: "trash.fill",
                    action: { [weak self] in
                        self?.showClearDataAlert()
                    }
                )
            ]
            
            settingsSections.append(SettingsSection(title: "Data Management", items: dataItems))
        }
        
        // App Information Section
        let appItems: [SettingsItem] = [
            SettingsItem(
                title: "Company",
                subtitle: Constants.companyName,
                icon: "building.2.fill",
                showDisclosure: false,
                action: {}
            ),
            SettingsItem(
                title: "Version",
                subtitle: "1.0.0",
                icon: "info.circle.fill",
                showDisclosure: false,
                action: {}
            ),
            SettingsItem(
                title: "Logout",
                icon: "rectangle.portrait.and.arrow.right.fill",
                action: { [weak self] in
                    self?.showLogoutAlert()
                }
            )
        ]
        
        settingsSections.append(SettingsSection(title: "App Information", items: appItems))
        
        tableView.reloadData()
    }
    
    // MARK: - Actions
    
    private func showChangePasswordAlert() {
        let alert = UIAlertController(title: "Change Password", message: "Enter your current and new password", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Current Password"
            textField.isSecureTextEntry = true
        }
        
        alert.addTextField { textField in
            textField.placeholder = "New Password"
            textField.isSecureTextEntry = true
        }
        
        alert.addTextField { textField in
            textField.placeholder = "Confirm New Password"
            textField.isSecureTextEntry = true
        }
        
        let changeAction = UIAlertAction(title: "Change Password", style: .default) { [weak self] _ in
            self?.changePassword(from: alert)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(changeAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    private func changePassword(from alert: UIAlertController) {
        guard let currentPasswordField = alert.textFields?[0],
              let newPasswordField = alert.textFields?[1],
              let confirmPasswordField = alert.textFields?[2],
              let currentPassword = currentPasswordField.text, !currentPassword.isEmpty,
              let newPassword = newPasswordField.text, !newPassword.isEmpty,
              let confirmPassword = confirmPasswordField.text, !confirmPassword.isEmpty else {
            showAlert(title: "Error", message: "Please fill in all fields.")
            return
        }
        
        guard newPassword == confirmPassword else {
            showAlert(title: "Error", message: "New passwords do not match.")
            return
        }
        
        if UserManager.shared.changePassword(currentPassword: currentPassword, newPassword: newPassword) {
            showAlert(title: "Success", message: "Password changed successfully.")
        } else {
            showAlert(title: "Error", message: "Current password is incorrect.")
        }
    }
    
    private func showUserManagement() {
        let alert = UIAlertController(title: "User Management", message: "Manage app users", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Add New User", style: .default) { [weak self] _ in
            self?.showAddUserAlert()
        })
        
        alert.addAction(UIAlertAction(title: "View All Users", style: .default) { [weak self] _ in
            self?.showAllUsers()
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        // For iPad
        if let popover = alert.popoverPresentationController {
            popover.sourceView = view
            popover.sourceRect = CGRect(x: view.frame.size.width / 2, y: view.frame.size.height / 2, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        present(alert, animated: true)
    }
    
    private func showAddUserAlert() {
        let alert = UIAlertController(title: "Add User", message: "Create a new user account", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Username"
        }
        
        alert.addTextField { textField in
            textField.placeholder = "Password"
            textField.isSecureTextEntry = true
        }
        
        let addAction = UIAlertAction(title: "Add User", style: .default) { [weak self] _ in
            self?.createUser(from: alert, role: .user)
        }
        
        let addAdminAction = UIAlertAction(title: "Add Admin", style: .default) { [weak self] _ in
            self?.createUser(from: alert, role: .admin)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(addAction)
        alert.addAction(addAdminAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    private func createUser(from alert: UIAlertController, role: Constants.UserRole) {
        guard let usernameField = alert.textFields?[0],
              let passwordField = alert.textFields?[1],
              let username = usernameField.text, !username.isEmpty,
              let password = passwordField.text, !password.isEmpty else {
            showAlert(title: "Error", message: "Please fill in all fields.")
            return
        }
        
        if UserManager.shared.createUser(username: username, password: password, role: role) {
            showAlert(title: "Success", message: "User created successfully.")
        } else {
            showAlert(title: "Error", message: "Username already exists.")
        }
    }
    
    private func showAllUsers() {
        let users = CoreDataManager.shared.fetchUsers()
        var message = "Current Users:\n\n"
        
        for user in users {
            message += "• \(user.username ?? "") (\(user.role?.capitalized ?? ""))\n"
        }
        
        let alert = UIAlertController(title: "All Users", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func backupAllData() {
        if let fileURL = ExportManager.shared.backupAllData() {
            ExportManager.shared.shareFile(fileURL, from: self)
        } else {
            showAlert(title: "Error", message: "Failed to create backup.")
        }
    }
    
    private func showClearDataAlert() {
        let alert = UIAlertController(
            title: "Clear All Data",
            message: "This will permanently delete all transactions, employees, and parts data. This action cannot be undone.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Clear Data", style: .destructive) { [weak self] _ in
            CoreDataManager.shared.deleteAllData()
            self?.showAlert(title: "Success", message: "All data has been cleared.")
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    private func showLogoutAlert() {
        let alert = UIAlertController(title: "Logout", message: "Are you sure you want to logout?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Logout", style: .destructive) { [weak self] _ in
            self?.logout()
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    private func logout() {
        UserManager.shared.logout()
        
        // Navigate to login screen
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginVC = storyboard.instantiateViewController(withIdentifier: Constants.StoryboardIDs.loginViewController) as! LoginViewController
        let navController = UINavigationController(rootViewController: loginVC)
        
        if let sceneDelegate = view.window?.windowScene?.delegate as? SceneDelegate {
            sceneDelegate.window?.rootViewController = navController
            sceneDelegate.window?.makeKeyAndVisible()
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension SettingsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return settingsSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingsSections[section].items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath)
        
        let item = settingsSections[indexPath.section].items[indexPath.row]
        
        cell.textLabel?.text = item.title
        cell.detailTextLabel?.text = item.subtitle
        cell.imageView?.image = UIImage(systemName: item.icon)
        cell.imageView?.tintColor = Constants.Colors.brand
        cell.accessoryType = item.showDisclosure ? .disclosureIndicator : .none
        
        cell.backgroundColor = Constants.Colors.cardBackground
        cell.layer.cornerRadius = 8
        cell.layer.masksToBounds = true
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return settingsSections[section].title
    }
}

// MARK: - UITableViewDelegate

extension SettingsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = settingsSections[indexPath.section].items[indexPath.row]
        item.action()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = Constants.Colors.background
        
        let titleLabel = UILabel()
        titleLabel.text = settingsSections[section].title
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = Constants.Colors.textPrimary
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        headerView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            titleLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -8)
        ])
        
        return headerView
    }
}