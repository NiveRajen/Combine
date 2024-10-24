//
//  CollectByTime.swift
//  CombineSwiftUI
//
//  Created by Nivedha Rajendran on 24.10.24.
//

//You can set a time interval for the collect operator. During that interval, the collect operator will be adding items coming down the pipeline to an array. When the time interval is reached, the array is then published and the interval timer starts again.

//CollectByTimeOrCount - When using collect you can also set it with a time interval and a count. When one of these limits is reached, the items collected will be published.

import SwiftUI
import Combine

struct Collect_ByTimeView: View {
    
    @StateObject private var vm = Collect_ByTimeViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            HeaderView(title: "Collect",
                       subtitle: "By Time",
                       desc: "Collect items within a certain amount of time, put them into an array, and publish them with the collect by time operator.")
            .layoutPriority(1)
            
            Text(String(format: "Time Interval: %.1f seconds", vm.timeInterval))
            
            Slider(value: $vm.timeInterval, in: 0.1...1,
                   minimumValueLabel: Image(systemName: "hare"),
                   maximumValueLabel: Image(systemName: "tortoise"),
                   label: { Text("Interval") })
            .padding(.horizontal)
            
            Text("Collections")
            
            List(vm.collections, id: \.self) { items in
                Text(items.joined(separator: " "))
            }
        }
        .font(.title)
    }
}


class Collect_ByTimeViewModel: ObservableObject {
    
    @Published var timeInterval = 0.5
    
    //Since the collect operator publishes arrays, I created an array of arrays type to hold everything published.
    @Published var collections: [[String]] = []
    
    private var cancellables: Set<AnyCancellable> = []
    
    private var timerCancellable: AnyCancellable?
    
    init() {
        //Every time timeInterval changes (slider moves), call fetch().
        $timeInterval
            .sink { [unowned self] _ in
                fetch()
            }
            .store(in: &cancellables)
    }
    
    func fetch() {
        //Since the fetch function will get called repeatedly as the slider is moving, I’m canceling the pipeline so it starts all over again.
        collections.removeAll()
        timerCancellable?.cancel()
        
        timerCancellable = Timer
            .publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
        //Replace anything that comes down the pipeline with a O
            .map { _ in "O" }
        //RunLoop.main is basically a mechanism to specify where and how work is done. I’m specifying I want work done on the main thread. You could also use: DispatchQueue.main or OperationQueue.main
        //You can also use milliseconds, microseconds, etc.
        //By Time:
//            .collect(.byTime(RunLoop.main, .seconds(timeInterval)))
        
        //ByTimeOrCount
       // From what I can see from experimentation, it seems to publish when both the count and interval are reached. When you look at the screenshot, it is publishing every 4 items AND, after one second, it publishes whatever is remaining. I could be wrong on this but I couldn’t find any good documentation that breaks this down clearly
            .collect(.byTimeOrCount(RunLoop.main, .seconds(1), 4))
            .sink{ [unowned self] (collection) in
                collections.append(collection)
            }
    }
}

struct Collect_ByTimeView_Previews: PreviewProvider {
    static var previews: some View {
        Collect_ByTimeView()
    }
}
