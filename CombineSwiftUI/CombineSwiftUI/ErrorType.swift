//
//  ErrorHandling.swift
//  CombineSwiftUI
//
//  Created by Nivedha Rajendran on 18.10.24.
//

import SwiftUI
import Combine

enum TickDetectedError: Error {
    case detetedTick
}

enum InvalidAgeError: Error {
    case invalidAge
    case moreThanOneHundred
    case lessThanZero
}

struct ErrorTypeView: View {
    
    @StateObject private var vm = ErrorTypeViewModel()
    
    @State private var age = ""
    
    var body: some View {
        VStack(spacing: 20) {
            HeaderView(title: "Empty",
                       subtitle: "Introduction",
                       desc: "The Empty publisher will send nothing down the pipeline.")
            List(vm.dataToView, id: \.self) { item in
                Text(item)
            }
            
            HeaderView(title: "Fail",
                       subtitle: "Description",
                       desc: "The Fail publisher will simply publish a failure with your error and close the pipeline.")
            TextField("Enter Age", text: $age)
                .keyboardType(UIKeyboardType.numberPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            Button("Save") {
                //When you tap Save, a save function on the view model is called. The age is validated and if not between 1 and 100 the Fail publisher is used.
                vm.save(age: Int(age) ?? -1)
            }
            Text("\(vm.age)")
        }
        .font(.title)
        .onAppear {
            vm.fetch()
        }
    }
}

struct ErrorTypeView_Previews: PreviewProvider {
    static var previews: some View {
        ErrorTypeView()
    }
}

class ErrorTypeViewModel: ObservableObject {
    
    @Published var dataToView: [String] = []
    
    @Published var age = 0
    @Published var error: InvalidAgeError?
    
    func fetch() {
        let dataIn = ["Value 1", "Value 2", "Value 3", "✅", "Value 5", "Value 6"]
        
        //The tryMap operator gives you a closure to run some code for each item that comes through the pipeline with the option of also throwing an error.
        _ = dataIn.publisher
            .tryMap{ item in
                if item == "✅" {
                    throw TickDetectedError.detetedTick
                }
                return item
            }.catch { (error) in
                //Combine has an Empty publisher. It is simply a publisher that publishes nothing. You can have it finish immediately or fail immediately. You can also have it never complete and just keep the pipeline open.
                //In this example, the Empty publisher is used to end a pipeline immediately after an error is caught. The catch operator is used to intercept errors and supply another publisher.
                //Note: I didn’t have to explicitly set the completeImmediately parameter to true because that is the default value.
                Empty(completeImmediately: true)
                //The item after Value 3 caused an error. The Empty publisher was then used and the pipeline finished immediately.
            }
            .sink { [unowned self] (item) in
                dataToView.append(item)
            }
    }
    
    func save(age: Int) {
        
        //If validAgePublisher returns a Fail publisher then the sink completion will catch it and the error is assigned to the error @Published property. Or else the Just publisher is returned and the age is used.
        
        _ = Validators.validAgePublisher(age: age)
            .sink { [unowned self] completion in
                if case .failure(let error) = completion {
                    self.error = error
                }
            } receiveValue: { [unowned self] age in
                self.age = age
            }
    }
}

//This function can return different publisher types. Luckily, we can use eraseToAnyPublisher to make them all a common type of publisher that returns an Int or an InvalidAgeError as its failure type.
class Validators {
    static func validAgePublisher(age: Int) -> AnyPublisher<Int, InvalidAgeError> {
        if age < 0 {
            return Fail(error: InvalidAgeError.lessThanZero)
                .eraseToAnyPublisher()
        } else if age > 100 {
            return Fail(error: InvalidAgeError.moreThanOneHundred)
                .eraseToAnyPublisher()
        }
        
        //Normally, the Just publisher doesn’t throw errors. So we have to use setFailureType so we can match up the failure types of our Fail publishers above. This allows us to use eraseToAnyPublisher so all Fail and this Just publisher are all the same type that we return from this function.
        
        //Using the Just publisher can turn any variable into a publisher. It will take any value you have and send it through a pipeline that you attach to it one time and then finish (stop) the pipeline.
        return Just(age)
            .setFailureType(to: InvalidAgeError.self)
            .eraseToAnyPublisher()
    }
}
