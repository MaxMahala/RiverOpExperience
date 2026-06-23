import SwiftUI
import MapKit

struct RRImagePicker: UIViewControllerRepresentable {
    let rrSourceType: UIImagePickerController.SourceType
    let rrOnImagePicked: (UIImage) -> Void

    @Environment(\.dismiss) private var rrDismiss

    func makeCoordinator() -> RRCoordinator {
        RRCoordinator(rrOnImagePicked: rrOnImagePicked, rrDismiss: rrDismiss)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let rrPicker = UIImagePickerController()
        rrPicker.sourceType = rrSourceType
        rrPicker.delegate = context.coordinator
        rrPicker.allowsEditing = false
        return rrPicker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    final class RRCoordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let rrOnImagePicked: (UIImage) -> Void
        let rrDismiss: DismissAction

        init(rrOnImagePicked: @escaping (UIImage) -> Void, rrDismiss: DismissAction) {
            self.rrOnImagePicked = rrOnImagePicked
            self.rrDismiss = rrDismiss
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            rrDismiss()
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
        ) {
            if let rrImage = info[.originalImage] as? UIImage {
                rrOnImagePicked(rrImage)
            }
            rrDismiss()
        }
    }
}

enum RRFont {
    static let black = "Montserrat-Black"
    static let semiBold = "Montserrat-SemiBold"
    static let regular = "Montserrat-Regular"
}

enum RRColor {
    static let riverDeep = Color(red: 0.039, green: 0.086, blue: 0.157)
    static let riverMid = Color(red: 0.059, green: 0.133, blue: 0.251)
    static let riverSurface = Color(red: 0.137, green: 0.290, blue: 0.478)
    static let boltGold = Color(red: 0.961, green: 0.784, blue: 0.259)
    static let boltSunrise = Color(red: 1.000, green: 0.851, blue: 0.400)
    static let foamWhite = Color.white
    static let foamMist = Color(red: 0.910, green: 0.929, blue: 0.961)
    static let sandWarm = Color(red: 0.86, green: 0.78, blue: 0.67)
    static let seaGreen = Color(red: 0.23, green: 0.63, blue: 0.55)
}

struct rrBackgroundViewMain324: View {
    var body: some View {
        ZStack {
            if UIDevice.current.userInterfaceIdiom == .phone && UIScreen.main.bounds.height < 700 {
                Image("blue-background_1409-1283")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 600)
            } else {
                Image("blue-background_1409-1283")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 350)
            }
            
            LinearGradient(
                colors: [
                    RRColor.riverDeep.opacity(0.85),
                    RRColor.riverMid.opacity(0.6),
                    RRColor.riverDeep.opacity(0.9)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            
            RadialGradient(
                colors: [
                    RRColor.boltGold.opacity(0.12),
                    Color.clear
                ],
                center: .center,
                startRadius: 20,
                endRadius: 280
            )
            .offset(y: -UIScreen.main.bounds.height * 0.12)
        }
    }
}

struct RRActivityMapRepresentable: UIViewRepresentable {
    @Binding var rrRegion: MKCoordinateRegion
    let rrActivities: [RRActivityPinModel]
    let rrSelectedAction: (RRActivityPinModel) -> Void
    let rrIs3DEnabled: Bool

    func makeCoordinator() -> RRCoordinator {
        RRCoordinator(parent: self)
    }

    func makeUIView(context: Context) -> MKMapView {
        let rrMapView = MKMapView(frame: .zero)
        rrMapView.delegate = context.coordinator
        rrMapView.showsCompass = false
        rrMapView.showsScale = false
        rrMapView.showsUserLocation = false
        rrMapView.pointOfInterestFilter = .includingAll
        rrMapView.setRegion(rrRegion, animated: false)
        context.coordinator.rrApplyAnnotations(on: rrMapView, activities: rrActivities)
        rrApplyCamera(to: rrMapView)
        return rrMapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        if abs(uiView.region.center.latitude - rrRegion.center.latitude) > 0.0001 ||
            abs(uiView.region.center.longitude - rrRegion.center.longitude) > 0.0001 {
            uiView.setRegion(rrRegion, animated: true)
        }

        context.coordinator.parent = self
        context.coordinator.rrApplyAnnotations(on: uiView, activities: rrActivities)
        rrApplyCamera(to: uiView)
    }

    private func rrApplyCamera(to mapView: MKMapView) {
        let rrCamera = MKMapCamera()
        rrCamera.centerCoordinate = rrRegion.center
        rrCamera.pitch = rrIs3DEnabled ? 58 : 0
        rrCamera.altitude = rrIs3DEnabled ? 900 : 2400
        rrCamera.heading = 0
        mapView.setCamera(rrCamera, animated: true)
    }

    final class RRCoordinator: NSObject, MKMapViewDelegate {
        var parent: RRActivityMapRepresentable

        init(parent: RRActivityMapRepresentable) {
            self.parent = parent
        }

        func rrApplyAnnotations(on mapView: MKMapView, activities: [RRActivityPinModel]) {
            let rrExisting = mapView.annotations.filter { !($0 is MKUserLocation) }
            mapView.removeAnnotations(rrExisting)

            let rrAnnotations = activities.map { activity -> RRPointAnnotation in
                let rrAnnotation = RRPointAnnotation(activity: activity)
                rrAnnotation.coordinate = activity.rrCoordinate
                rrAnnotation.title = activity.rrTitle
                return rrAnnotation
            }

            mapView.addAnnotations(rrAnnotations)
        }

        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            DispatchQueue.main.async {
                self.parent.rrRegion = mapView.region
            }
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard let rrAnnotation = annotation as? RRPointAnnotation else { return nil }

            let rrID = "RRActivityAnnotation"
            let rrView = mapView.dequeueReusableAnnotationView(withIdentifier: rrID) as? MKMarkerAnnotationView
                ?? MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: rrID)

            rrView.annotation = rrAnnotation
            rrView.canShowCallout = false
            rrView.markerTintColor = UIColor(rrAnnotation.activity.rrKind.rrAccent)
            rrView.glyphImage = UIImage(systemName: rrAnnotation.activity.rrKind.rrSystemIcon)
            rrView.displayPriority = .required
            return rrView
        }

        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            guard let rrAnnotation = view.annotation as? RRPointAnnotation else { return }
            parent.rrSelectedAction(rrAnnotation.activity)
        }
    }
}

final class RRPointAnnotation: MKPointAnnotation {
    let activity: RRActivityPinModel

    init(activity: RRActivityPinModel) {
        self.activity = activity
        super.init()
    }
}
