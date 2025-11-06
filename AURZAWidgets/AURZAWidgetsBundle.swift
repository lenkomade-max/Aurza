import WidgetKit
import SwiftUI

@main
struct AURZAWidgetsBundle: WidgetBundle {
    @WidgetBundleBuilder
    var body: some Widget {
        StreakWidget()
    }
}
