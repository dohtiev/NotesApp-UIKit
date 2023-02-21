//
//  EditNoteTableViewController.swift
//  NotesApp UIKit
//

import UIKit
import CoreData

class EditNoteTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    var note: Note!
    var currentNoteIndexPath: IndexPath = []
    var fetchResultController: NSFetchedResultsController<Note>!
    
    @IBOutlet var titleEditTextField: UITextField!
    
    @IBOutlet var noteEditTextField: UITextView!
    
    @IBAction func editButtonTapped(sender: UIButton){
        
        //        If the text of the note is empty, then it cannot be edited
        //        Note can be edited without title
        if noteEditTextField.text == "" {
            let alertController = UIAlertController(title: "Oops..", message: "Note text is empty", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alertController.addAction(alertAction)
            present(alertController, animated: true, completion: nil)
            return
        }
        
        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            let selectedNote = fetchResultController.object(at: currentNoteIndexPath) as NSManagedObject
            selectedNote.setValue(titleEditTextField.text, forKey: "title")
            selectedNote.setValue(noteEditTextField.text, forKey: "noteText")
            
            do {
                try appDelegate.save()
            } catch {
                print("Error")
            }
        }
        dismiss(animated: true, completion: nil)
    }

    func fetchNoteData(){
//        Fetch data from data store
        let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
            let context = appDelegate.persistentContainer.viewContext
            fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            fetchResultController.delegate = self
            
            do {
                try fetchResultController.performFetch()
            } catch {
                print(error)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchDataForCurrentNote(indexPath: currentNoteIndexPath)
    }

    func fetchDataForCurrentNote(indexPath: IndexPath){
        fetchNoteData()
        let selectedNote = fetchResultController.object(at: indexPath)
        
        titleEditTextField.text = selectedNote.title
        noteEditTextField.text = selectedNote.noteText
    }

}
