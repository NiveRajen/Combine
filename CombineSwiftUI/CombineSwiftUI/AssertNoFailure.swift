//
//  AssertNoFailure.swift
//  CombineSwiftUI
//
//  Created by Nivedha Rajendran on 15.12.24.
//

import SwiftUI

// Error-Throwing Pipelines - There are publishers and operators that can throw errors. Operators that begin with “try” are good examples. Xcode will let you add error handling to these pipelines.
//Non-Error-Throwing Pipelines - There are pipelines that never throw errors. They have publishers that are incapable of throwing errors and downstream there are no “try” operators that throw errors. Xcode will NOT let you add error handling to these pipelines.
/*publisher
    .try… { … }
    .sink(receiveCompletion: { … },
    receiveValue: { … })*/
//Xcode will not allow you to use just sink(receiveValue:) if it is an error-throwing pipeline. You need receiveCompletion (like you see in the example above) to handle the error that caused the failure. You also cannot use assign(to:). That subscriber is for non-error throwing pipelines only. Xcode will show you an error if you try.

/*publisher
 .map { … }
 .sink(receiveValue: { … })
 // OR
 .assign(to: )*/
//Xcode WILL allow you to use sink(receiveValue:), or sink(receiveCompletion:receiveValue:), or assign(to:). The assign(to:) subscriber is for non-error throwing pipelines only.
//Can I change error-throwing pipelines into non-error-throwing? Yes! This can go both ways. You can change error-throwing pipelines into pipelines that never throw errors. And you can turn pipelines that never throw errors into error-throwing pipelines just by adding one of the many “try” operators.
//How can I tell if a pipeline is error-throwing or not? All operators that begin with “try“ throw errors, decode operator. So far, the only publisher I know that can throw an error is the dataTaskPublisher. Try adding an assign(to:) subscriber. If Xcode gives you an error, then usually something is throwing an error.
//You use the assertNoFailure operator to ensure there will be no errors caused by anything upstream from it. If there is, your app will then crash. This is best to use when developing when you need to make sure that your data is always correct and your pipeline will always work.
//Once your app is ready to ship though, you may want to consider removing it or it can crash your app if there is a failure.
struct AssertNoFailureView: View {
    @StateObject private var vm = AssertNoFailureViewModel()
    var body: some View {
        VStack(spacing: 20) {
            HeaderView(title: "AssertNoFailure",
                       subtitle: "Introduction",
                       desc: "The assertNoFailure operator will crash your app if there is a failure. This will make it very obvious while developing so you can easily find and fix the problem.")
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

class AssertNoFailureViewModel: ObservableObject {
    @Published var dataToView: [String] = []
    func fetch() {
        let dataIn = ["Value 1", "Value 2", "%", "Value 3"]
        _ = dataIn.publisher
            .tryMap { item in
                // There should never be a % in the data
                if item == "%" {
                    //Throwing this error will make your app crash because you are using the assertNoFailure operator.
                    throw  InvalidValueError()
                }
                return item
            }
            .assertNoFailure("This should never happen.")
        //You have seen from the many examples where a try operator is used that Xcode forces you to use the sink(receiveCompletion:receiveValue:) subscriber because you have to handle the possible failure.
        //But in this case, the assertNoFailure tells the downstream pipeline that no failure will be sent downstream and therefore we can just use sink(receiveValue:).
            .sink { [unowned self] (item) in
                dataToView.append(item)
            }
    }
}

#Preview {
    AssertNoFailureView()
}
