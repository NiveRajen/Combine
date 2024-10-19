//
//  Timer.swift
//  CombineSwiftUI
//
//  Created by Nivedha Rajendran on 19.10.24.
//

import SwiftUI
import Combine

struct TimerView: View {
    
    @StateObject var vm = TimerViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            HeaderView(title: "Timer",
                       subtitle: "Definition",
                       desc: "The Timer continually publishes the updated date and time at an interval you specify.")
            Text("Adjust Interval")
            //The Timer publisher will be using the interval you are setting  with this Slider view. The shorter the interval, the faster the Timer publishes items.
            Slider(value: $vm.interval, in: 0.1...1,
                   minimumValueLabel: Image(systemName: "hare"),
                   maximumValueLabel: Image(systemName: "tortoise"),
                   label: { Text("Interval") })
            .padding(.horizontal)
            
            HStack {
                Button("Connect") { vm.startTimer() }
                    .frame(maxWidth: .infinity)
                Button("Stop") { vm.stopTimer() }
                    .frame(maxWidth: .infinity)
            }
            
            List(vm.data, id: \.self) { datum in
                Text(datum)
                    .font(.system(.title, design: .monospaced))
            }
        }
        .font(.title)
        .onAppear {
            vm.start()
        }
    }
}

struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        TimerView()
    }
}

class TimerViewModel: ObservableObject {
    
    @Published var data: [String] = []
    
    @Published var interval: Double = 1
    
    private var timerCancellable: AnyCancellable?
    
    private var intervalCancellable: AnyCancellable?
    
    let timeFormatter = DateFormatter()
    
    private var timerPublisher1 = Timer.publish(every: 0.2, on: .main, in: .common)
    
    private var timerCancellable1: Cancellable?
    
    init() {
        timeFormatter.dateFormat = "HH:mm:ss.SSS"
        //I created another pipeline on the interval published property so when it changes value, I can restart the timer’s pipeline so it reinitializes with the new interval value.
        intervalCancellable = $interval
            .dropFirst()
            .sink { [unowned self] interval in
                // Restart the timer pipeline
                timerCancellable?.cancel()
                data.removeAll()
                start()
            }
    }
    
    func start() {
        //You set the Timer’s interval with the publish modifier.
        //For the on parameter, I set .main to have this run on the main thread.
        //The last parameter is the RunLoop mode. (Run loops manage events and work and allow multiple things to happen simultaneously.)
        //In almost all cases you will just use the common run loop.
        //The autoconnect operator seen here allows the Timer to automatically start publishing items.
        timerCancellable = Timer
            .publish(every: interval, on: .main, in: .common)
            .autoconnect()
            .sink{ [unowned self] (datum) in
                data.append(timeFormatter.string(from: datum))
            }
    }
    
    func startTimer() {
        timerCancellable1 = timerPublisher1.connect()
    }
    func stopTimer() {
        timerCancellable1?.cancel()
        data.removeAll()
    }
}
