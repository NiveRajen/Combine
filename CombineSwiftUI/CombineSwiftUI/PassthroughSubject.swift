//
//  PassthroughSubject.swift
//  CombineSwiftUI
//
//  Created by Nivedha Rajendran on 19.10.24.
//
import SwiftUI
import Combine

enum CreditCardStatus {
    case ok
    case invalid
    case notEvaluated
}

//The PassthroughSubject is much like the CurrentValueSubject except this publisher does NOT hold on to a value. It simply allows you to create a pipeline that you can send values through.
//This makes it ideal to send “events” from the view to the view model.

struct PassthroughSubjectView: View {
    
    @StateObject private var vm = PassthroughSubjectViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            HeaderView(title: "PassthroughSubject",
                       subtitle: "Definition",
                       desc: "The PassthroughSubject publisher will send a value through a pipeline but not retain the value.")
            HStack {
                TextField("credit card number", text: $vm.creditCard)
                Group {
                    switch (vm.status) {
                    case .ok:
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    case .invalid:
                        Image(systemName: "x.circle.fill")
                            .foregroundColor(.red)
                    default:
                        EmptyView()
                    }
                }
            }
            .padding()
            
            Button("Verify CC Number") {
                vm.verifyCreditCard.send(vm.creditCard)
            }
        }
        .font(.title)
    }
}

struct PassthroughSubjectView_Previews: PreviewProvider {
    static var previews: some View {
        PassthroughSubjectView()
    }
}

class PassthroughSubjectViewModel: ObservableObject {
    
    @Published var creditCard = ""
    
    @Published var status = CreditCardStatus.notEvaluated
    
    //Without doing anything, the pipeline expects a String will go all the way through. But you can change this.
    let verifyCreditCard = PassthroughSubject<String, Never>()
    
    init() {
        verifyCreditCard
            .map{ creditCard -> CreditCardStatus in
                if creditCard.count == 16 {
                    return CreditCardStatus.ok
                } else {
                    return CreditCardStatus.invalid
                }
            }
            .assign(to: &$status)
    }
}
