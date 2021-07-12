//
//  DetailViewController.swift
//  ChallengeDay50
//
//  Created by Igor Chernyshov on 12.07.2021.
//

import UIKit

final class DetailViewController: UIViewController {

	// MARK: - Outlets
	@IBOutlet var photoView: UIImageView!

	// MARK: - Properties
	var photo: UIImage?

	// MARK: - Lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()
		navigationItem.largeTitleDisplayMode = .never
		photoView.image = photo
	}
}
