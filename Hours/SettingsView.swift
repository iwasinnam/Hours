//
//  Settings.swift
//  Hours
//
//  Created by Ariel Steiner on 10/12/2021.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var locationMonitor : LocationMonitor
    @State var officeAddress : String = ""

    var body: some View {
        VStack(alignment:.leading, spacing: 13) {
            Text("Office Address")
            HStack {
            TextField("Office Address", text: $officeAddress)
                    .disableAutocorrection(true)
                    .border(.black, width: 1)
                    .onSubmit {
                        locationMonitor.locateCoordinates(addressString: officeAddress)
                    }
                Button(action: {
                    guard let placemark = locationMonitor.suggestedPlacemark else {
                        locationMonitor.locateCoordinates(addressString: officeAddress)
                        return
                    }
                    locationMonitor.setOfficeLocation(placemark: placemark)
                }) {
                    Text("Set")
                }
                .disabled(locationMonitor.suggestedPlacemark == nil)
            }
            .padding()

            if let suggestion = locationMonitor.suggestedPlacemark
            {
                Text([suggestion.name, suggestion.locality].compactMap { $0 }.joined(separator: ", "))
                    .font(.caption2)
                    .italic()
            }

            if let workplace = locationMonitor.monitoredPlaceName {
                Text(workplace)
                    .bold()
            }

            Divider()

            if locationMonitor.authState != .authorizedAlways {
                Text("Please authorize the app to monitor your location always")
                    .font(.headline)
                Text(Bundle.main.object(forInfoDictionaryKey: "NSLocationAlwaysAndWhenInUseUsageDescription") as! String)
                    .font(.subheadline)
            }
            if UIApplication.shared.backgroundRefreshStatus != .available {
                Text("Warning: background refresh status disabled. Cannot check in/out")
            }
            Spacer()
        }
        .onAppear {
            if locationMonitor.authState != .authorizedAlways {
                locationMonitor.requestAuthorization()
            }
        }
    }
}

struct Settings_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(LocationMonitor())
    }
}
