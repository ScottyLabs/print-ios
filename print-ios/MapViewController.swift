//
//  MapViewController.swift
//  print-ios
//
//  Created by Richard Guo on 5/19/20.
//  Copyright © 2020 ScottyLabs. All rights reserved.
//

import UIKit
import PDFKit

class MapViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        openPDF()
    }
    
    // Creates the PDF view. Source: https://stackoverflow.com/questions/50037487/how-to-open-pdf-in-ios-not-using-uiwebview
    private func openPDF() {
        // Creates view
        let pdfView = PDFView()
        
        pdfView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pdfView)
        
        // Adds constraints
        pdfView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        pdfView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        pdfView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        pdfView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        // Finds file and opens it
        guard let path = Bundle.main.url(forResource: "printers-labs-map", withExtension: "pdf") else { return }
        
        if let document = PDFDocument(url: path) {
            pdfView.document = document
        }
    }

}
