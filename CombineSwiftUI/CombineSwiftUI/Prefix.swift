//
//  Prefix.swift
//  CombineSwiftUI
//
//  Created by Nivedha Rajendran on 22.10.24.
//
import SwiftUI
import Combine

struct PrefixView: View {
    
    @StateObject private var vm = PrefixViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            
            HeaderView(title: "Prefix",
                       subtitle: "Definition",
                       desc: "Use the prefix operator to get the first specified number of items from a pipeline.")
            
            Text("Limit Results")
            Slider(value: $vm.itemCount, in: 1...9, step: 1)
            Text("\(Int(vm.itemCount))")
            
            Text("Start Pipeline - Prefix Until")
                .foregroundColor(.blue)
                .onTapGesture {
                    vm.isPrefixUntil = true
                    vm.startPipeline.send()
                }
            Button("Simple Fetch Data") {
                vm.isPrefixUntil = false
                vm.fetch()
            }
            
            List(vm.data, id: \.self) { datum in
                Text(datum)
            }
            Spacer(minLength: 0)
            
            if vm.isPrefixUntil {
                Button("Close Pipeline") {
                    vm.stopPipeline.send()
                }
            }
        }
        .font(.title)
    }
}


struct PrefixView_Previews: PreviewProvider {
    static var previews: some View {
        PrefixView()
    }
}


class PrefixViewModel: ObservableObject {
    
    @Published var data: [String] = []
    
    @Published var itemCount = 5.0
    
    @Published var isPrefixUntil = false
    
    var startPipeline = PassthroughSubject<Void, Never>()
    
    var stopPipeline = PassthroughSubject<Void, Never>()
    
    private var cancellable: AnyCancellable?
    
    let timeFormatter = DateFormatter()
    
    init() {
        timeFormatter.timeStyle = .medium
        
        cancellable = Timer
            .publish(every: 0.5, on: .main, in: .common)
            .autoconnect()
        //You may notice the drop(untilOutputFrom:) operator is what turns on the flow of data.
            .drop(untilOutputFrom: startPipeline)
        //Once the prefix operator receives output from thestopPipeline it will no long republish items coming through the pipeline. This essentially shuts off the flow of data.
            .prefix(untilOutputFrom: stopPipeline)
            .map { datum in
                return self.timeFormatter.string(from: datum)
            }
            .sink{ [unowned self] (datum) in
                data.append(datum)
            }
    }
    
    func fetch() {
        data.removeAll()
        
        let fetchedData = ["Result 1", "Result 2", "Result 3", "Result 4", "Result 5", "Result 6", "Result 7", "Result 8", "Result 9"]
        
        //The prefix operator only republishes items up to the number you specify. It will then finish (close/stop) the pipeline even if there are more items.
        //Notice in this case I’m not storing the cancellable into a property because I don’t need to. After the pipeline finishes, I don’t have to hold on to a reference of it.
        _ = fetchedData.publisher
            .prefix(Int(itemCount))
            .sink { [unowned self] (result) in
                data.append(result)
            }
    }
    
    func fetchPrefixUntil() {
        
        
    }
}
