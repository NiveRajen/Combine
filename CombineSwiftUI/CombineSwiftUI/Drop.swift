//
//  Drop.swift
//  CombineSwiftUI
//
//  Created by Nivedha Rajendran on 22.10.24.
//

import SwiftUI
import Combine

//“In Combine, when the term “drop” is used, it means to not publish or send the item down the pipeline. When an item is “dropped”, it will not reach the subscriber. So with the drop(untilOutputFrom:) operator, the main pipeline will not publish its items until it receives an item from a second pipeline that signals “it’s ok to start publishing now.”

struct DropView: View {
    
    @StateObject private var vm = DropViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            HeaderView(title: "Drop(untilOutputFrom: )",
                       subtitle: "Introduction",
                       desc: "This operator will prevent items from being published until it gets data from another publisher.")
            Button("Open Pipeline") {
                //The idea here is that you have a publisher that may or may not be sending out data. But it won’t reach the subscriber (or ultimately, the UI) unless a second publisher sends out data too.
                //The second publisher is what opens the flow of data on the first publisher.
                //This Button sends a value through the second publisher.
                vm.startPipeline.send(true)
            }
            List(vm.data, id: \.self) { datum in
                Text(datum)
            }
            Spacer(minLength: 0)
            Button("Close Pipeline") {
                //I’m not actually “closing” a pipeline. I’m just removing it from memory which will stop it from publishing data.
                vm.cancellables.removeAll()
            }
        }
        .font(.title)
    }
}


class DropViewModel: ObservableObject {
    @Published var data: [String] = []
    
    //In this example, I use a PassthroughSubject<Bool, Never> but you don’t really have to send a value through to trigger the drop operator. I could have just used PassthroughSubject<Void, Never> and on the UI, the button code would be: vm.startPipeline.send()
    var startPipeline = PassthroughSubject<Bool, Never>()
    
    var cancellables: [AnyCancellable] = []
    
    let timeFormatter = DateFormatter()
    
    init() {
        timeFormatter.timeStyle = .medium
//        dropUntil()
        
//        dropFirst()
        
        dropFirstCount()
    }
    
    func dropUntil() {
        Timer.publish(every: 0.5, on: .main, in: .common)
            .autoconnect()
        //When the startPipeline receives a value it sends it straight through and the Timer publisher detects it and that’s when the pipeline is fully connected and data can freely flow through to the subscriber.
        //More values sent through the startPipeline have no effect on the Timer’s pipeline.
            .drop(untilOutputFrom: startPipeline)
            .map { datum in
                return self.timeFormatter.string(from: datum)
            }
            .sink{ [unowned self] (datum) in
                data.append(datum)
            }
            .store(in: &cancellables)
        
    }
    
    func dropFirst() {
        Timer.publish(every: 0.5, on: .main, in: .common)
            .autoconnect()
        //The dropFirst operator can prevent a certain number of items from initially being published.
            .dropFirst()
            .map { datum in
                return self.timeFormatter.string(from: datum)
            }
            .sink{ [unowned self] (datum) in
                data.append(datum)
            }
            .store(in: &cancellables)
    }
    
    func dropFirstCount() {
        Timer.publish(every: 0.5, on: .main, in: .common)
            .autoconnect()
        //  I want to skip first 4 items using the dropFirst operator.
            .dropFirst(4)
            .map { datum in
                return self.timeFormatter.string(from: datum)
            }
            .sink{ [unowned self] (datum) in
                data.append(datum)
            }
            .store(in: &cancellables)
    }
}

struct DropView_Previews: PreviewProvider {
    static var previews: some View {
        DropView()
    }
}
