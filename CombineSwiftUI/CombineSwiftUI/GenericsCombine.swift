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
    
    
    //    func getAgeText(value1: Int) -> String {
    // return String("Age is \(value1)")
    // }
    // func getAgeText(value1: String) -> String {
    // return String("Age is \(value1)")
    // }
    
    func getAgeText<T>(value1: T) -> String {
        return String("Age is \(value1)")
    }
    
    var body: some View {
        VStack(spacing: 20) {
            HeaderView(title: "Generics",
                       subtitle: "Introduction",
                       desc: "A generic variable allows you to create a type placeholder that can be set to any type the developer wants to use.")
            Group {
                Toggle("Use Int", isOn: $useInt)
                Button("Show Age") {
                    if useInt {
                        ageText = getAgeText(value1: 28)
                    } else {
                        ageText = getAgeText(value1: "28")
                    }
                }
                Text(ageText)
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
