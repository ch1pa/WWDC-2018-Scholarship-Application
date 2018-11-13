/*:
 
# Great Circle Route Creator
 
 Randall Beck II (Chip Beck)\
 WWDC 2018 Student Scholarship Application\
 \
 Make sure to use the assistant editor and make the window large enough to fit the 768x1024 live view. If the live view doesn't fit in the editor, you may need to scrolll to see the entire view.\
 \
 If you want to zoom in or out on the MapView, hold down the option key while dragging the map.\
 \
 The Playground is platform agnostic, but only runs on iPad in full screen mode. Running in Xcode is preferred.
 
 
*/

import PlaygroundSupport
import UIKit

var vc = ViewController()
vc.preferredContentSize = CGSize(width: 768, height: 1024)

PlaygroundPage.current.liveView = vc
