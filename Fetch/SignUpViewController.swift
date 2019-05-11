import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class SignUpViewController: UIViewController {
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//OBJE TANIMLARI------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var signUpButton: UIButton!
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//TANIMLAR-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    var selectedImage : UIImage?
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//OVERRİDE FONKSİYONLAR------------------------------------------------------------------------------------------------------------------------------------------------------------------
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        signUpButton.setTitleColor(UIColor.lightText, for: UIControlState.normal)
        signUpButton.isEnabled = false
        handleTextField()
        profileImage.layer.cornerRadius = 40
        profileImage.clipsToBounds = true
        let tapGesture = UITapGestureRecognizer(target: self , action: #selector(self.handleSelectProfileImageView))
        profileImage.addGestureRecognizer(tapGesture)
        profileImage.isUserInteractionEnabled = true
    }
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//BUTTON ACTİONS---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    @IBAction func dismiss_onClick(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    @IBAction func SignUpBtn_TouchUpInside(_ sender: Any) {
        Auth.auth().createUser(withEmail: emailTextField.text! , password: passwordTextField.text! , completion: {
            (user, error) in
            if error != nil {
                let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                self.present(alertController, animated: true, completion: nil)
                print(error!.localizedDescription)
                return
            }
            let uid = user?.uid
            let storageRef = Storage.storage().reference(forURL : "gs://my-project-1510502411596.appspot.com/").child("profile_image").child(uid!)
            if let profileImg = self.selectedImage, let ImageData = UIImageJPEGRepresentation(profileImg, 0.1) {
                storageRef.putData(ImageData, metadata: nil, completion: { (metadata, error) in
                    if error != nil {
                        return
                    }
                    let profileImageUrl = metadata?.downloadURL()?.absoluteString
                    self.setUserInformation(profileImageUrl: profileImageUrl!, username: self.usernameTextField.text!, email: self.emailTextField.text!, uid: uid!)
                })
            }
        })
        view.endEditing(true)
    }
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//FUNCIONSSS-----------------------------------------------------------------------------------------------------------------------------------------------------
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    func setUserInformation(profileImageUrl: String, username: String, email: String, uid: String){
        let ref = Database.database().reference()
        let usersReference = ref.child("users")
        let newUserReference = usersReference.child(uid)
        newUserReference.setValue(["username" : username, "email" : email, "profileImageUrl": profileImageUrl])
        self.performSegue(withIdentifier: "signUpInToTabbarVC", sender: nil)
    }
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    @objc func handleSelectProfileImageView() {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        present(pickerController, animated: true , completion: nil)
    }
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    @objc func textFieldDidChanged() {
        guard let username = usernameTextField.text , !username.isEmpty, let email = emailTextField.text , !email.isEmpty, let password = passwordTextField.text, !password.isEmpty else {
            signUpButton.setTitleColor(UIColor.lightText, for: UIControlState.normal)
            signUpButton.isEnabled = false
            return
        }
        signUpButton.setTitleColor(UIColor.white, for: UIControlState.normal)
        signUpButton.isEnabled = true
    }
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    func handleTextField(){
        usernameTextField.addTarget(self, action: #selector(self.textFieldDidChanged), for: UIControlEvents.editingChanged)
        emailTextField.addTarget(self, action: #selector(self.textFieldDidChanged), for: UIControlEvents.editingChanged)
        passwordTextField.addTarget(self, action: #selector(self.textFieldDidChanged), for: UIControlEvents.editingChanged)
    }
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//EXTENSİONS AND OTHERS-------------------------------------------------------------------------------------------------------------------------------------------------------
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
extension SignUpViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image=info["UIImagePickerControllerOriginalImage"] as? UIImage{
            selectedImage = image
            profileImage.image = image
        }
        dismiss(animated: true, completion: nil)
    }
}
