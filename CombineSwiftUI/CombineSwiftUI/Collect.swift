//
//  Collect.swift
//  CombineSwiftUI
//
//  Created by Nivedha Rajendran on 24.10.24.
//

//The collect operator won’t let items pass through the pipeline. Instead, it will put all items into an array, and then when the pipeline finishes it will publish the array.

import SwiftUI
import Combine

struct CollectView: View {
    
    @StateObject private var vm = CollectViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            HeaderView(title: "Collect",
                       subtitle: "Definition",
                       desc: "This operator collects values into an array. When the pipeline finishes, it publishes the array.")
            
            Toggle("Circles", isOn: $vm.circles)
                .padding()
            
            //Collect
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100, maximum: 200))]) {
                ForEach(vm.dataToView, id: \.self) { item in
                    Image(systemName: item)
                }
            }
            
            Spacer(minLength: 0)
        }
        .font(.title)
        .onAppear {
            vm.fetch()
        }
    }
}


class CollectViewModel: ObservableObject {
    
    @Published var dataToView: [String] = []
    
    @Published var circles = false
    
    private var cachedData: [Int] = []
    
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        $circles
            .sink { [unowned self] shape in formatData(shape: shape ? "circle" : "square") }
            .store(in: &cancellables)
    }
    
    func fetch() {
        cachedData = Array(1...25)
        formatData(shape: circles ? "circle" : "square")
    }
    
    //You will find that collect is great for SwiftUI because you can then use the assign(to:) subscriber. This means you don’t need to store a cancellable.
    func formatData(shape: String) {
        cachedData.publisher
            .map { "\($0).\(shape)" }
            .collect()
        //without collect
//            .sink { [unowned self] item in
//             dataToView.append(item)
//             }
            .assign(to: &$dataToView)
    }
}


struct CollectView_Previews: PreviewProvider {
    static var previews: some View {
        CollectView()
    }
}
