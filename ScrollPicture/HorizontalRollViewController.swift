//
//  HorizontalRollViewController.swift
//  ScrollPicture
//
//  Created by 俎大哥 on 2023/9/5.
//

import UIKit

class HorizontalRollViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    let collectionView: UICollectionView
    let images = ["image1", "image2", "image3"]
    let layout: UICollectionViewFlowLayout
    
    var myOffsetX = 0.0 // 记录上次的offsetx便于判断是左滑还是右滑
    let groupNum = 100 // 定义多少个组
    
    let lineSpacing = 30.0
    let itemWidth = UIScreen.main.bounds.width/2 // 卡片宽度
    let itemHeigh = UIScreen.main.bounds.height/2
    
    init() {
        layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = self.lineSpacing
        layout.itemSize = CGSize(width: itemWidth, height: itemHeigh)
        layout.scrollDirection = .horizontal
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.decelerationRate = .fast
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        view.backgroundColor = .white
        setupSubView()
        // 初始定位到中间
        collectionView.scrollToItem(at: IndexPath.init(item: groupNum/2 * images.count , section: 0), at: .centeredHorizontally, animated: false)
    }
    
    func setupSubView() {
        collectionView.frame = view.bounds
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isPagingEnabled = false
        // 注册单元格
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "UICollectionViewCell")
        view.addSubview(collectionView)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // 图片的数量
        return groupNum * images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UICollectionViewCell", for:indexPath)
        // 移除之前的子视图
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        // 取余 计算出应该在images数组哪个位置
        let imageIndex = indexPath.item % images.count
        let imageView = UIImageView(image: UIImage(named: images[imageIndex]))
        imageView.frame = cell.bounds
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        cell.contentView.addSubview(imageView)
        return cell
    }
    
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        // 停止滑动时，当前的偏移量（即最近停止的位置）
        self.myOffsetX = scrollView.contentOffset.x
    }
    
    // collectionView.pagingEnabled = NO;
    // 禁止分页滑动时，根据偏移量判断滑动到第几个item
    // 滑动 “减速滚动时” 是触发的代理，当用户用力滑动或者清扫时触发
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        self.scrollToNextPageOrLastPage(scrollView)
    }
    
    // 用户拖拽时 调用
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        self.scrollToNextPageOrLastPage(scrollView)
    }

    func scrollToNextPageOrLastPage(_ scrollView: UIScrollView) {
        
        // 到达左右边界，定位到中间
        let contentWidth = (itemWidth+lineSpacing) * Double(groupNum*images.count) // 内容的总宽度
        let adjustedContentWidth = contentWidth - lineSpacing // 调整后的内容宽度，减去最后一个间距
        let rightOffset = adjustedContentWidth - scrollView.bounds.width // 右侧边界的偏移量
        if (scrollView.contentOffset.x >= rightOffset || scrollView.contentOffset.x <= 0) {
            collectionView.scrollToItem(at: IndexPath.init(item: groupNum/2 * images.count , section: 0), at: .centeredHorizontally, animated: false)
            return
        }
        
        // 之前停止的位置，判断左滑、右滑
        if (scrollView.contentOffset.x > self.myOffsetX) { // 左滑，下一个（i最大为cell个数）
            
            // 计算移动的item的个数（item.width + 间距）
            let i = Int(scrollView.contentOffset.x / (itemWidth + lineSpacing) + 1)

            let indexPath = IndexPath(row: i, section: 0)
            // item居中显示
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            
        } else { // 右滑，上一个（i最小为0）
            
            let i = Int(scrollView.contentOffset.x / (itemWidth + lineSpacing) + 1)
            
            let indexPath = IndexPath(row: i - 1, section: 0)
            
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)

        }
        
        
    }
}


