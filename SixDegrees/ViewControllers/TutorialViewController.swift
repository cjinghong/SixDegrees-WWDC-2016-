//
//  TutorialViewController.swift
//  SixDegrees
//
//  Created by Chan Jing Hong on 29/04/2016.
//  Copyright © 2016 Chan Jing Hong. All rights reserved.
//

import UIKit

class TutorialViewController: UIViewController {

    @IBOutlet weak var tutorialCollectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!

    var tutorialImageNames: [String] = [
        "1.png",
        "2.png",
        "3.png",
        "4.png",
        "5.png",
        "6.png",
        "7.png"
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        if let flowLayout: UICollectionViewFlowLayout = self.tutorialCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.itemSize = CGSize(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // the controller that has a reference to the collection view
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        var insets = self.tutorialCollectionView.contentInset
        let value = (self.view.frame.size.width - (self.tutorialCollectionView.collectionViewLayout as! UICollectionViewFlowLayout).itemSize.width) * 0.5
        insets.left = value
        insets.right = value

        self.tutorialCollectionView.contentInset = insets
        self.tutorialCollectionView.decelerationRate = UIScrollViewDecelerationRateFast;
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func dismissButtonTapped(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension TutorialViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.tutorialImageNames.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: TutorialCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "TutorialCollectionViewCell", for: indexPath) as! TutorialCollectionViewCell
        cell.maximumIndex = self.tutorialImageNames.count
        cell.index = indexPath.row
        cell.tutorialImage = UIImage(named: self.tutorialImageNames[indexPath.row])!

        cell.doneButton.addTarget(self, action: #selector(self.dismissButtonTapped(_:)), for: UIControlEvents.touchUpInside)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell: TutorialCollectionViewCell = cell as? TutorialCollectionViewCell {
            cell.showInstructions()
        }
    }

    // Change page control paging

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if let indexPath = self.tutorialCollectionView.indexPathsForVisibleItems.first {
            self.pageControl.currentPage = indexPath.row
        }
    }
}





