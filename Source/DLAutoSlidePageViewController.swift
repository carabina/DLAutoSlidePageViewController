//
//  DLAutoSlidePageViewController.swift
//  DLAutoSlidePageViewController
//
//  Created by Alonso on 10/16/17.
//  Copyright © 2017 Alonso. All rights reserved.
//

import UIKit

public class DLAutoSlidePageViewController: UIPageViewController {

  private(set) var pages: [UIViewController] = []
  
  fileprivate var currentPageIndex: Int = 0
  fileprivate var nextPageIndex: Int = 0
  fileprivate var timer: Timer?
  fileprivate var timeInterval: TimeInterval = 0.0
  
  public var pageControl: UIPageControl? {
    return UIPageControl.appearance(whenContainedInInstancesOf: [UIPageViewController.self])
  }
  
  // MARK: - Lifecycle
  
  override public func viewDidLoad() {
    super.viewDidLoad()
    delegate = self
    dataSource = self
  }
  
  override public func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  override public func viewWillDisappear(_ animated: Bool) {
    stopTimer()
  }
  
  public convenience init(pages: [UIViewController], timeInterval ti: TimeInterval = 5.0, interPageSpacing: Float = 0.0) {
    self.init(transitionStyle: .scroll,
              navigationOrientation: .horizontal,
              options: [UIPageViewControllerOptionInterPageSpacingKey: interPageSpacing])
    self.pages = pages
    self.timeInterval = ti
    setupPageView()
    setupPageControl()
  }
  
  // MARK: - Private
  
  fileprivate func setupPageView() {
    currentPageIndex = 0
    setViewControllers([pages.first!], direction: .forward, animated: true, completion: nil)
  }
  
  fileprivate func setupPageControl() {
    setupPageTimer()
    pageControl?.currentPageIndicatorTintColor = UIColor.lightGray
    pageControl?.pageIndicatorTintColor = UIColor.gray
    pageControl?.backgroundColor = UIColor.clear
  }
  
  fileprivate func viewControllerAtIndex(_ index: Int) -> UIViewController {
    currentPageIndex = index
    return pages[index]
  }
  
  fileprivate func setupPageTimer() {
    timer = Timer.scheduledTimer(timeInterval: timeInterval,
                                 target: self,
                                 selector: #selector(changePage),
                                 userInfo: nil,
                                 repeats: true)
  }
  
  fileprivate func stopTimer() {
    guard let _ = timer as Timer? else { return }
    timer?.invalidate()
    timer = nil
  }
  
  fileprivate func restartTimer() {
    stopTimer()
    setupPageTimer()
  }
  
  @objc fileprivate func changePage() {
    if currentPageIndex < pages.count - 1 {
      currentPageIndex += 1
    } else {
      currentPageIndex = 0
    }
    guard let viewController = viewControllerAtIndex(currentPageIndex) as UIViewController? else { return }
    setViewControllers([viewController], direction: .forward, animated: true, completion: nil)
  }
  
}

// MARK: - UIPageViewControllerDelegate

extension DLAutoSlidePageViewController: UIPageViewControllerDelegate {
  
  public func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
    guard let viewController = pendingViewControllers.first as UIViewController?, let index = pages.index(of: viewController) as Int? else {
      return
    }
    nextPageIndex = index
  }
  
  public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
    if completed {
      currentPageIndex = nextPageIndex
    }
    nextPageIndex = 0
  }
  
}

// MARK: - UIPageViewControllerDataSource

extension DLAutoSlidePageViewController: UIPageViewControllerDataSource {
  
  public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
    restartTimer()
    guard var currentIndex = pages.index(of: viewController) as Int? else { return nil }
    if currentIndex > 0 {
      currentIndex = (currentIndex - 1) % pages.count
      return pages[currentIndex]
    } else {
      return nil
    }
  }
  
  public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
    restartTimer()
    guard var currentIndex = pages.index(of: viewController) as Int? else { return nil }
    if currentIndex < pages.count - 1 {
      currentIndex = (currentIndex + 1) % pages.count
      return pages[currentIndex]
    } else {
      return nil
    }
  }
  
  public func presentationCount(for pageViewController: UIPageViewController) -> Int {
    return pages.count
  }
  
  public func presentationIndex(for pageViewController: UIPageViewController) -> Int {
    return currentPageIndex
  }

}
