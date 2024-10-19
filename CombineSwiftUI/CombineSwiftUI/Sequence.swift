//
//  Sequence.swift
//  CombineSwiftUI
//
//  Created by Nivedha Rajendran on 19.10.24.
//

import SwiftUI
import Combine

struct SequenceView: View {
    
    @StateObject private var vm = SequenceViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            HeaderView(title: "Sequence",
                       subtitle: "Introduction",
                       desc: "Arrays have a built-in sequence publisher property. This means a pipeline can be constructed right on the array.")
            List(vm.dataToView, id: \.self) { datum in
                Text(datum)
            }
        }
        .font(.title)
        .onAppear {
            vm.fetch()
        }
    }
}

struct SequenceView_Previews: PreviewProvider {
    static var previews: some View {
        SequenceView()
    }
}

class SequenceViewModel: ObservableObject {
    
    @Published var dataToView: [String] = []
    
    var cancellables: Set<AnyCancellable> = []
    
    func fetch() {
        //Many data types in Swift now have built-in publishers, including arrays and Strings
        var dataIn = ["Paul", "Lem", "Scott", "Chris", "Kaya", "Mark", "Adam", "Jared"]
        
        let dataInString = "Hello, World!"
        
        // Input type is [String], not String for Publisher
        //This means the array is passed into the publisher and the publisher iterates through all items in the array (and then the publisher finishes).
        dataIn.publisher
            .sink(receiveCompletion: { (completion) in
                print(completion)
            }, receiveValue: { [unowned self] datum in
                self.dataToView.append(datum)
                print(datum)
            })
            .store(in: &cancellables)
        // These values will NOT go through the pipeline.
        // The pipeline finishes after publishing the initial set.
        //Notice if you try to add more to the sequence later, the pipeline will not execute.
        //As soon as the initial sequence was published it was automatically finished as you can see with the print statement in the receiveCompletion  closure.
        dataIn.append(contentsOf: ["Rod", "Sean", "Karin"])
        
        //If you need to iterate over each character in a String you can use its publisher property.
        dataInString.publisher
            .sink { [unowned self] datum in
                self.dataToView.append(String(datum))
                print(datum)
            }
            .store(in: &cancellables)
    }
}
