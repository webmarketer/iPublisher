
import UIKit
import ImageIO

struct AdvertiseHolder: Decodable {
    var group: String
    var width: Int
    var height: Int
    var show_title: Int
    var description_chars: Int
    var ads: [AdvertiseItem]
}
struct AdvertiseItem: Decodable {
    var title: String
    var description: String
    var image: String
    var url: String
    var domain: String
    var favicon: String
}

extension UIImageView {
    func downloadFrom(url: URL, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        DispatchQueue.main.async { // Correct
            self.contentMode = mode
        }
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() {
                self.image = image
            }
            }.resume()
    }
    func downloadFrom(link: String, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloadFrom(url: url, contentMode: mode)
    }
}
extension UIImage {
    public class func gifImageWithData(data: NSData) -> UIImage? {
        guard let source = CGImageSourceCreateWithData(data, nil) else {
            print("image doesn't exist")
            return nil
        }
        
        return UIImage.animatedImageWithSource(source: source)
    }
    
    public class func gifImageWithURL(gifUrl:String) -> UIImage? {
        guard let bundleURL = NSURL(string: gifUrl)
            else {
                print("image named \"\(gifUrl)\" doesn't exist")
                return nil
        }
        guard let imageData = NSData(contentsOf: bundleURL as URL) else {
            print("image named \"\(gifUrl)\" into NSData")
            return nil
        }
        
        return gifImageWithData(data: imageData)
    }
    
    public class func gifImageWithName(name: String) -> UIImage? {
        guard let bundleURL = Bundle.main
            .url(forResource: name, withExtension: "gif") else {
                print("SwiftGif: This image named \"\(name)\" does not exist")
                return nil
        }
        
        guard let imageData = NSData(contentsOf: bundleURL) else {
            print("SwiftGif: Cannot turn image named \"\(name)\" into NSData")
            return nil
        }
        
        return gifImageWithData(data: imageData)
    }
    class func delayForImageAtIndex(index: Int, source: CGImageSource!) -> Double {
        var delay = 0.1
        
        let cfProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil)
        let gifProperties: CFDictionary = unsafeBitCast(CFDictionaryGetValue(cfProperties, Unmanaged.passUnretained(kCGImagePropertyGIFDictionary).toOpaque()), to: CFDictionary.self)
        
        var delayObject: AnyObject = unsafeBitCast(CFDictionaryGetValue(gifProperties, Unmanaged.passUnretained(kCGImagePropertyGIFUnclampedDelayTime).toOpaque()), to: AnyObject.self)
        
        if delayObject.doubleValue == 0 {
            delayObject = unsafeBitCast(CFDictionaryGetValue(gifProperties, Unmanaged.passUnretained(kCGImagePropertyGIFDelayTime).toOpaque()), to: AnyObject.self)
        }
        
        delay = delayObject as! Double
        
        if delay < 0.1 {
            delay = 0.1
        }
        
        return delay
    }
    
    class func gcdForPair(a: Int?, _ b: Int?) -> Int {
        var a = a
        var b = b
        if b == nil || a == nil {
            if b != nil {
                return b!
            } else if a != nil {
                return a!
            } else {
                return 0
            }
        }
        
        if a! < b! {
            let c = a!
            a = b!
            b = c
        }
        
        var rest: Int
        while true {
            rest = a! % b!
            
            if rest == 0 {
                return b!
            } else {
                a = b!
                b = rest
            }
        }
    }
    
    class func gcdForArray(array: Array<Int>) -> Int {
        if array.isEmpty {
            return 1
        }
        
        var gcd = array[0]
        
        for val in array {
            gcd = UIImage.gcdForPair(a: val, gcd)
        }
        
        return gcd
    }
    
    class func animatedImageWithSource(source: CGImageSource) -> UIImage? {
        let count = CGImageSourceGetCount(source)
        var images = [CGImage]()
        var delays = [Int]()
        
        for i in 0..<count {
            if let image = CGImageSourceCreateImageAtIndex(source, i, nil) {
                images.append(image)
            }
            
            let delaySeconds = UIImage.delayForImageAtIndex(index: Int(i), source: source)
            delays.append(Int(delaySeconds * 1000.0)) // Seconds to ms
        }
        
        let duration: Int = {
            var sum = 0
            
            for val: Int in delays {
                sum += val
            }
            
            return sum
        }()
        
        let gcd = gcdForArray(array: delays)
        var frames = [UIImage]()
        
        var frame: UIImage
        var frameCount: Int
        for i in 0..<count {
            frame = UIImage(cgImage: images[Int(i)])
            frameCount = Int(delays[Int(i)] / gcd)
            
            for _ in 0..<frameCount {
                frames.append(frame)
            }
        }
        
        let animation = UIImage.animatedImage(with: frames, duration: Double(duration) / 1000.0)
        
        return animation
    }
}

