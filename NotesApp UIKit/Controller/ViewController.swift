//
//  ViewController.swift
//  NotesApp UIKit
//

import UIKit
import CoreData

class ViewController: UITableViewController {
    
    var notes: [Note] = []
    var fetchResultController: NSFetchedResultsController<Note>!
    
    lazy var dataSource = configureDataSource()
    
    enum Section{
        case all
    }
    
    @IBOutlet var emptyNoteView: UIView!

    @IBAction func unwindToHome(segue: UIStoryboardSegue){
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchNoteData()
        
        //    Appears text "Empty list" if there are no notes
        tableView.backgroundView = emptyNoteView
        tableView.backgroundView?.isHidden = notes.count == 0 ? false : true
    }

    func configureDataSource() -> UITableViewDiffableDataSource<Section, Note>{
        
        let dataSource = UITableViewDiffableDataSource<Section, Note>(
            tableView: tableView,
            cellProvider: { tableView, indexPath, notes in
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "notecell", for: indexPath) as! NoteTableViewCell
                
                cell.titleLabel.text = notes.title
                cell.noteLabel.text = notes.noteText
                
                return cell
            }
        )
        
        return dataSource
    }

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
//        Get the selected note
        guard let note = self.dataSource.itemIdentifier(for: indexPath) else {
            return UISwipeActionsConfiguration()
        }
        
//        Delete action
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") {(action, sourceView, completionHandler) in
            
            if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
                let context = appDelegate.persistentContainer.viewContext
                
//                Delete note
                context.delete(note)
                appDelegate.saveContext()
//                Update the view
                self.updateSnapshot(animationChange: true)
            }
//            Call completion handler to dismiss the action button
            completionHandler(true)
        }
        
        deleteAction.backgroundColor = UIColor.systemRed
        deleteAction.image = UIImage(systemName: "trash")
        
        let swipeConfiguration = UISwipeActionsConfiguration(actions: [deleteAction])
        return swipeConfiguration
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
                updateSnapshot()
            } catch {
                print(error)
            }
        }
    }
    
    func updateSnapshot(animationChange: Bool = false){
        if let fetchedObjects = fetchResultController.fetchedObjects{
            notes = fetchedObjects
        }

        var snapshot = NSDiffableDataSourceSnapshot<Section, Note>()
        snapshot.appendSections([.all])
        
//        Add new notes
        snapshot.appendItems(notes)
        
//        Update edited notes
        snapshot.reloadItems(notes)
        dataSource.apply(snapshot, animatingDifferences: animationChange)
        
        tableView.backgroundView?.isHidden = notes.count == 0 ? false : true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editNote" {
            if let indexPath = tableView.indexPathForSelectedRow{
                
                let dst = segue.destination as! UINavigationController
                let desctinationController = dst.topViewController as! EditNoteTableViewController
            
                desctinationController.currentNoteIndexPath = indexPath
            }
        }
    }
}

extension ViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        updateSnapshot()
    }
}
