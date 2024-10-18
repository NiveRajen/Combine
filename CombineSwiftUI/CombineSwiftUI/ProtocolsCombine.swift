//
//  ProtocolsCombine.swift
//  CombineSwiftUI
//
//  Created by Nivedha Rajendran on 18.10.24.
//


import SwiftUI
import UIKit

protocol PersonProtocol {
    var firstName: String { get set }
    var lastName: String { get set }
    func getFullName() -> String
}

//Struct confirming to PersonalProtocol
struct DeveloperStruct: PersonProtocol {
    var firstName: String
    var lastName: String
    func getFullName() -> String {
        return firstName + " " + lastName
    }
}

//Class confirming to PersonalProtocol
class StudentClass: PersonProtocol {
    var firstName: String
    var lastName: String
    init(first: String, last: String) {
        firstName = first
        lastName = last
    }
    func getFullName() -> String {
        return lastName + ", " + firstName
    }
}

struct ProtocolCombine: View {
    var developer: PersonProtocol//Struct
    var student: PersonProtocol//Class
    
    var body: some View {
        VStack(spacing: 20) {
            HeaderView(title: "Protocols",
                       subtitle: "Definition",
                       desc: "Protocols allow you to define a blueprint of properties and functions.Then, you can create new structs and classes that conform or implement the protocol's properties and function.")
            Text(developer.getFullName())
            Text(student.getFullName())
        }
        .font(.title)
    }
}


struct ProtocolCombine_Previews: PreviewProvider {
    static var previews: some View {
        ProtocolCombine(developer: DeveloperStruct(firstName: "Nivedha", lastName: "Rajendran"), student: StudentClass(first: "Jack", last: "Sparrow"))
    }
}



struct HeaderView: View {
    @State var title: String
    @State var subtitle: String
    @State var desc: String
    
    init(title: String, subtitle: String, desc: String) {
        self.title = title
        self.subtitle = subtitle
        self.desc = desc
    }
    
    var body: some View {
        VStack(spacing: 20) {
            
            Text(title)
                .font(.largeTitle)
            Text(subtitle)
                .font(.headline)
                .foregroundColor(.secondary)
            Text(desc)
                .background(Color.yellow.opacity(0.1))
        }
    }
}
