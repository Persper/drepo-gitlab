import EventEmitterError from './event_emitter_error';

export default class EventEmitter {
  constructor() {
    this.listeners = {};
  }

  emit(type, detail) {
    EventEmitter.validateListenerArguments(type, null, { enforceCallback: false });

    const listeners = this.listeners[type];
    if (!EventEmitter.hasListenersOfType(listeners)) return;

    const event = new CustomEvent(type, { detail });

    listeners.forEach(listener => EventEmitter.emitToListener(this, event, listener));
  }

  on(type, callback, options = {}) {
    EventEmitter.validateListenerArguments(type, callback, { enforceCallback: true });
    if (!EventEmitter.hasListenersOfType(this.listeners[type])) this.listeners[type] = [];

    this.listeners[type].push({
      callback,
      options,
    });
  }

  once(type, callback, options = {}) {
    EventEmitter.validateListenerArguments(type, callback);

    const onceOptions = Object.assign(options, { once: true });

    this.on(type, callback, onceOptions);
  }

  off(type, callback) {
    EventEmitter.validateListenerArguments(type, callback);

    const listeners = this.listeners[type];
    if (!EventEmitter.hasListenersOfType(listeners)) return;

    if (callback) {
      EventEmitter.removeMatchingListeners(listeners, callback);
    } else {
      delete this.listeners[type];
    }
  }

  // Static methods are used to avoid prototype clutter when inheriting from EventEmitter

  static emitToListener(eventEmitter, event, { callback, options }) {
    callback(event);

    if (options.once) eventEmitter.off(event.type);
  }

  static hasListenersOfType(listeners = []) {
    return listeners.length > 0;
  }

  static removeMatchingListeners(listeners = [], callback) {
    EventEmitter.findMatchingListenerIndexes(listeners, callback).forEach(listenerIndex =>
      listeners.splice(listenerIndex, 1),
    );
  }

  static findMatchingListenerIndexes(listeners = [], callback) {
    return listeners.reduce((accumulator, listener, index) => {
      if (listener.callback.name !== callback.name) return accumulator;

      accumulator.push(index);

      return accumulator;
    }, []);
  }

  static validateListenerArguments(type, callback, validationOptions = {}) {
    const { enforceCallback } = validationOptions;

    if (!type) throw new EventEmitterError('no event type provided');
    if (enforceCallback !== false)
      EventEmitter.validateListenerCallback(callback, validationOptions);
  }

  static validateListenerCallback(callback, validationOptions) {
    const { enforceCallback } = validationOptions;

    const hasEnforcedCallback = enforceCallback === true && !callback;
    const isCallbackFunction = !(callback instanceof Function);

    if (hasEnforcedCallback && isCallbackFunction)
      throw new EventEmitterError('event callback is not a function');
  }
}
