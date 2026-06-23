import SwiftUI
import PhotosUI
import MapKit

struct RRCreateActivityScreen: View {
    @Environment(\.dismiss) private var rrDismiss
    @StateObject private var rrVm = RRActivityMapViewModel2()

    var body: some View {
        ZStack {
            rrBackgroundViewMain324()
                .ignoresSafeArea()

            rrCreateAmbientDecor

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 18) {
                    rrTopBar
                    rrHeroCard
                    rrLiveLocationCard
                    rrTitleSection
                    rrPlaceSection
                    rrNoteSection
                    rrTypeSection
                    rrPhotoSection
                    rrBottomActions
                    Spacer().frame(height: 34)
                }
                .padding(.horizontal, 20)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            rrVm.rrPrepareNewDraft()
        }
        .confirmationDialog("Choose Image Source", isPresented: $rrVm.rrShowImageSourceDialog, titleVisibility: .visible) {
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                Button("Open Camera") {
                    RRPermissions.rrCheckCamera { granted in
                        if granted {
                            rrVm.rrShowCameraPicker = true
                        } else {
                            rrVm.rrDeniedKind = .camera
                            rrVm.rrShowSettingsAlert = true
                        }
                    }
                }
            }

            Button("Open Gallery") {
                RRPermissions.rrCheckGallery { granted in
                    if granted {
                        rrVm.rrShowGalleryPicker = true
                    } else {
                        rrVm.rrDeniedKind = .gallery
                        rrVm.rrShowSettingsAlert = true
                    }
                }
            }

