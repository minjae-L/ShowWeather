//
//  RxCocoaExtension.swift
//  showWeather
//
//  Created by 이민재 on 7/15/24.
//

import Foundation
import RxSwift
import RxCocoa
import MapKit

// MARK: MKLocalSearchCompleter Reactive Extension
extension MKLocalSearchCompleter: HasDelegate {
    public typealias Delegate = MKLocalSearchCompleterDelegate
}

class RxMKLocalSearchCompleterDelegateProxy: DelegateProxy<MKLocalSearchCompleter, MKLocalSearchCompleterDelegate>, DelegateProxyType, MKLocalSearchCompleterDelegate {
    public weak private(set) var localSearchCompleter: MKLocalSearchCompleter?
    
    public init(localSearchCompleter: ParentObject) {
        self.localSearchCompleter = localSearchCompleter
        super.init(parentObject: localSearchCompleter,
                   delegateProxy: RxMKLocalSearchCompleterDelegateProxy.self)
    }
    static func registerKnownImplementations() {
        self.register { RxMKLocalSearchCompleterDelegateProxy(localSearchCompleter: $0)}
    }
    
}
extension Reactive where Base: MKLocalSearchCompleter {
    
    func castOrThrow<T>(_ resultType: T.Type, _ object: Any) throws -> T {
        guard let returnValue = object as? T else {
            throw RxCocoaError.castingError(object: object, targetType: resultType)
        }
        return returnValue
    }
    public var delegate: DelegateProxy<MKLocalSearchCompleter, MKLocalSearchCompleterDelegate> {
        return RxMKLocalSearchCompleterDelegateProxy.proxy(for: base)
    }
    
    public var didUpdateResults: ControlEvent<MKLocalSearchCompleter> {
        let source = delegate
            .methodInvoked(#selector(MKLocalSearchCompleterDelegate.completerDidUpdateResults(_:)))
            .map { a in
                return try castOrThrow(MKLocalSearchCompleter.self, a[0])
            }
        return ControlEvent(events: source)
    }
}


// MARK: UISearchResultUpdating Reactive Extenstion
extension Reactive where Base: UISearchController {
    
    var delegate: DelegateProxy<UISearchController, UISearchResultsUpdating> {
        return RxSearchResultsUpdatingProxy.proxy(for: base)
    }
    
    var searchPhrase: Observable<String> {
        return RxSearchResultsUpdatingProxy.proxy(for: base).searchPhraseSubject.asObservable()
    }
}

class RxSearchResultsUpdatingProxy: DelegateProxy<UISearchController, UISearchResultsUpdating>,DelegateProxyType, UISearchResultsUpdating {
    
    // DelegateProxyType
    static func registerKnownImplementations() {
        register { RxSearchResultsUpdatingProxy(searchController: $0) }
    }
    static func currentDelegate(for object: UISearchController) -> UISearchResultsUpdating? {
        return object.searchResultsUpdater
    }
    static func setCurrentDelegate(_ delegate: UISearchResultsUpdating?, to object: UISearchController) {
        object.searchResultsUpdater = delegate
    }
    
    
    lazy var searchPhraseSubject = PublishSubject<String>()
    
    init(searchController: UISearchController) {
        super.init(parentObject: searchController, delegateProxy: RxSearchResultsUpdatingProxy.self)
    }
    
    // UISearchResultsUpdating
    func updateSearchResults(for searchController: UISearchController) {
        searchPhraseSubject.onNext(searchController.searchBar.text ?? "")
    }
    
}
