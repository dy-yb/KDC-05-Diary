//
//  ViewController.swift
//  KDC-05-Diary
//
//  Created by Daye on 2022/03/10.
//

import UIKit

class ViewController: UIViewController {

  @IBOutlet weak var collectionView: UICollectionView!

  private var diaryList = [Diary]() {
    didSet {
      self.saveDiaryList()   // diaryList 값이 변하면 저장하도록
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    configureCollectionView()
    loadDiaryList()
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(editDiaryNotification(_:)),
      name: NSNotification.Name("editDiary"),
      object: nil
    )
  }

  private func configureCollectionView() {
    self.collectionView.collectionViewLayout = UICollectionViewFlowLayout()
    self.collectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    self.collectionView.delegate = self
    self.collectionView.dataSource = self
  }

  @objc func editDiaryNotification(_ notification: Notification) {
    guard let diary = notification.object as? Diary else { return }
    guard let row = notification.userInfo?["indexPath.row"] as? Int else { return }
    self.diaryList[row] = diary
    self.diaryList = self.diaryList.sorted(by: {
      $0.date.compare($1.date) == .orderedDescending
    })
    self.collectionView.reloadData()
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let writeDiaryViewController = segue.destination as? WriteDiaryViewController {
      writeDiaryViewController.delegate = self
    }
  }

  private func saveDiaryList() {
    let data = self.diaryList.map {
      [
        "title": $0.title,
        "contents": $0.contents,
        "date": $0.date,
        "isStar": $0.isStar
      ]
    }
    let userDefaults = UserDefaults.standard
    userDefaults.set(data, forKey: "diaryList")
  }

  private func loadDiaryList() {
    let userDefaults = UserDefaults.standard
    guard let data = userDefaults.object(forKey: "diaryList") as? [[String: Any]] else { return }
    self.diaryList = data.compactMap {
      guard let title = $0["title"] as? String else { return nil }
      guard let contents = $0["contents"] as? String else { return nil }
      guard let date = $0["date"] as? Date else { return nil }
      guard let isStar = $0["isStar"] as? Bool else { return nil }
      return Diary(title: title, contents: contents, date: date, isStar: isStar)
    }
    // 날짜 최신 순으로 정렬
    self.diaryList = self.diaryList.sorted(by: {
      $0.date.compare($1.date) == .orderedDescending
    })
  }

  private func dateToString(date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy년 MM월 dd일(EEEEE)"
    formatter.locale = Locale(identifier: "ko_KR")
    return formatter.string(from: date)
  }
}

extension ViewController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return self.diaryList.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DiaryCell", for: indexPath) as? DiaryCell else { return UICollectionViewCell() }
    let diary = self.diaryList[indexPath.row]
    cell.titleLabel.text = diary.title
    cell.dateLabel.text = dateToString(date:diary.date)
    return cell
  }
}

extension ViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "DiaryDetailViewController") as? DiaryDetailViewController else { return }
    let diary = self.diaryList[indexPath.row]
    viewController.diary = diary
    viewController.indexPath = indexPath
    viewController.delegate = self
    self.navigationController?.pushViewController(viewController, animated: true)
  }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: (UIScreen.main.bounds.width / 2) - 20, height: 200)
  }
}

extension ViewController: WriteDiaryViewDelegate {
  func didSelectResigter(diary: Diary) {
    self.diaryList.append(diary)
    self.diaryList = self.diaryList.sorted(by: {
      $0.date.compare($1.date) == .orderedDescending
    })
    self.collectionView.reloadData()
  }
}

extension ViewController: DiaryDetailViewDelegate {
  func didSelectDelete(indexPath: IndexPath) {
    self.diaryList.remove(at: indexPath.row)
    self.collectionView.deleteItems(at: [indexPath])
  }
}
