import SwiftUI
import PhotosUI
import MapKit

struct RRActivityMapView: View {
    @Environment(\.dismiss) private var rrDismiss
    @StateObject private var rrVm = RRActivityMapViewModel()

    var body: some View {
        ZStack {
            rrBackgroundViewMain324()
                .ignoresSafeArea()

            rrWaveDecoration

            VStack(spacing: 0) {
                rrTopBar
                rrMapCard
                rrCenterPinHint
                rrBottomDock
            }
        }
        .fullScreenCover(isPresented: $rrVm.rrShowCreateSheet) {
            RRCreateActivitySheet(rrVm: rrVm)
        }
        .fullScreenCover(item: $rrVm.rrSelectedActivity) { rrActivity in
            RRActivityDetailSheet(rrActivity: rrActivity) {
                rrVm.rrDeleteActivity(rrActivity)
            }
        }
    }

    private var rrWaveDecoration: some View {
        VStack {
            Spacer()
            RRWaveShape(rrOffset: 90, rrAmplitude: 10, rrFrequency: 1.5)
                .fill(RRColor.boltGold.opacity(0.06))
                .frame(height: 70)
            RRWaveShape(rrOffset: 120, rrAmplitude: 8, rrFrequency: 1.9)
                .fill(RRColor.foamWhite.opacity(0.025))
                .frame(height: 46)
                .offset(y: -26)
        }
        .ignoresSafeArea()
    }

