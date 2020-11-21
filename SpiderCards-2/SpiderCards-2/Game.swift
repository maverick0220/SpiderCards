//
//  Game.swift
//  SpiderCards
//
//  Created by 周河晓 on 2020/10/23.
//
import SwiftUI
import Foundation

/*
 The model never talks to the view, the view ask for the model !!!!!
*/

class Game: ObservableObject{
    init(cardPacks: Int, cardTypes: Int){
        /*
        stackCount: how many stack should the hole game have
        cardPacks:  how many `K` would there be at last
        */
        self.cardTypes = cardTypes
        self.cardPacks = cardPacks
        self.stackCount = 8
        createGames()
    }
    
    var cardTypes = 0 //can only be 1,2,4
    var cardLength = 6
    var cardPacks = 8
    var stackCount = 5
    var solvedPack = 0//the `K`
    
    @Published private(set) var cardsStack = [CardStack]()
    @Published private(set) var cardsLib = [[Card]]()
    
    var currentStack = -1
    var currentCard = -1
    var currentSubStack = [Card]()
    
    // MARK: - Game Operations:
    func createGames(){
        self.cardsLib.removeAll()
        self.cardsStack.removeAll()
        self.currentSubStack = [Card]()
        self.solvedPack = 0
        
        let colors = [Color.clear, Color.green, Color.blue, Color.orange, Color.yellow]
        
        //create cards lib
        if self.cardTypes == 1{
            var cards = [Card]()
            let color_1 = Int.random(in: 1..<colors.count)
            for _ in 0..<self.cardPacks{
                cards.removeAll()
                for i in 0..<cardLength{
                    cards.append(Card(id: i, color: colors[color_1], number: i, type: 1))
                }
                self.cardsLib.append(cards)
            }
        }else if self.cardTypes == 2{
            var cards_1 = [Card]()
            var cards_2 = [Card]()
            
            let color_1 = Int.random(in: 1..<colors.count)
            var color_2 = -1
            repeat{
                color_2 = Int.random(in: 1..<colors.count)
            }while(color_1 == color_2)
            
            for _ in 0..<(self.cardPacks/2){
                cards_1.removeAll()
                cards_2.removeAll()
                for i in 0..<cardLength{
                    cards_1.append(Card(id: i, color: colors[color_1], number: i, type: color_1))
                    cards_2.append(Card(id: i, color: colors[color_2], number: i, type: color_2))
                }
                self.cardsLib.append(cards_1)
                self.cardsLib.append(cards_2)
            }
        }else{
            var cards_1 = [Card]()
            var cards_2 = [Card]()
            var cards_3 = [Card]()
            var cards_4 = [Card]()
            
            for _ in 0..<(self.cardPacks/2){
                cards_1.removeAll()
                cards_2.removeAll()
                cards_3.removeAll()
                cards_4.removeAll()
                for i in 0..<cardLength{
                    cards_1.append(Card(id: i, color: colors[1], number: i, type: 1))
                    cards_2.append(Card(id: i, color: colors[2], number: i, type: 2))
                    cards_3.append(Card(id: i, color: colors[3], number: i, type: 3))
                    cards_4.append(Card(id: i, color: colors[4], number: i, type: 4))
                }
                self.cardsLib.append(cards_1)
                self.cardsLib.append(cards_2)
                self.cardsLib.append(cards_3)
                self.cardsLib.append(cards_4)
            }
        }
        
        //create stacks
        for i in 0..<self.stackCount{
            let stack = CardStack(id: i)
            self.cardsStack.append(stack)
        }
        
        //send cards to stack
        for _ in 0...3{
            self.sendCards(isStartGame: true)
        }
    }
    
    func sendCards(isStartGame: Bool){
        //get cards to send from self.CardsLib
        var cardsToSend = [Card]()
        var counter = 0
        
        if self.getLeftCardsCount() == 0{
            print("no cards left to send")
            return
        }
        
        while(counter < self.stackCount){
            let pack = Int.random(in: 0..<self.cardsLib.count)
            if self.cardsLib[pack].isEmpty == false{
                let cardIndex = Int.random(in: 0..<self.cardsLib[pack].count)
                
                cardsToSend.append(self.cardsLib[pack][cardIndex])
                self.cardsLib[pack].remove(at: cardIndex)
                
                counter += 1
            }
        }
        
        print("Cards to send:\(cardsToSend)")
        
        //send cards
        for i in 0..<cardsToSend.count{
            if isStartGame{
                self.cardsStack[i].cards.append(cardsToSend[i])
            }else{
                self.setSubStack(toStack: i, subStack: [cardsToSend[i]], permission: true)
            }
        }
    }
    
