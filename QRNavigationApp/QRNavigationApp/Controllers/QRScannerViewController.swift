import UIKit
import AVFoundation
import CoreLocation

class QRScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate, CLLocationManagerDelegate {
    
    var isManualEntry: Bool = false // Hangi modda olduğumuzu belirliyor
    
    // Kamera Oturumu
    private var captureSession: AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    // Konum Yönetimi
    private let locationManager = CLLocationManager()
    private var currentLocation: CLLocation?
    
    // UI - Başlık ve Banner
        private let bannerView: UIView = {
            let view = UIView()
            view.backgroundColor = UIColor.systemBlue
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
    
    // UI - Başlık Etiketi
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Navigasyon Başlat"
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let infoLabel: UILabel = {
            let label = UILabel()
            label.text = "Lütfen QR kodu kamera ile taratın"
            label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            label.textColor = .white
            label.textAlignment = .center
            label.numberOfLines = 0
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
    
    // Geçici Manuel Giriş UI Elemanları
    private let latitudeTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enlem (Latitude)"
        textField.backgroundColor = UIColor(white: 1.0, alpha: 0.8)
        textField.borderStyle = .roundedRect
        textField.keyboardType = .decimalPad
        textField.layer.cornerRadius = 8
        textField.layer.shadowColor = UIColor.black.cgColor
        textField.layer.shadowOpacity = 0.2
        textField.layer.shadowOffset = CGSize(width: 0, height: 2)
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let longitudeTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Boylam (Longitude)"
        textField.backgroundColor = UIColor(white: 1.0, alpha: 0.8)
        textField.borderStyle = .roundedRect
        textField.keyboardType = .decimalPad
        textField.layer.cornerRadius = 8
        textField.layer.shadowColor = UIColor.black.cgColor
        textField.layer.shadowOpacity = 0.2
        textField.layer.shadowOffset = CGSize(width: 0, height: 2)
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let simulateButton: UIButton = {
            let button = UIButton(type: .system)
            button.setTitle("Simülasyonu Başlat", for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
            button.backgroundColor = UIColor.systemBlue
            button.setTitleColor(.white, for: .normal)
            button.layer.cornerRadius = 12
            button.layer.shadowColor = UIColor.black.cgColor
            button.layer.shadowOpacity = 0.2
            button.layer.shadowOffset = CGSize(width: 0, height: 3)
            button.translatesAutoresizingMaskIntoConstraints = false
            return button
        }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBarStyle()
    }
    
    // Navigasyon Çubuğu Stilini Ayarlama
    private func setupNavigationBarStyle() {
        navigationController?.navigationBar.tintColor = .darkGray // Geri tuşu rengi
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.white // Başlık metni beyaz
        ]
        navigationController?.navigationBar.barTintColor = UIColor.systemBlue // Arka plan mavi
        navigationController?.navigationBar.isTranslucent = false
    }
    
    // UI Kurulumu
    private func setupUI() {
        view.backgroundColor = UIColor.systemGray6
        
        // Banner ve Başlık
        view.addSubview(bannerView)
        bannerView.addSubview(titleLabel)
        bannerView.addSubview(infoLabel) // Bilgi Metni de Banner İçinde
        
        NSLayoutConstraint.activate([
            // Banner Ayarları
            bannerView.topAnchor.constraint(equalTo: view.topAnchor),
            bannerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bannerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bannerView.heightAnchor.constraint(equalToConstant: 150),
            
            // Başlık Ayarları (Banner içinde)
            titleLabel.centerXAnchor.constraint(equalTo: bannerView.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: bannerView.topAnchor, constant: 20),
            
            // Bilgi Metni (Banner İçinde)
            infoLabel.centerXAnchor.constraint(equalTo: bannerView.centerXAnchor),
            infoLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            infoLabel.widthAnchor.constraint(equalTo: bannerView.widthAnchor, multiplier: 0.9)
        ])
        
        if isManualEntry {
            setupManualEntryUI()
        } else {
            setupCamera()
        }
    }

    
    // Manuel Giriş UI Kurulumu
    private func setupManualEntryUI() {
        view.addSubview(latitudeTextField)
        view.addSubview(longitudeTextField)
        view.addSubview(simulateButton)
        
        // Banner ve Başlığı Manuel Giriş Ekranında da Göster
        titleLabel.text = "Manuel Konum Girişi"
        infoLabel.text = "Lütfen enlem ve boylam bilgilerini giriniz."
        
        simulateButton.addTarget(self, action: #selector(simulateNavigation), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            // Latitude TextField
            latitudeTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            latitudeTextField.topAnchor.constraint(equalTo: bannerView.bottomAnchor, constant: 20),
            latitudeTextField.widthAnchor.constraint(equalToConstant: 250),
            latitudeTextField.heightAnchor.constraint(equalToConstant: 40),
            
            // Longitude TextField
            longitudeTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            longitudeTextField.topAnchor.constraint(equalTo: latitudeTextField.bottomAnchor, constant: 15),
            longitudeTextField.widthAnchor.constraint(equalToConstant: 250),
            longitudeTextField.heightAnchor.constraint(equalToConstant: 40),
            
            // Simulate Button
            simulateButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            simulateButton.topAnchor.constraint(equalTo: longitudeTextField.bottomAnchor, constant: 20),
            simulateButton.widthAnchor.constraint(equalToConstant: 220),
            simulateButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    // Kamera Kurulumu
    private func setupCamera() {
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            showErrorAlert(message: "Kamera bulunamadı. Lütfen cihazınızın kamera erişimini kontrol edin.")
            return
        }
        
        guard let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice) else {
            showErrorAlert(message: "Kameraya erişilemiyor. Lütfen uygulamanın kamera iznini kontrol edin.")
            return
        }
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            showErrorAlert(message: "Kamera girişi eklenemiyor. Lütfen cihazınızı kontrol edin.")
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            showErrorAlert(message: "QR Kod çıkışı eklenemiyor. Lütfen cihazınızı kontrol edin.")
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        captureSession.startRunning()
    }
    
    // QR Kod Tarama İşlevi
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()
        
        if let metadataObject = metadataObjects.first,
           let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
           let qrCodeString = readableObject.stringValue {
            processQRCodeContent(qrCodeString)
        } else {
            showErrorAlert(message: "Geçersiz QR Kod. Lütfen geçerli bir kod taratın.")
        }
    }
    
