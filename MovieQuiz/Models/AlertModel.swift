//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Богдан Топорин on 14.06.2024.
//

import Foundation
import UIKit

struct AlertModel{
    let title: String
    let message: String
    let buttonText: String
    let completion: () -> Void
}
