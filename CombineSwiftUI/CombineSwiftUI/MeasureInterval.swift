//
//  MeasureInterval.swift
//  CombineSwiftUI
//
//  Created by Nivedha Rajendran on 22.10.24.
//

//The measureInterval operator will tell you how much time elapsed between one item and another coming through a pipeline. It publishes the timed interval. It will not republish the item values coming through the pipeline though.

import SwiftUI
import Combine

struct MeasureIntervalView: View {
    
    @StateObject private var vm = MeasureIntervalViewModel()
    
    @State private var ready = false
    
    @State private var showSpeed = false
    
    var body: some View {
        VStack(spacing: 20) {
            HeaderView(title: "MeasureInterval",
                       subtitle: "Introduction",
                       desc: "The measureInterval operator can measure how much time has elapsed between items sent through a publisher.")
            
            VStack(spacing: 20) {
                
                Text("Tap Start and then tap the rectangle when it turns green")
                
                //The timeEvent property here is a PassthroughSubject publisher. You can call send with no value to send something down the pipeline just so we can measure the interval between.
                Button("Start") {
                    DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 0.5...2.0)) {
                        ready = true
                        vm.timeEvent.send()
                    }
                }
                
                Button(action: {
                    vm.timeEvent.send()
                    showSpeed = true
                }, label: {
                    RoundedRectangle(cornerRadius: 25.0).fill(ready ? Color.green : Color.secondary)
                })
                //The idea here is that once you tap the Start button, the gray shape will turn green at a random time. As soon as it turns green you tap it to measure your reaction time!
                Text("Reaction Speed: \(vm.speed)")
                    .opacity(showSpeed ? 1 : 0)
            }
            .padding()
        }
        .font(.title)
    }
}


class MeasureIntervalViewModel: ObservableObject {
    
    @Published var speed: TimeInterval = 0.0
    
    var timeEvent = PassthroughSubject<Void, Never>()
    
    private var cancellable: AnyCancellable?
    
    init() {
        cancellable = timeEvent
            .measureInterval(using: RunLoop.main)
            .sink { [unowned self] (stride) in
                //The value of this time interval in seconds.
                //The measureInterval will republish a Stride type which is basically a form of elapsed time.
                speed = stride.timeInterval
            }
    }
}

struct MeasureInteval_Previews: PreviewProvider {
    static var previews: some View {
        MeasureIntervalView()
    }
}
