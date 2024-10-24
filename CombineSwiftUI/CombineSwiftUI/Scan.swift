//
//  Scan.swift
//  CombineSwiftUI
//
//  Created by Nivedha Rajendran on 24.10.24.
//

//The scan operator gives you the ability to see the item that was previously returned from the scan closure along with the current one. That is all the operator does.

//The tryScan operator works just like the scan operator, it allows you to examine the last item that the scan operator’s closure returned. In addition to that, it allows you to throw an error. Once this happens the pipeline will finish.

import SwiftUI
import Combine

struct InvalidValueFoundError: Error {
    let message = "Invalid value was found: "
}

struct ScanView: View {
    
    @StateObject private var vm = ScanViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            HeaderView(title: "Scan",
                       subtitle: "Introduction",
                       desc: "The scan operator allows you to access the previous item that it had returned.")
            List(vm.dataToView, id: \.self) { datum in
                Text(datum)
            }
        }
        .font(.title)
        .onAppear {
//            vm.fetch()
            vm.tryScanFetch()
        }
    }
}


class ScanViewModel: ObservableObject {
    
    @Published var dataToView: [String] = []
    
    private let invalidValue = "*"
    
    func fetch() {
        
        let dataIn = ["1 ", "2 ", "3 ", "4 ", "5 ", "6 ", "7"]
        
        _ = dataIn.publisher
        //The first time an item comes through the scan closure there will be no previous item. So you can provide an initial value to use.
            .scan("0 ") { (previousReturnedValue, currentValue) in
                //What you return from scan becomes available to look at the next time the current item comes through this closure.
                previousReturnedValue + " " + currentValue
            }
        
        //Above operator can be written as
        //.scan("0 ") { $0 + " " + $1 }
            .sink { [unowned self] (item) in
                dataToView.append(item)
            }
    }
    
    func tryScanFetch(){
        let dataIn = ["1 ", "2 ", "3 ", "4 ", "*", "5 ", "6 ", "7"]
        
        
        _ = dataIn.publisher
            .tryScan("0 ") { [unowned self] (previousReturnedValue, currentValue) in
                if currentValue == invalidValue {
                    throw InvalidValueFoundError()
                }
                return previousReturnedValue + " " + currentValue
            }
            .sink { [unowned self] (completion) in
                if case .failure(let error) = completion {
                    if let err = error as? InvalidValueFoundError {
                        dataToView.append(err.message + invalidValue)
                    }
                }
            } receiveValue: { [unowned self] (item) in
                //The error message is just being appended to our data to be displayed on the view.
                dataToView.append(item)
            }
    }
}


struct ScanView_Previews: PreviewProvider {
    static var previews: some View {
        ScanView()
    }
}
