//
//  AnyRouter.swift
//  XCoordinator
//
//  Created by Paul Kraft on 28.07.18.
//  Copyright © 2018 QuickBird Studios. All rights reserved.
//

///
/// AnyRouter is a type-erasure of a given Router object and, therefore, can be used as an abstraction from a specific Router
/// implementation without losing type information about its RouteType.
///
/// This type abstraction can be especially helpful when injecting routers into viewModels.
/// AnyRouter abstracts away any implementation specific details and
/// essentially reduces them to properties specified in the `Router` protocol.
///
public final class AnyRouter<RouteType: Route>: Router {

    // MARK: - Stored properties

    private let _contextTrigger: (RouteType, TransitionOptions, ContextPresentationHandler?) -> Void
    private let _trigger: (RouteType, TransitionOptions, PresentationHandler?) -> Void
    private let _presented: (Presentable?) -> Void
    private let _viewController: () -> UIViewController?
    private let _setRoot: (UIWindow) -> Void

    // MARK: - Initialization

    ///
    /// Creates an AnyRouter object from a given router.
    ///
    /// - Parameter router:
    ///     The source router.
    ///
    public init<T: Router>(_ router: T) where T.RouteType == RouteType, T: AnyObject {
        _trigger = { [weak router] in
            guard let router = router else { fatalError("AnyRouter does not increase reference count.") }
            return router.trigger($0, with: $1, completion: $2)
        }
        _presented = { [weak router] in
            guard let router = router else { fatalError("AnyRouter does not increase reference count.") }
            return router.presented(from: $0)
        }
        _viewController = { [weak router] in
            guard let router = router else { fatalError("AnyRouter does not increase reference count.") }
            return router.viewController
        }
        _setRoot = { [weak router] in
            guard let router = router else { fatalError("AnyRouter does not increase reference count.") }
            return router.setRoot(for: $0)
        }
        _contextTrigger = { [weak router] in
            guard let router = router else { fatalError("AnyRouter does not increase reference count.") }
            return router.contextTrigger($0, with: $1, completion: $2)
        }
    }

    // MARK: - Public methods

    ///
    /// Triggers routes and provides the transition context in the completion-handler.
    ///
    /// Useful for deep linking. It is encouraged to use `trigger` instead, if the context is not needed.
    ///
    /// - Parameters:
    ///     - route: The route to be triggered.
    ///     - options: Transition options configuring the execution of transitions, e.g. whether it should be animated.
    ///     - completion:
    ///         If present, this completion handler is executed once the transition is completed
    ///         (including animations).
    ///         If the context is not needed, use `trigger` instead.
    ///
    public func contextTrigger(_ route: RouteType,
                               with options: TransitionOptions,
                               completion: ContextPresentationHandler?) {
        _contextTrigger(route, options, completion)
    }

    ///
    /// Triggers the specified route by performing a transition.
    ///
    /// - Parameters:
    ///     - route: The route to be triggered.
    ///     - options: Transition options for performing the transition, e.g. whether it should be animated.
    ///     - completion:
    ///         If present, this completion handler is executed once the transition is completed
    ///         (including animations).
    ///
    public func trigger(_ route: RouteType, with options: TransitionOptions, completion: PresentationHandler?) {
        _trigger(route, options, completion)
    }

    ///
    /// This method is called whenever a Presentable is shown to the user.
    /// It further provides information about the presentable responsible for the presenting.
    ///
    /// - Parameter presentable:
    ///     The context in which the presentable is shown.
    ///     This could be a window, another viewController, a coordinator, etc.
    ///     `nil` is specified whenever a context cannot be easily determined.
    ///
    public func presented(from presentable: Presentable?) {
        _presented(presentable)
    }

    ///
    /// The viewController of the Presentable.
    ///
    /// In the case of a `UIViewController`, it returns itself.
    /// A coordinator returns its rootViewController.
    ///
    public var viewController: UIViewController! {
        return _viewController()
    }
}
