//
//  ProfileSwiftUIView.swift
//  TawkIOSDeveloperTest
//
//  Created by Anthony Fullwood on 24/10/2022.
//

import SwiftUI
import UIKit


struct ProfileSwiftUIView: View {
    
    
    var profileVM: ProfileViewModel
    @State var notes: String
    @State var presentAlert = false
    
    var body: some View {
        
        
            VStack(alignment: .center, spacing: 100){
                
                ScrollView{
                    
                    VStack(alignment: .center,spacing: 50){
                        
                        HStack( spacing: 50){
                            
                            Image(uiImage: profileVM.getImage()!)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 150, height: 150, alignment: .center)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color(UIColor.systemTeal),lineWidth: 1))
                            
                                
                            
                            VStack(alignment: .leading,spacing: 10){
                                Text("Name: \(profileVM.getName())")
                                    
                                
                                Text("Company: \(profileVM.getCompany())")
                                
                                Text("Blog: \(profileVM.getBlog())")
                                  
                            }
                            
                            
                        }.frame(width: 400, height: 200)
                        
                       
                        HStack(spacing: 100){
                            Text("Followers: \(profileVM.getFollowers())")
                            Text("Following: \(profileVM.getFollowing())")
                              
                        }
                        
                    
                    }.padding(20)
                    
                    VStack(alignment: .leading,spacing: 0){
                        
                        Text("Notes:").padding(EdgeInsets(top: 0, leading: 20, bottom: 5, trailing: 0))
                       
                        TextField("Enter notes here", text: $notes)
                            .frame(height: 100)
                        .clipShape(RoundedRectangle(cornerSize: CGSize(width: 10, height: 10)))
                        .overlay(RoundedRectangle(cornerSize: CGSize(width: 10, height: 10)).stroke(Color.gray,lineWidth: 0.5))
                        .padding()
                            
                
            
                    }
                    
                    
                    
                
                    Button("Save") {
                        
                         profileVM.saveNotes(notes: notes)
                        
                        presentAlert = true
                        
                        
                        
                    }.padding(EdgeInsets(top: 10, leading: 120, bottom: 10, trailing: 120))
                        .background(Color(UIColor.systemTeal))
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .foregroundColor(Color.white)
                        
                        
                }
                
            }.alert(isPresented: $presentAlert) {
                Alert(title: Text("Status"),
                      message: Text("Notes Saved")
                )
            }
        
        

    }
    
}

