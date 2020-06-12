//
//  PageView.swift
//  ePills
//
//  Created by Javier Calatrava on 27/04/2020.
//  Copyright © 2020 Javier Calatrava. All rights reserved.
//

import SwiftUI

struct PageView<Page: View>: View {
    var viewControllers: [UIHostingController<Page>] = []

    @Binding var currentPage: Int
    init(_ views: [Page], currentPage: Binding<Int>) {
        self.viewControllers = views.map {
            let hostingController = UIHostingController(rootView: $0)
            hostingController.view.backgroundColor = UIColor.clear
            hostingController.view.isOpaque = false
            return hostingController
        }
        self._currentPage = currentPage
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            PageViewController(controllers: viewControllers, currentPage: $currentPage)
            if viewControllers.count > 1 {
                PageControl(numberOfPages: viewControllers.count, currentPage: $currentPage)
            }
        }
    }
}

struct PageViewController: UIViewControllerRepresentable {
    var controllers: [UIViewController]
    @Binding var currentPage: Int

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIPageViewController {
        let pageViewController = UIPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal)

        return pageViewController
    }

    func updateUIViewController(_ pageViewController: UIPageViewController, context: Context) {
        guard !self.controllers.isEmpty else { return }
        context.coordinator.parent.controllers = self.controllers
        let pageToRefresh = currentPage >= controllers.count ? 0 : currentPage

        pageViewController.dataSource = controllers.count > 1 ? context.coordinator : nil
        pageViewController.delegate = context.coordinator

        pageViewController.setViewControllers([controllers[pageToRefresh]],
                                              direction: .forward,
                                              animated: false)
    }

    class Coordinator: NSObject, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
        var parent: PageViewController

        init(_ pageViewController: PageViewController) {
            self.parent = pageViewController
        }

        func pageViewController(
            _ pageViewController: UIPageViewController,
            viewControllerBefore viewController: UIViewController) -> UIViewController? {
            guard parent.controllers.count > 1,
                let index = parent.controllers.firstIndex(of: viewController) else {
                    return nil
            }
            if index == 0 {
                return nil
            }
            return parent.controllers[index - 1]
        }

        func pageViewController(
            _ pageViewController: UIPageViewController,
            viewControllerAfter viewController: UIViewController) -> UIViewController? {
            guard parent.controllers.count > 1,
                let index = parent.controllers.firstIndex(of: viewController) else {
                    return nil
            }
            if index + 1 == parent.controllers.count {
                return nil//parent.controllers.first
            }
            return parent.controllers[index + 1]
        }

        func pageViewController(_ pageViewController: UIPageViewController,
                                didFinishAnimating finished: Bool,
                                previousViewControllers: [UIViewController],
                                transitionCompleted completed: Bool) {
            if completed,
                let visibleViewController = pageViewController.viewControllers?.first,
                let index = parent.controllers.firstIndex(of: visibleViewController) {
                parent.currentPage = index
            }
        }
    }
}

struct PageControl: UIViewRepresentable {
    var numberOfPages: Int
    @Binding var currentPage: Int

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    func makeUIView(context: Context) -> UIPageControl {
        let control = UIPageControl()
        control.numberOfPages = numberOfPages
        control.pageIndicatorTintColor = UIColor.lightGray
        control.currentPageIndicatorTintColor = UIColor.darkGray
        control.addTarget(
            context.coordinator,
            action: #selector(Coordinator.updateCurrentPage(sender:)),
            for: .valueChanged)

        return control
    }

    func updateUIView(_ uiView: UIPageControl, context: Context) {
        uiView.numberOfPages = numberOfPages
        uiView.currentPage = currentPage
    }

    class Coordinator: NSObject {
        var control: PageControl

        init(_ control: PageControl) {
            self.control = control
        }
        @objc
        func updateCurrentPage(sender: UIPageControl) {
            control.currentPage = sender.currentPage
        }
    }
}