    private func checkResult(stackID: Int)->Bool{
        //check if the longgest continue-sub-stack can be assemble to a `K`
        let cardsValue:[(number: Int, type: Int)] = self.getStackValues(stackID: stackID)
        var counter = (lastCard: -1, type:-1)
        
        for i in cardsValue{
            if i.number == 0 && counter.lastCard == -1{//if there is a start
                counter.lastCard += 1
                counter.type = i.type
                continue
            }else if i.type == counter.type && i.number == counter.lastCard + 1{//if the card can enlong the queue
                counter.lastCard += 1
                continue
            }else{
                counter = (lastCard: -1, type:-1)
            }
        }
        
        if counter.lastCard + 1 == self.cardLength{
//            print("stackID -> \(stackID): true, \(counter)")
            return true
        }
        
//        print("stackID -> \(stackID): false, \(counter)")
        return false
    }
    
    func gameOperate(type: Int, info: (stackID: Int, cardID: Int)){
        //This func would get all the event from UI, and this func will judge what to do by current game state and the event type
        //   type: how many click did it send, can only be 1 or 2
        //message: which card and which stack send this message
        
        var command = ""//to record what operate actually did at last
        
        //1.No State: select a sub-stack
        if (self.currentCard == -1 && self.currentStack == -1){
            command = "select a sub-stack"
            self.getSubStack(fromStack: info.stackID, subStackHead: info.cardID)
        //2.With State: attach current sub-stack to the choosen stackID
        }else if type == 1{
            if (self.currentSubStack.isEmpty == false){
                command = "attach current sub-stack"
                self.setSubStack(toStack: info.stackID, subStack: currentSubStack, permission: false)
            }
        //3.Cancel State: clear current sub-stack,put things back
        }else if type == 2{
            command = "clear current sub-stack"
            self.setSubStack(toStack: currentStack, subStack: currentSubStack, permission: true)
        }
        
        //4.Print current state
        self.printGameInfo(command)
        
        //5.check the game situation
        self.gameWatcher()
    }
    
    func gameWatcher(){
        //after every set operate, check if any stack need to change
        //0: nothing need to change
        //1: there is a sub-stack is completed
        //2: game finished
        
        //check if there is a `K` needs to assemble
        for i in 0..<self.cardsStack.count{
            if self.checkResult(stackID: i) == true{
                self.removeSubStack(stackID: i, subStackHead: self.cardsStack[i].cards.count - self.cardLength)
                self.solvedPack += 1
                
                self.printGameInfo("assemble a K")
            }
        }
        
        //check if the game is finished
        if self.getLeftCardsCount() == 0 && self.getLeftStackCards() == 0{
            // FIXIT :should show something first, then manually start next game
            print("game finished")
            self.createGames()
        }
        
    }
    
    func printGameInfo(_ command: String){
        var current_sub_stack = [Int]()
        for i in currentSubStack{
            current_sub_stack.append(i.number)
        }
        print("          command: \(command)")
        print("    current stack: \(currentStack)")
        print("    current card : \(currentCard)")
        print("current sub-stack: \(current_sub_stack)")
        
        print("current stacks:")
        for i in 0..<self.cardsStack.count{
            print(self.getStackValues(stackID: i))
        }
        print("=========================\n")
    }
    
    private func getLeftCardsCount()->Int{
        //how many cards haven't been sent
        var count = 0
        for i in self.cardsLib{ count += i.count }
        
        return count
    }
    
    func getLeftCardsPacks()->Int{
        //how many card packs haven't been sent
        var leftCardsSum = 0
        for i in self.cardsLib{ leftCardsSum += i.count }

        return leftCardsSum / self.cardLength
    }
    
    func getLeftStackCards()->Int{
        //how many card are in the cardsStack
        var leftCardsSum = 0
        for i in self.cardsStack{
            leftCardsSum += i.cards.count
        }
        return leftCardsSum
    }
    
