//
//  ViewController.swift
//  ChallengeDay50
//
//  Created by Igor Chernyshov on 12.07.2021.
//

import UIKit

final class ViewController: UITableViewController {

	// MARK: - Properties
	private var models: [PhotoModel] = []

	// MARK: - Lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()
		configureNavigationBar()
		loadModels()
	}

	// MARK: - UI Configuration
	private func configureNavigationBar() {
		title = "Your photos"
		navigationController?.navigationBar.prefersLargeTitles = true
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addPhotoDidTap))
	}

	// MARK: - Actions
	@objc private func addPhotoDidTap() {
		let photoController = UIImagePickerController()
		photoController.allowsEditing = true
		if UIImagePickerController.isSourceTypeAvailable(.camera) {
			photoController.sourceType = .camera
		}
		photoController.delegate = self
		present(photoController, animated: true)
	}

	private func presentDescriptionPickerController(for image: UIImage) {
		let alertController = UIAlertController(title: "Add description", message: nil, preferredStyle: .alert)
		alertController.addTextField()
		alertController.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
			let fileName = UUID().uuidString
			if let fileURL = self?.getDocumentsDirectory()?.appendingPathComponent(fileName), let pngData = image.pngData() {
				try? pngData.write(to: fileURL)
			}
			let description = alertController.textFields?.first?.text ?? "Add photo description"
			let model = PhotoModel(fileName: fileName, description: description)
			self?.models.append(model)
			self?.saveModels()
			self?.tableView.reloadData()
		})
		alertController.addAction(UIAlertAction(title: "Cancel", style: .destructive))
		present(alertController, animated: UIView.areAnimationsEnabled)
	}

	// MARK: - Data Operations
	private func saveModels() {
		if let data = try? JSONEncoder().encode(models) {
			UserDefaults.standard.setValue(data, forKey: "photos")
		} else {
			print("Failed to encode models")
		}
	}

	private func loadModels() {
		if let data = UserDefaults.standard.data(forKey: "photos") {
			do {
				let loadedModels = try JSONDecoder().decode([PhotoModel].self, from: data)
				models = loadedModels
				tableView.reloadData()
			} catch {
				print("Failed to decode models")
			}
		}
	}

	// MARK: - Helpers
	private func loadPhoto(fileName: String) -> UIImage? {
		guard let url = getFileURL(fileName: fileName) else { return nil }
		return UIImage(contentsOfFile: url.path)
	}

	private func getFileURL(fileName: String) -> URL? {
		getDocumentsDirectory()?.appendingPathComponent(fileName)
	}

	private func getDocumentsDirectory() -> URL? {
		FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
   }
}

// MARK: - UITableViewDataSource
extension ViewController {

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { models.count }

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: "PhotoCell") as? PhotoCell else {
			fatalError("Unable to dequeue cell")
		}
		let model = models[indexPath.row]

		cell.descriptionLabel.text = model.description
		cell.photoView.image = loadPhoto(fileName: model.fileName)

		return cell
	}
}

// MARK: - UITableViewDelegate
extension ViewController {

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		guard let detailViewController = storyboard?.instantiateViewController(identifier: "DetailViewController") as? DetailViewController else { return }
		let model = models[indexPath.row]
		detailViewController.title = model.description
		detailViewController.photo = loadPhoto(fileName: model.fileName)
		navigationController?.pushViewController(detailViewController, animated: UIView.areAnimationsEnabled)
	}
}

// MARK: - UIImagePickerControllerDelegate & UINavigationControllerDelegate
extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

	func imagePickerController(_ picker: UIImagePickerController,
							   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
		guard let image = info[.editedImage] as? UIImage else { return }
		dismiss(animated: true)
		presentDescriptionPickerController(for: image)
	}
}
