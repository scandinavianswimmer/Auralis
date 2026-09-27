// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Auralis contributors

import SwiftUI

/// A small page-level transition. Selection and input remain live throughout;
/// only the page envelope moves, never its sliders, meters or other controls.
struct NavigationPageStack<Selection: Hashable & Sendable, Content: View>: View {
    let selection: Selection
    @ViewBuilder var content: () -> Content
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        let animation = PanelMotion.navigation(reduceMotion: reduceMotion)
        NavigationPageLayout(selection: selection) {
            content()
                .transaction { $0.animation = nil }
                .id(selection)
                .transition(animation == nil ? .identity : .asymmetric(
                    insertion: .opacity.combined(with: .offset(y: 8)),
                    removal: .opacity.animation(.easeOut(duration: 0.10))))
                .layoutValue(key: NavigationPageIdentity<Selection>.self, value: selection)
        }
        .animation(animation, value: selection)
        .clipped()
    }
}

private struct NavigationPageIdentity<Selection: Hashable & Sendable>: LayoutValueKey {
    static var defaultValue: Selection? { nil }
}

/// The outgoing page may still be fading, but must not keep a short incoming
/// page tall or stack the two page heights inside the menu's AppKit scroll view.
private struct NavigationPageLayout<Selection: Hashable & Sendable>: Layout {
    let selection: Selection

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        subviews.first { $0[NavigationPageIdentity<Selection>.self] == selection }?
            .sizeThatFits(proposal) ?? .zero
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize,
                       subviews: Subviews, cache: inout ()) {
        for subview in subviews {
            subview.place(at: bounds.origin, anchor: .topLeading,
                          proposal: ProposedViewSize(width: bounds.width, height: proposal.height))
        }
    }
}
