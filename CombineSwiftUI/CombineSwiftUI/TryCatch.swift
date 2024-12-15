//
//  TryCatch.swift
//  CombineSwiftUI
//
//  Created by Nivedha Rajendran on 15.12.24.
//

import SwiftUI
import Combine

//If you want the ability of the catch operator but also want to be able to throw an error, then tryCatch is what you need.
struct TryCatchView: View {
    @StateObject private var vm = TryCatchViewModel()
    var body: some View {
        VStack(spacing: 20) {
            HeaderView(title: "TryCatch",
                       subtitle: "Introduction",
                       desc: "The tryCatch operator will work just like catch but also allow you to throw an error within the closure.")
            .layoutPriority(1)
            List(vm.dataToView, id: \.self) { item in
                Text(item)
            }
        }
        .font(.title)
        .alert(item: $vm.error) { error in
            Alert(title: Text("Error"), message: Text("Failed fetching alternate data."))
        }
        .onAppear {
            vm.fetch()
        }
    }
}

//Can I use tryMap on a non-error throwing pipeline? No. Upstream from the tryCatch has to be some operator or publisher that is capable of throwing errors. That is why you see tryMap upstream from tryCatch. Otherwise, Xcode will give you an error.
class TryCatchViewModel: ObservableObject {
    @Published var dataToView: [String] = []
    @Published var error: BombDetectedError?
    
    func fetch() {
        let dataIn = ["Value 1", "Value 2", "Value 3", "*", "Value 5", "Value 6"]
        
        _ = dataIn.publisher
            .tryMap{ item in
                if item == "*" {
                    throw BombDetectedError()
                }
                return item
            }
            .tryCatch { [unowned self] (error) in
                fetchAlternateData()
            }
        //When fetch tries to get data it runs into a problem, throws an error, and then tryCatch calls another publisher that also throws an error.
        //In the end, the sink subscriber is handling the error from    fetchAlternateData.
            .sink { [unowned self] completion in
                if case .failure(let error) = completion {
                    self.error = error as? BombDetectedError
                }
            } receiveValue: { [unowned self] item in
                dataToView.append(item)
            }
    }
    
    func fetchAlternateData() -> AnyPublisher<String, Error> {
        ["Alternate Value 1", "Alternate Value 2", "*", "Alternate Value 3"]
            .publisher
            .tryMap{ item -> String in
                if item == "*"  { throw BombDetectedError() }
                return item
            }
            .eraseToAnyPublisher()
    }
}

#Preview {
    TryCatchView()
}
