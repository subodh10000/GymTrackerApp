//
//  FullScreenMotivationView.swift
//  GymTrackerApp
//
//  Created by Subodh Kathayat on 4/20/25.
//

import SwiftUI

struct FullScreenMotivationView: View {
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            Image("beast_mode")
                .resizable()
                .scaledToFit()
                .edgesIgnoringSafeArea(.all)

            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.white)
                            .font(.largeTitle)
                            .padding()
                    }
                }
                Spacer()
            }
        }
    }
}
