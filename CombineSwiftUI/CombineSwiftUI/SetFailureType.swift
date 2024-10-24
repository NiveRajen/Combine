//
//  SetFailureType.swift
//  CombineSwiftUI
//
//  Created by Nivedha Rajendran on 24.10.24.
//

//There are two types of pipelines. Pipelines that have publishers/operators that can throw errors and those that do not. The setFailureType is for those pipelines that do not throw errors. This operator doesn’t actually throw an error and it will not cause an error to be thrown later. It does not affect your pipeline in any way other than to change the type of your pipeline.

import SwiftUI
import Combine

struct SetFailureTypeView: View {
    @StateObject private var vm = SetFailureTypeViewModel()
    var body: some View {
        VStack(spacing: 20) {
            HeaderView(title: "SetFailureType",
                       subtitle: "Introduction",
                       desc: "The setFailureType operator can change a type of a publisher by changing its failure type from Never to something else.")
            HStack(spacing: 50) {
                Button("Western") { vm.fetch(westernStates: true) }
                Button("Eastern") { vm.fetch(westernStates: false) }
            }
            Text("States")
                .bold()
            List(vm.states, id: \.self) { state in
                Text(state)
            }
        }
        .font(.title)
        .alert(item: $vm.error) { error in
            Alert(title: Text("Error"), message: Text(error.message))
        }
    }
}


class SetFailureTypeViewModel: ObservableObject {
    
    @Published var states: [String] = []
    
    @Published var error: ErrorForAlert?
    
    func getPipeline(westernStates: Bool) -> AnyPublisher<String, Error> {
        if westernStates {
            return ["Utah", "Nevada", "Colorado", "*", "Idaho"].publisher
                .tryMap { item -> String in
                    if item == "*" {
                        throw ErrorForAlert()
                    }
                    return item
                }
                .eraseToAnyPublisher()
        } else {
            return ["Vermont", "New Hampshire", "Maine", "*", "Rhode Island"].publisher
                .map { item -> String in
                    if item == "*" {
                        return "Massachusetts"
                    }
                    return item
                }
            //You have a choice here. You can either make both publishers error-throwing or make both non-errorthrowing.
            //The setFailureType is used to make this pipeline error throwing to match the first publisher.
                .setFailureType(to: Error.self)
            //The eraseToAnyPublisher operator allows you to simplify the type of your publishers.
                .eraseToAnyPublisher()
        }
    }
    
    func fetch(westernStates: Bool) {
        states.removeAll()
        
        //Once you have a publisher, all you need to do is to attach a subscriber.
        //Because the type returned specifies the possible failure of Error instead of Never, it is an error-throwing pipeline.
        //Xcode will force you to use sink(receiveCompletion:receiveValue:) for error-throwing pipelines.
        //(Non-error-throwing pipelines can use either sink(receiveValue:) or assign(to:). )
        _ = getPipeline(westernStates: westernStates)
            .sink { [unowned self] (completion) in
                if case .failure(let error) = completion {
                    self.error = error as? ErrorForAlert
                }
            } receiveValue: { [unowned self] (state) in
                states.append(state)
            }
    }
}

struct SetFailureTypeView_Previews: PreviewProvider {
    static var previews: some View {
        SetFailureTypeView()
    }
}
