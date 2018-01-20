//
//  SongDetailViewController.swift
//  RepMusica
//
//  Created by Andrés on 24/12/17.
//  Copyright © 2017 Andrés. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

class SongDetailViewController: BaseViewController {

    @IBOutlet var slider: UISlider!         // Slider que permite controlar el volumen
    @IBOutlet var repSound: UIButton!       // Repite la cancion constantemente
    @IBOutlet var playSound: UIButton!      // Permite pausear y reanudar la cancion
    @IBOutlet var nextSound: UIButton!      // Permite acceder a la siguiente cancion
    @IBOutlet var prevSound: UIButton!      // Permite acceder a la cancion anterior
    @IBOutlet var aleatSound: UIButton!     // Reproduce una cancion aleatoria al terminar
    @IBOutlet var moreVolume: UIButton!     // Permite subir el volumen de la musica
    @IBOutlet var lessVolume: UIButton!     // Permite bajar el volumen de la musica
    @IBOutlet var progView: UIProgressView! //
    
    @IBOutlet var timeSound: UILabel!       // Nos muestra el tiempo transcurrido
    @IBOutlet var nameSound: UILabel!       // Nos muestra el nombre de la cnacion
    @IBOutlet var percSound: UILabel!       // Nos muestra el lugar que tiene en la lista
    @IBOutlet var authSound: UILabel!       // Nos muestra el lugar que tiene en la lista
    @IBOutlet var fav: UIButton!            // Nos muestra el lugar que tiene en la lista

    let logo = UIImage(named: "srcBac.png")
    let cR = UIImage(named: "heartR.png")
    let cB = UIImage(named: "heartB.png")

    var player = AVAudioPlayer()            // AVAudioPlayer para reproducir musica
    var pos = 0                             // Posicion de la cancion en el array
    var posN = 0                            // Posicion +1 de la cancion en el array
    var auxPrevSong = 0                     // Nos permite volver a la cancion anterior
    var songName = ""                       // Nombre de la cancion
    var letraDeCancion = ""
    var tituloCancion = ""
    var atSong = [String]()                 // Array
    var allfiles = [String]()               // Array que contiene el nombre de las canciones
    var soundpathURL: URL!                  // Path a la cancion
    var documentsPath: URL!                 // Path al direcotrio documentos del dispositivo
    var sonando = false                     // Nos dice si una cancion se esta reproduciendo
    var aleatorio = false                   // Nos dice si la siguiente cancion es aleatoria
    var repetir = false                     // Nos dice si tenemos que repetir la cancion
    var pausa = false						// Nos dice si el usuario ha pausado la cancion
    var favorito = false					// Indica si la cancion esta en favoritos
    var songDuration = 0					// Duracion de la cancion total
    var songDCount = 0						// Posicion de la cancion "1/10"
    var songMinutes = 0						// Duracion de la cancion en minutos
    var songSecs = 0						// Duracion de la cancion en segundos
    var auxMin = 0							// Variable auxiliar para saber los minutos
    var auxP = 0							// Variable auxiliar para saber la pos anterior
    var guardSongDCount = 0					// Variable que guarda los segundos transcurridos
    var guardAuxMin = 0						// Variable que guarda los minutos transcurridos
    var myT: Timer!							// Timer para mostrar el paso de segundos
    
    let favSongsSaved = UserDefaults.standard.object(forKey: "favSongs")
    var favSongs = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Asignamos las canciones favoritas a un array para conocer si la cancion elegida
        // desde la tabla es favorita. Si lo es, actualizaremos la imagen del Fav
        favSongs = favSongsSaved as! [String]
        
        // Si la cancion seleccionada esta en el array, significa que es favorita,
        // por lo tanto actualizamos el bool y la imagen
        if favSongs.contains(songName){
            favorito = true
            fav.setImage(cR, for: .normal)
        }

        // Asignamos la posicionN para si quieremos pasar a las siguientes canciones
        posN = pos
        print("a ver songdetalle",allfiles,documentsPath,songName, pos)
        // Obtenemos un path a la cancion nueva
        let soundpathURLforM = documentsPath.appendingPathComponent(allfiles[pos])
        // Establecemos un playerItem
        let playerItem = AVPlayerItem(url: soundpathURLforM)
        // Obtenemos los metadata
        let metadataList = playerItem.asset.commonMetadata
        var nombreArtista = ""
        
