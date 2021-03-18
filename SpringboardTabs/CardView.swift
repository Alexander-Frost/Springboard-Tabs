//
//  CardView.swift
//  SpringboardTabs
//
//  Created by Alex Frost on 3/13/21.
//

import UIKit

class CardView: UIView {
    
    // MARK: - Properties
    
    var theLabels: [UILabel] = []
    
    var cardID: Int = 0 {
        didSet {
            theLabels.forEach {
                $0.text = "\(cardID)"
            }
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
        for i in 1...5 {
            let v = UILabel()
            v.font = .systemFont(ofSize: 24.0)
            v.translatesAutoresizingMaskIntoConstraints = false
            addSubview(v)
            switch i {
            case 1:
                v.topAnchor.constraint(equalTo: topAnchor, constant: 10.0).isActive = true
                v.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.0).isActive = true
            case 2:
                v.topAnchor.constraint(equalTo: topAnchor, constant: 10.0).isActive = true
                v.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.0).isActive = true
            case 3:
                v.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10.0).isActive = true
                v.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.0).isActive = true
            case 4:
                v.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10.0).isActive = true
                v.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.0).isActive = true
            default:
                v.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
                v.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            }
            theLabels.append(v)
        }
        
        layer.cornerRadius = 40
        
        // border
        layer.borderWidth = 1.0
        layer.borderColor = UIColor.gray.cgColor
        
        // shadow
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: -3, height: 3)
        layer.shadowOpacity = 0.25
        layer.shadowRadius = 2.0
    }
    
}
