import UIKit

class QRNavigationViewController: UIViewController {

    // UI Elemanları
    private let bannerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemBlue
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "QR Navigasyon Uygulaması"
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let scanQRCodeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("QR Kod Taramak için Başla", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.2
        button.layer.shadowOffset = CGSize(width: 0, height: 3)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let manualEntryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Manuel Konum Girişi", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.2
        button.layer.shadowOffset = CGSize(width: 0, height: 3)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        // Banner ve Başlık
        view.addSubview(bannerView)
        bannerView.addSubview(titleLabel)
        
        // Butonlar
        view.addSubview(scanQRCodeButton)
        view.addSubview(manualEntryButton)
        
        scanQRCodeButton.addTarget(self, action: #selector(scanQRCodeTapped), for: .touchUpInside)
        manualEntryButton.addTarget(self, action: #selector(manualEntryTapped), for: .touchUpInside)
        
        // Otomatik yerleşim ayarları
        NSLayoutConstraint.activate([
            // Banner Ayarları
            bannerView.topAnchor.constraint(equalTo: view.topAnchor),
            bannerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bannerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bannerView.heightAnchor.constraint(equalToConstant: 150),
            
            // Başlık Ayarları (Banner içinde)
            titleLabel.centerXAnchor.constraint(equalTo: bannerView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: bannerView.centerYAnchor, constant: 10),
            
            // QR Kod Butonu
            scanQRCodeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scanQRCodeButton.topAnchor.constraint(equalTo: bannerView.bottomAnchor, constant: 40),
            scanQRCodeButton.widthAnchor.constraint(equalToConstant: 250),
            scanQRCodeButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Manuel Giriş Butonu
            manualEntryButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            manualEntryButton.topAnchor.constraint(equalTo: scanQRCodeButton.bottomAnchor, constant: 20),
            manualEntryButton.widthAnchor.constraint(equalToConstant: 250),
            manualEntryButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc private func scanQRCodeTapped() {
        let scannerVC = QRScannerViewController()
        scannerVC.isManualEntry = false // QR kod tarama
        navigationController?.pushViewController(scannerVC, animated: true)
    }
    
    @objc private func manualEntryTapped() {
        let scannerVC = QRScannerViewController()
        scannerVC.isManualEntry = true // Manuel giriş
        navigationController?.pushViewController(scannerVC, animated: true)
    }
}
