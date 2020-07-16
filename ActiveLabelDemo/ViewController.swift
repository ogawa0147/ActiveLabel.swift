//
//  ViewController.swift
//  ActiveLabelDemo
//
//  Created by Johannes Schickling on 9/4/15.
//  Copyright © 2015 Optonaut. All rights reserved.
//

import UIKit
import ActiveLabel

class ViewController: UIViewController {

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 0
        return stackView
    }()
    private lazy var label: ActiveLabel = {
        let label = ActiveLabel()
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

//        let text = """
//        This is a post with #multiple #hashtags and a @userhandle.
//        Links are also supported like this one: http://optonaut.co. Now it also supports custom patterns -> are
//
//
//        Let's trim a long link: \nhttps://twitter.com/twicket_app/status/649678392372121601
//        """

        let text = """
        #1
        #12345678901234567890123456789012345678901234567890123456789012345678901234567890123456
        #1234567890123456789012345678901234567890123456789012345678901234567890123456789012345
        #123456789012345678901234567890123456789012345678901234567890123456789012345678901234
        
        #some@mention ##some@mention #https://www.google.com
        .#somehashtag #. #somehashtag.
        #some&#mention
        #あいうえお
        #さしすせそ#かきくけこ
        
        #@ #% #* #+ #~ #! ## #$ #^ #& #( #) #{ #} #[ #] #; #' #: #" #? #/
        
        #1 #2 #3 #4 #5 #6 #7 #8 #9 #10 #11 #12 #13 #14 #15 #16 #17 #18 #19 #20 #21 #22 #23 #24 #25 #26 #27 #28 #29 #30 #31 #32 #33 #34 #35 #36 #37 #38 #39 #40 #41 #42 #43
        
        #h
        @mention @mention2
        https://www.google.com.com
        """

        let customType = ActiveType.custom(pattern: "\\sare\\b") //Looks for "are"
        let customType2 = ActiveType.custom(pattern: "\\sit\\b") //Looks for "it"
        let customType3 = ActiveType.custom(pattern: "\\ssupports\\b") //Looks for "supports"

//        label.enabledTypes = [.hashtag, .hashtag2, .mention, .url]
        label.enabledTypes = [.hashtag, .mention, .url]
        label.enabledTypes.append(customType)
        label.enabledTypes.append(customType2)
        label.enabledTypes.append(customType3)

        label.urlMaximumLength = 31

        label.availableHashtags = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30"]

        label.customize { label in
            label.text = text

            label.numberOfLines = 0
            label.lineSpacing = 4
            
            label.textColor = UIColor(red: 102.0/255, green: 117.0/255, blue: 127.0/255, alpha: 1)
            label.hashtagColor = UIColor(red: 85.0/255, green: 172.0/255, blue: 238.0/255, alpha: 1)
            label.mentionColor = UIColor(red: 238.0/255, green: 85.0/255, blue: 96.0/255, alpha: 1)
            label.URLColor = UIColor(red: 85.0/255, green: 238.0/255, blue: 151.0/255, alpha: 1)
            label.URLSelectedColor = UIColor(red: 82.0/255, green: 190.0/255, blue: 41.0/255, alpha: 1)

            label.handleMentionTap { self.alert("Mention", message: $0) }
            label.handleHashtagTap { self.alert("Hashtag", message: $0) }
            label.handleURLTap { self.alert("URL", message: $0.absoluteString) }

            //Custom types

            label.customColor[customType] = UIColor.purple
            label.customSelectedColor[customType] = UIColor.green
            label.customColor[customType2] = UIColor.magenta
            label.customSelectedColor[customType2] = UIColor.green
            
            label.configureLinkAttribute = { (type, attributes, isSelected) in
                var atts = attributes
                switch type {
                case customType3:
                    atts[NSAttributedString.Key.font] = isSelected ? UIFont.boldSystemFont(ofSize: 16) : UIFont.boldSystemFont(ofSize: 14)
                default: ()
                }
                
                return atts
            }

            label.handleCustomTap(for: customType) { self.alert("Custom type", message: $0) }
            label.handleCustomTap(for: customType2) { self.alert("Custom type", message: $0) }
            label.handleCustomTap(for: customType3) { self.alert("Custom type", message: $0) }
        }

        view.addSubview(stackView)

        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 30.0).isActive = true
        stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10.0).isActive = true
        stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10.0).isActive = true
        stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30.0).isActive = true

        stackView.addArrangedSubview(label)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func alert(_ title: String, message: String) {
        let vc = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        vc.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        present(vc, animated: true, completion: nil)
    }
}