            Button("Cancel", role: .cancel) { }
        }
        .alert("Permission needed", isPresented: $rrVm.rrShowSettingsAlert) {
            Button("Open Settings") { RRPermissions.rrOpenSettings() }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text(rrVm.rrDeniedMessage)
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

    private var rrCreateAmbientDecor: some View {
        ZStack {
            VStack {
                Circle()
                    .fill(RRColor.boltGold.opacity(0.13))
                    .frame(width: 240, height: 240)
                    .blur(radius: 55)
                    .offset(x: 120, y: -30)
                Spacer()
            }

            VStack {
                Spacer()
                Circle()
                    .fill(RRColor.seaGreen.opacity(0.12))
                    .frame(width: 220, height: 220)
                    .blur(radius: 55)
                    .offset(x: -110, y: 70)
            }
        }
        .ignoresSafeArea()
    }

    private var rrTopBar: some View {
        HStack {
            Button {
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
                Text("Create Activity")
                    .font(.custom(RRFont.black, size: 23))
                    .foregroundStyle(RRColor.foamWhite)

                Text("Save a new memory on your map")
                    .font(.custom(RRFont.regular, size: 11))
                    .foregroundStyle(RRColor.foamMist.opacity(0.45))
                    .tracking(1.1)
            }

            Spacer()

            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 46, height: 46)

                Image("game-key")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 22, height: 22)
            }
        }
        .padding(.top, UIScreen.main.bounds.height * 0.07)
    }

    private var rrHeroCard: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(rrVm.rrDraftKind.rrAccent.opacity(0.14))
                    .frame(width: 76, height: 76)

                Image(systemName: rrVm.rrDraftKind.rrSystemIcon)
                    .font(.system(size: 30, weight: .bold))
                    .foregroundStyle(rrVm.rrDraftKind.rrAccent)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(rrVm.rrDraftTitle.isEmpty ? "Untitled Activity" : rrVm.rrDraftTitle)
                    .font(.custom(RRFont.black, size: 22))
                    .foregroundStyle(RRColor.foamWhite)
                    .lineLimit(1)

                Text(rrVm.rrDraftKind.rrTitle)
                    .font(.custom(RRFont.semiBold, size: 12))
                    .foregroundStyle(rrVm.rrDraftKind.rrAccent)

                Text(rrVm.rrDraftPlaceName.isEmpty ? "Pinned at current map center" : rrVm.rrDraftPlaceName)
                    .font(.custom(RRFont.regular, size: 11))
                    .foregroundStyle(RRColor.foamMist.opacity(0.45))
                    .lineLimit(1)
            }

            Spacer()
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 28)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    rrVm.rrDraftKind.rrAccent.opacity(0.22),
                                    RRColor.foamWhite.opacity(0.08)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
    }

    private var rrLiveLocationCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Map Position")
                    .font(.custom(RRFont.semiBold, size: 16))
                    .foregroundStyle(RRColor.foamWhite)

                Spacer()

                Text("Live center point")
                    .font(.custom(RRFont.regular, size: 10))
                    .foregroundStyle(RRColor.boltGold)
            }

            HStack(spacing: 12) {
                rrSmallMetric(
                    title: "Latitude",
                    value: String(format: "%.4f", rrVm.rrCenterCoordinate.latitude)
                )
                rrSmallMetric(
                    title: "Longitude",
                    value: String(format: "%.4f", rrVm.rrCenterCoordinate.longitude)
                )
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(RRColor.foamWhite.opacity(0.08), lineWidth: 1)
                )
        )
    }

    private func rrSmallMetric(title: String, value: String) -> some View {
        VStack(spacing: 6) {
            Text(title)
                .font(.custom(RRFont.regular, size: 10))
                .foregroundStyle(RRColor.foamMist.opacity(0.45))

            Text(value)
                .font(.custom(RRFont.semiBold, size: 13))
                .foregroundStyle(RRColor.foamWhite)
                .monospacedDigit()
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(RRColor.foamWhite.opacity(0.05))
        )
    }

    private var rrTitleSection: some View {
        rrFieldCard(
            rrTitle: "Activity Title",
            rrPlaceholder: "Morning Run",
            rrText: $rrVm.rrDraftTitle
        )
    }

    private var rrPlaceSection: some View {
        rrFieldCard(
            rrTitle: "Place Name",
            rrPlaceholder: "Beach line, city park, home desk",
            rrText: $rrVm.rrDraftPlaceName
        )
    }

    private var rrNoteSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Notes")
                .font(.custom(RRFont.regular, size: 12))
                .foregroundStyle(RRColor.foamMist.opacity(0.45))

            TextField("Write a short note", text: $rrVm.rrDraftNote, axis: .vertical)
                .lineLimit(4, reservesSpace: true)
                .font(.custom(RRFont.regular, size: 15))
                .foregroundStyle(RRColor.foamWhite)
                .padding(16)
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

    private func rrFieldCard(rrTitle: String, rrPlaceholder: String, rrText: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(rrTitle)
                .font(.custom(RRFont.regular, size: 12))
                .foregroundStyle(RRColor.foamMist.opacity(0.45))

            TextField(rrPlaceholder, text: rrText)
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

    private var rrTypeSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Activity Kind")
                .font(.custom(RRFont.regular, size: 12))
                .foregroundStyle(RRColor.foamMist.opacity(0.45))

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(RRActivityKind.allCases, id: \.self) { rrKind in
                        Button {
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

    private var rrPhotoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Activity Photo")
                .font(.custom(RRFont.regular, size: 12))
                .foregroundStyle(RRColor.foamMist.opacity(0.45))

            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(RRColor.foamWhite.opacity(0.08), lineWidth: 1)
                    )
                    .frame(height: 210)

                if let rrImage = rrVm.rrDraftImage {
                    Image(uiImage: rrImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 210)
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                } else {
                    VStack(spacing: 10) {
                        ZStack {
                            Circle()
                                .fill(RRColor.boltGold.opacity(0.14))
                                .frame(width: 58, height: 58)

                            Image(systemName: "camera.fill")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundStyle(RRColor.boltGold)
                        }

                        Text("Add camera or gallery image")
                            .font(.custom(RRFont.regular, size: 12))
                            .foregroundStyle(RRColor.foamMist.opacity(0.45))
                    }
                }
            }

            HStack(spacing: 12) {
                Button {
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

    private var rrBottomActions: some View {
        VStack(spacing: 12) {
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
                .shadow(color: RRColor.boltGold.opacity(0.35), radius: 14, x: 0, y: 6)
            }
            .buttonStyle(RRGameCardButtonStyle())
            .disabled(!rrVm.rrCanSaveDraft)
            .opacity(rrVm.rrCanSaveDraft ? 1 : 0.72)

            Text("Saved activities appear on your Activity Map")
                .font(.custom(RRFont.regular, size: 12))
                .foregroundStyle(RRColor.foamMist.opacity(0.45))
        }
    }
}

struct RRStoryGameView: View {
    @Environment(\.dismiss) private var rrDismiss
    @ObservedObject var rrStats: RRStatsModel
    @StateObject private var rrVm = RRStoryGameViewModel()

    var body: some View {
        ZStack {
            rrBackgroundViewMain324()
                .ignoresSafeArea()

            rrStoryGlow

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 18) {
                    rrTopBar
                    rrHeroProgress
                    rrSceneCard
                    rrTraitsBoard
                    rrChoicesSection
                    rrJourneyLog
                    Spacer().frame(height: 30)
                }
                .padding(.horizontal, 20)
            }
        }
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $rrVm.rrShowEnding) {
            RRStoryEndingScreen(rrVm: rrVm, rrDismiss: rrDismiss)
        }
    }

    private var rrStoryGlow: some View {
        VStack {
            Circle()
                .fill(rrVm.rrCurrentNode.rrThemeColor.opacity(0.14))
                .frame(width: 240, height: 240)
                .blur(radius: 50)
                .offset(x: 110, y: -40)
            Spacer()
        }
        .ignoresSafeArea()
    }

    private var rrTopBar: some View {
        HStack {
            Button {
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
                Text("Story Mode")
                    .font(.custom(RRFont.black, size: 24))
                    .foregroundStyle(RRColor.foamWhite)

                Text(rrVm.rrHasCompletedStory ? "Completed once" : "Treasure route active")
                    .font(.custom(RRFont.regular, size: 11))
                    .foregroundStyle(RRColor.foamMist.opacity(0.45))
            }

            Spacer()

            Image("game-key")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 26, height: 26)
                .padding(10)
                .background(
                    Circle()
                        .fill(.ultraThinMaterial)
                )
        }
        .padding(.top, UIScreen.main.bounds.height * 0.07)
    }

    private var rrHeroProgress: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Island of Trials")
                        .font(.custom(RRFont.black, size: 24))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [RRColor.foamWhite, RRColor.boltSunrise],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    Text("Make choices, shape the ending, unlock rare rewards.")
                        .font(.custom(RRFont.regular, size: 12))
                        .foregroundStyle(RRColor.foamMist.opacity(0.52))
                }

                Spacer()

                Image("closed-golden-padlock")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 64, height: 64)
            }

            VStack(spacing: 8) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(RRColor.foamWhite.opacity(0.08))

                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [RRColor.boltGold, RRColor.boltSunrise],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geo.size.width * max(0.1, rrVm.rrCompletionProgress))
                    }
                }
                .frame(height: 10)

                HStack {
                    Text(rrVm.rrCurrentNode.rrSubtitle)
                    Spacer()
                    Text(rrVm.rrHasCompletedStory ? "Unlocked ending" : "Route in progress")
                }
                .font(.custom(RRFont.regular, size: 11))
                .foregroundStyle(RRColor.foamMist.opacity(0.45))
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 28)
                        .stroke(RRColor.boltGold.opacity(0.16), lineWidth: 1)
                )
        )
    }

    private var rrSceneCard: some View {
        VStack(spacing: 14) {
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 28)
                    .fill(
                        LinearGradient(
                            colors: [
                                rrVm.rrCurrentNode.rrThemeColor.opacity(0.20),
                                RRColor.riverDeep.opacity(0.22)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 220)

                Image(rrVm.rrCurrentNode.rrImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 130, height: 130)
                    .padding(.top, 20)
                    .padding(.trailing, 20)

                VStack(alignment: .leading, spacing: 8) {
                    Spacer()

                    Text(rrVm.rrCurrentNode.rrTitle)
                        .font(.custom(RRFont.black, size: 26))
                        .foregroundStyle(RRColor.foamWhite)

                    Text(rrVm.rrCurrentNode.rrBody)
                        .font(.custom(RRFont.regular, size: 13))
                        .foregroundStyle(RRColor.foamMist.opacity(0.88))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                .padding(20)
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 28)
                .stroke(RRColor.foamWhite.opacity(0.08), lineWidth: 1)
        )
    }

    private var rrTraitsBoard: some View {
        HStack(spacing: 12) {
            rrTraitPill(title: "Trust", value: rrVm.rrTrust, accent: RRColor.seaGreen)
            rrTraitPill(title: "Courage", value: rrVm.rrCourage, accent: Color(red: 1.0, green: 0.45, blue: 0.2))
            rrTraitPill(title: "Wisdom", value: rrVm.rrWisdom, accent: RRColor.boltGold)
        }
    }

    private func rrTraitPill(title: String, value: Int, accent: Color) -> some View {
        VStack(spacing: 8) {
            Text("\(value)")
                .font(.custom(RRFont.black, size: 20))
                .foregroundStyle(RRColor.foamWhite)

            Text(title)
                .font(.custom(RRFont.regular, size: 10))
                .foregroundStyle(accent)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(accent.opacity(0.16), lineWidth: 1)
                )
        )
    }

    private var rrChoicesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Choose Your Path")
                .font(.custom(RRFont.semiBold, size: 18))
                .foregroundStyle(RRColor.foamWhite)

            ForEach(rrVm.rrCurrentNode.rrChoices) { rrChoice in
                Button {
                    rrVm.rrSelectChoice(rrChoice, rrStats: rrStats)
                } label: {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text(rrChoice.rrTitle)
                                .font(.custom(RRFont.semiBold, size: 15))
                                .foregroundStyle(RRColor.foamWhite)

                            Spacer()

                            Image(systemName: "chevron.right")
                                .foregroundStyle(RRColor.boltGold.opacity(0.75))
                        }

                        Text(rrChoice.rrSubtitle)
                            .font(.custom(RRFont.regular, size: 11))
                            .foregroundStyle(RRColor.foamMist.opacity(0.45))

                        rrChoiceRewardRow(rrChoice)
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 22)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 22)
                                    .stroke(RRColor.foamWhite.opacity(0.08), lineWidth: 1)
                            )
                    )
                }
                .buttonStyle(RRGameCardButtonStyle())
            }
        }
    }

    private func rrChoiceRewardRow(_ rrChoice: RRStoryChoiceModel) -> some View {
        HStack(spacing: 10) {
            switch rrChoice.rrReward {
            case .fire(let value):
                rrMiniReward(icon: "fireStats", value: value)
            case .pineapple(let value):
                rrMiniReward(icon: "pineappleStats", value: value)
            case .stars(let value):
                rrMiniReward(icon: "3d-star-icon", value: value)
            case .mixed(let fire, let pineapple, let stars):
                rrMiniReward(icon: "fireStats", value: fire)
                rrMiniReward(icon: "pineappleStats", value: pineapple)
                rrMiniReward(icon: "3d-star-icon", value: stars)
            }
        }
    }

    private func rrMiniReward(icon: String, value: Int) -> some View {
        HStack(spacing: 6) {
            Image(icon)
                .resizable()
                .frame(width: 18, height: 18)

            Text("+\(value)")
                .font(.custom(RRFont.semiBold, size: 12))
                .foregroundStyle(RRColor.foamWhite)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(RRColor.foamWhite.opacity(0.06))
        )
    }

    private var rrJourneyLog: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Journey Log")
                    .font(.custom(RRFont.semiBold, size: 18))
                    .foregroundStyle(RRColor.foamWhite)

                Spacer()

                Button {
                    rrVm.rrRestartStory()
                } label: {
                    Text("Restart")
                        .font(.custom(RRFont.regular, size: 12))
                        .foregroundStyle(RRColor.boltGold)
                }
            }

            if rrVm.rrStoryLogs.isEmpty {
                Text("No choices yet. Start your story above.")
                    .font(.custom(RRFont.regular, size: 12))
                    .foregroundStyle(RRColor.foamMist.opacity(0.45))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.ultraThinMaterial)
                    )
            } else {
                ForEach(rrVm.rrStoryLogs.prefix(3)) { rrLog in
                    HStack(spacing: 12) {
                        Image("runner_tab_image")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 34, height: 34)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(rrLog.rrTitle)
                                .font(.custom(RRFont.semiBold, size: 14))
                                .foregroundStyle(RRColor.foamWhite)

                            Text(rrLog.rrEffectText)
                                .font(.custom(RRFont.regular, size: 11))
                                .foregroundStyle(RRColor.foamMist.opacity(0.45))
                        }

                        Spacer()
                    }
                    .padding(14)
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
        }
    }
}

