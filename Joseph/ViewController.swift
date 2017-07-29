//
//  ViewController.swift
//  Joseph
//
//  Created by Max on 10/06/2017.
//  Copyright © 2017 Lisacintosh. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
	
	private var whiteLabel: UILabel!
	private var redLabel: UILabel!
	private var greenLabel: UILabel!
	private var blueLabel: UILabel!
	private var purpleLabel: UILabel!
	private var yellowLabel: UILabel!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		whiteLabel = UILabel()
		whiteLabel.text = "White Label"
		whiteLabel.font = .systemFont(ofSize: 10)
		whiteLabel.layer.borderColor = UIColor.lightGray.cgColor
		whiteLabel.layer.borderWidth = 1
		
		redLabel = UILabel()
		redLabel.backgroundColor = .red
		redLabel.text = "Red \n Label"
		redLabel.numberOfLines = 2
		
		greenLabel = UILabel()
		greenLabel.backgroundColor = .green
		greenLabel.text = "Green Label"
		greenLabel.font = .systemFont(ofSize: 20)
		
		blueLabel = UILabel()
		blueLabel.backgroundColor = .blue
		blueLabel.text = "Blue Label"
		blueLabel.textColor = .white
		blueLabel.font = .systemFont(ofSize: 10)
		
		purpleLabel = UILabel()
		purpleLabel.backgroundColor = .purple
		purpleLabel.text = "Purple Label"
		purpleLabel.textColor = .white
		
		yellowLabel = UILabel()
		yellowLabel.backgroundColor = .yellow
		yellowLabel.text = "Yellow Label"
		yellowLabel.alpha = 0.5
		
		let labels = [ whiteLabel, redLabel, greenLabel, blueLabel, purpleLabel, yellowLabel ]
		labels.forEach {
			$0!.translatesAutoresizingMaskIntoConstraints = false
			self.view.addSubview($0!)
		}
		setupConstraints()
	}
	
	private func setupConstraints() {
		// Set `whiteLabel` frame with margins inset and extra 20pt margin on top and bottom 
		whiteLabel.edges = self.view.margins + UIOffset(horizontal: 0, vertical: 20)
		
		// Set `redLabel` position
		redLabel.top = self.view.topMargin + 30
		redLabel.left = self.view.leftMargin * 1.5 // ~16pt (margin) * 1.5
		
		// Set `greenLabel` position
		greenLabel.left = redLabel.left // Left aligned
		greenLabel.top = redLabel.bottom + 10 ~ 751 // with priority of 751
		
		greenLabel.width.in(220...280) // Same that `220 <= greenLabel.width; greenLabel.width <= 280`
		greenLabel.width = redLabel.width × 2 ~ 251 // 2 times wider with priority of 251
		greenLabel.height = redLabel.height / 0.5
		
		// Set `blueLabel` centered
		blueLabel.centerX = self.view.centerX
		blueLabel.bottom = self.view.bottomMargin - 40
		
		blueLabel.width >= redLabel.width // `blueLabel` wider or same width
		greenLabel.height <= blueLabel.height // `blueLabel` taller or same height
		
		// Set `purpleLabel` centered with 2/3 ratio (3 * width = 2 * height)
		purpleLabel.middle = self.view.middle - UIOffset(horizontal: 0, vertical: 10)
		purpleLabel.ratio = 2∶3
		purpleLabel.x <~> 249 // Set hugging priority for x-axis to 249
		
		// Set `yellowLabel` smaller by 20pt for each edge than `purpleLabel`
		yellowLabel.edges = purpleLabel.edges + 20
	}
}
