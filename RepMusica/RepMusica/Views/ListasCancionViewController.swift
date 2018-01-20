//
//  ListasCancionViewController.swift
//  RepMusica
//
//  Created by Andrés on 4/1/18.
//  Copyright © 2018 Andrés. All rights reserved.
//

import UIKit

class ListasCancionViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {

    let unCheck = UIImage(named: "circleB.png")
    let check = UIImage(named: "checkV.png")
    let TAG = "ListaCancionView"
    
    @IBOutlet var botonGuardar : UIButton!
    @IBOutlet var nombreLista : UITextField!
    @IBOutlet var tablaCanciones : UITableView!
    
    var allfiles = [String]()               // Array que contiene todas las canciones
    var allfilesAux = [String]()
    var documentsPath: URL!
    
    var activo = false
    
    let listaRep = UserDefaults.standard.object(forKey: "listaReproduccion")
    var listaRepGuardadas = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        super.addSlideMenuButton()
        
        tablaCanciones.delegate = self
        tablaCanciones.dataSource = self
    
        listaRepGuardadas = listaRep as! [String]
        
        // Cargamos el Path a documentos del dispositivo
        documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        // Carga la lista de archivos del directorio documentos
        let fm = FileManager.default
        allfiles = try! fm.contentsOfDirectory(atPath: documentsPath.path)

        for file in allfiles{
            if (file.contains(".txt")){
                allfiles = allfiles.filter {$0 != file}
            }else{}
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allfiles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "id_cell", for: indexPath as IndexPath)
        
        cell.textLabel?.text = allfiles[indexPath.row]
        cell.textLabel?.textColor = UIColor.white
        cell.imageView?.image = unCheck
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 40.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
        let cell = tableView.cellForRow(at: indexPath)
        let nombreCancion = cell?.textLabel?.text ?? "s"
        
        if (allfilesAux.contains(nombreCancion)){
            allfilesAux = allfilesAux.filter {$0 != nombreCancion}
            cell?.imageView?.image = unCheck
            print(TAG,"eliminado ",nombreCancion)
        }else{
            allfilesAux.insert(nombreCancion, at: allfilesAux.endIndex)
            cell?.imageView?.image = check
            print(TAG,"insertado ",nombreCancion)
        }
    }
    
    @IBAction func guardarListaCancion(){
        
        // Caracteres validos para el nombre de la lista
        let set = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ")
        
        // Si tiene menos de 4 letras informamos al usuario
        if((nombreLista.text?.count)! < 4 ){
            nombreNoValido(mensaje: "Introduzca un nombre más largo")
        }else if(nombreLista.text?.rangeOfCharacter(from: set.inverted) != nil){
            // Si introduce caracteres invalidos informamos al usuario
            nombreNoValido(mensaje: "Introduzca carácteres válidos [a-Z]")
        }else{
            // Si ya tenemos una lista con ese nombre, no la sobreescribimos, avisamo al usuario
            for _ in listaRepGuardadas{
                if (listaRepGuardadas.contains((nombreLista.text)!)){
                    nombreNoValido(mensaje: "Ya tienes una lista de reproducción con ese nombre.")
                
                // Si no eta en la lista la añadimos
                }else{
                    // Añadimos el nombre de la lista de reproduccion a la lista
                    listaRepGuardadas.insert((nombreLista.text)!, at: listaRepGuardadas.endIndex)
                    UserDefaults.standard.set(listaRepGuardadas, forKey: "listaReproduccion")
                    
                    // Creamos un nuevo set con las canciones asociado al nombre
                    UserDefaults.standard.set(allfilesAux, forKey: (nombreLista.text)!)
                    
                    // Volvemos a la vista Home
                    let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let viewController = storyBoard.instantiateViewController(withIdentifier: "Home") as! ViewController
                    self.show(viewController, sender:nil)
                }
            }
        }
    }
    
    func nombreNoValido(mensaje:String){
        let alert = UIAlertController(title: "Cuidado", message: mensaje, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        alert.addAction(UIAlertAction(title: "Vale", style: UIAlertActionStyle.default, handler:
            { action -> Void in}))
        self.present(alert, animated: true, completion: nil)
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
