//
//  GenericsCombine.swift
//  CombineSwiftUI
//
//  Created by Nivedha Rajendran on 18.10.24.
//

import SwiftUI

struct GenericsCombine: View {
    @State private var useInt = false
    @State private var ageText = ""
    private var age1 = 25
    private var age2 = 45
    
    //    func getAgeText(value1: Int) -> String {
    // return String("Age is \(value1)")
    // }
    // func getAgeText(value1: String) -> String {
    // return String("Age is \(value1)")
    // }
    
    //That generic function can now replace above two functions.
    //The <T> is called a “type placeholder”. This indicates a generic is being used and you can substitute T with any type you want.
    //Function with generic type
    func getAgeText<T>(value1: T) -> String {
        return String("Age is \(value1)")
    }
    
    //Specify your constraint the same way you specify a parameter’s type.
    //Maybe you don't want a generic to be entirely generic. You can narrow down just how generic you want it to be with a ‘constraint'
    //Constraints can be used where ever you can add a generic declaration, not just on functions like you see here.
    //Constraints are usually protocols
    //You can’t declare protocols with generics like you can with structs and classes. If you try, you will get an error: “Protocols do not allow generic parameters.”
    //You use the associatedtype keyword. This is something the Publisher and Subscriber protocols make use of.
    func getOldest<T: SignedInteger>(age1: T, age2: T) -> String {
        if age1 > age2 {
            return "The first is older."
        } else if age1 == age2 {
            return "The ages are equal"
        }
        return "The second is older."
    }
    
    var body: some View {
        let myGenericWithString = MyGenericClass(myProperty1: "Nivedha", myProperty2: "Rajendran")
        let myGenericWithBool = MyGenericClass(myProperty1: 27, myProperty2: true)
        
        
        VStack(spacing: 20) {
            HeaderView(title: "Generics",
                       subtitle: "Definition",
                       desc: "A generic variable allows you to create a type placeholder that can be set to any type the developer wants to use.")
            Group {
                Toggle("Use Int", isOn: $useInt)
                Button("Show Age") {
                    if useInt {
                        ageText = getAgeText(value1: 28)//Int
                    } else {
                        ageText = getAgeText(value1: "28")//String
                    }
                }
                HStack(spacing: 40) {
                    Text("Age One: \(age1)")
                    Text("Age Two: \(age2)")
                }
                
                Text(getOldest(age1: age1, age2: age2))
                Text(myGenericWithString.myProperty1)
                Text(myGenericWithBool.myProperty2.description)
            }
            .padding(.horizontal)
        }
        .font(.title)
    }
}


struct GenericsCombine_Previews: PreviewProvider {
    static var previews: some View {
        GenericsCombine()
    }
}

//Class with property as generic type
//Keep adding additional letters or names separated by commas for your generic placeholders like this.
class MyGenericClass<T, U> {
    var myProperty1: T
    var myProperty2: U
    
    init(myProperty1: T, myProperty2: U) {
        self.myProperty1 = myProperty1
        self.myProperty2 = myProperty2
    }
}
