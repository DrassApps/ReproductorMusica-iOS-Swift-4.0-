//
//  LyricsViewController.swift
//  RepMusica
//
//  Created by Andrés on 4/1/18.
//  Copyright © 2018 Andrés. All rights reserved.
//

import UIKit

class LyricsViewController: BaseViewController {

    @IBOutlet var nombre : UILabel!
    @IBOutlet var vista : UIView!
    @IBOutlet var letra : UITextView!
    
    var nombreCancion = ""
    var letraCancion = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nombreCancion = nombreCancion.replacingOccurrences(of: ".mp3", with:"")
        nombre.text = nombreCancion
        
        if(letraCancion.count > 2){
            letraCancion = letraCancion.replacingOccurrences(of: ", ", with: "\n")
            vista.isHidden = true
            letra.text = letraCancion
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
