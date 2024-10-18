//
//  Future.swift
//  CombineSwiftUI
//
//  Created by Nivedha Rajendran on 18.10.24.
//
import SwiftUI
import Combine

//The Future publisher will publish only one value and then the pipeline will close. WHEN the value is published is up to you. It can publish immediately, be delayed, wait for a user response, etc. But one thing to know about Future is that it ONLY runs one time. You can use the same Future with multiple subscribers. But it still only executes its closure one time and stores the one value it is responsible for publishing.

struct FutureView: View {
    @StateObject private var vm = FutureViewModel()
    var body: some View {
        VStack(spacing: 20) {
            HeaderView(title: "Future",
                       subtitle: "Introduction",
                       desc: "The future publisher will publish one value, either immediately or at some future time, from the closure provided to you.")
            Button("Say Hello") {
                vm.sayHello()
            }
            Text(vm.hello)
                .padding(.bottom)
            Button("Say Goodbye") {
                vm.sayGoodbye()
            }
            Text(vm.goodbye)
            
            Text(vm.firstResult)
            
            Button("Run Again") {
                vm.runAgain()
            }
            
            Text(vm.secondResult)
            
            Spacer()
        }
        .font(.title)
        .onAppear {
            vm.fetch()
        }
    }
}


class FutureViewModel: ObservableObject {
    
    @Published var hello = ""
    
    @Published var goodbye = ""
    
    @Published var data = ""
    
    @Published var firstResult = ""
    
    @Published var secondResult = ""
    
    var goodbyeCancellable: AnyCancellable?
    
    //Here is an example of where the Future publisher is being assigned to a variable.
    let futurePublisher = Future<String, Never> { promise in
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            promise(.success("Goodbye, my friend"))
            print("Goodbye, my friend")
        }
    }
    
    //The Deferred publisher is pretty simple to implement. You just put another publisher within it like this.
    //The Future publisher will not execute immediately now when it is created because it is inside the Deferred publisher. Even more, it will execute every time a subscriber is attached.
    let futurePublisher1 =  Deferred {
        Future<String, Never> { promise in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                promise(.success("Goodbye, my friend"))
                print("Goodbye, my friend")
            }
        }
    }
    
    
    func sayHello() {
        //The promise parameter passed into the closure is actually a function definition.
        Future<String, Never> { promise in
            //Result is an enum with two cases: success and failure. You can assign a value to each one. The value is a generic so you can assign a String, Bool, Int, or any other type to them. In this example, a String is being assigned to the success case.
            promise(Result.success("Hello, World!"))
        }
        .assign(to: &$hello)
        //We don’t need sink(receiveCompletion:receiveValue:) to look for and handle errors. So, assign(to:) can be used.
    }
    
    func sayGoodbye() {
        
        //This pipeline is also non-error-throwing but instead of using assign(to:), sink is use (You could just as easily use assign(to:) here.) Also, there are two reasons why this pipeline is being assigned to an AnyCancellable:
        //1. Because there is a delay within the future’s closure, the pipeline will get deallocated as soon as it goes out of the scope of this function - BEFORE a value is returned.
        //2. The sink subscriber returns AnyCancellable. If assign(to:) was used, then this would not be needed.
        goodbyeCancellable = futurePublisher
            .sink { [unowned self] message in
                goodbye = message
            }
    }
    
    
    //the Future publisher will publish immediately, whether it has a subscriber or not. - it is not recommended
    func fetch() {
        _ = Future<String, Never> { [unowned self] promise in
            data = "Hello, my friend"
        }
        
        //Change the publisher to see the difference
        futurePublisher
            .assign(to: &$firstResult)
    }
    
    //This function can be run repeatedly and the futurePublisher will emit the same, original value, every single time but will not actually get executed.
    func runAgain() {
        
        //Change the publisher to see the difference
        futurePublisher
            .assign(to: &$secondResult)
    }
}


struct FutureView_Previews: PreviewProvider {
    static var previews: some View {
        FutureView()
    }
}
