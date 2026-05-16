//
//  ListMemoViewController.swift
//  SwipeMemo
//
//  Created by 優也田島 on 2022/06/30.
//

import UIKit

class ListMemoViewController: UIViewController {
    
    private var firstViewController: CreateMemoViewController!
    
    private var presenter: ListMemoPresenterInput!

    @IBOutlet weak var tableView: UITableView!
    
    func inject(presenter: ListMemoPresenter) {
        self.presenter = presenter
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    private func setup() {
        setupCreateMemoViewController()
        setupTableView()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }

    private func setupCreateMemoViewController() {
        firstViewController = storyboard?.instantiateViewController(withIdentifier: "FirstInput") as? CreateMemoViewController
        let model = CreateMemoModel()
        let helper = InputMemoHelper()
        firstViewController.inject(
            presenter: CreateMemoPresenter(
                view: firstViewController,
                model: model,
                helper: helper
            )
        )
    }

    private func setupTableView() {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .clear
        refreshControl.addTarget(self, action: #selector(createMemo(_:)), for: .valueChanged)
        
        tableView.refreshControl = refreshControl
        tableView.dataSource = self
        tableView.delegate   = self
        tableView.fillerRowHeight = 40
        
        let rightSwipe = UISwipeGestureRecognizer(
            target: self,
            action: #selector(self.didSwipe(_:))
        )
        rightSwipe.direction = .right
        tableView.addGestureRecognizer(rightSwipe)
        tableView.dragDelegate = self
        tableView.dropDelegate = self
        tableView.dragInteractionEnabled = true
    }
    
    @objc func didSwipe(_ sender: UISwipeGestureRecognizer) {
        switch sender.direction {
        case .right:
            presenter.didSwipeLeft()
        default:
            break
        }
    }
    
    @objc private func createMemo(_ sender: UIRefreshControl) {
        tableView.refreshControl!.endRefreshing()
        presenter.pullDown()
    }

    private func presentDeleteConfirmation(at indexPath: IndexPath) {
        let dialog = UIAlertController(
            title: NSLocalizedString("delete_memo_confirmation_title", comment: ""),
            message: NSLocalizedString("delete_memo_confirmation_message", comment: ""),
            preferredStyle: .alert
        )
        dialog.addAction(
            UIAlertAction(
                title: NSLocalizedString("delete_memo_confirmation_ok", comment: ""),
                style: .destructive,
                handler: { [weak self] _ in
                    self?.presenter.didTapDeleteButton(at: indexPath)
                }
            )
        )
        dialog.addAction(
            UIAlertAction(
                title: NSLocalizedString("delete_memo_confirmation_cancel", comment: ""),
                style: .cancel,
                handler: { [weak self] _ in
                    self?.tableView.setEditing(false, animated: true)
                }
            )
        )
        present(dialog, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "cellSegue" {
            guard let editViewController: EditMemoViewController = segue.destination as? EditMemoViewController
            else {
                print("ERROR: EditMemoViewController does not exist")
                return
            }
            let model = EditMemoModel()
            let helper = InputMemoHelper()

            guard let indexPath = self.tableView.indexPathForSelectedRow else {
                print("ERROR: The selected row of tavleview does not exist")
                return
            }

            let memo = presenter.memo(at: indexPath)

            let sender = EditDataSender(
                prevScene: self,
                memoID: memo.id,
                initialText: memo.text,
                initialIsFavorite: memo.isFavorite
            )
            editViewController.inject(
                presenter: EditMemoPresenter(
                    view:editViewController,
                    model: model,
                    helper: helper,
                    sender: sender
                )
            )
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.viewWillAppear()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if MemoError.exists() {
            let dialog = UIAlertController(title: "Error", message: MemoError.popErrorMessage(), preferredStyle: .alert)
            dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(dialog, animated: true, completion: nil)
        }
    }
}

extension ListMemoViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath)-> UITableViewCell.EditingStyle {
        return .delete
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            presentDeleteConfirmation(at: indexPath)
        }
    }
}

extension ListMemoViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return presenter.numberOfSections
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.numberOfMemos(in: section)
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return presenter.titleForSection(section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let memo = presenter.memo(at: indexPath)

        var content = cell.defaultContentConfiguration()
        content.text = memo.text
        content.image = nil
        content.textProperties.numberOfLines = 15
        content.textProperties.lineBreakMode = .byTruncatingTail
        cell.contentConfiguration = content

        cell.imageView?.image = nil
        cell.imageView?.highlightedImage = nil
        cell.imageView?.isHidden = true
        cell.imageView?.tintColor = nil
        cell.accessoryType = .none
        cell.accessoryView = nil

        var background = UIBackgroundConfiguration.listPlainCell()
        if memo.isFavorite {
            background.backgroundColor = UIColor.systemYellow.withAlphaComponent(0.12)
            cell.accessibilityValue = NSLocalizedString("favorite_memo_accessibility_value", comment: "")
        } else {
            background.backgroundColor = .systemBackground
            cell.accessibilityValue = nil
        }
        cell.backgroundConfiguration = background

        return cell
    }

    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        _ = presenter.moveMemo(from: sourceIndexPath, to: destinationIndexPath)
    }
}

