import UIKit
import FirebaseStorage
import FirebaseAuth
import FirebaseDatabase

class CameraViewController: UIViewController {
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//OBJE TANIMLARI------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var captionTextView: UITextView!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var removeButton: UIBarButtonItem!
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//TANIMLAR-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    var selectedImage : UIImage?
    let ref = Database.database().reference()
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//OVERRİDE FONKSİYONLAR------------------------------------------------------------------------------------------------------------------------------------------------------------------
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        handlePost()
    }
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target: self , action: #selector(self.handleSelectPhoto))
        photo.addGestureRecognizer(tapGesture)
        photo.isUserInteractionEnabled = true
    }
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//BUTTON ACTİONS---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    @IBAction func shareButton_TouchUpInside(_ sender: Any) {
        if let profileImg = self.selectedImage, let ImageData = UIImageJPEGRepresentation(profileImg, 0.1) {
            let photoIdString = NSUUID().uuidString
            let storageRef = Storage.storage().reference(forURL : "gs://my-project-1510502411596.appspot.com/").child("posts").child(photoIdString)
            storageRef.putData(ImageData, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                    print("hata var !!")
                    return
                }
                let photoUrl = metadata?.downloadURL()?.absoluteString
                self.sendDataToDatabase(photoUrl: photoUrl!)
            })
        }
    }
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    @IBAction func remove_TouchUpInside(_ sender: Any) {
        clean()
        handlePost()
    }
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//FUNCIONSSS-----------------------------------------------------------------------------------------------------------------------------------------------------
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    func handlePost(){
        if selectedImage != nil{
            self.shareButton.isEnabled = true
            self.removeButton.isEnabled = true
            self.shareButton.backgroundColor = .black
        }else{
            self.shareButton.isEnabled = false
            self.removeButton.isEnabled = false
            self.shareButton.backgroundColor = .lightGray
        }
    }
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    func sendDataToDatabase(photoUrl: String){
        let likeCount = 0
        let userID : String = (Auth.auth().currentUser?.uid)!
        Database.database().reference().child("users").child(userID).observe(.value, andPreviousSiblingKeyWith: { (snapshot, String) in
            if let dictionary = snapshot.value as? [String : AnyObject]{
              let usrname = dictionary["username"] as? String
                let postsReference = self.ref.child("posts")
                let newPostId = postsReference.childByAutoId().key
                let newPostReference = postsReference.child(newPostId)
                newPostReference.setValue(["photoUrl": photoUrl , "caption": self.captionTextView.text! , "userName": usrname as! String, "likeCount": likeCount as Int]) { (error, ref) in
                    if error != nil {
                        let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                        alertController.addAction(defaultAction)
                        self.present(alertController, animated: true, completion: nil)
                        print("hata var !!")
                        return
                    }
                    let alertController = UIAlertController(title: "Success", message:"Success", preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                    self.clean()
                    self.tabBarController?.selectedIndex = 0
                }
            }
        }, withCancel: nil)
        
       
    }
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    func clean(){
        self.captionTextView.text = ""
        self.photo.image = UIImage(named:"placeholder-Copy-1")
        self.selectedImage = nil
    }
    @objc func handleSelectPhoto (){
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        present(pickerController, animated: true , completion: nil)
    }
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//EXTENSİONS AND OTHERS-------------------------------------------------------------------------------------------------------------------------------------------------------
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
extension CameraViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            selectedImage = image
            photo.image = image
        }
        dismiss(animated: true, completion: nil)
    }
}


