//
//  InterviewPrepCollectionViewController.swift
//  jobApplication_prepTrack_app
//
//  Created by Chin Yen Tung on 10/5/2024.
//

import UIKit

class InterviewPrepCollectionViewController: UICollectionViewController {
    let CATEGORY_CELL = "questionBankCategoryCell"
    var API_KEY = "nAWGuORbcb5KqDoG4bhDpuG6Nce8jjLoOVGvZlac"
    var categoryList = [QuizCategory]() // to show list of categories
    
    // Activity Indicator View to display a spinning animation used to indicate loading
    var indicator = UIActivityIndicatorView()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // set up and add our indicator to the view controller’s view
        // Add a loading indicator view
        indicator.style = UIActivityIndicatorView.Style.large
        indicator.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(indicator)
        
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        ])
        
        indicator.startAnimating()
        // call the requestQuestionData method to handle the request
        // Because requestQuestionData method is async, we must encapsulate it within a Task.
        Task {
            await requestCategoryData()
        }
        
        // set collection view layout
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.setCollectionViewLayout(UICollectionViewCompositionalLayout(section: createTiledLayoutSection()), animated: false)
    }
    
    
    // MARK: - Fetch data from API
    
    func requestCategoryData() async {
        var searchURLComponents = URLComponents()
        searchURLComponents.scheme = "https"
        searchURLComponents.host = "quizapi.io"
        searchURLComponents.path = "/api/v1/categories"
        searchURLComponents.queryItems = [
            URLQueryItem(name: "apiKey", value: "\(API_KEY)")
        ]
        
        guard let requestURL = searchURLComponents.url else {
            print("Invalid URL.")
            return
        }
        
        let urlRequest = URLRequest(url: requestURL)
        
        // create the data task and execute it
        do {
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            
            // Once we receive a response and the function begins executing again:
            // tell our loading indicator to stop animating
            indicator.stopAnimating()
            
            // print raw JSON string for debugging
//            if let jsonString = String(data: data, encoding: .utf8) {
//                print(jsonString)
//                print(requestURL)
//            }
            
            // With a response back we should attempt to parse the data
            // parsing data through decoder can throw error so need do... catch {}
            // we can use the outer do... catch() block too.
            // but we want to use a second one so that the rest of the function can occur even if this fails
            do {
                let decoder = JSONDecoder()     // create a JSONDecoder instance
                let categoryData = try decoder.decode([QuizCategory].self, from: data)
//                print(categoryData)

                // Append new books to the array
                categoryList.append(contentsOf: categoryData)
//                print(categoryList)
                collectionView.reloadData()
                
            } catch {
                print("Error decoding JSON: \(error)")
            }
        } catch {
            print("URLSession Error: \(error)")
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        print(categoryList.count)
        return categoryList.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CATEGORY_CELL, for: indexPath) as! InterviewPrepCollectionViewCell
        
        let catName = categoryList[indexPath.item].catName
        print(catName)
        cell.backgroundColor = UIColor.systemGray3
        cell.label.text = catName?.uppercased() // convert all letters to Caps
    
        return cell
    }
    
    
    // MARK: Collection View Layout
    
    func createTiledLayoutSection() -> NSCollectionLayoutSection {
        // Tiled layout.
        //  * Group is 2 posters, side-by-side.
        //  * Group is 1 x screen width, and height is 1/2 x screen width (poster height)
        //  * Item width is 1/2 x group width, with height as 1 x group width
        //  * contentInsets puts a 5 pixel margin around each poster.
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/2), heightDimension: .fractionalHeight(1))
        let itemLayout = NSCollectionLayoutItem(layoutSize: itemSize)
        // Add padding around each item
        itemLayout.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(1/2))
        let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [itemLayout])
        
        let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
        layoutSection.interGroupSpacing = 10
        layoutSection.contentInsets = NSDirectionalEdgeInsets(top: 15, leading: 15, bottom: 15, trailing: 15)
        
        //layoutSection.orthogonalScrollingBehavior = .continuous
        return layoutSection
    }


    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
