//
//  RepositoryCell.swift
//  GitRepoApp
//
//  Created by Almira Khafizova on 17.02.26.
//

import UIKit

final class RepositoryCell: UITableViewCell {
  
  static let identifier = "RepositoryCell"
  
  //shadow is under the container
  private let shadowView = UIView()
  private let containerView = UIView()
  
  private let nameLabel = UILabel()
  private let starsLabel = UILabel()
  private let descriptionLabel = UILabel()
  private let commitLabel = UILabel()
  private let commitActivity = UIActivityIndicatorView(style: .medium)
  private let titleStack = UIStackView()
  
  private struct CornerRadii {
    let topLeft: CGFloat
    let topRight: CGFloat
    let bottomLeft: CGFloat
    let bottomRight: CGFloat
  }
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setupUI()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setupUI()
  }
  
  private func setupUI() {
    selectionStyle = .none
    backgroundColor = .clear
    contentView.backgroundColor = .clear
    
    //Shadow view
    shadowView.translatesAutoresizingMaskIntoConstraints = false
    shadowView.backgroundColor = .clear
    contentView.addSubview(shadowView)
    
    //Container view
    containerView.translatesAutoresizingMaskIntoConstraints = false
    containerView.backgroundColor = UIColor.systemMint.withAlphaComponent(1)
    contentView.addSubview(containerView)
    
    //Labels setup
    [nameLabel, starsLabel, descriptionLabel, commitLabel, commitActivity].forEach {
      $0.translatesAutoresizingMaskIntoConstraints = false
    }
    nameLabel.font = .boldSystemFont(ofSize: 16)
    starsLabel.font = .systemFont(ofSize: 14)
    descriptionLabel.font = .systemFont(ofSize: 14)
    descriptionLabel.numberOfLines = 2
    commitLabel.font = .italicSystemFont(ofSize: 13)
    commitLabel.numberOfLines = 2
    
    //Title stack
    titleStack.axis = .horizontal
    titleStack.spacing = 6
    titleStack.alignment = .center
    titleStack.translatesAutoresizingMaskIntoConstraints = false
    titleStack.addArrangedSubview(nameLabel)
    titleStack.addArrangedSubview(starsLabel)
    containerView.addSubview(titleStack)
    
    // Other views
    containerView.addSubview(descriptionLabel)
    containerView.addSubview(commitLabel)
    containerView.addSubview(commitActivity)
    
    //Constraints
    NSLayoutConstraint.activate([
      shadowView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
      shadowView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
      shadowView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
      shadowView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
      
      containerView.topAnchor.constraint(equalTo: shadowView.topAnchor),
      containerView.leadingAnchor.constraint(equalTo: shadowView.leadingAnchor),
      containerView.trailingAnchor.constraint(equalTo: shadowView.trailingAnchor),
      containerView.bottomAnchor.constraint(equalTo: shadowView.bottomAnchor),
      
      titleStack.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
      titleStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
      titleStack.trailingAnchor.constraint(lessThanOrEqualTo: containerView.trailingAnchor, constant: -12),
      
      descriptionLabel.topAnchor.constraint(equalTo: titleStack.bottomAnchor, constant: 6),
      descriptionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
      descriptionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
      
      commitLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 6),
      commitLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
      commitLabel.trailingAnchor.constraint(equalTo: commitActivity.leadingAnchor, constant: -6),
      commitLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
      
      commitActivity.centerYAnchor.constraint(equalTo: commitLabel.centerYAnchor),
      commitActivity.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12)
    ])
  }
  
  // MARK: - Layout for custom radius and shadow
  override func layoutSubviews() {
    super.layoutSubviews()
    
    let radii = CornerRadii(topLeft: 0, topRight: 10, bottomLeft: 10, bottomRight: 30)
    let path = pathWithCustomCorners(bounds: containerView.bounds, radii: radii).cgPath
    
    //shadowView
    shadowView.layer.shadowPath = path
    shadowView.layer.shadowColor = UIColor.black.cgColor
    shadowView.layer.shadowOpacity = 0.3
    shadowView.layer.shadowRadius = 4
    shadowView.layer.shadowOffset = CGSize(width: 0, height: 2)
    
    // custom corner masks containerView
    let maskLayer = CAShapeLayer()
    maskLayer.path = path
    containerView.layer.mask = maskLayer
  }
  
  private func pathWithCustomCorners(bounds: CGRect, radii: CornerRadii) -> UIBezierPath {
    let path = UIBezierPath()
    let topLeftRadius = radii.topLeft
    let topRightRadius = radii.topRight
    let bottomLeftRadius = radii.bottomLeft
    let bottomRightRadius = radii.bottomRight
    
    path.move(to: CGPoint(x: bounds.minX + topLeftRadius, y: bounds.minY))
    path.addLine(to: CGPoint(x: bounds.maxX - topRightRadius, y: bounds.minY))
    path.addArc(withCenter: CGPoint(x: bounds.maxX - topRightRadius, y: bounds.minY + topRightRadius),
                radius: topRightRadius,
                startAngle: -.pi/2,
                endAngle: 0,
                clockwise: true)
    
    path.addLine(to: CGPoint(x: bounds.maxX, y: bounds.maxY - bottomRightRadius))
    path.addArc(withCenter: CGPoint(x: bounds.maxX - bottomRightRadius, y: bounds.maxY - bottomRightRadius),
                radius: bottomRightRadius,
                startAngle: 0,
                endAngle: .pi/2,
                clockwise: true)
    
    path.addLine(to: CGPoint(x: bounds.minX + bottomLeftRadius, y: bounds.maxY))
    path.addArc(withCenter: CGPoint(x: bounds.minX + bottomLeftRadius, y: bounds.maxY - bottomLeftRadius),
                radius: bottomLeftRadius,
                startAngle: .pi/2,
                endAngle: .pi,
                clockwise: true)
    
    path.addLine(to: CGPoint(x: bounds.minX, y: bounds.minY + topLeftRadius))
    path.addArc(withCenter: CGPoint(x: bounds.minX + topLeftRadius, y: bounds.minY + topLeftRadius),
                radius: topLeftRadius,
                startAngle: .pi,
                endAngle: 3 * .pi/2,
                clockwise: true)
    
    path.close()
    return path
  }
  
  // MARK: - Configure
  func configure(with repo: Repository, commit: Commit?, isLoadingCommit: Bool) {
    nameLabel.text = repo.name
    starsLabel.text = "⭐️ \(repo.stargazersCount ?? 0)"
    descriptionLabel.text = repo.description ?? "No description"
    
    if isLoadingCommit {
      commitLabel.text = "Loading commit..."
      commitActivity.startAnimating()
    } else {
      commitActivity.stopAnimating()
      UIView.transition(with: commitLabel,
                        duration: 0.3,
                        options: .transitionCrossDissolve,
                        animations: {
        self.commitLabel.text = commit?.message ?? "No commits yet"
      })
    }
  }
}
