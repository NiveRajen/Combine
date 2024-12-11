//
//  Assignto.swift
//  CombineSwiftUI
//
//  Created by Nivedha Rajendran on 10.12.24.
//

import SwiftUI
//“The assign(to:) subscriber receives values and directly assigns the value to a @Published property. This is a special subscriber that works with published properties. In a SwiftUI app, this is a very common subscriber.”


struct Assignto: View {
    @StateObject private var vm = AssignToViewModel()
    var body: some View {
        VStack(spacing: 20) {
            HeaderView(title: "Assign To",
                       subtitle: "Introduction",
                       desc: "The assign(to:) subscriber is very specific to JUST @Published properties. It will easily allow you to add the value that come down the pipeline to your published properties which will then notify and update your views.")
            Text(vm.greeting)
        }
        .font(.title)
        .onAppear {
            vm.fetch()
        }
    }
}

class AssignToViewModel: ObservableObject {
    @Published var name = ""
    @Published var greeting = ""
    
    init() {
        //“Pipeline: Whenever the name changes, the greeting is automatically updated.”
        //“No AnyCancellable : Notice you don’t have to keep a reference to an AnyCancellable type.This is because Combine will automatically handle this for you.  This feature is exclusive to just this subscriber. When this view model is de-initialized and then the @Published properties de-initialize, the pipeline will automatically be canceled.”
        
        $name
            .map { [unowned self] name in
                createGreeting(with: name)
            }            .assign(to: &$greeting)
    }
    
    func fetch() {
        name = "Developer"
    }
    
    func createGreeting(with name: String) -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        
        var prefix = ""
        switch hour {
        case 0..<12:
            prefix = "Good morning, "
        case 12..<18:
            prefix = "Good afternoon, "
        default:
            prefix = "Good evening, "
        }
        return prefix + name
    }
}

#Preview {
    Assignto()
}