    private var rrTopBar: some View {
        HStack {
            Button {
                RRHapticsManager.rrLight()
                RRSoundManager.rrTap()
                rrDismiss()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 15, weight: .semibold))
                    Image("back-3d")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 28, height: 28)
                }
                .foregroundStyle(RRColor.foamWhite)
                .padding(10)
                .background(
                    Capsule()
                        .fill(.ultraThinMaterial)
                        .overlay(
                            Capsule()
                                .stroke(RRColor.foamWhite.opacity(0.08), lineWidth: 1)
                        )
                )
            }

            Spacer()

            VStack(spacing: 2) {
                Text("Activity Map")
                    .font(.custom(RRFont.black, size: 23))
                    .foregroundStyle(RRColor.foamWhite)

                Text(rrVm.rrTotalActivitiesText)
                    .font(.custom(RRFont.regular, size: 11))
                    .foregroundStyle(RRColor.foamMist.opacity(0.45))
                    .tracking(1.1)
            }

            Spacer()

            Button {
                RRHapticsManager.rrLight()
                RRSoundManager.rrTap()
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    rrVm.rrIs3DEnabled.toggle()
                }
            } label: {
                ZStack {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 46, height: 46)

                    Image(systemName: rrVm.rrIs3DEnabled ? "cube.fill" : "cube.transparent")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(RRColor.boltGold)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, UIScreen.main.bounds.height * 0.07)
        .padding(.bottom, 16)
    }

    private var rrMapCard: some View {
        ZStack {
            RRActivityMapRepresentable(
                rrRegion: $rrVm.rrRegion,
                rrActivities: rrVm.rrActivities,
                rrSelectedAction: { rrActivity in
                    rrVm.rrSelectedActivity = rrActivity
                },
                rrIs3DEnabled: rrVm.rrIs3DEnabled
            )
            .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))

            VStack {
                HStack {
                    rrMapBadge(icon: "mappin.and.ellipse", title: rrVm.rrLatestActivityTitle)
                    Spacer()
                }
                .padding(16)
                Spacer()
            }

            Image(systemName: "plus.circle.fill")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(RRColor.boltGold)
                .shadow(color: RRColor.riverDeep.opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .frame(height: UIScreen.main.bounds.height * 0.48)
        .overlay(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .stroke(RRColor.foamWhite.opacity(0.08), lineWidth: 1)
        )
        .padding(.horizontal, 20)
    }

    private func rrMapBadge(icon: String, title: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(RRColor.boltGold)

            Text(title)
                .lineLimit(1)
                .font(.custom(RRFont.regular, size: 11))
                .foregroundStyle(RRColor.foamWhite)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 9)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
        )
    }

    private var rrCenterPinHint: some View {
        HStack(spacing: 8) {
            Image(systemName: "sparkles")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(RRColor.boltGold)

            Text("Move the map and save activity at the center pin")
                .font(.custom(RRFont.regular, size: 11))
                .foregroundStyle(RRColor.foamMist.opacity(0.45))
        }
        .padding(.top, 14)
        .padding(.bottom, 10)
    }

    private var rrBottomDock: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                rrMetricCard(icon: "figure.run", title: "Run", value: "\(rrVm.rrActivities.filter { $0.rrKind == .run }.count)")
                rrMetricCard(icon: "briefcase.fill", title: "Work", value: "\(rrVm.rrActivities.filter { $0.rrKind == .work }.count)")
                rrMetricCard(icon: "book.fill", title: "Read", value: "\(rrVm.rrActivities.filter { $0.rrKind == .read }.count)")
            }
            .padding(.horizontal, 20)

            HStack(spacing: 12) {
                Button {
                    rrVm.rrOpenCreate()
                } label: {
                    HStack(spacing: 10) {
                        Image("game-key")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)

                        Text("Add Activity")
                            .font(.custom(RRFont.semiBold, size: 16))
                    }
                    .foregroundStyle(RRColor.riverDeep)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [RRColor.boltGold, RRColor.boltSunrise],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
                }
                .buttonStyle(RRGameCardButtonStyle())

                Button {
                    RRHapticsManager.rrLight()
                    RRSoundManager.rrTap()
                    rrVm.rrIs3DEnabled.toggle()
                } label: {
                    ZStack {
                        Circle()
                            .fill(.ultraThinMaterial)
                            .frame(width: 54, height: 54)

                        Image(systemName: "cube.fill")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(RRColor.boltGold)
                    }
                }
                .buttonStyle(RRGameCardButtonStyle())
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 26)
        }
        .overlay(alignment: .top) {
            if rrVm.rrIs3DEnabled {
                Text("3D ON")
                    .font(.custom(RRFont.semiBold, size: 10))
                    .foregroundStyle(RRColor.riverDeep)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [RRColor.boltGold, RRColor.boltSunrise],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
                    .offset(y: -18)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: rrVm.rrIs3DEnabled)
    }

    private func rrMetricCard(icon: String, title: String, value: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(RRColor.boltGold)

            Text(value)
                .font(.custom(RRFont.black, size: 18))
                .foregroundStyle(RRColor.foamWhite)

            Text(title)
                .font(.custom(RRFont.regular, size: 10))
                .foregroundStyle(RRColor.foamMist.opacity(0.45))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(RRColor.foamWhite.opacity(0.08), lineWidth: 1)
                )
        )
    }
}

#Preview {
    RRActivityMapView()
}

struct RRCreateActivitySheet: View {
    @ObservedObject var rrVm: RRActivityMapViewModel
    @Environment(\.dismiss) private var rrDismiss

