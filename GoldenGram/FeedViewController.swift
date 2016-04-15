//
//  FeedViewController.swift
//  GoldenGram
//
//  Created by Kyle on 4/12/16.
//  Copyright © 2016 Mingu Chu. All rights reserved.
//

import UIKit

class FeedViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, LikeAddedDelegate {
    
    @IBOutlet weak var feedCollectionView: UICollectionView!
    
    var posts = [Post]()
    var indexPath: NSIndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let userPostRef = FIREBASE_REF.childByAppendingPath("users").childByAppendingPath(NSUserDefaults.standardUserDefaults().valueForKey("uid") as! String).childByAppendingPath("userPosts")
        userPostRef.observeEventType(.Value, withBlock: { snapshot1 in
            let postArray = snapshot1.value.allValues as? [String]
            if postArray != nil {
                for address: String in postArray! {
                    let postRef = FIREBASE_REF.childByAppendingPath("posts").childByAppendingPath(address)
                    postRef.observeEventType(.Value, withBlock: { snapshot2 in
                        let aPost = Post.init(snapshot: snapshot2)
                        print(aPost)
                        self.posts.append(aPost)
                        if self.posts.count == postArray!.count {
                            dispatch_async(dispatch_get_main_queue()) {
                                self.feedCollectionView.reloadData()
                            }
                        }
                    })
                }
            }
        })
    }
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PostID", forIndexPath: indexPath) as! PostCollectionViewCell
        let post = posts[indexPath.row];
        cell.postImageView.image = coversion(post.photo)
        cell.userButton.setTitle(post.username, forState: .Normal)
        cell.userButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        cell.likesButton.setTitle("Likes: \(post.likes)", forState: .Normal)
        cell.likesButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        return cell
    }
    
    func coversion(post: String) -> UIImage {
        let imageData = NSData(base64EncodedString: post, options: [] )
        let image = UIImage(data: imageData!)
        return image!
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        guard let collectionView = self.feedCollectionView else {return}
        guard let visibleCells = collectionView.visibleCells() as? [PostCollectionViewCell] else
        {return}
        for collectionViewCell in visibleCells {
            let yOffSet = ((collectionView.contentOffset.y - collectionViewCell.frame.origin.y) /
                imageHeight) * offSetSpeed
            collectionViewCell.offset(CGPointMake(0.0, yOffSet))
        }
    }
    
    func likeAdded(cell: PostCollectionViewCell) {
        indexPath = feedCollectionView.indexPathForCell(cell)
        let likeCell = posts[(indexPath?.row)!]
        likeCell.likes = 1

        
        print("like added")

        FIREBASE_REF.childByAppendingPath("posts").childByAppendingPath(NSUserDefaults.standardUserDefaults().valueForKey("uid") as! String).childByAppendingPath("likes").setValue(likeCell.likes)
        feedCollectionView.reloadData()
        

    }
//    for post in self.posts {
//    userPostRef.updateChildValues([String(format:"Timestamp: %i:", NSInteger(NSDate.timeIntervalSinceReferenceDate())) : post], withCompletionBlock: { (error:NSError?, ref:Firebase!) in
//    if (error != nil) {
//    print("Data could not be saved.")
//    } else {
//    print("Data saved successfully!")
//    }
//    })
    
}
