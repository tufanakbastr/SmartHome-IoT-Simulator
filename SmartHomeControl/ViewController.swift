import UIKit


struct DeviceResponse: Codable {
    let power: Bool
    let temp: Int
}

class ViewController: UIViewController {


    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Akıllı Ev Kontrolü"
        label.font = UIFont.boldSystemFont(ofSize: 26)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let statusLabel: UILabel = {
        let label = UILabel()
        label.text = "Sunucuya Bağlanıyor..."
        label.font = UIFont.systemFont(ofSize: 20)
        label.textColor = .gray
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Yükleniyor...", for: .normal)
        button.backgroundColor = .lightGray
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 15
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        setupUI()
        fetchStatus()
        
        
        actionButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }
    
   
    func setupUI() {
        
        view.addSubview(titleLabel)
        view.addSubview(statusLabel)
        view.addSubview(actionButton)
        
        
        NSLayoutConstraint.activate([
            
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            
            statusLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            statusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            
            actionButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -100),
            actionButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            actionButton.widthAnchor.constraint(equalToConstant: 220),
            actionButton.heightAnchor.constraint(equalToConstant: 55)
        ])
    }
    
    
    
    @objc func buttonTapped() {
        sendCommand()
    }
    
    
    func updateUI(isOn: Bool, temp: Int) {
        DispatchQueue.main.async {
            self.statusLabel.text = "Sıcaklık: \(temp)°C\nDurum: \(isOn ? "AÇIK" : "KAPALI")"
            self.statusLabel.textColor = isOn ? .systemGreen : .systemRed
            
            self.actionButton.setTitle(isOn ? "Cihazı KAPAT" : "Cihazı AÇ", for: .normal)
            self.actionButton.backgroundColor = isOn ? .systemRed : .systemGreen
        }
    }

    
    
    
    func fetchStatus() {
        
        guard let url = URL(string: "http://10.22.50.115:8080/status") else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let data = data {
                
                if let decoded = try? JSONDecoder().decode(DeviceResponse.self, from: data) {
                    self?.updateUI(isOn: decoded.power, temp: decoded.temp)
                }
            } else if let error = error {
                print("Hata oluştu: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    
    func sendCommand() {
        guard let url = URL(string: "http://10.22.50.115:8080/control") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if error == nil {
                
                self?.fetchStatus()
            }
        }.resume()
    }
}
