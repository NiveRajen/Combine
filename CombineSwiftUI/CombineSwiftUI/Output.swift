//
//  Output.swift
//  CombineSwiftUI
//
//  Created by Nivedha Rajendran on 16.11.24.
//


import SwiftUI
import Combine

struct OutputView: View {
    
    @StateObject private var vm = OutputViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            HeaderView(title: "Output(at: )",
             subtitle: "Introduction",
             desc: "Specify an index for the output operator and it will publish the item at that position.")
            .layoutPriority(1)
            
            Stepper("Start Index: \(vm.startIndex)", value: $vm.startIndex)
                .padding(.horizontal)
            
            Stepper("End Index: \(vm.endIndex)", value: $vm.endIndex)
             .padding(.horizontal)
            
            Text("Animal: \(vm.selection)")
             .italic()
             .font(.title3)
             .foregroundColor(.gray)
             .frame(maxWidth: .infinity, alignment: .leading)
             .padding(.horizontal)
            
            Text("Filtered Animals: \(vm.filteredAnimals)")
             .italic()
             .font(.title3)
             .foregroundColor(.gray)
             .frame(maxWidth: .infinity, alignment: .leading)
             .padding(.horizontal)
            
            Text("Smart Animals")
             .bold()
            
            List(vm.animals, id: \.self) { animal in
                Text(animal)
            }
        }
        .font(.title)
    }
}

//With the output(at:) operator, you can specify an index and when an item at that index comes through the pipeline it will be republished and the pipeline will finish. If you specify a number higher than the number of items that come through the pipeline before it finishes, then nothing is published. (You won’t get any index out-ofbounds errors.)

//You can also use the output operator to select a range of values that come through the pipeline. This operator says, “I will only republish items that match the index between this beginning number and this ending number.”

class OutputViewModel: ObservableObject {
    @Published var startIndex = 0
    
    @Published var endIndex = 5
    
    @Published var index = 0
    
    @Published var selection = ""
    
    @Published var animals = ["Chimpanzee", "Elephant", "Parrot", "Dolphin", "Pig", "Octopus"]
    
    @Published var filteredAnimals: [String] = []
    
    private var cancellable: AnyCancellable?
    
    var cancellables1: Set<AnyCancellable> = []
    
    init() {
        cancellable = $index
            .sink { [unowned self] in
                getAnimal(at: $0)
            }
        
        $startIndex
            .map { [unowned self] index in
                if index < 0 {
                    return 0
                } else if index > endIndex {
                    return endIndex
                }
                return index
            }
            .sink { [unowned self] index in
                getAnimals(between: index, end: endIndex)
            }
         .store(in: &cancellables1)
        
        $endIndex
            .map { [unowned self] index in
                index < startIndex ? startIndex : index
            }
            .sink { [unowned self] index in
                getAnimals(between: startIndex, end: index)
            }
         .store(in: &cancellables1)
    }
    
    func getAnimal(at index: Int) {
        animals.publisher
            .output(at: index)
            .assign(to: &$selection)
    }
    
    func getAnimals(between start: Int, end: Int) {
        filteredAnimals.removeAll()
        animals.publisher
            .output(in: start...end)
            .sink { [unowned self] animal in
                filteredAnimals.append(animal)
            }
            .store(in: &cancellables1)
    }
}

struct OutputView_Previews: PreviewProvider {
    static var previews: some View {
        OutputView()
    }
}
