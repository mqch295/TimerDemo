//
//  TimerViewController.swift
//  TimerDemo
//
//  Created by Mqch on 2021/4/15.
//

import UIKit
import RxSwift
import RxCocoa
import ReactorKit
import SnapKit
import RxDataSources
class TimerViewController: UIViewController, View {
    var disposeBag: DisposeBag = DisposeBag()
    typealias Reactor = TimerViewModel
    var timeView = UIView()
    var timeLab = UILabel()
    var btnGroupView = UIView()
    var leftBtn = UIButton()
    var rightBtn = UIButton()
    var tableView = UITableView(frame: .zero, style: .plain)
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "定时器"
        setupUI()
        setConstanse()
    }
    func setupUI(){
        self.view.backgroundColor = .black

        view.addSubview(timeView)
        timeLab.textColor = .white
        timeLab.font = .systemFont(ofSize: 80)
        timeLab.textAlignment = .center
        timeView.addSubview(timeLab)

        view.addSubview(btnGroupView)

        leftBtn.backgroundColor = .lightGray
        leftBtn.layer.cornerRadius = 30
        leftBtn.layer.masksToBounds = true
        leftBtn.titleLabel?.font = .systemFont(ofSize: 14)
        leftBtn.titleLabel?.textAlignment = .center
        btnGroupView.addSubview(leftBtn)

        rightBtn.layer.cornerRadius = 30
        rightBtn.layer.masksToBounds = true
        rightBtn.titleLabel?.font = .systemFont(ofSize: 14)
        rightBtn.titleLabel?.textAlignment = .center
        btnGroupView.addSubview(rightBtn)


        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.backgroundColor = .black
        view.addSubview(tableView)
    }
    func setConstanse(){
        btnGroupView.snp.makeConstraints { maker in
            maker.center.width.equalToSuperview()
            maker.height.equalTo(80)
        }
        leftBtn.snp.makeConstraints { maker in
            maker.leading.equalToSuperview().offset(15)
            maker.centerY.equalToSuperview()
            maker.size.equalTo(CGSize(width: 60, height: 60))
        }
        rightBtn.snp.makeConstraints { maker in
            maker.trailing.equalToSuperview().offset(-15)
            maker.centerY.equalToSuperview()
            maker.size.equalTo(CGSize(width: 60, height: 60))
        }
        timeView.snp.makeConstraints { maker in
            maker.top.width.centerX.equalToSuperview()
            maker.bottom.equalTo(btnGroupView.snp.top)
        }
        timeLab.snp.makeConstraints { maker in
            maker.center.equalToSuperview()
        }
        tableView.snp.makeConstraints { maker in
            maker.top.equalTo(btnGroupView.snp.bottom)
            maker.leading.width.bottom.equalToSuperview()
        }
    }
    func bind(reactor: TimerViewModel) {
        reactor.state.map{ $0.uiStyle }
            .distinctUntilChanged()
            .map{ style -> (rightTitle: String, leftTitle: String, color: UIColor) in
                switch style{
                case .running:
                    return (rightTitle: "停止", leftTitle: "计次", color: UIColor.red)
                case .pause:
                    return (rightTitle: "启动", leftTitle: "复位", color: UIColor.green)
                }
            }.observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] info in
                self?.rightBtn.setTitle(info.rightTitle, for: [])
                self?.rightBtn.setTitleColor(info.color, for: [])
                self?.rightBtn.backgroundColor = info.color.withAlphaComponent(0.6)
                self?.leftBtn.setTitle(info.leftTitle, for: [])
            }).disposed(by: disposeBag)
        reactor.state.map{ $0.time }
            .distinctUntilChanged()
            .bind(to: timeLab.rx.text)
            .disposed(by: disposeBag)
        reactor.state.map{ $0.recordTimes }
            .distinctUntilChanged()
            .map { [SectionModel(model: "", items: $0)] }
            .bind(to: tableView.rx.items(dataSource: RxTableViewSectionedReloadDataSource<SectionModel<String, String>>.init(configureCell: { (ds, tv, index, item) -> UITableViewCell in
                let cell = tv.dequeueReusableCell(withIdentifier: "cell", for: index)
                let count = ds.sectionModels.first?.items.count ?? 0
                cell.textLabel?.text = "计次 \(count - index.row)  \(item)"
                cell.selectionStyle = .none
                cell.textLabel?.textColor = .white
                cell.backgroundColor = .black
                return cell
            })))
            .disposed(by: disposeBag)

        rightBtn.rx.tap
            .map{ Reactor.Action.startOrPause }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        leftBtn.rx.tap
            .map{ Reactor.Action.recordOrReset }
            .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .default))
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

    }
}