    var body: some View {
        ZStack {
            rrBackgroundViewMain324()
                .ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 18) {
                    rrTopBar

                    rrField(title: "Title", text: $rrVm.rrDraftTitle, placeholder: "Morning Run")
                    rrField(title: "Place", text: $rrVm.rrDraftPlaceName, placeholder: "City park")
                    rrField(title: "Notes", text: $rrVm.rrDraftNote, placeholder: "How did it go?")

                    rrKindPicker

                    rrPhotoCard

                    Button {
                        rrVm.rrSaveDraftActivity()
                        rrDismiss()
                    } label: {
                        HStack(spacing: 10) {
                            Image("3d-star-icon")
                                .resizable()
                                .frame(width: 22, height: 22)

                            Text("Save Activity")
                                .font(.custom(RRFont.semiBold, size: 16))
                        }
                        .foregroundStyle(RRColor.riverDeep)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [RRColor.boltGold, RRColor.boltSunrise],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                    }
                    .buttonStyle(RRGameCardButtonStyle())
                    .disabled(rrVm.rrDraftTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .opacity(rrVm.rrDraftTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.7 : 1)

                    Spacer().frame(height: 30)
                }
                .padding(.horizontal, 20)
            }
            
            if rrVm.rrShowCameraDeniedOverlay {
                Rectangle()
                    .fill(RRColor.riverDeep)
                    .ignoresSafeArea()
                
                RRDeniedCameraOverlay(
                    rrOpenSettings: {
                        RRHapticsManager.rrLight()
                        RRSoundManager.rrTap()
                        rrVm.rrOpenAppSettings()
                    },
                    rrDismiss: {
                        RRHapticsManager.rrLight()
                        RRSoundManager.rrTap()
                        rrVm.rrShowCameraDeniedOverlay = false
                    }
                )
            }
        }
        .confirmationDialog("Choose Image Source", isPresented: $rrVm.rrShowImageSourceDialog, titleVisibility: .visible) {
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                Button("Open Camera") {
                    RRHapticsManager.rrLight()
                    RRSoundManager.rrTap()
                    rrVm.rrHandleCameraRequest()
                }
            }

            Button("Open Gallery") {
                rrVm.rrShowGalleryPicker = true
            }

            Button("Cancel", role: .cancel) {}
        }
        .sheet(isPresented: $rrVm.rrShowCameraPicker) {
            RRImagePicker(rrSourceType: .camera) { rrImage in
                rrVm.rrDraftImage = rrImage
            }
            .ignoresSafeArea()
        }
        .sheet(isPresented: $rrVm.rrShowGalleryPicker) {
            RRImagePicker(rrSourceType: .photoLibrary) { rrImage in
                rrVm.rrDraftImage = rrImage
            }
            .ignoresSafeArea()
        }
    }
    
    private var rrTopBar: some View {
        HStack {
            Button {
                RRHapticsManager.rrLight()
                RRSoundManager.rrTap()
                rrDismiss()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 15, weight: .semibold))
                    Image("back-3d")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 28, height: 28)
                }
                .foregroundStyle(RRColor.foamWhite)
                .padding(10)
                .background(
                    Capsule()
                        .fill(.ultraThinMaterial)
                        .overlay(
                            Capsule()
                                .stroke(RRColor.foamWhite.opacity(0.08), lineWidth: 1)
                        )
                )
            }
            
            Spacer()
            
            Text("New Activity")
                .font(.custom(RRFont.black, size: 24))
                .foregroundStyle(RRColor.foamWhite)
            
            Spacer()
            
            Color.clear
                .frame(width: 45, height: 45)
        }
    }

    private func rrField(title: String, text: Binding<String>, placeholder: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.custom(RRFont.regular, size: 12))
                .foregroundStyle(RRColor.foamMist.opacity(0.45))

            TextField(placeholder, text: text)
                .font(.custom(RRFont.regular, size: 15))
                .foregroundStyle(RRColor.foamWhite)
                .padding(.horizontal, 16)
                .frame(height: 52)
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(RRColor.foamWhite.opacity(0.08), lineWidth: 1)
                        )
                )
        }
    }

    private var rrKindPicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Kind")
                .font(.custom(RRFont.regular, size: 12))
                .foregroundStyle(RRColor.foamMist.opacity(0.45))

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(RRActivityKind.allCases, id: \.self) { rrKind in
                        Button {
                            RRHapticsManager.rrLight()
                            RRSoundManager.rrTap()
                            rrVm.rrDraftKind = rrKind
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: rrKind.rrSystemIcon)
                                    .font(.system(size: 13, weight: .bold))

                                Text(rrKind.rrTitle)
                                    .font(.custom(RRFont.semiBold, size: 13))
                            }
                            .foregroundStyle(rrVm.rrDraftKind == rrKind ? RRColor.riverDeep : RRColor.foamWhite)
                            .padding(.horizontal, 14)
                            .frame(height: 42)
                            .background(
                                Capsule()
                                    .fill(rrVm.rrDraftKind == rrKind ? rrKind.rrAccent : RRColor.foamWhite.opacity(0.08))
                            )
                        }
                        .buttonStyle(RRGameCardButtonStyle())
                    }
                }
            }
        }
    }

    private var rrPhotoCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Activity Photo")
                .font(.custom(RRFont.regular, size: 12))
                .foregroundStyle(RRColor.foamMist.opacity(0.45))

            ZStack {
                RoundedRectangle(cornerRadius: 22)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 22)
                            .stroke(RRColor.foamWhite.opacity(0.08), lineWidth: 1)
                    )
                    .frame(height: 180)

                if let rrImage = rrVm.rrDraftImage {
                    Image(uiImage: rrImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 180)
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: 22))
                } else {
                    VStack(spacing: 10) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundStyle(RRColor.boltGold)

                        Text("Add camera or gallery image")
                            .font(.custom(RRFont.regular, size: 12))
                            .foregroundStyle(RRColor.foamMist.opacity(0.45))
                    }
                }
            }

            HStack(spacing: 12) {
                Button {
                    RRHapticsManager.rrLight()
                    RRSoundManager.rrTap()
                    rrVm.rrShowImageSourceDialog = true
                } label: {
                    Text("Camera / Gallery")
                        .font(.custom(RRFont.semiBold, size: 14))
                        .foregroundStyle(RRColor.foamWhite)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(RRColor.foamWhite.opacity(0.08))
                        )
                }
                .buttonStyle(RRGameCardButtonStyle())

                PhotosPicker(selection: $rrVm.rrDraftPickerItem, matching: .images) {
                    Text("Quick Gallery")
                        .font(.custom(RRFont.semiBold, size: 14))
                        .foregroundStyle(RRColor.riverDeep)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(RRColor.boltGold)
                        )
                }
                .onChange(of: rrVm.rrDraftPickerItem) { _ in
                    rrVm.rrLoadPickedGalleryItem()
                }
            }
        }
    }
}

