//
//  Throttle.swift
//  CombineSwiftUI
//
//  Created by Nivedha Rajendran on 22.10.24.
//

//If you are getting a lot of data quickly and you don’t want SwiftUI to needlessly keep redrawing your view then the throttle operator might be just the thing you’re looking for.
//You can set an interval and then republish just one value out of the many you received during that interval. For example, you can set a 2-second interval. And during those 2 seconds, you may have received 200 values. You have the choice to republish just the most recent value received or the first value received.

import SwiftUI
import Combine

struct ThrottleView: View {
    
    @StateObject private var vm = ThrottleViewModel()

    @State private var startStop = true
    
    var body: some View {
        VStack(spacing: 20) {
            HeaderView(title: "Throttle",
                       subtitle: "Introduction",
                       desc: "Set a time interval and specify if you want the first or last item received within that interval republished.")
            .layoutPriority(1)
            
            Text("Adjust Throttle")
            
            Slider(value: $vm.throttleValue, in: 0.1...1,
                   minimumValueLabel: Image(systemName: "hare"),
                   maximumValueLabel: Image(systemName: "tortoise"),
                   label: { Text("Throttle") })
            .padding(.horizontal)
            
            HStack {
                //This button will toggle from Start to Stop. We’re calling the same start function on the view model though so it will handle turning the pipeline on or off.
                Button(startStop ? "Start" : "Stop") {
                    startStop.toggle()
                    vm.start()
                }
                .frame(maxWidth: .infinity)
                Button("Reset") { vm.reset() }
                    .frame(maxWidth: .infinity)
            }
            
            List(vm.data, id: \.self) { datum in
                Text(datum)
            }
        }
        .font(.title)
    }
}


class ThrottleViewModel: ObservableObject {
    
    @Published var data: [String] = []
    
    var throttleValue: Double = 0.5
    
    private var cancellable: AnyCancellable?
    
    let timeFormatter = DateFormatter()
    
    init() {
        timeFormatter.dateFormat = "HH:mm:ss.SSS"
    }
    
    func start() {
        if (cancellable != nil) {
            cancellable = nil
        } else {
            cancellable = Timer
                .publish(every: 0.1, on: .main, in: .common)
                .autoconnect()
            //The latest option lets you republish the last one if true or the first one during the interval if false.
                .throttle(for: .seconds(throttleValue), scheduler: RunLoop.main, latest: true)
                .map { [unowned self] datum in
                    timeFormatter.string(from: datum)
                }
                .sink{ [unowned self] (datum) in
                    data.append(datum)
                }
        }
    }
    
    func reset() {
        data.removeAll()
    }
}


struct ThrottleView_Previews: PreviewProvider {
    static var previews: some View {
        ThrottleView()
    }
}
