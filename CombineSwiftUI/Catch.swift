//
//  Catch.swift
//  CombineSwiftUI
//
//  Created by Nivedha Rajendran on 15.12.24.
//

import SwiftUI
import Combine

//The catch operator has a very specific behavior. It will intercept errors thrown by upstream publishers/operators but you must then specify a new publisher that will publish a new value to go downstream. The new publisher can be to send one value, many values, or do a network call to get values. It’s up to you.
//The one thing to remember is that the publisher you specify within the catch’s closure must return the same type as the upstream publisher.

struct CatchView: View {
    @StateObject private var vm = Catch_IntroViewModel()
    var body: some View {
        VStack(spacing: 20) {
            HeaderView(title: "Catch",
                       subtitle: "Introduction",
                       desc: "Use the catch operator to intercept errors thrown upstream and specify a publisher to publish new data from within the provided closure.")
            .layoutPriority(1)
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

struct BombDetectedError: Error, Identifiable {
    let id = UUID()
}

class Catch_IntroViewModel: ObservableObject {
    @Published var dataToView: [String] = []
    func fetch() {
        let dataIn = ["Value 1", "Value 2", "Value 3", "*", "Value 5", "Value 6"]
        
        _ = dataIn.publisher
            .tryMap{ item in
                if item == "*" {
                    throw BombDetectedError()
                }
                return item
            }
        //When fetching data the pipeline encounters invalid data and throws an error. The catch intercepts this and publishes “Error Found”.
        //Catch will intercept and replace the upstream publisher. “Replace” is the important word here.
        //This means that the original publisher will not publish any other values after the error was thrown because it was replaced with a new one.
            .catch { (error) in
                //Using the Just publisher to send another value downstream.
                Just("Error Found")
            }
            .sink { [unowned self] (item) in
                dataToView.append(item)
            }
    }
}
         

#Preview {
    CatchView()
}