struct RRActivityDetailSheet: View {
    let rrActivity: RRActivityPinModel
    let rrDeleteAction: () -> Void
    @Environment(\.dismiss) private var rrDismiss

    var body: some View {
        ZStack {
            rrBackgroundViewMain324()
                .ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 18) {
                    if let rrData = rrActivity.rrImageData,
                       let rrImage = UIImage(data: rrData) {
                        Image(uiImage: rrImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 210)
                            .frame(maxWidth: .infinity)
                            .clipShape(RoundedRectangle(cornerRadius: 26))
                            .overlay(
                                RoundedRectangle(cornerRadius: 26)
                                    .stroke(RRColor.foamWhite.opacity(0.08), lineWidth: 1)
                            )
                    }

                    HStack(alignment: .center) {
                        ZStack {
                            Circle()
                                .fill(rrActivity.rrKind.rrAccent.opacity(0.16))
                                .frame(width: 60, height: 60)

                            Image(systemName: rrActivity.rrKind.rrSystemIcon)
                                .font(.system(size: 22, weight: .bold))
                                .foregroundStyle(rrActivity.rrKind.rrAccent)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text(rrActivity.rrTitle)
                                .font(.custom(RRFont.black, size: 24))
                                .foregroundStyle(RRColor.foamWhite)

                            Text(rrActivity.rrKind.rrTitle)
                                .font(.custom(RRFont.regular, size: 12))
                                .foregroundStyle(rrActivity.rrKind.rrAccent)
                        }

                        Spacer()
                    }

                    rrInfoRow(title: "Place", value: rrActivity.rrPlaceName)
                    rrInfoRow(title: "Date", value: rrActivity.rrDate.formatted(date: .abbreviated, time: .shortened))
                    rrInfoRow(title: "Coordinates", value: "\(String(format: "%.4f", rrActivity.rrLatitude)), \(String(format: "%.4f", rrActivity.rrLongitude))")

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notes")
                            .font(.custom(RRFont.regular, size: 12))
                            .foregroundStyle(RRColor.foamMist.opacity(0.45))

                        Text(rrActivity.rrNote.isEmpty ? "No notes added." : rrActivity.rrNote)
                            .font(.custom(RRFont.regular, size: 14))
                            .foregroundStyle(RRColor.foamWhite)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(.ultraThinMaterial)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(RRColor.foamWhite.opacity(0.08), lineWidth: 1)
                                    )
                            )
                    }

                    HStack(spacing: 12) {
                        Button {
                            RRHapticsManager.rrLight()
                            RRSoundManager.rrTap()
                            rrDeleteAction()
                            rrDismiss()
                        } label: {
                            Text("Delete")
                                .font(.custom(RRFont.semiBold, size: 15))
                                .foregroundStyle(RRColor.foamWhite)
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .background(
                                    Capsule()
                                        .fill(Color.red.opacity(0.18))
                                )
                        }
                        .buttonStyle(RRGameCardButtonStyle())

                        Button {
                            RRHapticsManager.rrLight()
                            RRSoundManager.rrTap()
                            rrDismiss()
                        } label: {
                            Text("Done")
                                .font(.custom(RRFont.semiBold, size: 15))
                                .foregroundStyle(RRColor.riverDeep)
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .background(
                                    Capsule()
                                        .fill(
                                            LinearGradient(
                                                colors: [RRColor.boltGold, RRColor.boltSunrise],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                )
                        }
                        .buttonStyle(RRGameCardButtonStyle())
                    }

                    Spacer().frame(height: 20)
                }
                .padding(.horizontal, 20)
            }
        }
    }

    private func rrInfoRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.custom(RRFont.regular, size: 12))
                .foregroundStyle(RRColor.foamMist.opacity(0.45))

            Spacer()

            Text(value)
                .font(.custom(RRFont.semiBold, size: 13))
                .foregroundStyle(RRColor.foamWhite)
                .multilineTextAlignment(.trailing)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(RRColor.foamWhite.opacity(0.08), lineWidth: 1)
                )
        )
    }
}

