//
//  ViewController.swift
//  WordAnagram
//
//  Created by Omkar Khanvilkar on 4/3/19.
//  Copyright © 2019 Omkar Khanvilkar. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    var allWords = [String]()
    var usedWords = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .play, target: self, action: #selector(startGame))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
        
        if let startFileURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startFileURL) {
                allWords = startWords.components(separatedBy: "\n")
            }
        }
        if allWords.isEmpty {
            allWords = ["Silkworm"]
        }
        startGame()
    }

    
    @objc func startGame()  {
        title = allWords.randomElement()
        usedWords.removeAll(keepingCapacity: true)
        tableView.reloadData()
    }
    
    @objc func promptForAnswer() {
        let ac = UIAlertController(title: "Enter Answer", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) {
            [weak self, weak ac] _ in
            guard let answer = ac?.textFields?[0].text else {
                return
            }
            self?.submit(answer)
        }
        
        ac.addAction(submitAction)
        present(ac, animated: true)
    }
    
    func submit(_ answer: String)  {
        let lowerAns = answer.lowercased()
        let eTitle: String
        let eMessage: String
        if isPossible(word: lowerAns) {
            if isOriginal(word: lowerAns) {
                if isReal(word: lowerAns) {
                    usedWords.insert(answer, at: 0 )
                    let indexpath = IndexPath(row: 0, section: 0)
                    tableView.insertRows(at: [indexpath], with: .automatic)
                    return
                } else {
                    eTitle = "Not a real word"
                    eMessage = "You can't just make things up!"
                }
            }else {
                eTitle = "Word already used"
                eMessage = "Be more original"
            }
        }else {
            guard let title = title else {return}
            eTitle = "Word not possible"
            eMessage = "You can't spell that from \(title.lowercased())"
        }
        showErrorMessage(title: eTitle, message: eMessage)
    }
    
    func showErrorMessage(title: String, message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    func isPossible(word: String) -> Bool {
        guard var tempWord = title?.lowercased() else {return false}
        
        for letter in word {
            if let poition = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: poition)
            }
            else {
                return false
            }
        }
        return true
    }
    
    func isOriginal(word: String) -> Bool {
        return !usedWords.contains(word)
    }
    
    func isReal(word: String) -> Bool {
        
        if word.count < 3 || word == title { return false }
        
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspellRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspellRange.location == NSNotFound
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usedWords.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        cell.textLabel?.text = usedWords[indexPath.row]
        return cell
    }

}

