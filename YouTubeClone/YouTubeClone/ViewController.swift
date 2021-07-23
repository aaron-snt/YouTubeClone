
import UIKit
import SnapKit
import RxSwift
import RxCocoa
import Kingfisher


class ViewController: UIViewController {

    var topView = UIView(frame: .zero)
    var videoTableView = UITableView(frame: .zero)
    
    let disposeBag = DisposeBag()
    
    let viewModel = YouTubeVideoViewModel()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(topView)
        self.view.addSubview(videoTableView)
        
        videoTableView.register(YouTubeVideoTableViewCell.self, forCellReuseIdentifier: "videoCell")
        videoTableView.rx.setDelegate(self).disposed(by: disposeBag)
        videoTableView.rowHeight = 280

        viewModel.videoSubject.bind(to: videoTableView.rx.items(cellIdentifier: "videoCell", cellType: YouTubeVideoTableViewCell.self)) { (index, element, cell) in
            print("\(element.id)")
            if let url = element.snippet.thumbnails?.medium?.url {
                cell.update(url: url)
            }

            cell.updateTitle(title: element.snippet.title)
            cell.updateChannelTitle(title: element.snippet.channelTitle)

            
//            if let url = element.snippet.t?.url {
//                cell.update(url: url)
//            }
            
           // cell.textLabel?.text = element

        }.disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.fetchData().subscribe(onSuccess: { response in
                    print("success")
                }, onFailure: {_ in
                    print("fail")
                }).disposed(by: disposeBag)
        
        setupLayout()
    }

    func setupLayout() {
        topView.snp.makeConstraints { make in
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.top.equalTo(self.view.safeAreaLayoutGuide)
            make.height.equalTo(50)
        }
        topView.backgroundColor = .red
        
        videoTableView.snp.makeConstraints{ make in
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.top.equalTo(topView.snp.bottom)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
        }
    }

}

extension ViewController: UITableViewDelegate {
    

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 280
    }
}



class YouTubeVideoTableViewCell: UITableViewCell {
    let thumbnailView: UIImageView = UIImageView(frame: .zero)
    
    let descriptionView: UIView = UIView(frame: .zero)
    let descriptionImageView: UIImageView = UIImageView(frame: .zero)
    let descriptionTitleView: UILabel = UILabel(frame: .zero)
    let descriptionChannelTitleView: UILabel = UILabel(frame: .zero)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.addSubview(thumbnailView)
        self.contentView.addSubview(descriptionView)
        self.descriptionView.addSubview(descriptionImageView)
        self.descriptionView.addSubview(descriptionTitleView)
        self.descriptionView.addSubview(descriptionChannelTitleView)
        
        thumbnailView.contentMode = .scaleAspectFill
        thumbnailView.snp.makeConstraints { make in
            make.left.equalTo(self.contentView)
            make.right.equalTo(self.contentView)
            make.top.equalTo(self.contentView)
            make.height.equalTo(200)
        }
        
        descriptionView.snp.makeConstraints { make in
            make.left.equalTo(self.contentView)
            make.right.equalTo(self.contentView)
            make.top.equalTo(self.thumbnailView.snp.bottom)
            make.bottom.equalTo(self.contentView)
        }
        
        descriptionView.backgroundColor = .blue
        
        descriptionImageView.layer.masksToBounds = true
        descriptionImageView.layer.cornerRadius = 40 / 2
        
        descriptionImageView.snp.makeConstraints { make in
            make.left.equalTo(self.descriptionView).inset(20)
            make.height.equalTo(40)
            make.width.equalTo(40)
            make.top.equalTo(self.descriptionView).inset(10)
        }
        
        descriptionTitleView.font = UIFont.boldSystemFont(ofSize: 16.0)
        descriptionTitleView.numberOfLines = 2
        descriptionTitleView.lineBreakMode = .byWordWrapping
        
        descriptionTitleView.snp.makeConstraints { make in
            make.left.equalTo(self.descriptionImageView).inset(20)
            make.top.equalTo(self.descriptionView).inset(10)
            make.right.equalTo(self.descriptionView).inset(20)
        }
        
        descriptionChannelTitleView.font = UIFont.systemFont(ofSize: 13.0, weight: .regular)
        descriptionChannelTitleView.numberOfLines = 1
        
        descriptionChannelTitleView.snp.makeConstraints { make in
            make.left.equalTo(self.descriptionImageView).inset(20)
            make.top.equalTo(self.descriptionTitleView.snp.bottom).offset(5)
            make.width.greaterThanOrEqualTo(50)
        }
        
        descriptionChannelTitleView.backgroundColor = .red
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func update(url: String) {
        thumbnailView.kf.setImage(with: URL(string: url))
    }
    
    func updateTitle(title: String) {
        descriptionTitleView.text = title
    }
    
    func updateChannelTitle(title: String) {
        descriptionChannelTitleView.text = title
    }

    
}

class YouTubeVideoViewModel {
    let disposeBag = DisposeBag()
    
    let videoSubject = BehaviorSubject<[YouTubeVideoItem]>(value: [])
    var videos: [YouTubeVideoItem] = []

    func fetchData() -> Single<YouTubeVideoResponse?>{
        return YouTubeApi.shared.mostPopular().do( onSuccess: { response in
            self.videos = response?.items ?? []
            print("\(self.videos.count)")
            self.videoSubject.on(.next(self.videos))
        })
    }
    
}

