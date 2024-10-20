//
//  AllSatisfy.swift
//  CombineSwiftUI
//
//  Created by Nivedha Rajendran on 20.10.24.
//
import SwiftUI

//These operators will evaluate items coming through a pipeline and match them against the criteria you specify and publish the results in different ways.

struct InvalidNumberError: Error, Identifiable
{
    var id = UUID()
}

struct AllSatisfyView: View {
    
    @State private var number = ""
    
    @State private var resultVisible = false
    
    @StateObject private var vm = AllSatisfyViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            HeaderView(title: "AllSatisfy", subtitle: "Introduction",
                       desc: "Use allSatisfy operator to test all items against a condition. If all items satisfy your criteria, a true is returned, else a false is returned.\nThe tryAllSatisfy operator works like allSatisfy except now the subscriber can also receive an error in addition to a true or false.")
            .layoutPriority(1)
            
            HStack {
                TextField("add a number", text: $number)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
                
                Button(action: {
                    vm.add(number: number)
                    number = ""
                }, label: { Image(systemName: "plus") })
            }.padding()
            
            List(vm.numbers, id: \.self) { number in
                Text("\(number)")
            }
            
            Spacer(minLength: 0)
            
            Button("Fibonacci Numbers?") {
//                vm.allFibonacciCheck()
                vm.allFibonacciCheckwithError()
                resultVisible = true
            }
            
            Text(vm.allFibonacciNumbers ? "Yes" : "No")
                .opacity(resultVisible ? 1 : 0)
        }
        .padding(.bottom)
        .font(.title)
        .alert(item: $vm.invalidNumberError) { error in
            Alert(title: Text("A number is greater than 144"),
                  primaryButton: .default(Text("Start Over"), action: {
                vm.numbers.removeAll()
            }),
                  secondaryButton: .cancel()
            )
        }
    }
}

struct AllSatisfyView_Previews: PreviewProvider {
    static var previews: some View {
        AllSatisfyView()
    }
}


class AllSatisfyViewModel: ObservableObject {
    
    @Published var numbers: [Int] = []
    
    @Published var allFibonacciNumbers = false
    
    @Published var invalidNumberError: InvalidNumberError?
    
    func allFibonacciCheck() {
        
        let fibonacciNumbersTo144 = [0, 1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144]
        
        // as soon as allSatisfy finds a number that is not a Fibonacci number, then a false is published and the pipeline finishes early.
        //By using numbers.publisher, I’m actually using the Sequence publisher so each item in the array will go through the pipeline individually.
        numbers.publisher
        //            .allSatisfy { (number) in
        //                fibonacciNumbersTo144.contains(number)
        //            }
        //Above condition can be written as
            .allSatisfy { fibonacciNumbersTo144.contains($0) }
            .assign(to: &$allFibonacciNumbers)
    }
    
    func allFibonacciCheckwithError() {
        
        let fibonacciNumbersTo144 = [0, 1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144]

        _ = numbers.publisher
            .tryAllSatisfy { (number) in
//                If tryAllSatisfy detects a number over 144, an error
//                is thrown and the pipeline will then finished
//                (completed).
                if number > 144 {
                    throw InvalidNumberError()
                }
                return fibonacciNumbersTo144.contains(number)
            }
            .sink { [unowned self] (completion) in
                switch completion {
                case .failure(let error):
                    self.invalidNumberError = error as? InvalidNumberError
                default:
                    break
                }
            } receiveValue: { [unowned self] (result) in
                allFibonacciNumbers = result
            }
    }
    
    func add(number: String) {
        if number.isEmpty { return }
        numbers.append(Int(number) ?? 0)
    }
}
