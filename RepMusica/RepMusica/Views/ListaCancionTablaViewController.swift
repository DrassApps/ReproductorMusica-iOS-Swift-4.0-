//
//  ListaCancionTablaViewController.swift
//  RepMusica
//
//  Created by Andrés on 5/1/18.
//  Copyright © 2018 Andrés. All rights reserved.
//

import UIKit

class ListaCancionTablaViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate{

    let dwnImage = UIImage(named: "imageDownl.png")

    @IBOutlet weak var sBar: UISearchBar!
    @IBOutlet var tablaCanciones : UITableView!
    
    var allfiles = [String]()               // Array que contiene todas las canciones
    var documentsPath: URL!
    
    var nombreLista = ""
    
    var filteredData: [String]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tablaCanciones.delegate = self
        tablaCanciones.dataSource = self
        sBar.delegate = self
        
        let listaRep = UserDefaults.standard.object(forKey: nombreLista)
        allfiles = listaRep as! [String]
        
        documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        // Eliminamos el nombre de la lista de los archivos reales
        for file in allfiles{
            if (!file.contains(".mp3")){
                allfiles = allfiles.filter {$0 != file}
            }else{}
        }
        
        filteredData = allfiles
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 80.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    // This method updates filteredData based on the text in the Search Box
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // When there is no text, filteredData is the same as the original data
        // When user has entered text into the search box
        // Use the filter method to iterate over all items in the data array
        // For each item, return true if the item should be included and false if the
        // item should NOT be included
        filteredData = searchText.isEmpty ? allfiles : allfiles.filter { (item: String) -> Bool in
            // If dataItem matches the searchText, return true to include it
            return item.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
        }
        
        tablaCanciones.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.sBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        sBar.showsCancelButton = false
        sBar.text = ""
        sBar.resignFirstResponder()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        sBar.resignFirstResponder()
        
        let pos = tablaCanciones.indexPathForSelectedRow?.row
        let name = filteredData[pos!];
        let backItem = UIBarButtonItem()
        
        // Cambiamos el texto del boton volver atras
        backItem.title = "Volver"
        backItem.tintColor = UIColor.white
        navigationItem.backBarButtonItem = backItem
        
        if (segue.identifier == "ListaSongToSongDetail") {
            (segue.destination as! SongDetailViewController).allfiles = filteredData
            (segue.destination as! SongDetailViewController).pos = pos!
            (segue.destination as! SongDetailViewController).songName = name
            (segue.destination as! SongDetailViewController).documentsPath = documentsPath
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
