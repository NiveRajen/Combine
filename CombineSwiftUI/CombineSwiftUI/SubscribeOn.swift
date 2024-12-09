//
//  SubscribeOn.swift
//  CombineSwiftUI
//
//  Created by Nivedha Rajendran on 09.12.24.


//“Use the subscribe(on:) operator when you want to suggest that work be done in the background for upstream publishers and operators. I say “suggest” because subscribe(on:) does NOT guarantee that the work in operators will actually be performed in the background. Instead, it affects the thread where publishers get their subscriptions (from the subscriber/sink), where they receive the request for how much data is wanted, where they receive the data, where they get cancel requests from, and the thread where the completion event happens. (Apple calls these 5 events “operations”.)”

//“operations”, -  5 events for publishers:
//Receive Subscription - This is when a subscriber, like sink or assign, says, “Hey, I would like some data now.
//”Receive Output - This is when an item is coming through the pipeline and this publisher/operator receives it.
//Receive Completion - When the pipeline completes, this event occurs.
//Receive Cancel - Early in this book, you learned to create a cancellable pipeline. This happens when a pipeline is cancelled.
//Receive Request - This is where the subscriber says how much data it requests (also called “demand”). It is usually either “unlimited” or “none”
//
import SwiftUI

struct SubscribeOnView: View {
    
    @StateObject private var vm = SubscribeOnViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            HeaderView(title: "Subscribe",
                       subtitle: "Introduction",
                       desc: "The subscribe operator will schedule operations to be done in the background for all upstream publishers and operators.")
            List(vm.dataToView, id: \.self) { item in
                Text(item)
            }
        }
        .font(.title)
        .onAppear {
            vm.fetch()
        }
    }
}

class SubscribeOnViewModel: ObservableObject {
    
    @Published var dataToView: [String] = []
    
    func fetch() {
        let dataIn = ["Which", "thread", "is", "used?"]
        _ = dataIn.publisher
            .map { item in
                print("map: Main thread? \(Thread.isMainThread)")
                return item
            }
            .handleEvents(receiveSubscription: { subscription in
                print("receiveSubscription: Main thread? \(Thread.isMainThread)")
            }, receiveOutput: { item in
                print("\(item) - receiveOutput: Main thread? \(Thread.isMainThread)")
            }, receiveCompletion: { completion in
                print("receiveCompletion: Main thread? \(Thread.isMainThread)")
            }, receiveCancel: {
                print("receiveCancel: Main thread? \(Thread.isMainThread)")
            }, receiveRequest: { demand in
                print("receiveRequest: Main thread? \(Thread.isMainThread)")
            })
        //“Even though subscribe(on:) is added to the pipeline, the map operator still performs on the main thread. So you can see that this operator does NOT guarantee that work in operators will be performed in the background.But the 5 operations all perform in the background.”
            .subscribe(on: DispatchQueue.global())
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] item in
                dataToView.append(item)
            }
    }
}


struct SubscribeOnView_Previews: PreviewProvider {
    static var previews: some View {
        SubscribeOnView()
    }
}
