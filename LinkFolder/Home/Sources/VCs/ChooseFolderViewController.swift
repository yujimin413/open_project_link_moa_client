//
//  ChooseFolderViewController.swift
//  LinkFolder
//
//  Created by 유지민 on 2022/12/05.
//

import UIKit
//
//protocol HomeReloadDelegate {
//    func setupFolderData()
//}

class ChooseFolderViewController: UIViewController, HomeReloadDelegate {
    
    
    // MARK: - Properties
    @IBOutlet weak var homeCollectionView: UICollectionView!
    
    
    var folderData: [folderInfo]? {
        didSet { self.homeCollectionView.reloadData()
            print("didset호출됨")
        }
    }
    
    
    var selectedFolderIndex: Int!
    var selectedFolderName: String?
    
    var linkIdx: Int!
    var senderUserIdx: Int!
    var alertIdx: Int!
    
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupFolderData()
    }
    
    //    override func viewWillAppear(_ animated: Bool) {
    //        print(#function)
    //        FoldersListRepository().getFoldersList(self)
    //        homeCollectionView.reloadData()
    //    }
    
    // 폴더 리스트 불러오기
    func setupFolderData() {
        print("폴더 리스트 불러오기")
        FoldersListRepository().getFoldersList(self)
    }
    
    // MARK: - Actions
    @IBAction func addFolderButtonTapped(_ sender: Any) {
        // 링크 폴더 추가 팝업뷰
        let storyboard = UIStoryboard.init(name: "AddLinkFolder", bundle: nil)
        let addFolderPopUpVC = storyboard.instantiateViewController(withIdentifier: "AddFolderPopUpVC") as! AddFolderPopUpViewController
        addFolderPopUpVC.delegate = self
        addFolderPopUpVC.modalPresentationStyle = .overCurrentContext
        self.present(addFolderPopUpVC, animated: false, completion: nil)
        
    }
    
    // 선택한 폴더 내부로 이동
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let section = indexPath.section
        if section == 0 {
            
            var id = indexPath.row
            print(id)
            print("번째 폴더에 링크 사본 생성")
            
            // 선택된 폴더 정보(인덱스, 이름)
            let cellData = folderData![id]
            selectedFolderIndex = cellData.folderIdx
            selectedFolderName = cellData.folderName
            
            let input = LinkCopyInput(folderIdx: selectedFolderIndex, linkIdx: self.linkIdx, senderUserIdx: self.senderUserIdx)
      
            self.copyLink(input: input){
                // 알림 삭제 api 호출 및 알림목록 reload
                self.deleteAlert(alertIdx: self.alertIdx){
                    // 링크 사본 생성 완료시 alert
                    let alert = UIAlertController(title: "알림", message: "[\(self.selectedFolderName!)]폴더에 링크 사본이 생성되었습니다.", preferredStyle: .alert)
                    let done = UIAlertAction(title: "닫기", style: .cancel) {
                        (action) in
                    }

                    alert.addAction(done)

                    guard let pvc = self.presentingViewController else { return }
                    self.dismiss(animated: false) {
                        pvc.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    func copyLink(input: LinkCopyInput, completion: @escaping() -> Void) {
        LinkCopyRepository().copyLink(input, completion)
    }
    
    func deleteAlert(alertIdx: Int, completion: @escaping() -> Void) {
        NoticeDeleteRepository().deleteNotice(alertIdx, completion)
    }
    
    // MARK: - Helpers
    private func setupCollectionView() {
        // delegate 연결
        homeCollectionView.delegate = self
        homeCollectionView.dataSource = self
        
        // cell 등록
        // 폴더
        homeCollectionView.register(
            UINib(nibName: "FolderCollectionViewCell",
                  bundle: nil),
            forCellWithReuseIdentifier: FolderCollectionViewCell.identifier)
    }
    
}

extension ChooseFolderViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    // 섹션의 개수
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    // 셀의 개수
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return folderData?.count ?? 0
    }
    
    // 셀 생성
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: FolderCollectionViewCell.identifier,
                for: indexPath) as? FolderCollectionViewCell else {
                fatalError("셀 타입 캐스팅 실패...")
            }
            
            let itemIndex = indexPath.item
            if let cellData = self.folderData {
                // 폴더 데이터 있는 경우, 폴더 이름 전달
                cell.setupFolderData(cellData[itemIndex].folderName, cellData[itemIndex].folderIdx)
            }
            
            return cell
    }
    
}

// for collectionView size 조절
extension ChooseFolderViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
            return CGSize(
                width: collectionView.frame.width * 150 / 390,
                height: collectionView.frame.height * 150 / 673)
    }
    // 열 간격
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
            return CGFloat(0)
    }
    // 행 간격
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
            return CGFloat(10)
    }
    // contentInset 상하좌우
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        let interval = UIEdgeInsets(top: 5, left: 32, bottom: 5, right: 32)
            return interval
    }
}

// MARK: - 폴더 목록 가져오기 API 통신 메소드
extension ChooseFolderViewController {
    func successFeedAPI(_ result: FoldersListModel) {
        self.folderData = result.result
    }
}


