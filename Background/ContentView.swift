//
//  ContentView.swift
//  Background
//
//  Created by Hannes Tribus on 22/02/2020.
//  Copyright © 2020 3Bus. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        Button(action: {
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            appDelegate?.scheduleNotification(notificationType: "Local Notification with Action")
        }){
            Text("Send internal Notification")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
