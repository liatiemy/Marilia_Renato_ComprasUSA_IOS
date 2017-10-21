//
//  SettingsViewController.swift
//  ComprasUSA
//
//  Created by Lia Tiemy on 30/09/17.
//  Copyright © 2017 FIAP. All rights reserved.
//

import UIKit
import CoreData

enum StateType {
    case add
    case edit
}

class SettingsViewController: UIViewController {

    @IBOutlet weak var tfCotacao: UITextField!
    @IBOutlet weak var tfIof: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    var dataSource: [State] = []
    var products: [Product] = []
    var product: Product!
    
    
    @IBAction func addState(_ sender: UIButton) {
        showAlert(type: .add, state: nil)
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tfCotacao.delegate = self
        tfIof.delegate = self
        
        loadStates()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tfCotacao.text = UserDefaults.standard.string(forKey: "cotacao")
        tfIof.text = UserDefaults.standard.string(forKey: "iof")
        
    }
    

    func loadStates() {
        let fetchRequest: NSFetchRequest<State> = State.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "state", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            dataSource = try context.fetch(fetchRequest)
            tableView.reloadData()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func showAlert(type: StateType, state: State?) {
        let title = (type == .add) ? "Adicionar" : "Editar"
        let alert = UIAlertController(title: "Adicionar Estado", message: nil, preferredStyle: .alert)
            
            //title: "\(state) Estado", message: nil, preferredStyle: .alert)
        alert.addTextField { (textField: UITextField) in
            textField.placeholder = "Nome do estado"
            if let name = state?.state {
                textField.text = name
            }
        }
        
        alert.addTextField{(textField: UITextField) in
            textField.placeholder = "Imposto"
            if let tax = state?.tax{
                textField.text = "\(tax)"
            }
            textField.keyboardType = .numbersAndPunctuation
        }
        
        alert.addAction(UIAlertAction(title: title, style: .default, handler: { (action: UIAlertAction) in
            let category = state ?? State(context: self.context)
            category.state = alert.textFields?.first?.text
            if let tax = alert.textFields?.last?.text {
                category.tax = Double(tax)!
            }
            do {
                try self.context.save()
                self.loadStates()
                
            } catch {
                print(error.localizedDescription)
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    @IBAction func changeDolar(_ sender: UITextField) {
        UserDefaults.standard.set(tfCotacao.text, forKey: "cotacao")
    }
    
    @IBAction func changeIOF(_ sender: UITextField) {
        UserDefaults.standard.set(tfIof.text, forKey: "iof")
    }
    
}


extension SettingsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        print("entrei no excluir estado")
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Excluir") { (action: UITableViewRowAction, indexPath: IndexPath) in
            let state = self.dataSource[indexPath.row]
            
            
            if let stateName = state.state {
                print("o estado que sera deletado \(stateName)")
                
//                let fetchRequest: NSFetchRequest<Product> = Product.fetchRequest()
//                fetchRequest.predicate = NSPredicate(format: "state = '%@'", stateName)
                //NSPredicate(format: "state = '%@'", stateName)
                
                    let res: [Product] = state.products?.filter{($0 as! Product).state?.state == stateName} as! [Product]
                    print(res.count)
                    for result in res
                    {
                        print(result.product)
                        self.context.delete(result)
                    }
                
                
//                do {
//                    self.products = try self.context.fetch(fetchRequest)
//                    print(self.products.count)
//                    for product in self.products{
//                        print(product)
//                        self.context.delete(product)
//                    }
//                } catch {
//                    print(error.localizedDescription)
//                }
            }
            
            
            
            self.context.delete(state)
            try! self.context.save()
            self.dataSource.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        
        let editAction = UITableViewRowAction(style: .normal, title: "Editar") { (action: UITableViewRowAction, indexPath: IndexPath) in
            let states = self.dataSource[indexPath.row]
            tableView.setEditing(false, animated: true)
            self.showAlert(type: .edit, state: states)
        }
        editAction.backgroundColor = .blue
        return [editAction, deleteAction]
    }
}

// MARK: - UITableViewDelegate
extension SettingsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! StateTableViewCell
        let state = dataSource[indexPath.row]
        cell.tfEstado.text = state.state
        cell.tfTaxa.text = "\(state.tax)"
        cell.accessoryType = .none
        return cell
    }
}


extension SettingsViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}



