//
//  CharacterDetails.swift
//  MarvelCodingExercise
//
//  Created by endOfLine on 7/18/21.
//

import UIKit

class CharacterDetails: UIViewController {

    @IBOutlet var attributionBtn: UIBarButtonItem!
    @IBOutlet var bio: UILabel!
    @IBOutlet var thumbnail: UIImageView!
    @IBOutlet var thumbnailHeight: NSLayoutConstraint!
    @IBOutlet var name: UILabel!
    
    var character: CharacterMO!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        assignProperties()
    }
}

// MARK: - Setup
extension CharacterDetails {
    
    func assignProperties() {
        attributionBtn.title = character.attribution
        name.text = character.name
        
        if character.bio?.isEmpty ?? true {
            bio.text = "no description available"
        } else {
            bio.text = character.bio
        }
        
        var image = UIImage.placeholder
        if let imageData = character.image, let cImage = UIImage(data: imageData) { image = cImage }
        thumbnail.image = image
        thumbnail.layoutIfNeeded()
        let ratio = image.size.width / image.size.height
        let imageHeight = thumbnail.frame.width / ratio
        thumbnailHeight.constant = imageHeight
        thumbnail.layoutIfNeeded()
    }
    
    func buildArrayOfLinks() {
        //TODO
    }
}


// MARK: - IBActions
extension CharacterDetails {
    
    @IBAction func attributionBtnTapped(_ sender: UIBarButtonItem) {
        if let url = URL(string: "http://marvel.com") {
            UIApplication.shared.open(url)
        }
    }
}
