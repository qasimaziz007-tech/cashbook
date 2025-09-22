//
//  MainTabBarController.swift
//  CashPro
//
//  Created on 2024
//  Copyright © 2024 Esthetics Auto. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTabBar()
        setupViewControllers()
    }
    
    private func setupTabBar() {
        // Configure tab bar appearance
        tabBar.backgroundColor = UIColor.systemBackground
        tabBar.tintColor = Constants.Colors.brand
        tabBar.unselectedItemTintColor = Constants.Colors.textSecondary
        
        // Add shadow
        tabBar.layer.shadowColor = UIColor.black.cgColor
        tabBar.layer.shadowOpacity = 0.1
        tabBar.layer.shadowOffset = CGSize(width: 0, height: -2)
        tabBar.layer.shadowRadius = 4
    }
    
    private func setupViewControllers() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        // Dashboard
        let dashboardVC = storyboard.instantiateViewController(withIdentifier: Constants.StoryboardIDs.dashboardViewController) as! DashboardViewController
        let dashboardNav = UINavigationController(rootViewController: dashboardVC)
        dashboardNav.tabBarItem = UITabBarItem(title: "Dashboard", image: UIImage(systemName: "chart.pie.fill"), tag: 0)
        
        // Transactions
        let transactionsVC = storyboard.instantiateViewController(withIdentifier: Constants.StoryboardIDs.transactionsViewController) as! TransactionsViewController
        let transactionsNav = UINavigationController(rootViewController: transactionsVC)
        transactionsNav.tabBarItem = UITabBarItem(title: "Transactions", image: UIImage(systemName: "list.bullet.rectangle.portrait"), tag: 1)
        
        // Employees
        let employeesVC = storyboard.instantiateViewController(withIdentifier: Constants.StoryboardIDs.employeesViewController) as! EmployeesViewController
        let employeesNav = UINavigationController(rootViewController: employeesVC)
        employeesNav.tabBarItem = UITabBarItem(title: "Employees", image: UIImage(systemName: "person.2.fill"), tag: 2)
        
        // Parts
        let partsVC = storyboard.instantiateViewController(withIdentifier: Constants.StoryboardIDs.partsViewController) as! PartsViewController
        let partsNav = UINavigationController(rootViewController: partsVC)
        partsNav.tabBarItem = UITabBarItem(title: "Parts", image: UIImage(systemName: "gearshape.2.fill"), tag: 3)
        
        // Settings
        let settingsVC = storyboard.instantiateViewController(withIdentifier: Constants.StoryboardIDs.settingsViewController) as! SettingsViewController
        let settingsNav = UINavigationController(rootViewController: settingsVC)
        settingsNav.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(systemName: "gearshape.fill"), tag: 4)
        
        // Set view controllers
        viewControllers = [dashboardNav, transactionsNav, employeesNav, partsNav, settingsNav]
        
        // Configure navigation bar appearance for all view controllers
        configureNavigationBars([dashboardNav, transactionsNav, employeesNav, partsNav, settingsNav])
    }
    
    private func configureNavigationBars(_ navigationControllers: [UINavigationController]) {
        for navController in navigationControllers {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = Constants.Colors.brand
            appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
            appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
            
            navController.navigationBar.standardAppearance = appearance
            navController.navigationBar.scrollEdgeAppearance = appearance
            navController.navigationBar.compactAppearance = appearance
            navController.navigationBar.tintColor = UIColor.white
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Check if user is still logged in
        if !UserManager.shared.isUserLoggedIn() {
            showLoginScreen()
        }
    }
    
    private func showLoginScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginVC = storyboard.instantiateViewController(withIdentifier: Constants.StoryboardIDs.loginViewController) as! LoginViewController
        let navController = UINavigationController(rootViewController: loginVC)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: false)
    }
}