struct RRStoryEndingScreen: View {
    @ObservedObject var rrVm: RRStoryGameViewModel
    let rrDismiss: DismissAction

    var body: some View {
        ZStack {
            rrBackgroundViewMain324()
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Spacer()

                Image("3d-star-icon")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 90, height: 90)

                Text(rrVm.rrEndingTitle)
                    .font(.custom(RRFont.black, size: 28))
                    .foregroundStyle(RRColor.foamWhite)
                    .multilineTextAlignment(.center)

                Text(rrVm.rrEndingBody)
                    .font(.custom(RRFont.regular, size: 14))
                    .foregroundStyle(RRColor.foamMist.opacity(0.82))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 28)

                HStack(spacing: 12) {
                    rrEndingReward(icon: "fireStats", value: rrVm.rrFireEarned)
                    rrEndingReward(icon: "pineappleStats", value: rrVm.rrPineappleEarned)
                    rrEndingReward(icon: "3d-star-icon", value: rrVm.rrStarsEarned)
                }

                VStack(spacing: 12) {
                    Button {
                        rrVm.rrRestartStory()
                    } label: {
                        Text("Play Again")
                            .font(.custom(RRFont.semiBold, size: 16))
                            .foregroundStyle(RRColor.riverDeep)
                            .frame(width: 220, height: 54)
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
                        rrDismiss()
                    } label: {
                        Text("Back Home")
                            .font(.custom(RRFont.regular, size: 14))
                            .foregroundStyle(RRColor.foamMist.opacity(0.55))
                    }
                }

                Spacer()
            }
            .padding(.horizontal, 20)
        }
    }

    private func rrEndingReward(icon: String, value: Int) -> some View {
        VStack(spacing: 8) {
            Image(icon)
                .resizable()
                .frame(width: 28, height: 28)

            Text("\(value)")
                .font(.custom(RRFont.black, size: 18))
                .foregroundStyle(RRColor.foamWhite)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
        )
    }
}

enum RRMediaKind {
    case camera
    case gallery
}

enum RRPermissions {
    static func rrCheckCamera(_ completion: @escaping (Bool) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            completion(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async { completion(granted) }
            }
        default:
            completion(false)
        }
    }

    static func rrCheckGallery(_ completion: @escaping (Bool) -> Void) {
        switch PHPhotoLibrary.authorizationStatus(for: .readWrite) {
        case .authorized, .limited:
            completion(true)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                DispatchQueue.main.async {
                    completion(status == .authorized || status == .limited)
                }
            }
        default:
            completion(false)
        }
    }

    static func rrOpenSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}
