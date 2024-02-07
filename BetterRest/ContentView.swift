//
//  ContentView.swift
//  BetterRest
//
//  Created by Izaan Saleem on 31/01/2024.
//

import SwiftUI
import CoreML

struct ContentView: View {
    
    @State private var sleepAmount = 8.0
    @State private var wakeUp = defaultWakeTime
    @State private var coffeeAmount = 1
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? .now
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(alignment: .leading) {
                        Text("When do you want to wakeup?")
                            .font(.headline)
                        DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                    }
                }
                
                Section("Desired amount of sleep") {
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                }
                
                Section("Daily coffee intake") {
                    //Stepper("^[\(coffeeAmount) cup](inflect: true)", value: $coffeeAmount, in: 1...10)
                    
                    Picker("^[\(coffeeAmount) cup](inflect: true)", selection: $coffeeAmount) {
                        ForEach(0..<11) { number in
                            Text("\(number)")
                        }
                    }
                }
                
                Section {
                    HStack {
                        Spacer()
                        Button {
                            calculateBedTime()
                        } label: {
                            Text("Calculate Sleep time")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .multilineTextAlignment(.trailing)
                                .foregroundStyle(.black)
                        }
                        .padding()
                        Spacer()
                    }
                }
                
                if showingAlert {
                    Section {
                        HStack {
                            Spacer()
                            VStack(alignment: .center) {
                                Text("\(alertTitle)")
                                    .font(.title2)
                                    .fontWeight(.medium)
                                Text("\(alertMessage)")
                                    .font(.title)
                                    .fontDesign(.monospaced)
                            }
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("BetterRest")
        }
    }
    
    func calculateBedTime() {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Int64(hour + minute), estimatedSleep: sleepAmount, coffee: Int64(coffeeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
            alertTitle = "Your ideal bedtime is"
            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
        } catch {
            alertTitle = "Error"
            alertMessage = "Sorry, there was a problem calculating your bedtime"
        }
        
        showingAlert = true
    }
}

#Preview {
    ContentView()
}
