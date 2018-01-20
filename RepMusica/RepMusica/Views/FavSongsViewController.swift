//
//  FavSongsViewController.swift
//  RepMusica
//
//  Created by Andrés on 3/1/18.
//  Copyright © 2018 Andrés. All rights reserved.
//

import UIKit

class FavSongsViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate{

    let dwnImage = UIImage(named: "imageDownl.png")

    @IBOutlet var tableView: UITableView!   // TableView que contiene las canciones
    @IBOutlet weak var sBar: UISearchBar!
    @IBOutlet var vistaVacia: UIView!

    let favSongsSaved = UserDefaults.standard.object(forKey: "favSongs")
    var favSongs = [String]()
    var documentsPath: URL!
    
    var pistas = 0
    
    var filteredData: [String]!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.addSlideMenuButton()
        
        tableView.delegate = self
        tableView.dataSource = self
        sBar.delegate = self
        
        favSongs = favSongsSaved as! [String]
        filteredData = favSongs
        
        if (favSongs.count > 0 ){
            vistaVacia.isHidden = true
        }
        
        // Cargamos el Path a documentos del dispositivo
        documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "id_cell", for: indexPath as IndexPath)
        
        cell.textLabel?.text = filteredData[indexPath.row]
        cell.textLabel?.textColor = UIColor.white
        cell.imageView?.image = dwnImage
        return cell
    }
    
    
    // This method updates filteredData based on the text in the Search Box
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // When there is no text, filteredData is the same as the original data
        // When user has entered text into the search box
        // Use the filter method to iterate over all items in the data array
        // For each item, return true if the item should be included and false if the
        // item should NOT be included
        filteredData = searchText.isEmpty ? favSongs : favSongs.filter { (item: String) -> Bool in
            // If dataItem matches the searchText, return true to include it
            return item.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
        }
        
        tableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.sBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        sBar.showsCancelButton = false
        sBar.text = ""
        sBar.resignFirstResponder()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 80.0
    }
    
    /* Al pulsar sobre un elemento de la lista enviamos a la vista hija la informacion necesaria para que se reproduzca la musica
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        sBar.resignFirstResponder()
        
        let pos = tableView.indexPathForSelectedRow?.row
        let name = favSongs[pos!];
        let backItem = UIBarButtonItem()
        
        // Cambiamos el texto del boton volver atras
        backItem.title = "Volver"
        backItem.tintColor = UIColor.white
        navigationItem.backBarButtonItem = backItem
        
        print("a ver 2",favSongs)
        
        if (segue.identifier == "FavToSong") {
            (segue.destination as! SongDetailViewController).allfiles = favSongs
            (segue.destination as! SongDetailViewController).pos = pos!
            (segue.destination as! SongDetailViewController).songName = name
            (segue.destination as! SongDetailViewController).documentsPath = documentsPath
        }
    }
    
    // Cuando aparece actualizamos la lista de provincias y el contenido de la lista
    override func viewWillAppear(_ animated: Bool) {
        if let p = UserDefaults.standard.object(forKey: "favSongs"){ favSongs = p as! [String] }
        else{ UserDefaults.standard.set(favSongs, forKey: "favSongs")}
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {}
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
