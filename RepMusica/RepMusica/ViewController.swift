//
//  ViewController.swift
//  RepMusica
//
//  Created by Andrés on 17/12/17.
//  Copyright © 2017 Andrés. All rights reserved.
//

import UIKit
import Foundation

// Extension de UIColor para poder pasar los colores en formato hexadecimal
extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}


class ViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet var labFav : UILabel!
    @IBOutlet var labAll : UILabel!
    @IBOutlet var labMss : UILabel!
    @IBOutlet var listaVacia : UITextView!
    @IBOutlet var tablaLista : UITableView!
    
    let logo = UIImage(named: "srcBac.png")
    var favSongs = [String]()
    var lyricsDownload = [String]()
    var listaReproduccion = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.addSlideMenuButton()
    
        tablaLista.delegate = self
        tablaLista.dataSource = self
        
        self.navigationController?.navigationBar.barTintColor = UIColor(rgb: 0x1A202020)
        
        // Recogemos las canciones favoritas del UserDefaults, si no esta creada la clave
        // ya que es la priemra vez que abrimos la app, se creara el set vacio 
        if let fv = UserDefaults.standard.object(forKey: "favSongs"){ favSongs = fv as! [String] }
        else{ UserDefaults.standard.set(favSongs, forKey: "favSongs") }
        
        // Recogemos las canciones que ya estan descargadas, para no volver a descargarlas
        // si el usuario lo pide, al ser la primera vez que se abre la aplicacion, crea
        // un set vacio
        if let lD = UserDefaults.standard.object(forKey: "lyricsDownload"){ lyricsDownload = lD as! [String] }
        else{ UserDefaults.standard.set(lyricsDownload, forKey: "lyricsDownload") }
        
        // Recogemos las listas de reproduccion guardadas
        if let lR = UserDefaults.standard.object(forKey: "listaReproduccion"){ listaReproduccion = lR as! [String] }
        else{ UserDefaults.standard.set(listaReproduccion, forKey: "listaReproduccion") }
        
        // Cargamos el Path a documentos del dispositivo
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        // Carga la lista de archivos del directorio documentos
        let fm = FileManager.default
        var allfiles = try! fm.contentsOfDirectory(atPath: documentsPath.path)
        
        for file in allfiles{
            if (file.contains(".txt")){
                allfiles = allfiles.filter {$0 != file}
            }else{}
        }
        
        let stFav = String(format: "%d%@",favSongs.count," pistas")
        let stAll = String(format: "%d%@",allfiles.count," pistas")

        labFav.text = stFav
        labAll.text = stAll
        
        // Tenemos listas de reproduccion asi que las mostramos en la tabla
        if (listaReproduccion.count != 0){
            listaVacia.isHidden = true
        }else{
            tablaLista.isHidden = true
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(listaReproduccion.count > 0){
            return listaReproduccion.count
        }else{
            return 0
        }
    }
    
    // Borra elemento de la lista
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            // Elimina la lista de canciones
            listaReproduccion.remove(at: indexPath.row)
            UserDefaults.standard.set(listaReproduccion, forKey: "listaReproduccion")
            
            // Hacemos fade de la row seleccionada, este metodo necesariamente debe ir despues
            // del cambio de datos en el modelo
            tableView.deleteRows(at:[indexPath], with: .fade)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "id_cell", for: indexPath as IndexPath)
        
        cell.textLabel?.text = listaReproduccion[indexPath.row]
        cell.textLabel?.textColor = UIColor.white
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 40.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {}
    
    // Sobreescribimos el metodo para pasar algunos parametros
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "MainToFav") {
            (segue.destination as! FavSongsViewController).pistas = favSongs.count
       
        }else if (segue.identifier == "MainToListSongs"){

            let pos = tablaLista.indexPathForSelectedRow?.row
            let nombreLista = listaReproduccion[pos!]
    
            // Cambiamos el texto del boton volver atras
            let backItem = UIBarButtonItem()
            backItem.title = "Volver"
            backItem.tintColor = UIColor.white
            navigationItem.backBarButtonItem = backItem
            
            (segue.destination as! ListaCancionTablaViewController).nombreLista = nombreLista
        }
    }
    
    @IBAction func buttonSinFuncion(){
        let alert = UIAlertController(title: "Ups..", message: "Esta funcionalidad esta desactivada", preferredStyle: UIAlertControllerStyle.actionSheet)
        
        alert.addAction(UIAlertAction(title: "Vale", style: UIAlertActionStyle.default, handler:
            { action -> Void in}))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
