import UIKit

class ViewController: UICollectionViewController {
    
    var people = [Person]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewPerson))
        
    }
    
    @objc func addNewPerson() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self // need to conform two protocols
        present(picker, animated: true, completion: nil)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return people.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Person", for: indexPath) as? PersonCell else {
            fatalError("Unable to dequeue PersonCell")
        }
        let person = people[indexPath.item]
        cell.nameLabel.text = person.name
        
        let path = getDocumentDirectory().appendingPathComponent(person.image)
        cell.imageView.image = UIImage(contentsOfFile: path.path)
        
        cell.imageView.layer.borderColor = UIColor(white: 0, alpha: 0.3).cgColor
        cell.imageView.layer.borderWidth = 2
        cell.imageView.layer.cornerRadius = 3
        cell.layer.cornerRadius = 7
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let person = people[indexPath.item] // works because it's instance of the class
        let alertController = UIAlertController(title: "Rename", message: nil, preferredStyle: .alert)
        alertController.addTextField()

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self, weak alertController] (action) in
            guard let name = alertController?.textFields?[0].text else { return }
            person.name = name
            self?.collectionView.reloadData()
        }

        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }
}

// to be delegate view controller must conform these two protocols
extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // extract image from dictionary that is passed as a parameter - apple's common practice to send dictinary as a parameter with some value, need to know key to get the values from it
        // generate a unique filename for it
        // convert it to a jpeg, then write that jpeg to disk
        // dismiss the view controller
        
        guard let image = info[.editedImage] as? UIImage else { return }
        let imageName = UUID().uuidString
        let imagePath = getDocumentDirectory().appendingPathComponent(imageName)
        
        if let data = image.jpegData(compressionQuality: 0.8) {
            try? data.write(to: imagePath)
        }
        
        let person = Person(name: "Unknown", image: imageName)
        people.append(person)
        
        collectionView.reloadData()
        
        dismiss(animated: true, completion: nil)
    }
    
    func getDocumentDirectory() -> URL {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return path[0]
    }
}
