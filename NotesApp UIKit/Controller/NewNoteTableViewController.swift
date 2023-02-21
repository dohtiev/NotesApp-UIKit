//
//  NewNoteTableViewController.swift
//  NotesApp UIKit
//

import UIKit
import CoreData

class NewNoteTableViewController: UITableViewController, UITextFieldDelegate, UITextViewDelegate {

    var note: Note!
    
    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var noteTextField: UITextView!
    
    @IBAction func saveButtonTapped(sender: UIButton){
//        test output
//        print(titleTextField.text!)
//        print(noteTextField.text!)
        
//        If the text of the note is empty, then it cannot be saved
//        Note can be saved without title
        if noteTextField.text == "" {
            let alertController = UIAlertController(title: "Oops..", message: "Note text is empty", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alertController.addAction(alertAction)
            present(alertController, animated: true, completion: nil)
            return
        }
        
//        Save to CoreData
        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
            note = Note(context: appDelegate.persistentContainer.viewContext)
            note.title = titleTextField.text!
            note.noteText = noteTextField.text!
            appDelegate.saveContext()
        }
        
        dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
}
