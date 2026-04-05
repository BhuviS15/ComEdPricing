//
//  ComEdPriceWidgetBundle.swift
//  ComEdPriceWidget
//
//  Created by Bhuvi Singh on 3/22/26.
//

import WidgetKit
import SwiftUI

@main
struct ComEdPriceWidgetBundle: WidgetBundle {
    var body: some Widget {
        ComEdPriceWidget()
        ComEdPriceWidgetControl()
        ComEdPriceWidgetLiveActivity()
    }
}
