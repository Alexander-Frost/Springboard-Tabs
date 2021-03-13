//
//  SwitcherView.swift
//  SpringboardTabs
//
//  Created by Alex Frost on 3/13/21.
//

import UIKit

class SwitcherView: UIView {

    // MARK: - Properties
    
    var cards: [CardView] = []
    var currentCard: CardView?
    var firstLayout: Bool = true

    // useful during development...
    //  if true, highlight the current "control" card in yellow
    //  if false, leave them all cyan
    let showHighlight: Bool = false
    
    // MARK: - Actions
    
    @objc func didPan(_ gesture: UIPanGestureRecognizer) -> Void {
        let translation = gesture.translation(in: self)
        
        var pt = gesture.location(in: self)
        pt.y = self.bounds.midY
        for c in cards.reversed() {
            if c.frame.contains(pt) {
                if let cc = currentCard {
                    if  let idx1 = cards.firstIndex(of: cc),
                        let idx2 = cards.firstIndex(of: c),
                        idx2 > idx1 {
                        if showHighlight {
                            currentCard?.backgroundColor = .cyan
                        }
                        currentCard = c
                        if showHighlight {
                            currentCard?.backgroundColor = .yellow
                        }
                    }
                } else {
                    currentCard = c
                    if showHighlight {
                        currentCard?.backgroundColor = .yellow
                    }
                }
                break
            }
        }
        switch gesture.state {
        case .changed:
            if let controlCard = currentCard {
                // update card leading edge
                controlCard.frame.origin.x += translation.x
                // don't allow drag left past 1.0
                controlCard.frame.origin.x = max(controlCard.frame.origin.x, 1.0)
                // update the positions for the rest of the cards
                updateCards(controlCard)
                gesture.setTranslation(.zero, in: self)
            }
        case .ended:
            if showHighlight {
                currentCard?.backgroundColor = .cyan
            }
            
            guard let controlCard = currentCard else {
                return
            }
            
            if let idx = cards.firstIndex(of: controlCard) {
                // use pan velocity to "throw" the cards
                let velocity = gesture.velocity(in: self)
                // convert to a reasonable Int value
                let offset: Int = Int(floor(velocity.x / 500.0))
                // step up or down in array of cards based on velocity
                let newIDX = max(min(idx - offset, cards.count - 1), 0)
//                doCentering(for: cards[newIDX])
            }
            currentCard = nil
        default:
            break
        }
    }
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func commonInit() -> Void {
        clipsToBounds = true
        
        // add 20 "cards" to the view
        for i in 1...20 {
            let v = CardView()
            v.backgroundColor = .cyan
            v.cardID = i
            cards.append(v)
            addSubview(v)
            v.isHidden = true
        }
                
        // add a pan gesture recognizer to the view
        let pan = UIPanGestureRecognizer(target: self, action: #selector(self.didPan(_:)))
        addGestureRecognizer(pan)
    }

    // MARK: - Lifecycle
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if firstLayout {
            // if it's the first time through, layout the cards
            firstLayout = false
            if let firstCard = cards.first {
                if firstCard.frame.width == 0 {
                    cards.forEach { thisCard in
                        //thisCard.alpha = 0.750
                        thisCard.frame = CGRect(origin: .zero, size: CGSize(width: self.bounds.width, height: self.bounds.height))
                        thisCard.transform = CGAffineTransform(scaleX: 0.71, y: 0.71)
                        thisCard.frame.origin.x = 0
                        if thisCard == cards.last {
                            thisCard.frame.origin.x = 10
                        }
                        thisCard.isHidden = false
                    }
//                    doCentering(for: cards.last!)
                }
            }
        }
    }
    
    private func updateCards(_ controlCard: CardView) -> Void {
        guard let idx = cards.firstIndex(of: controlCard) else {
            print("controlCard not found in array of cards - can't update")
            return
        }
        
        var relativeCard: CardView = controlCard
        var n = idx
        
        // for each card to the right of the control card
        while n < cards.count - 1 {
            let nextCard = cards[n + 1]
            // get percent distance of leading edge of relative card
            //  to 33% of the view width
            let pct = relativeCard.frame.origin.x / (self.bounds.width * 1.0 / 3.0)
            // move next card that percentage of the width of a card
            nextCard.frame.origin.x = relativeCard.frame.origin.x + (relativeCard.frame.size.width * pct) // min(pct, 1.0))
            relativeCard = nextCard
            n += 1
        }
        
        // reset relative card and index
        relativeCard = controlCard
        n = idx
        
        // for each card to the left of the control card
        while n > 0 {
            let prevCard = cards[n - 1]
            // get percent distance of leading edge of relative card
            //  to half the view width
            let pct = relativeCard.frame.origin.x / self.bounds.width
            // move prev card that percentage of 33% of the view width
            prevCard.frame.origin.x = (self.bounds.width * 1.0 / 3.0) * pct
            relativeCard = prevCard
            n -= 1
        }
        
        self.cards.forEach { c in
            let x = c.frame.origin.x
            
            // scale transform each card between 71% and 75%
            //  based on card's leading edge distance to one-half the view width
            let pct = x / (self.bounds.width * 0.5)
            let sc = 0.71 + (0.04 * min(pct, 1.0))
            c.transform = CGAffineTransform(scaleX: sc, y: sc)
            
            // set translucent for far left cards
            if cards.count > 1 {
                c.alpha = min(1.0, x / 10.0)
            }
        }
    }
    
    private func doCentering(for cCard: CardView) -> Void {
        guard let idx = cards.firstIndex(of: cCard) else {
            return
        }
        
        var controlCard = cCard
        
        // if the leading edge is greater than 1/2 the view width,
        //  and it's not the Bottom card,
        //  set cur card to the previous card
        if idx > 0 && controlCard.frame.origin.x > self.bounds.width * 0.5 {
            controlCard = cards[idx - 1]
        }
        
        // center of control card will be offset to the right of center
        var newX = self.bounds.width * 0.6
        if controlCard == cards.last {
            // if it's the Top card, center it
            newX = self.bounds.width * 0.5
        }
        if controlCard == cards.first {
            // if it's the Bottom card, center it + just a little to the right
            newX = self.bounds.width * 0.51
        }
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.1, options: [.allowUserInteraction, .curveEaseOut], animations: {
            controlCard.center.x = newX
            self.updateCards(controlCard)
        }, completion: nil)
    }
    
}
