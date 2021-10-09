

import WireDataModel


extension Analytics {

    @objc(tagStorableEvent:) public func tag(_ storableEvent: StorableTrackingEvent) {
        tagEvent(storableEvent.name, attributes: storableEvent.attributes)
    }

}
