//
//  Published.swift
//  CombineSwiftUI
//
//  Created by Nivedha Rajendran on 18.10.24.
//

//Use the @Published property wrapper inside a class that conforms to ObservableObject.
//When the @Published properties change they will notify any view that subscribes to it.
//The view can subscribe to this ObservableObject by using the @StateObject property wrapper

import SwiftUI
import Combine

class PublishedViewModel: ObservableObject {
    @Published var state = "1. Begin State"
    @Published var changedState = ""
    @Published var name: String = ""
    @Published var validation: String = ""
    private var cancellable: AnyCancellable?
    private var validationCancellables: Set<AnyCancellable> = []
    
    @Published var firstName: String = ""
    @Published var firstNameValidation: String = ""
    @Published var lastName: String = ""
    @Published var lastNameValidation: String = ""
    
    var y = 4
    
    init() {
        // Change the name value after 1 second
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.state = "2. Second State"
        }
        //Your pipeline always starts with a publisher and always ends with a subscriber. - $name is a Publisher
        //You now need an operator that can evaluate every value that comes down through your pipeline to see if it’s empty or not.
        //use the map operator to write some code using the value coming through the pipeline.
        //The assign(to: ) subscriber will take the data coming down the pipeline and just drop it right into the @Published property you have specified.
        //The assign(to: ) ONLY works with @Published properties.
        
        $state //name- property, $name - Publisher
            .map {
                //The pipeline is run FIRST, before the property is even set.
                print("state property is now: \(self.state)")
                print("Value received is: \($0)")
                return "Processing..."
            }
            .assign(to: &$changedState)
        
        //            .assign(to: &$name) - This might cause recursion
        
        //Include ampersand to denote that the value will change in function
        doubleThis(value: &y)
        
        
        cancellable = $name
            .map { $0.isEmpty ? "❌ " : "✅ " }
            .delay(for: 5, scheduler: RunLoop.main)
        //Use unowned or weak to manage ARC
            .sink { [unowned self] value in
                self.validation = value
            }
        
        
        //Store in cancellables
        $firstName
            .map { $0.isEmpty ? "❌ " : "✅ " }
            .sink { [unowned self] value in
                self.firstNameValidation = value
            }
            .store(in: &validationCancellables)
        
        $lastName
            .map { $0.isEmpty ? "❌ " : "✅ " }
            .sink { [unowned self] value in
                self.lastNameValidation = value
            }
            .store(in: &validationCancellables)
    }
    
    //declare the value as inout so the value can be changed
    func doubleThis(value: inout Int) {
        value = value * 2
    }
    
    func cancel() {
        state = "Cancelled"
        cancellable?.cancel()
        cancellable = nil
    }
    
    func cancelAllValidations() {
        validationCancellables.removeAll()
    }
}

struct PublishedView: View {
    @StateObject private var vm = PublishedViewModel()
    
    @State private var message = ""
    
    var body: some View {
        VStack(spacing: 20) {
            HeaderView(title: "@Published",
                       subtitle: "Introduction",
                       desc: "The @Published property wrapper with the ObservableObject is the publisher. It sends out a message to the view whenever its value has changed. The StateObject property wrapper helps to make the view the subscriber.")
            
            HStack {
                TextField("state", text: $vm.state)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                //This can be moved to viewmodel
                //                    .onChange(of: vm.state, { oldValue, newValue in
                //                        message = newValue.isEmpty ? "❌ " : "✅ "
                //                    })
                
                Text(message)
            }
            Text(vm.state)
            
            HStack {
                TextField("name", text: $vm.name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Text(vm.validation)
            }
            
            
            DescView(desc: "When the state property changes after 1 second, the UI updates in response. This is read-only from your view model.")
            
            Button("Cancel Subscription") {
                vm.cancel()
            }
        }
        .font(.title)
    }
}


struct PublishedView_Previews: PreviewProvider {
    static var previews: some View {
        PublishedView()
    }
}


struct DescView: View {
    @State var desc: String
    
    init(desc: String) {
        self.desc = desc
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text(desc)
                .background(Color.yellow.opacity(0.1))
        }
    }
}
