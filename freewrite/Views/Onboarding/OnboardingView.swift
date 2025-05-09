import SwiftUI
import UIKit // for UIPageControl styling and haptics

// MARK: — data structure for onboarding screens
typealias DetailPoints = [String]

struct OnboardingPage: Identifiable {
    let id = UUID()
    var imageName: String? = nil // Optional illustration
    let title: String
    let subtitle: String
    let detailPoints: DetailPoints? // For bullet lists
    let isLastPage: Bool     // show final CTA
    let showOnlyButton: Bool // hide arrow hint only
    let isFirstPage: Bool    // initial page tap hint

    static let pages: [OnboardingPage] = [
        OnboardingPage(
            imageName: "Raccoon_Onboarding",
            title: "Hey, welcome to your dumpster! 👋",
            subtitle: "This is your freewrite zone. Type it, don't tidy it. Let Scribbles the raccoon sort the note later.",
            detailPoints: nil,
            isLastPage: false,
            showOnlyButton: false,
            isFirstPage: true
        ),
        OnboardingPage(
            imageName: "Raccoon_Thinking",
            title: "Why even bother dumping? 🤔",
            subtitle: "Unlock these cool perks:",
            detailPoints: [
                "Instant Mental Declutter: Empty your mind's cache.",
                "Idea-Spark Machine: Discover new ideas and epiphanies.",
                "Feelings Dump: Calm the chaos and find more chill."
            ],
            isLastPage: false,
            showOnlyButton: false,
            isFirstPage: false
        ),
        OnboardingPage(
            imageName: "Raccoon_Entry_Toss",
            title: "Unlock Your Dumpster's Potential ✨",
            subtitle: "A few of Scribbles' special tools:",
            detailPoints: [
                "Dumpster Dive: Stuck? Tap 'Dumpster Dive' while writing for a nudge.",
                "Snapshots: Add a photo to your mood check-in.",
                "Customize: Change themes & fonts in 'Display'.",
                "History: Revisit past dumps & insights."
            ],
            isLastPage: false,
            showOnlyButton: false,
            isFirstPage: false
        ),
        OnboardingPage(
            imageName: "RaccoonWaving",
            title: "Ready to Lighten Your Load?",
            subtitle: "Your dumpster awaits!",
            detailPoints: nil,
            isLastPage: true,
            showOnlyButton: true,
            isFirstPage: false
        )
    ]
}

// MARK: — container view with page control & skip
struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding = false
    @Binding var showSplash: Bool
    @State private var currentPage = 0

    init(showSplash: Binding<Bool>) { self._showSplash = showSplash }

    var body: some View {
        ZStack {
            TabView(selection: $currentPage) {
                ForEach(Array(OnboardingPage.pages.enumerated()), id: \.offset) { idx, page in
                    OnboardingPageView(
                        page: page,
                        currentPage: $currentPage,
                        pageCount: OnboardingPage.pages.count,
                        showSplash: $showSplash,
                        hasCompleted: $hasCompletedOnboarding
                    )
                    .tag(idx)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .background(BrandColors.cream.ignoresSafeArea())
            .onAppear {
                UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(BrandColors.accentPink)
                UIPageControl.appearance().pageIndicatorTintColor = UIColor(BrandColors.defaultDarkBrown.opacity(0.3))
            }

            // single Skip
            if currentPage < OnboardingPage.pages.count - 1 {
                Button("Skip") {
                    hasCompletedOnboarding = true
                    showSplash = false
                }
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(BrandColors.defaultDarkBrown)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(BrandColors.cream.opacity(0.8))
                .clipShape(Capsule())
                .padding(.trailing, 20)
                .padding(.bottom, 30)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .animation(.easeInOut, value: currentPage)
            }
        }
    }
}

// MARK: — single page view
struct OnboardingPageView: View {
    let page: OnboardingPage
    @Binding var currentPage: Int
    let pageCount: Int
    @Binding var showSplash: Bool
    @Binding var hasCompleted: Bool
    @State private var showBullets = false

    var body: some View {
        let fontSize: CGFloat = page.isLastPage ? 18 : 16
        let bulletIcons = ["brain.head.profile", "sparkles", "face.smiling"]

        VStack(spacing: 20) {
            Spacer()

            // illustration
            if let img = page.imageName {
                Image(img)
                    .resizable()
                    .scaledToFit()
                    .frame(height: page.isLastPage ? 180 : 130)
                    .padding(.bottom, page.isLastPage ? 20 : 15)
            }

            // title
            Text(page.title)
                .font(.custom("Georgia-Bold", size: page.isLastPage ? 30 : 26))
                .foregroundColor(BrandColors.defaultDarkBrown)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)

            // subtitle
            Text(page.subtitle)
                .font(.system(size: fontSize, weight: .light))
                .foregroundColor(BrandColors.secondaryText(for: "light"))
                .multilineTextAlignment(.center)
                .padding(.horizontal, page.isLastPage ? 35 : 30)
                .lineSpacing(4)
                .padding(.bottom, page.isLastPage ? 30 : 10)

            // detail bullets
            if let pts = page.detailPoints, !pts.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(Array(pts.enumerated()), id: \.offset) { idx, text in
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: bulletIcons.indices.contains(idx)
                                  ? bulletIcons[idx] : "circle.fill")
                                .font(.system(size: fontSize, weight: .light))
                                .foregroundColor(BrandColors.accentPink)
                            Text(text)
                                .font(.system(size: fontSize, weight: .light))
                                .foregroundColor(BrandColors.defaultDarkBrown.opacity(0.9))
                                .lineSpacing(4)
                            Spacer()
                        }
                        .opacity(showBullets ? 1 : 0)
                        .animation(.easeIn.delay(Double(idx) * 0.1), value: showBullets)
                    }
                }
                .padding(.horizontal, 35)
                .onAppear {
                    showBullets = false
                    DispatchQueue.main.async { showBullets = true }
                }
            }

            Spacer()

            // arrow on every non-last page
            if !page.isLastPage {
                Button {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    withAnimation { currentPage = min(currentPage+1, pageCount-1) }
                } label: {
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.system(size: 36))
                        .foregroundColor(BrandColors.defaultDarkBrown.opacity(0.7))
                        .padding()
                        .background(Circle().fill(Color.white.opacity(0.2)))
                }
                .padding(.bottom, 10)
                .transition(.scale.combined(with: .opacity))

                Spacer().frame(height: 60)

            } else {
                // final page has CTA
                Button("Start Dumping!") {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    hasCompleted = true
                    showSplash = false
                }
                .font(.system(.headline, design: .default).weight(.semibold))
                .foregroundColor(BrandColors.primaryText(for: "light"))
                .padding(.vertical, 18)
                .frame(maxWidth: .infinity)
                .background(BrandColors.accentPink)
                .cornerRadius(25)
                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                .padding(.horizontal, 50)
                .padding(.bottom, 20)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .padding(.bottom, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#if DEBUG
struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(showSplash: .constant(true))
            .environmentObject(ContentViewModel())
    }
}
#endif