        // Recorremos el array de metadatos para obtener el nombre del artista
        for item in metadataList {
            if let stringValue = item.value as? String {
                if item.commonKey!.rawValue == "artist" {
                    // Asignamos el nombre del artista
                    nombreArtista = stringValue
                }
                if item.commonKey!.rawValue == "title" {
                    // Asignamos el titulo de la cancion
                    tituloCancion = stringValue
                }
            }
        }
        
        // Si es igual a nil significa que no ha recogido ningun nombre pues en los metadatos
        // no aparece, ya sea porque no hay o porque no estan incliudos. No obstante para
        // las canciones que si se encuentra el artista en sus metadatos actualizaremos
        // la vista con su nombre
        if (nombreArtista.count > 0){
            authSound.text = nombreArtista
        }else {authSound.text = "Desconocido" }
        
       
        // Iniciamos el numero que ocupa en la lista
        let strS = String(format: "%d%@%d",pos+1," de ",allfiles.count)
        percSound.text = strS
        
        // Iniciamos la cancion que elije el usuario
        nameSound.text = songName
        
        // Habilita la reproduccion del sonido en BackGround
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            do {
                try AVAudioSession.sharedInstance().setActive(true)
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        // Si esta sonando
        if (sonando){
            
            // Paramos la cancion
            player.stop()
            
            // Cargamos el nombre de la cancion que hemos seleccionado en la tabla
            let soundname = allfiles[pos]
            atSong = soundname.components(separatedBy: "-")
            soundpathURL = documentsPath.appendingPathComponent(soundname)
            
            // Inicializamos el player
            player = try! AVAudioPlayer(contentsOf: soundpathURL)
            player.prepareToPlay()
    
            // Rreproducimos la cancion y asignamos un volumen inicial
            player.play()
            sonando = true
            player.volume = 0.5
            auxPrevSong = posN
            progView.setProgress(0.0, animated: false)
            myT = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(countSongTick), userInfo: nil, repeats: true)
            
        }else {
            
            // Cargamos el nombre de la cancion que hemos seleccionado en la tabla
            let soundname = allfiles[pos]
            atSong = soundname.components(separatedBy: "-")

            soundpathURL = documentsPath.appendingPathComponent(soundname)
            
            // Inicializamos el player
            player = try! AVAudioPlayer(contentsOf: soundpathURL)
            player.prepareToPlay()
         
            // Inicializamos el player y asignamos un volumen inicial
            player.play()
            sonando = true
            player.volume = 0.5
            auxPrevSong = posN
            progView.setProgress(0.0, animated: false)
            myT = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(countSongTick), userInfo: nil, repeats: true)
        }
    }
    
    // Controla los eventos del pausa y reproducir musica
    @IBAction func controlPlaySound(){
        // Si hay una cancion paramos la cancion y cambiamos la imagen del boton
        if (sonando){
            player.pause()
            myT.invalidate()
            pausa = true
            playSound.setImage(#imageLiteral(resourceName: "playButton"), for: .normal)
            guardSongDCount = songDCount
            guardAuxMin = auxMin
            sonando = false
        // Continuamos reproduciendo y cambiamos la imagen
        }else{
            player.play()
            playSound.setImage(#imageLiteral(resourceName: "pauseSound"), for: .normal)
            sonando = true
            pausa = false
            myT = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(countSongTick), userInfo: nil, repeats: true)
        }
    }
    
    // Permite pasar a la siguiente cancion de la lista
    @IBAction func controlNextSong(){
        // Si esta sonando, paramos y reproducimos la siguiente
        if (sonando){
            // Paramos
            player.stop()
            
            // Si aleatoria esta activa la proxima cancion a coger (posN) es aleatoria
            if (aleatorio){
                auxPrevSong = posN
                posN = randomSong()
                if (auxPrevSong == posN){posN = randomSong()}
                let song = obtenerCancion(posicion: posN)
                prepareSong(url: song)
                player.play()
                sonando = true
                playSound.setImage(#imageLiteral(resourceName: "pauseSound"), for: .normal)
                updateUI(songPos: posN)
                songDCount = 0
                auxMin = 0
                guardAuxMin = 0
                guardSongDCount = 0
                auxP = 0
                progView.setProgress(0.0, animated: false)
                if(myT.isValid){
                    myT.invalidate()
                    myT = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(countSongTick), userInfo: nil, repeats: true)
                }else{
                    myT = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(countSongTick), userInfo: nil, repeats: true)
                }
                
            // Repitmos la misma cancion indicando el mismo posN
            }else if (repetir){
                
                let song = obtenerCancion(posicion: posN)
                prepareSong(url: song)
                player.play()
                sonando = true
                playSound.setImage(#imageLiteral(resourceName: "pauseSound"), for: .normal)
                updateUI(songPos: posN)
                songDCount = 0
                auxMin = 0
                guardAuxMin = 0
                guardSongDCount = 0
                auxP = 0
                progView.setProgress(0.0, animated: false)
                if(myT.isValid){
                    myT.invalidate()
                    myT = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(countSongTick), userInfo: nil, repeats: true)
                }else{
                    myT = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(countSongTick), userInfo: nil, repeats: true)
                }
                
            // Si ni repetir ni aleatoria esta activa, pasamos a la siguiente cancion
            }else{
                auxPrevSong = posN+1
                posN = posN+1
                let song = obtenerCancion(posicion: posN)
                prepareSong(url: song)
                player.play()
                sonando = true
                playSound.setImage(#imageLiteral(resourceName: "pauseSound"), for: .normal)
                updateUI(songPos: posN)
                songDCount = 0
                auxMin = 0
                guardAuxMin = 0
                guardSongDCount = 0
                auxP = 0
                progView.setProgress(0.0, animated: false)
                if(myT.isValid){
                    myT.invalidate()
                    myT = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(countSongTick), userInfo: nil, repeats: true)
                }else{
                    myT = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(countSongTick), userInfo: nil, repeats: true)
                }
            }
        // Si no esta reproduciendo ninguna, simplemente pasa a la siguiente
        }else{
            
            // Si aleatoria esta activa la proxima cancion a coger (posN) es aleatoria
            if (aleatorio){
                auxPrevSong = posN
                posN = randomSong()
                // Obtenemos la siguiente cancion y la prerparamos para reproducir
                let song = obtenerCancion(posicion: posN)
                prepareSong(url: song)
                player.play()
                sonando = true
                updateUI(songPos: posN)
                playSound.setImage(#imageLiteral(resourceName: "pauseSound"), for: .normal)
                nameSound.text = allfiles[posN]
                songDCount = 0
                auxMin = 0
                guardAuxMin = 0
                guardSongDCount = 0
                auxP = 0
                progView.setProgress(0.0, animated: false)
                if(myT.isValid){
                    myT.invalidate()
                    myT = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(countSongTick), userInfo: nil, repeats: true)
                }else{
                    myT = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(countSongTick), userInfo: nil, repeats: true)
                }
                
             // Repitmos la misma cancion indicando el mismo posN
            }else if (repetir){
                
                let song = obtenerCancion(posicion: posN)
                prepareSong(url: song)
                player.play()
                sonando = true
                playSound.setImage(#imageLiteral(resourceName: "pauseSound"), for: .normal)
                updateUI(songPos: posN)
                songDCount = 0
                auxMin = 0
                guardAuxMin = 0
                guardSongDCount = 0
                auxP = 0
                progView.setProgress(0.0, animated: false)
                if(myT.isValid){
                    myT.invalidate()
                    myT = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(countSongTick), userInfo: nil, repeats: true)
                }else{
                    myT = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(countSongTick), userInfo: nil, repeats: true)
                }
                
            // Si ni repetir ni aleatoria esta activa, pasamos a la siguiente cancion
            }else {
                auxPrevSong = posN+1
                posN = posN+1
                // Obtenemos la siguiente cancion y la prerparamos para reproducir
                let song = obtenerCancion(posicion: posN)
                prepareSong(url: song)
                player.play()
                sonando = true
                updateUI(songPos: posN)
                playSound.setImage(#imageLiteral(resourceName: "pauseSound"), for: .normal)
                nameSound.text = allfiles[posN]
                songDCount = 0
                auxMin = 0
                guardAuxMin = 0
                guardSongDCount = 0
                auxP = 0
                progView.setProgress(0.0, animated: false)
                if(myT.isValid){
                    myT.invalidate()
                    myT = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(countSongTick), userInfo: nil, repeats: true)
                }else{
                    myT = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(countSongTick), userInfo: nil, repeats: true)
                }
            }
        }
    }
    
    // Permite pasar a la cancion anterior
    @IBAction func controlPrevSong(){
        // Si esta sonando, paramos y reproducimos la anterior
        if (sonando){
            // Paramos
            player.stop()
            auxPrevSong = auxPrevSong-1
            // Si hemos llegado a la primera cancion reproducimos la ultioma
            if (auxPrevSong < 0){
                auxPrevSong = allfiles.count-1
                posN = 0
                // Reproducimos la cancion anterior
                let song = obtenerCancion(posicion: allfiles.count-1)
                prepareSong(url: song)
                player.play()
                sonando = true
                playSound.setImage(#imageLiteral(resourceName: "pauseSound"), for: .normal)
                updateUI(songPos: allfiles.count-1)
                songDCount = 0
                auxMin = 0
                guardAuxMin = 0
                guardSongDCount = 0
                auxP = 0
                progView.setProgress(0.0, animated: false)
                if(myT.isValid){
                    myT.invalidate()
                    myT = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(countSongTick), userInfo: nil, repeats: true)
                }else{
                    myT = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(countSongTick), userInfo: nil, repeats: true)
                }
            // Si no reproducimos de forma normal
            }else{
                // Reproducimos la cancion anterior
                let song = obtenerCancion(posicion: auxPrevSong)
                posN = auxPrevSong
                prepareSong(url: song)
                player.play()
                sonando = true
                playSound.setImage(#imageLiteral(resourceName: "pauseSound"), for: .normal)
                updateUI(songPos: auxPrevSong)
                songDCount = 0
                auxMin = 0
                guardAuxMin = 0
                guardSongDCount = 0
                auxP = 0
                progView.setProgress(0.0, animated: false)
                if(myT.isValid){
                    myT.invalidate()
                    myT = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(countSongTick), userInfo: nil, repeats: true)
                }else{
                    myT = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(countSongTick), userInfo: nil, repeats: true)
                }
            }
        // Si no esta reproduciendo ninguna, simplemente pasa a la anterior
        }else{
            auxPrevSong = auxPrevSong-1
            // Si hemos llegado a la primera cancion reproducimos la ultioma
            if (auxPrevSong < 0){
                auxPrevSong = allfiles.count-1
                posN = 0
                // Reproducimos la cancion anterior
                let song = obtenerCancion(posicion: allfiles.count-1)
                prepareSong(url: song)
                player.play()
                sonando = true
                playSound.setImage(#imageLiteral(resourceName: "pauseSound"), for: .normal)
                updateUI(songPos: allfiles.count-1)
                songDCount = 0
                auxMin = 0
                guardAuxMin = 0
                guardSongDCount = 0
                auxP = 0
                progView.setProgress(0.0, animated: false)
                if(myT.isValid){
                    myT.invalidate()
                    myT = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(countSongTick), userInfo: nil, repeats: true)
                }else{
                    myT = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(countSongTick), userInfo: nil, repeats: true)
                }
                // Si no reproducimos de forma normal
            }else{
                // Reproducimos la cancion anterior
                let song = obtenerCancion(posicion: auxPrevSong)
                posN = auxPrevSong
                prepareSong(url: song)
                player.play()
                sonando = true
                playSound.setImage(#imageLiteral(resourceName: "pauseSound"), for: .normal)
                updateUI(songPos: auxPrevSong)
                songDCount = 0
                auxMin = 0
                guardAuxMin = 0
                guardSongDCount = 0
                auxP = 0
                progView.setProgress(0.0, animated: false)
                if(myT.isValid){
                    myT.invalidate()
                    myT = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(countSongTick), userInfo: nil, repeats: true)
                }else{
                    myT = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(countSongTick), userInfo: nil, repeats: true)
                }
            }
        }
    }
    
    // Actualiza la informacion de la vista
    func updateUI(songPos:Int){
        let strS = String(format: "%d%@%d",songPos+1," de ",allfiles.count)
        let soundname = allfiles[songPos]

        nameSound.text = allfiles[songPos]
        percSound.text = strS
        
        // Obtenemos un path a la cancion nueva
        let soundpathURL = documentsPath.appendingPathComponent(allfiles[songPos])
        // Establecemos un playerItem
        let playerItem = AVPlayerItem(url: soundpathURL)
        // Obtenemos los metadata
        let metadataList = playerItem.asset.commonMetadata
        var nombreArtista = ""
        
        // Recorremos el array de metadatos para obtener el nombre del artista
        for item in metadataList {
            if let stringValue = item.value as? String {
                if item.commonKey!.rawValue == "artist" {
                    // Asignamos el nombre del artista
                    nombreArtista = stringValue
                    print("metadata",nombreArtista)
                   
                }
            }
        }
        
        // Si es igual a nil significa que no ha recogido ningun nombre pues en los metadatos
        // no aparece, ya sea porque no hay o porque no estan incliudos. No obstante para
        // las canciones que si se encuentra el artista en sus metadatos actualizaremos
        // la vista con su nombre
        if (nombreArtista.count > 0){
            authSound.text = nombreArtista
        }else {authSound.text = "Desconocido" }
        
        
        // Actualizamos el bool favorito y la imagen segun si la cancion esta en la lista
        if favSongs.contains(soundname){
            favorito = true
            fav.setImage(cR, for: .normal)
        }else{
            fav.setImage(cB, for: .normal)
            favorito = false
        }
    }
    
    // Aumenta el volumen de la musica
    @IBAction func moreSound(){
        if(player.volume == 0){
            player.volume = 0.25
            slider.value = 0.25
        }else if (player.volume == 0.25){
            player.volume = 0.5
            slider.value = 0.5
        }else if (player.volume == 0.5){
            player.volume = 0.75
            slider.value = 0.75
        }else if (player.volume == 0.75){
            player.volume = 1
            slider.value = 1
        }
    }
    
    // Reduce el volumen de la musica
    @IBAction func lowSound(){
        if(player.volume == 1){
            player.volume = 0.75
            slider.value = 0.75
        }else if (player.volume == 0.75){
            player.volume = 0.5
            slider.value = 0.5
        }else if (player.volume == 0.5){
            player.volume = 0.25
            slider.value = 0.25
        }else if (player.volume == 0.25){
            player.volume = 0
            slider.value = 0
        }
    }
    
    // Devuelve un random para la siguiente cancion, al habilitar el aleatorio
    func randomSong()->Int{
        return Int(arc4random_uniform(UInt32(allfiles.count)))
    }
    
    // Asigna que la proxima cancion sea aleatoria
    @IBAction func randomSongNum(){
        if(aleatorio){
            aleatSound.setImage(#imageLiteral(resourceName: "atlSound"), for: .normal)
            aleatorio = false
        }else{
            aleatSound.setImage(#imageLiteral(resourceName: "altSoundN"), for: .normal)
            aleatorio = true
        }
    }
    
    // Asigna que la proxima cancion sea la misma
    @IBAction func repetirSong(){
        if(repetir){
            repSound.setImage(#imageLiteral(resourceName: "repiSoundN"), for: .normal)
            repetir = false
        }else{
            repSound.setImage(#imageLiteral(resourceName: "repiSound"), for: .normal)
            repetir = true
        }
    }
    
    // Nos devuelve una URL a la cancion del array dada una posicion
    func obtenerCancion(posicion:Int) ->URL{
        // Si posicion es mayor o igual, por lo tanto ya no hay mas canciones, volvemos a la primera
        if (posicion >= allfiles.count){
            posN = 0
            let soundname = allfiles[0]
            soundpathURL = documentsPath.appendingPathComponent(soundname)
            return soundpathURL
            
        // Si no hemos llegado a la ultima cancion
        }else{
            let soundname = allfiles[posicion]
            soundpathURL = documentsPath.appendingPathComponent(soundname)
            return soundpathURL
        }
    }
    
    // Prepara el player para reproducir
    func prepareSong(url:URL){
        player = try! AVAudioPlayer(contentsOf: url)
        player.prepareToPlay()
    }
    
    @IBAction func favPulsado(){
        // Si ya es favorita la cancion, cambiamos el icono y eliminamos de la lista de fav
        // la cancion y del UserDefaults
        if(favorito){
            fav.setImage(#imageLiteral(resourceName: "heartB"), for: .normal)
            favorito = false
            if let index = favSongs.index(of: songName){
                favSongs.remove(at: index)
                UserDefaults.standard.set(favSongs, forKey: "favSongs")
            }
        // Si no era favorita, actualizamos la imagen y la incluimos en el set de UserDefaults
        // de tal forma que podamos recuperar las canciones fav en otra vista
        }else{
            fav.setImage(#imageLiteral(resourceName: "heartR"), for: .normal)
            favorito = true
            favSongs.insert(songName, at: favSongs.endIndex)
            UserDefaults.standard.set(favSongs, forKey: "favSongs")

        }
    }
    
    // Sobreescribimos el metodo de ir a la siguiente vista. Al pulsar sobre el libro para
    // ver la letra, establecemos el texto y el nombre de la cancion
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
        let backItem = UIBarButtonItem()
        
        // Cambiamos el texto del boton volver atras
        backItem.title = "Volver"
        backItem.tintColor = UIColor.white
        navigationItem.backBarButtonItem = backItem
        
        // Leemos la letra para pasarla a la siguiente vista
        leerDatos(titulo: tituloCancion)
        
        // Le pasamos la letra y el nombre de la cancion
        if (segue.identifier == "SongToLyric") {
            (segue.destination as! LyricsViewController).letraCancion = letraDeCancion
            (segue.destination as! LyricsViewController).nombreCancion = songName
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if(sonando){
            player.stop()
        }
    }
    
    func leerDatos(titulo:String){
        // Obtenemos el path al archivo
        let file = documentsPath.appendingPathComponent(titulo+".txt")
        
        print("LOCO",titulo)
        
        // Leemos el contenido, lo guardamos en una string por si el usuario pide ver la letra de
        // la cancion
        do{
            let datosGuardados = try String(contentsOf: file, encoding: String.Encoding.utf8)
            let ms = datosGuardados.components(separatedBy: .newlines)
            letraDeCancion = ms.joined(separator: ", ")
            
            print("LOCO",letraDeCancion)
        }
        catch{print("LOCO","yes")}
    }
    
    
    // Funcion que controla el paso del tiempo en la cancion.
    // 1. Actualiza el label de la UI para indiar al usuario por que segundo va de la cancion asi como la duracion total de la misma
    // 2. Actualiza el progressView segun la duracion de la cancion y el tiempo pasado
    @objc func countSongTick() {
        
        if (!pausa){
            songDuration = Int(player.duration)
            songMinutes  = (songDuration % 3600) / 60
            songSecs = (songDuration % 3600) % 60
            songDCount = songDCount+1
            auxP = auxP+1
            
            let res : Float = (Float(auxP*100) / Float(songDuration)) / 100.0
            progView.setProgress(res, animated: true)
            
            if (songDCount == songDuration) {myT.invalidate()}
            else if(songDCount >= 60){
                if (auxMin == 0){
                    timeSound.text = String(format: "%@%d%@%d","01:00 | 0", songMinutes,":",songSecs)
                    auxMin = auxMin+1
                    songDCount = 0
                }else if (auxMin == 1){
                    timeSound.text = String(format: "%@%d%@%d","02:00 | 0", songMinutes,":",songSecs)
                    auxMin = auxMin+1
                    songDCount = 0
                } else if (auxMin == 2){
                    timeSound.text = String(format: "%@%d%@%d","02:00 | 0", songMinutes,":",songSecs)
                    auxMin = auxMin+1
                    songDCount = 0
                }
            }
            else if (songDCount >= 10){
                if (auxMin == 0){
                    timeSound.text = String(format: "%@%d%@%@%d%@%d","00:", songDCount," | ", "0" ,songMinutes,":",songSecs)
                }else if (auxMin == 1){
                    timeSound.text = String(format: "%@%d%@%@%d%@%d","01:", songDCount," | ", "0" ,songMinutes,":",songSecs)
                }else if (auxMin == 2){
                    timeSound.text = String(format: "%@%d%@%@%d%@%d","02:", songDCount," | ", "0" ,songMinutes,":",songSecs)
                }else if (auxMin == 3){
                    timeSound.text = String(format: "%@%d%@%@%d%@%d","03:", songDCount," | ", "0" ,songMinutes,":",songSecs)
                }
            }
            else{
                if (auxMin == 0){
                    timeSound.text = String(format: "%@%d%@%@%d%@%d","00:0", songDCount," | ", "0" ,songMinutes,":",songSecs)
                }else if (auxMin == 1){
                    timeSound.text = String(format: "%@%d%@%@%d%@%d","01:0", songDCount," | ", "0" ,songMinutes,":",songSecs)
                }else if (auxMin == 2){
                    timeSound.text = String(format: "%@%d%@%@%d%@%d","02:0", songDCount," | ", "0" ,songMinutes,":",songSecs)
                }else if (auxMin == 3){
                    timeSound.text = String(format: "%@%d%@%@%d%@%d","03:0", songDCount," | ", "0" ,songMinutes,":",songSecs)
                }
            }
        }else{
            songDuration = Int(player.duration)
            songMinutes  = (songDuration % 3600) / 60
            songSecs = (songDuration % 3600) % 60
            guardSongDCount = guardSongDCount+1
            
            // cambiar esto con el guard
            
            auxP = auxP+1
            
            let res : Float = (Float(auxP*100) / Float(songDuration)) / 100.0
            progView.setProgress(res, animated: true)
            
            if (guardSongDCount == songDuration) {myT.invalidate()}
            else if(guardSongDCount >= 60){
                if (guardAuxMin == 0){
                    timeSound.text = String(format: "%@%d%@%d","01:00 | 0", songMinutes,":",songSecs)
                    guardAuxMin = guardAuxMin+1
                    guardSongDCount = 0
                }else if (guardAuxMin == 1){
                    timeSound.text = String(format: "%@%d%@%d","02:00 | 0", songMinutes,":",songSecs)
                    guardAuxMin = guardAuxMin+1
                    guardSongDCount = 0
                } else if (guardAuxMin == 2){
                    timeSound.text = String(format: "%@%d%@%d","02:00 | 0", songMinutes,":",songSecs)
                    guardAuxMin = guardAuxMin+1
                    guardSongDCount = 0
                }
            }
            else if (guardSongDCount >= 10){
                if (guardAuxMin == 0){
                    timeSound.text = String(format: "%@%d%@%@%d%@%d","00:", guardSongDCount," | ", "0" ,songMinutes,":",songSecs)
                }else if (guardAuxMin == 1){
                    timeSound.text = String(format: "%@%d%@%@%d%@%d","01:", guardSongDCount," | ", "0" ,songMinutes,":",songSecs)
                }else if (guardAuxMin == 2){
                    timeSound.text = String(format: "%@%d%@%@%d%@%d","02:", guardSongDCount," | ", "0" ,songMinutes,":",songSecs)
                }else if (guardAuxMin == 3){
                    timeSound.text = String(format: "%@%d%@%@%d%@%d","03:", guardSongDCount," | ", "0" ,songMinutes,":",songSecs)
                }
            }
            else{
                if (guardAuxMin == 0){
                    timeSound.text = String(format: "%@%d%@%@%d%@%d","00:0", guardSongDCount," | ", "0" ,songMinutes,":",songSecs)
                }else if (guardAuxMin == 1){
                    timeSound.text = String(format: "%@%d%@%@%d%@%d","01:0", guardSongDCount," | ", "0" ,songMinutes,":",songSecs)
                }else if (guardAuxMin == 2){
                    timeSound.text = String(format: "%@%d%@%@%d%@%d","02:0", guardSongDCount," | ", "0" ,songMinutes,":",songSecs)
                }else if (guardAuxMin == 3){
                    timeSound.text = String(format: "%@%d%@%@%d%@%d","03:0", guardSongDCount," | ", "0" ,songMinutes,":",songSecs)
                }
            }
        }
    }
}
