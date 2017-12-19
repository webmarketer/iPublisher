
import UIKit

@IBDesignable public class MPU: UIView, UIGestureRecognizerDelegate {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var adImage: UIImageView!
    @IBOutlet weak var adFavicon: UIImageView!
    
    var advertise: AdvertiseHolder? = nil
    
    @IBInspectable public var accessToken: String = "" {
        didSet{
            commonInit()
        }
    }
    @IBInspectable public var borderColor: UIColor = UIColor.clear {
        didSet{
            commonInit()
        }
    }
    @IBInspectable public var borderWidth: CGFloat = 0 {
        didSet{
            commonInit()
        }
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override public func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        commonInit()
        contentView?.prepareForInterfaceBuilder()
    }
    
    override public var intrinsicContentSize: CGSize {
        return CGSize(width: self.bounds.width, height: self.bounds.height)
    }
    
    private func commonInit() {
        self.contentView = UINib(nibName: "MPUView", bundle: Bundle(for:
            type(of: self))).instantiate(withOwner: self, options: nil)[0]
            as! UIView
        //Bundle.main.loadNibNamed("MPUView", owner: self, options: nil)
        
        if accessToken != "" {
            let urlPath: String = "http://www.webmarketer.ir/app_upload/applications/ads/api/json/?adboxid=" + TokenGenerator() + "&adgroup=MPU&adclient=" + accessToken + "&adcount=1&linkcolor=&btcolor=&border=&bordercolor=&urlcolor=&textcolor=&pagination="
            CompleteLoadAction(urlString: urlPath, completion: { result in
                
            })
        }
    }
    
    public func refreshAd() {
        if accessToken != "" {
            let urlPath: String = "http://www.webmarketer.ir/app_upload/applications/ads/api/json/?adboxid=" + TokenGenerator() + "&adgroup=MPU&adclient=" + accessToken + "&adcount=1&linkcolor=&btcolor=&border=&bordercolor=&urlcolor=&textcolor=&pagination="
            CompleteLoadAction(urlString: urlPath, completion: { result in
                
            })
        }
    }
    
    @objc func onAdvertiseClick() {
        guard let url = URL(string: (self.advertise?.ads[0].url)!) else {
            return
        }
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    func CompleteLoadAction(urlString:String, completion: @escaping (AdvertiseHolder?) -> ()) {
        let url = URL(string:urlString.trimmingCharacters(in: .whitespaces))
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        let stringPost = "app=" + Bundle.main.bundleIdentifier!
        let data = stringPost.data(using: String.Encoding.utf8)
        request.httpBody = data
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("error=\(String(describing: error))")
                completion(nil)
                return
            }
            
            do {
                self.advertise = try JSONDecoder().decode(AdvertiseHolder.self, from: data)
                DispatchQueue.main.async {
                    let format = String((self.advertise?.ads[0].image)!.suffix(3))
                    if format == "gif" {
                        self.adImage.image = UIImage.gifImageWithURL(gifUrl: (self.advertise?.ads[0].image)!)
                    }
                    else {
                        self.adImage.downloadFrom(link: (self.advertise?.ads[0].image)!)
                    }
                    let rate = CGFloat((self.advertise?.width)!)/CGFloat((self.advertise?.height)!)
                    let height = self.bounds.width/CGFloat(rate)
                    let faviconHeight = height/CGFloat(10)
                    let topSpace = self.bounds.height - height
                    self.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: self.bounds.width, height: height)
                    self.adImage.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height)
                    self.adFavicon.frame = CGRect(x: 8, y: 8 + topSpace, width: faviconHeight, height: faviconHeight)
                    self.adImage.layer.borderColor = self.borderColor.cgColor
                    self.adImage.layer.borderWidth = self.borderWidth
                    self.contentView.bringSubview(toFront: self.adFavicon)
                    self.addSubview(self.contentView)
                    self.invalidateIntrinsicContentSize()
                    self.contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
                    
                    let tap = UITapGestureRecognizer(target: self, action: #selector(self.onAdvertiseClick))
                    tap.delegate = self
                    self.contentView.addGestureRecognizer(tap)
                }
                completion(self.advertise)
            }
            catch {
                print(error)
                completion(nil)
            }
        }
        task.resume()
        
    }
    
    func TokenGenerator() -> String {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        
        var randomString = ""
        
        for _ in 0 ..< 16 {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        return randomString
    }
    
}