extension ListMemoViewController: UITableViewDragDelegate {

    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let memo = presenter.memo(at: indexPath)
        let itemProvider = NSItemProvider(object: memo.text as NSString)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = indexPath
        return [dragItem]
    }
}

extension ListMemoViewController: UITableViewDropDelegate {

    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        guard session.localDragSession != nil else {
            return UITableViewDropProposal(operation: .cancel)
        }

        if let sourceIndexPath = session.localDragSession?.items.first?.localObject as? IndexPath,
           let destinationIndexPath = destinationIndexPath,
           sourceIndexPath.section != destinationIndexPath.section {
            return UITableViewDropProposal(operation: .cancel)
        }

        return UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
    }

    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
        guard coordinator.proposal.operation == .move,
              let item = coordinator.items.first,
              let sourceIndexPath = item.sourceIndexPath else {
            return
        }

        guard presenter.numberOfSections > sourceIndexPath.section else {
            return
        }

        let rowCount = presenter.numberOfMemos(in: sourceIndexPath.section)
        guard rowCount > 0 else {
            return
        }

        let proposedIndexPath = coordinator.destinationIndexPath ?? IndexPath(row: rowCount - 1, section: sourceIndexPath.section)
        guard presenter.numberOfSections > proposedIndexPath.section,
              proposedIndexPath.section == sourceIndexPath.section else {
            return
        }

        let destinationRowCount = presenter.numberOfMemos(in: proposedIndexPath.section)
        guard destinationRowCount > 0 else {
            return
        }

        let destinationRow = min(max(proposedIndexPath.row, 0), destinationRowCount - 1)
        let destinationIndexPath = IndexPath(row: destinationRow, section: proposedIndexPath.section)

        guard sourceIndexPath != destinationIndexPath else {
            coordinator.drop(item.dragItem, toRowAt: destinationIndexPath)
            return
        }

        guard presenter.moveMemo(from: sourceIndexPath, to: destinationIndexPath) else {
            return
        }

        tableView.performBatchUpdates({
            tableView.moveRow(at: sourceIndexPath, to: destinationIndexPath)
        }, completion: nil)
        coordinator.drop(item.dragItem, toRowAt: destinationIndexPath)
    }
}

extension ListMemoViewController: ListMemoPresenterOutput {
    
    func reloadMemo () {
        tableView.reloadData()
    }
    
    func transitionToCreate() {
        let transition:CATransition = CATransition()
        transition.duration = 0.1
        transition.type = .push
        transition.subtype = .fromBottom
        self.navigationController?.view.layer.add(transition, forKey: kCATransition)
        self.navigationController?.setViewControllers([firstViewController], animated: false)
    }

    func transitionToSettings() {
        performSegue(withIdentifier: "Settings", sender: nil)
    }
}

extension ListMemoViewController: EditMemoDismissActionProtocol {
    func viewWillAppear() {
        presenter.viewWillAppear()
    }
    
    func viewDidAppear() {
        if MemoError.exists() {
            let dialog = UIAlertController(title: "Error", message: MemoError.popErrorMessage(), preferredStyle: .alert)
            dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(dialog, animated: true, completion: nil)
        }
    }
}
