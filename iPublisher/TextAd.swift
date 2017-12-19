
import UIKit

@IBDesignable public class TextAd: UIView, UIGestureRecognizerDelegate {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var adTitle: UILabel!
    @IBOutlet weak var adFavicon: UIImageView!
    @IBOutlet weak var siteFavicon: UIImageView!
    @IBOutlet weak var siteUrl: UILabel!
    @IBOutlet weak var adDesc: UILabel!
    
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
    
    //"H17YM53923MF14PL43PW15U6"
    
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
        self.contentView = UINib(nibName: "TextView", bundle: Bundle(for:
            type(of: self))).instantiate(withOwner: self, options: nil)[0]
            as! UIView
        //Bundle.main.loadNibNamed("TextView", owner: self, options: nil)
        
        if accessToken != "" {
            let urlPath: String = "http://www.webmarketer.ir/app_upload/applications/ads/api/json/?adboxid=" + TokenGenerator() + "&adgroup=TEXT&adclient=" + accessToken + "&adcount=1&linkcolor=&btcolor=&border=&bordercolor=&urlcolor=&textcolor=&pagination="
            CompleteLoadAction(urlString: urlPath, completion: { result in
                
            })
        }
    }
    
    public func refreshAd() {
        if accessToken != "" {
            let urlPath: String = "http://www.webmarketer.ir/app_upload/applications/ads/api/json/?adboxid=" + TokenGenerator() + "&adgroup=TEXT&adclient=" + accessToken + "&adcount=1&linkcolor=&btcolor=&border=&bordercolor=&urlcolor=&textcolor=&pagination="
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
                self.siteFavicon.downloadFrom(link: (self.advertise?.ads[0].favicon)!)
                DispatchQueue.main.async {
                    
                    self.adTitle.text = self.advertise?.ads[0].title
                    self.adDesc.text = self.advertise?.ads[0].description
                    self.siteUrl.text = self.advertise?.ads[0].domain
                    self.adDesc.numberOfLines = 0
                    self.adDesc.lineBreakMode = .byWordWrapping
                    self.adDesc.sizeToFit()
                    self.contentView.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.adDesc.frame.height + CGFloat(77))
                    self.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.adDesc.frame.height + CGFloat(77))
                    self.contentView.layer.borderColor = self.borderColor.cgColor
                    self.contentView.layer.borderWidth = self.borderWidth
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