@IBDesignable public class LeaderBoard: UIView, UIGestureRecognizerDelegate {

    @IBOutlet private var contentView: UIView!
    @IBOutlet private weak var adImage: UIImageView!
    @IBOutlet private weak var adFavicon: UIImageView!
    
    private var advertise: AdvertiseHolder? = nil
    
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
        self.contentView = UINib(nibName: "LeaderBoardView", bundle: Bundle(for:
            type(of: self))).instantiate(withOwner: self, options: nil)[0]
            as! UIView
        
        if accessToken != "" {
            let urlPath: String = "http://www.webmarketer.ir/app_upload/applications/ads/api/json/?adboxid=" + TokenGenerator() + "&adgroup=LEADERBOARD&adclient=" + accessToken + "&adcount=1&linkcolor=&btcolor=&border=&bordercolor=&urlcolor=&textcolor=&pagination="
            CompleteLoadAction(urlString: urlPath, completion: { result in
                
            })
        }
    }
    
    public func refreshAd() {
        if accessToken != "" {
            let urlPath: String = "http://www.webmarketer.ir/app_upload/applications/ads/api/json/?adboxid=" + TokenGenerator() + "&adgroup=LEADERBOARD&adclient=" + accessToken + "&adcount=1&linkcolor=&btcolor=&border=&bordercolor=&urlcolor=&textcolor=&pagination="
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
                    if self.bounds.width <= CGFloat((self.advertise?.width)!) {
                        let rate = CGFloat((self.advertise?.width)!)/CGFloat((self.advertise?.height)!)
                        let height = self.bounds.width/CGFloat(rate)
                        let faviconHeight = height/CGFloat(6)
                        self.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: height)
                        let topSpace = self.bounds.height - height
                        self.adImage.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height)
                        self.adFavicon.frame = CGRect(x: 4, y: 4 + topSpace, width: faviconHeight, height: faviconHeight)
                        self.adImage.layer.borderColor = self.borderColor.cgColor
                        self.adImage.layer.borderWidth = self.borderWidth
                        self.contentView.bringSubview(toFront: self.adFavicon)
                        self.addSubview(self.contentView)
                        self.invalidateIntrinsicContentSize()
                        self.contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
                    }
                    else {
                        let rate = CGFloat((self.advertise?.width)!)/CGFloat((self.advertise?.height)!)
                        let height = CGFloat((self.advertise?.width)!)/CGFloat(rate)
                        let faviconHeight = height/CGFloat(6)
                        self.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: height)
                        let topSpace = self.bounds.height - height
                        let leftSpace = (self.bounds.width - CGFloat((self.advertise?.width)!))/2
                        self.adImage.frame = CGRect(x: leftSpace, y: 0, width: CGFloat((self.advertise?.width)!), height: self.bounds.height)
                        self.adFavicon.frame = CGRect(x: 8 + leftSpace, y: 8 + topSpace, width: faviconHeight, height: faviconHeight)
                        self.adImage.layer.borderColor = self.borderColor.cgColor
                        self.adImage.layer.borderWidth = self.borderWidth
                        self.contentView.bringSubview(toFront: self.adFavicon)
                        self.addSubview(self.contentView)
                        self.invalidateIntrinsicContentSize()
                        self.contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
                    }
                    
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