struct RRDeniedCameraOverlay: View {
    let rrOpenSettings: () -> Void
    let rrDismiss: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.45)
                .ignoresSafeArea()

            VStack(spacing: 18) {
                ZStack {
                    Circle()
                        .fill(Color.red.opacity(0.16))
                        .frame(width: 84, height: 84)

                    Image(systemName: "camera.fill")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundStyle(Color.red.opacity(0.9))
                }

                Text("Camera Access Needed")
                    .font(.custom(RRFont.black, size: 15))
                    .foregroundStyle(RRColor.foamWhite)

                Text("Camera permission is turned off. Open Settings and allow camera access to capture an activity photo.")
                    .font(.custom(RRFont.regular, size: 13))
                    .foregroundStyle(RRColor.foamMist.opacity(0.82))
                    .multilineTextAlignment(.center)

                HStack(spacing: 12) {
                    Button {
                        rrDismiss()
                    } label: {
                        Text("Not Now")
                            .font(.custom(RRFont.semiBold, size: 15))
                            .foregroundStyle(RRColor.foamWhite)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(
                                Capsule()
                                    .fill(RRColor.foamWhite.opacity(0.08))
                                    .overlay(
                                        Capsule()
                                            .stroke(RRColor.foamWhite.opacity(0.08), lineWidth: 1)
                                    )
                            )
                    }
                    .buttonStyle(RRGameCardButtonStyle())

                    Button {
                        rrOpenSettings()
                    } label: {
                        Text("Open Settings")
                            .font(.custom(RRFont.semiBold, size: 15))
                            .foregroundStyle(RRColor.riverDeep)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(
                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            colors: [RRColor.boltGold, RRColor.boltSunrise],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                            )
                    }
                    .buttonStyle(RRGameCardButtonStyle())
                }
            }
            .padding(.horizontal, 22)
            .padding(.vertical, 26)
            .frame(maxWidth: 340)
            .background(
                RoundedRectangle(cornerRadius: 28)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 28)
                            .stroke(RRColor.boltGold.opacity(0.18), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 20)
        }
        .transition(.opacity.combined(with: .scale(scale: 0.96)))
    }
}