    // MARK: - Player Operations:
    func getSubStack(fromStack: Int, subStackHead: Int){
        
        func dragSubStack(_ subStackHead: Int, stackID: Int)->(Bool,[Card]){
            //in :subStackHead: in self.cards, a sub-satck start from where to the tail.
            //out:Bool, where this drag can be done
            //out:Array<Card>(), if it could be drag, return the sub-stack, else a empty array
            
            //is the calling sub-stack can be draged
            
    //        let subStack = self.selectSubStack(stackID: stackID, at: subStackHead)
            var subStack = [Card]()
            for i in subStackHead..<self.cardsStack[stackID].cards.count{
                subStack.append(self.cardsStack[stackID].cards[i])
            }
            
            //check if the type are the same
            var typeCounts = Set<Int>()
            for i in subStack{
                typeCounts.insert(i.type)
            }
            if typeCounts.count > 1{
                return (false,[])
            }
            
            //check the numbers are continuous
            var base = subStack[0].number
            for i in 1..<subStack.count{
                if (base + 1 == subStack[i].number){
                    base = subStack[i].number
                }else{
                    return (false,[])
                }
            }
            
            //remove the draged sub-stack
            self.removeSubStack(stackID: stackID, subStackHead: subStackHead)
            
            return (true,subStack)
        }
        
        if self.cardsStack[fromStack].cards[0].number == -1{
            return
        }
        
        let dragResult = dragSubStack(subStackHead, stackID: fromStack)
        if (dragResult.0 == true){
            self.currentSubStack = dragResult.1
            self.currentStack = fromStack
            self.currentCard = subStackHead
        }
    }
    
    func setSubStack(toStack: Int, subStack: [Card], permission: Bool){
        //toStack: which stack is this subStack going to
        //subStack: the subStack that gonna be set
        //permision: if this operation has a permission, then it does not require a validation, just put it there
        
        func attachSubStack(_ subStack: [Card], stackID: Int, permission: Bool)->Bool{
            //is the dragging sub-stack can be attached to current stack's end.
            //the sub-stack is draggable, so it only need to comfirm the first card can be attached
            
            //current stack is empty or got the permission, just put things in
    //        if (self.cardsStack[stackID].cards.count == 1 && self.cardsStack[stackID].cards[0].color == Color.clear){
            if (self.cardsStack[stackID].cards[0].number == -1){
                self.cardsStack[stackID].cards = subStack
    //            for _ in 0..<subStack.count{
    //                self.cardsStack[stackID].mask.append(1)
    //            }
                return true
            }
            
            let lastCardValue = self.cardsStack[stackID].cards.last!.number
            let lastCardType = self.cardsStack[stackID].cards.last!.type
            
            if self.cardTypes == 4{
                if subStack[0].number == lastCardValue + 1 || subStack[0].type == lastCardType || permission == true{
                    self.cardsStack[stackID].cards += subStack
                    return true
                }
            }else{
                if (subStack[0].number == lastCardValue + 1 && subStack[0].type == lastCardType) || permission == true{
                    self.cardsStack[stackID].cards += subStack
                    return true
                }
            }
            return false
        }
        
        if attachSubStack(subStack, stackID: toStack, permission: permission) == true{
            //clear all current state
            self.currentStack = -1
            self.currentCard = -1
            self.currentSubStack = [Card(id: 0, color: Color.clear, number: -1, type: 0)]
        }
    }
    
    // MARK: - stack operations:
    public func getStackValues(stackID: Int)->[(Int, Int)]{
        var values = [(Int, Int)]()
        
        for i in self.cardsStack[stackID].cards{
            values.append((i.number, i.type))
        }
        
        return values
    }
    
    private func removeSubStack(stackID: Int, subStackHead: Int){
        let subStackLength = self.cardsStack[stackID].cards.count - subStackHead
        
        if subStackLength == self.cardsStack[stackID].cards.count{
            self.cardsStack[stackID].cards = [Card(id: 0, color: Color.clear, number: -1, type: 1)]
            return
        }
        
        self.cardsStack[stackID].cards.removeLast(subStackLength)
//        self.cardsStack[stackID].mask.removeLast(subStackLength)
        
        if cardsStack[stackID].cards.isEmpty{
            cardsStack[stackID].cards.append(Card(id: -1, color: Color.clear, number: -1, type: -1))
        }
    }
    
    
}

//MARK: - Structures:
struct CardStack: Identifiable{
    // in GameView.swift, ForEach need to identify this thing, so this struct needs this
    
    var id: Int //this name is inherented
    
    var cards = [Card](){
        didSet{
            for i in 0..<cards.count{
                cards[i].id = i
            }
        }
    }
    var mask = [0,0,0,0,1]
    /*
    mask:
    1:is showing
    0:is covered
    */
}

struct Card: Identifiable {
    var id: Int //this name is inherented
    //if id is bigger than 0, it'a a validate card, else it's a empty card

    var color: Color
    var number: Int
    var type: Int
    /*
     0:clear
     1:orange
     2:blue
     3.green
     4.yellow
     */
}
