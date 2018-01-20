//
//  AllSongsViewController.swift
//  RepMusica
//
//  Created by Andrés on 23/12/17.
//  Copyright © 2017 Andrés. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

class AllSongsViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    let dwnImage = UIImage(named: "imageDownl.png")
    let TAG = "AllSongsView"
    
    @IBOutlet var tableView: UITableView!   // TableView que contiene las canciones
    @IBOutlet weak var sBar: UISearchBar!
    @IBOutlet var dwnButton: UIButton!
    @IBOutlet var dwnIndica: UIActivityIndicatorView!

    var filteredData: [String]!

    var allfiles = [String]()               // Array que contiene todas las canciones
    var documentsPath: URL!

    // Recogemos las canciones Favoritas
    let favSongsSaved = UserDefaults.standard.object(forKey: "favSongs")
    var favSongs = [String]()
    
    // Recogemos las canciones que ya estan descargadas
    let lyricsDownloadSaved = UserDefaults.standard.object(forKey: "lyricsDownload")
    var lyricsDownload = [String]()

    // Api para la descarga de las letras
    let apiLetrasBase = "https://www.letras.com/"
    var url : URL!
    var html = ""
    
    var nombreArtista = ""
    var tituloCancion = ""
    
    var myActivityIndicator = UIActivityIndicatorView()
    
     var filePos = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addSlideMenuButton()
        tableView.delegate = self
        tableView.dataSource = self
        sBar.delegate = self
        
        favSongs = favSongsSaved as! [String]
        lyricsDownload = lyricsDownloadSaved as! [String]
        
        // Cargamos el Path a documentos del dispositivo
        documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        print(TAG,lyricsDownload)
        
        // Carga la lista de archivos del directorio documentos
        let fm = FileManager.default
        allfiles = try! fm.contentsOfDirectory(atPath: documentsPath.path)

        // Eliminamos los txt de la lista que se tiene que mostrar en las canciones
        for file in allfiles{
            if (file.contains(".txt")){
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
    
    
    // Este metodo actualiza el array filteredData con el contenido del searchBar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // Cuando no hay texto, filteredata es el mismo que el array original
        // Cuando el usuario introduce texto en el searchbox, usamos el
        // metodo filter para iterar todos los elementos del array
        // Para cada item si la condicion es true, lo añadimos y si no,
        // no lo incluimos en filtereddata
        
        filteredData = searchText.isEmpty ? allfiles : allfiles.filter { (item: String) -> Bool in
            // Si el texto coincide con los elementos lo añadimos
            return item.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
        }
        
        // Hacemos un reloaddatada cada vez que el usuario escribe para que se
        // actualize el contenido de la tabla
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
        
        if (segue.identifier == "AlltoSong") {
          
            let pos = tableView.indexPathForSelectedRow?.row
            let name = allfiles[pos!];
            let backItem = UIBarButtonItem()
            
            // Cambiamos el texto del boton volver atras
            backItem.title = "Volver"
            backItem.tintColor = UIColor.white
            navigationItem.backBarButtonItem = backItem
            
            (segue.destination as! SongDetailViewController).allfiles = allfiles
            (segue.destination as! SongDetailViewController).pos = pos!
            (segue.destination as! SongDetailViewController).songName = name
            (segue.destination as! SongDetailViewController).documentsPath = documentsPath
        }
    }
    

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {}
    
    @IBAction func obtenerLetraCanciones(){
        // Incrementamos en uno segun el bucle for
        var aux = 0
        
        // Creamos un alert para informar al uuario de que se va a producir la descarga
        let alert = UIAlertController(title: "Descarga", message: "Se descargará la letra de las canciones nuevas. Espere a que finalize la descarga", preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "Vale", style: UIAlertActionStyle.default, handler:
            { action -> Void in
                // Añadimos las tres canciones a la lista para que no se puedan descargar otra vez
                // tanto si esta la letra en la web como si no
                for song in self.lyricsDownload {
                    
                    if (self.lyricsDownload.contains(song)){
                        
                        // Ya hemos intentado descargar esta cancion, no vamos a volver a realizar
                        // el proceso
                        
                    }else{
                        // Obtenermos los metadatos de las canciones de la lista para inicializar
                        // la descarga, por tanto solo podremos descargar canciones que tengan
                        // metadatos. Guardamos el titulo y el autor en variables que pasaremos
                        // a la siguiente funcion
                        self.obtenerDatosCancion(posicion:aux)
                        
                        // Incluimos la cancion en la lista
                        self.lyricsDownload.insert(self.tituloCancion, at: self.lyricsDownload.endIndex)
                        UserDefaults.standard.set(self.lyricsDownload, forKey: "lyricsDownload")

                        // Descargamos la letra de la cancion para un determinado autor y titulo
                        // de cancion
                        self.descargarCancion(titulo:self.tituloCancion, autor: self.nombreArtista)
                        
                        // Incrementamos en uno para que pase a la siguiente cancion
                        aux = aux+1
                    }
                }
                
                self.descargaFinalizada()
            }
        ))
        alert.addAction(UIAlertAction(title: "Cerrar", style: UIAlertActionStyle.default, handler: { action -> Void in}))
                
        self.present(alert, animated: true, completion: nil)
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func obtenerDatosCancion(posicion:Int){
        // Obtenemos un path a la cancion nueva
        let soundpathURLforM = documentsPath.appendingPathComponent(allfiles[posicion])
        // Establecemos un playerItem
        let playerItem = AVPlayerItem(url: soundpathURLforM)
        // Obtenemos los metadata
        let metadataList = playerItem.asset.commonMetadata
       
        // Recorremos el array de metadatos para obtener el nombre del artista
        for item in metadataList {
            if let stringValue = item.value as? String {
                if item.commonKey!.rawValue == "artist" {
                    // Asignamos el nombre del artista
                    nombreArtista = stringValue
                    print(TAG,nombreArtista)
                }
                if item.commonKey!.rawValue == "title" {
                    // Asignamos el nombre de la cancion
                    tituloCancion = stringValue
                    print(TAG,tituloCancion)
                }
            }
        }
    }
    
    func descargarCancion(titulo:String, autor:String){
        // Creamos la URL añadiendo a la base el autor y el titulo
        var apiLetras = String(format: "%@%@%@%@",apiLetrasBase,autor,"/",titulo)
        
        // Formateamos la api para que no tenga espacios
        apiLetras = apiLetras.replacingOccurrences(of: " ", with:"-")
        
        // Creamos una url
        url = URL(string: apiLetras)
        
        // Intentamos obtener el contenido
        do{ html = try! String(contentsOf: url!) }
        
        // Si existe la cancion en la web y la url esta bien, procedemos a formatear el html
        if (html.contains("cnt-letra p402_premium")){
            print("Existe la cancion en la pagina")
            
            // Formatea el html recibido para obtener solo la letra de la cancion
            let words = html.components(separatedBy: "cnt-letra p402_premium")
            let words2 = words[1].components(separatedBy: "</article>")
            var words3 = words2[0].replacingOccurrences(of: ">", with:"")
            words3 = words3.replacingOccurrences(of: "<article", with:"")
            words3 = words3.replacingOccurrences(of: "<p>", with:"")
            words3 = words3.replacingOccurrences(of: "<br>", with:"")
            words3 = words3.replacingOccurrences(of: "</p", with:"")
            words3 = words3.replacingOccurrences(of: "<p", with:"")
            words3 = words3.replacingOccurrences(of: "<br/", with:"\n")
            words3 = words3.replacingOccurrences(of: "<p/", with:"")
            words3 = words3.replacingOccurrences(of: "\"", with:"")
            words3 = words3.replacingOccurrences(of: "  ", with:"")
            
            // Guardamos la letra de la cancion en un archivo que tiene por nombre el
            // titulo de la cancion, de tal forma que lo podemos recuperar mas tarde
            guardaLetra(titulo:titulo, letra:words3)
            print(words3)
        }else{}
    }
    
    func guardaLetra(titulo:String, letra:String){
        let file = documentsPath.appendingPathComponent(titulo+".txt")
        do{
            try letra.write(to: file, atomically: true, encoding: String.Encoding.utf8)
        }
        catch {}
    }
    
    func descargaFinalizada(){
        let alert = UIAlertController(title: "Descarga", message: "Se ha descargado la letra", preferredStyle: UIAlertControllerStyle.actionSheet)
        
        alert.addAction(UIAlertAction(title: "Genial", style: UIAlertActionStyle.default, handler:
            { action -> Void in}))
        self.present(alert, animated: true, completion: nil)
    }


}

