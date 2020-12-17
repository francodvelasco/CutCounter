//
//  introScreen.swift
//  Cut Counter
//
//  Created by Franco Velasco on 10/8/20.
//

import SwiftUI

//this will be the view that will be shown at the app's first launch
struct introScreen: View {
    @Binding var showIntroScreen: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            Spacer()
            HStack {
                VStack(alignment: .leading) {
                    Text("Welcome to")
                        .fontWeight(.heavy)
                    Text("Cut Counter")
                        .fontWeight(.heavy)
                        .foregroundColor(Color.blue)
                }
                .padding(.leading, 15)
                .font(.largeTitle)
                Spacer()
            }
            .padding(.bottom, 20)
            HStack {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(Color.blue)
                VStack(alignment: .leading) {
                    Text("Add")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Easily track all of your class cuts by adding and subtracting one from your subjects.")
                        .font(.callout)
                }
            }
            .padding(.bottom, 10)
            .padding(.horizontal, 15)
            HStack {
                Image(systemName: "magnifyingglass.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(Color.blue)
                VStack(alignment: .leading) {
                    Text("Monitor")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("The Subject Color will let you know if you're nearing the maximum amount of cuts allowed.")
                        .font(.callout)
                }
            }
            .padding(.bottom, 10)
            .padding(.horizontal, 15)
            Spacer()
            Button(action: {
                self.showIntroScreen = false
                defaults.set(true, forKey: "showIntroScreen")
            }) {
                HStack {
                    Spacer()
                    Text("Get Started")
                        .fontWeight(.medium)
                        .font(.title3)
                    Spacer()
                }
                .padding(10)
                .background(Color.blue)
                .foregroundColor(Color.white)
                .cornerRadius(7.5)
                .padding(.horizontal, 15)
            }
            Spacer()
        }
    }
}

struct addGradingPeriodScreen: View {
    var body: some View {
        Text("Hello!")
    }
}

struct introScreen_Previews: PreviewProvider {
    static var previews: some View {
        introScreen(showIntroScreen: .constant(true))
    }
}
