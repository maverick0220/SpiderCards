//
//  ContentView.swift
//  SpiderCards-2
//
//  Created by Maverick on 2020/11/11.
//

import SwiftUI

struct GameView: View {
    @ObservedObject var game: Game
    var body: some View {
        HStack{
            //main view
            VStack(){
                HStack(){
                    ForEach(game.cardsStack){ stack in
                        StackView(game: game, stack: stack)
                            .onTapGesture(perform: {
                                game.getSubStack(fromStack: stack.id, subStackHead: 1)
                            })
                    }
                }
                    .padding()
            }
                //.frame(width: 600, height: 400, alignment: .topLeading)
            
            //Side info
            VStack(){
                ControlCenter(game: game).frame(alignment: .top)
                
                Text("Card Pack left:\n \(game.getLeftCardsPacks())")
                    .frame(alignment: .center)
                
                Text("Card Pack solved:\n \(game.solvedPack)")
                    .frame(alignment: .center)
                
                Text("Current Stack:\n")
                    .frame(alignment: .center)
                
                //current card stack preview:
                ForEach(game.currentSubStack){ card in
                    ZStack{
                        RoundedRectangle(cornerRadius: 6.0)
                            .fill(card.color)
                        Text(String(card.number))
                            .font(Font.largeTitle)
                            .foregroundColor(.black)
                    }
                        .frame(width: 120, height: 100, alignment: .center)
                        .onTapGesture(count: 1, perform: {
                            game.gameOperate(type: 2, info: (game.currentStack, card.id))
                        })
                }
            }
            
        }
        
        
    }
}

struct StackView: View {
    var game: Game
    var stack: CardStack
    
    var body: some View {
        
        VStack{
            ForEach(stack.cards){ card in
                CardView(game: game, stack: stack, card: card).onTapGesture(count:1, perform: {
                })
                Spacer()
            }
        }
        .onTapGesture(count:1, perform: {
            game.gameOperate(type: 1, info: (stack.id, -1))
        })
    }
    
}

struct CardView: View {
    var game: Game
    var stack: CardStack
    var card: Card
    
    var body: some View{
        ZStack{
            RoundedRectangle(cornerRadius: 6.0)
                .fill(card.color)
            if card.number != -1{
                Text(String(card.number))
                    .font(Font.largeTitle)
                    .foregroundColor(.black)
            }else{
                Text("HERE")
                    .font(.largeTitle)
            }
        }
        .onTapGesture(count: 1, perform: {
            game.gameOperate(type: 1, info: (stack.id, card.id))
        })
        
    }
}

struct CurrentStackPreview: View {
    var game: Game
    var stack: [Card]
    
    var body: some View{
        VStack{
            ForEach(stack){ card in
                RoundedRectangle(cornerRadius: 6.0)
                    .fill(card.color)
                if card.number != -1{
                    Text(String(card.number))
                        .font(Font.largeTitle)
                        .foregroundColor(.black)
                }else{
                    Text(" ")
                        .font(Font.largeTitle)
                        .foregroundColor(.black)
                }
            }
        }
        .onTapGesture(count: 1, perform: {
            game.gameOperate(type: 2, info: (-1, -1))
        })
        .frame(width: 120, height: 300, alignment: .center)
        
    }
}

struct ControlCenter: View {
    var game: Game
    
    var body: some View{
        VStack(){
            
            MenuButton("Type"){
                Button("1 type", action: { game.cardTypes=1; game.createGames() })
                Button("2 type", action: { game.cardTypes=2; game.createGames() })
                Button("4 type", action: { game.cardTypes=4; game.createGames() })
            }
            .frame(width: 80, height: 20, alignment: .center)
            
            Button("print info", action: {
                game.printGameInfo("manually")
            })
            
            Button("SendCard", action: {
                print("send card")
                game.sendCards(isStartGame: false)
            })
            
            Button("restart", action: {
                game.createGames()
            }).frame(alignment: .bottomTrailing)
        }
        .padding()
    }
}




struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}
