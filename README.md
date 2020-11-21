# SpiderCards
a macOS platform game based on swiftUI, without any third-party lib
theoretically this app can run in a AppleSilicon mac

this game actually was based on the SpiderCard game in windows7, which basiclly is just drag cards stack and assemble an ordered stack
this game is a much more simplified version(becuase I still haven't learnt how to perform a animation with swiftUI)

if there is any sub-stack contains cards from 0 to 5, it can be assembled
you can only drag a sub-stack when it contains same type cards and each one of them is nearby to it's next card
there are 3 different game model, you can play 1 or 2 or 4 card type(s)
  1.in 1 & 2 type model the rule is the same as the original game: 
    only cards with both same type and nearby-value(3 and 4 is nearby, 3 and 5 is not) can be attached togather
  2.in 4 type model, I did some modify(or the game is basicly impossible to play):
    cards with same type can be attached togather regardless thire value
    cards with nearby value and different type can be attached togather
    
you can ask for more cards or restart current type game or change game type in the side controller UI
click the card stack in the controller UI(which would only appear when you choosed a card stack), it will put what you choose back to it's original position
