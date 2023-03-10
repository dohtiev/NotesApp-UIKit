//
//  Note+CoreDataProperties.swift
//  NotesApp UIKit
//

import Foundation
import CoreData


extension Note {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Note> {
        return NSFetchRequest<Note>(entityName: "Note")
    }

    @NSManaged public var title: String?
    @NSManaged public var noteText: String?

}

extension Note : Identifiable {

}
