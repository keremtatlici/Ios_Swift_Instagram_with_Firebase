import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class HomeViewController: UIViewController{
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//OBJE TANIMLARI------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    @IBOutlet weak var userNameBtn: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//TANIMLAR-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    var posts = [Post]()
    var uid = Auth.auth().currentUser?.uid
    var ref = Database.database().reference()
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//OVERRİDE FONKSİYONLAR------------------------------------------------------------------------------------------------------------------------------------------------------------------
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    override func viewDidLoad(){
        super.viewDidLoad()
        
        tableView.dataSource = self
        loadPosts()
        showUserName(uid: uid!)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "likeSegue" {
            if let geciciIndexPath = self.tableView.indexPathForSelectedRow{
                let name = posts[posts.count - geciciIndexPath.row - 1].caption
                let query = ref.child("posts").queryOrdered(byChild: "caption").queryEqual(toValue: name)
                
                query.observeSingleEvent(of: .value, with: { (snapshot) in
                    for snap in snapshot.children {
                        let postSnap = snap as! DataSnapshot
                        let uid = postSnap.key //the uid of each user
                        let postDict = postSnap.value as! [String : AnyObject]
                        let value =  postDict["likeCount"] as! Int
                        
                        let queryy = self.ref.child("posts").child(uid).child("usersWhichLiked")
                        
                        queryy.observeSingleEvent(of: .value, with: { (snapshott) in
                            if snapshott.hasChild((Auth.auth().currentUser?.uid)!){
                                self.ref.child("posts").child(uid).updateChildValues(["likeCount" : (value - 1)])
                                self.ref.child("posts").child(uid).child("usersWhichLiked").child((Auth.auth().currentUser?.uid)!).removeValue()
                                print ("BEĞENDEN ÇIK BLOGU")
                                
                            }else{
                                self.ref.child("posts").child(uid).updateChildValues(["likeCount" : (value + 1)])
                                self.ref.child("posts").child(uid).child("usersWhichLiked").child((Auth.auth().currentUser?.uid)!).setValue((Auth.auth().currentUser?.uid)!)
                                print ("BEĞEN BLOGU")
                            }
                        })

                    }
                })
            }
            
        }
    }
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//BUTTON ACTİONS---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    @IBAction func logout_TouchUpInside(_ sender: Any) {
        do{
            try Auth.auth().signOut()
        }
        catch let logoutError{
            print(logoutError)
        }
        if Auth.auth().currentUser == nil{
            self.performSegue(withIdentifier: "logoutInToSignInVC", sender: nil)
        }
    }
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//FUNCIONSSS-----------------------------------------------------------------------------------------------------------------------------------------------------
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    func showUserName(uid : String)
    {
        self.userNameBtn.title = ""
        
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value) { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                self.userNameBtn.title = (dictionary["username"] as? String)
            }
        }
    }
    
    func loadPosts(){
        Database.database().reference().child("posts").observe(.childAdded) { (snapshot: DataSnapshot) in
            if let dict = snapshot.value as? [String: Any] {
                let captionText = dict["caption"] as! String
                let photoUrlString = dict["photoUrl"] as! String
                let userNameText = dict["userName"] as! String
                let likeCount = dict["likeCount"] as! Int
                let post = Post(captionText: captionText , photoUrlString: photoUrlString, userNameText: userNameText, likeCount: likeCount)
                self.posts.append(post)
                self.tableView.reloadData()
            }
        }
    }
    func goToNextView() {
        performSegue(withIdentifier: "likeSegue", sender: self)
    }
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//EXTENSİONS AND OTHERS-------------------------------------------------------------------------------------------------------------------------------------------------------
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
extension HomeViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CaptionCell", for: indexPath)as! YourCell
        cell.label.text = posts[(posts.count - indexPath.row - 1)].caption
        cell.userNameLabel.text = "\(posts[(posts.count - indexPath.row - 1)].usernm) : "
        cell.likeCountLabel.text = "\(posts[(posts.count - indexPath.row - 1)].likecount) Beğeni "
        
        let urlKey = posts[(posts.count - indexPath.row - 1)].postUrl
        cell.imgView.image = nil
        
        if let url = URL(string: urlKey){
            do {
                let data = try Data(contentsOf: url)
                cell.imgView.image = UIImage(data: data)
            }catch let err {
                print("err\(err.localizedDescription)")
            }
        }else{
            print("resim yüklenemedi!!")
        }
        cell.delegate = self
        return cell
    }
}
extension HomeViewController: HomeViewControllerDelegate{
    func goToNextViewDelegate() {
        performSegue(withIdentifier:"likeSegue", sender: self)
    }
    
    
}
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
class YourCell: UITableViewCell{
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var likeCountLabel: UILabel!
    var checked = false
    var delegate : HomeViewControllerDelegate?
    let ref = Database.database().reference()
    @IBAction func buttonClicked(_ sender: UIButton) {
        if checked {
            sender.setImage( UIImage(named:"icons8-heart-35"), for: .normal)
            delegate?.goToNextViewDelegate()
            checked = false
        } else {
            sender.setImage(UIImage(named:"icons8-heart-filled-35"), for: .normal)
                delegate?.goToNextViewDelegate()
            self.isSelected = true
            checked = true
        }
    }
}
protocol HomeViewControllerDelegate {
    func goToNextViewDelegate()
}
