//
//  ContentView.swift
//  SwiftUIDemo
//
//  Created by puneet pal on 03/09/23.
//

import SwiftUI

struct ContentView: View {
    @State private var user: GitHubUser?
    var body: some View {
        VStack {
            AsyncImage(url: URL(string: user?.avatarUrl ?? "")) { image in
                image.resizable()
                    .clipShape(Circle())
            } placeholder: {
                Circle()
                     .foregroundColor(.gray)
            }
            .frame(width: 100,height: 120)
            Text(user?.login ?? "")
                .bold()
                .font(.title3)
            Text(user?.bio ?? "")
                .padding()
            Spacer()
        }
        .padding()
        .task {
            do {
                user = try await getUser()
            } catch ErrorHandler.InvalidUrl{
                print("Invalid url")
            }catch ErrorHandler.InvalidResponse{
                print("Invalid Response")
            }catch ErrorHandler.InvalidData{
                print("Invalid Data")
            } catch {
                print("Unexpected error")
            }
        }
    }
    
    func getUser() async throws -> GitHubUser {
        let endPoint = "https://api.github.com/users/puneetpal10"
        guard let url = URL(string: endPoint) else {
            throw ErrorHandler.InvalidUrl
        }
        let (data, responce) = try await URLSession.shared.data(from: url)
        
        guard let response = responce as? HTTPURLResponse, response.statusCode == 200 else {
            throw ErrorHandler.InvalidResponse
        }
        
        do {
           let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
          return try decoder.decode(GitHubUser.self, from: data)
        } catch {
            print(error.localizedDescription)
            throw ErrorHandler.InvalidData
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


struct GitHubUser: Codable {
    let login: String
    let avatarUrl : String
    let bio : String?
}


enum ErrorHandler: Error {
    case InvalidUrl
    case InvalidResponse
    case InvalidData
}