    // QR Kod İçeriğini İşleme
    private func processQRCodeContent(_ qrCodeString: String) {
        let components = qrCodeString.split(separator: ",")
        if components.count == 2,
           let latitude = Double(components[0]),
           let longitude = Double(components[1]) {
            navigateToLocation(LocationModel(latitude: latitude, longitude: longitude))
        } else {
            showErrorAlert(message: "Geçersiz QR Kod formatı. Enlem ve boylam bilgileri bekleniyor.")
        }
    }
    
    // Simülasyon ile Manuel Konum Girişi
    @objc private func simulateNavigation() {
        guard let latitudeText = latitudeTextField.text,
              let longitudeText = longitudeTextField.text,
              let latitude = Double(latitudeText),
              let longitude = Double(longitudeText) else {
            showErrorAlert(message: "Geçerli bir enlem ve boylam giriniz.")
            return
        }
        navigateToLocation(LocationModel(latitude: latitude, longitude: longitude))
    }
    
    /*// Hedef Konuma Yönlendirme
    private func navigateToLocation(_ location: LocationModel) {
            guard let current = currentLocation else {
                showErrorAlert(message: "Mevcut konum alınamadı. Lütfen GPS'in açık olduğundan emin olun.")
                return
            }
            
            let alert = UIAlertController(title: "Navigasyon Başlat", message: "Harita uygulamasını seçin:", preferredStyle: .actionSheet)
            
            alert.addAction(UIAlertAction(title: "Apple Maps", style: .default, handler: { _ in
                self.openInAppleMaps(current: current, destination: location)
            }))
            
            alert.addAction(UIAlertAction(title: "Google Maps", style: .default, handler: { _ in
                self.openInGoogleMaps(current: current, destination: location)
            }))
            
            present(alert, animated: true)
        }*/
    // Hedef Konuma Navigasyon Başlatma
    private func navigateToLocation(_ location: LocationModel) {
        // Simülasyon için otomatik konum ayarı (Sanal Makine Sorununu Çözmek İçin)
        #if targetEnvironment(simulator)
        currentLocation = CLLocation(latitude: 37.7749, longitude: -122.4194) // San Francisco (Simülatör için)
        #endif
        
        guard let current = currentLocation else {
            showErrorAlert(message: "Mevcut konum alınamadı. Lütfen GPS'in açık olduğundan emin olun.")
            return
        }
        
        let alert = UIAlertController(title: "Navigasyon Başlat", message: "Harita uygulamasını seçin:", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Apple Maps", style: .default, handler: { _ in
            self.openInAppleMaps(current: current, destination: location)
        }))
        
        alert.addAction(UIAlertAction(title: "Google Maps", style: .default, handler: { _ in
            self.openInGoogleMaps(current: current, destination: location)
        }))
        
        present(alert, animated: true)
    }
    
    // Apple Maps ile aç
    private func openInAppleMaps(current: CLLocation, destination: LocationModel) {
            let url = URL(string: "http://maps.apple.com/?saddr=\(current.coordinate.latitude),\(current.coordinate.longitude)&daddr=\(destination.latitude),\(destination.longitude)")!
            UIApplication.shared.open(url)
        }
    
    // Google Maps ile aç
    private func openInGoogleMaps(current: CLLocation, destination: LocationModel) {
            let url = URL(string: "comgooglemaps://?saddr=\(current.coordinate.latitude),\(current.coordinate.longitude)&daddr=\(destination.latitude),\(destination.longitude)")!
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            } else {
                showErrorAlert(message: "Google Maps yüklü değil.")
            }
        }
    
    // Hata Mesajı Gösterme
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Hata", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default))
        present(alert, animated: true)
    }
}
