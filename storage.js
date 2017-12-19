{
    const LS = localStorage;
    const HAS = Object.prototype.hasOwnProperty;
    const STORAGE = Object.assign(Object.create(null), {
        getItem (k) { return LS.getItem(k); },
        hasItem (k) { return HAS.call(localStorage, k); },
        getLength () { return LS.length; },
        key (i) { return LS.key(Number(i)); },
        clear () { return LS.clear(); },
        dump () {  return Object.keys(LS).reduce(dump, {}); },
        setItem (k, v) { LS.setItem(k, v); return v; },
        removeItem (k) {
            var v = LS.getItem(k);
                    LS.removeItem(k);
            return v;
        }
    });

    function dump (acc, k) {
        acc[k] = LS.getItem(k);
        return acc;
    }

    function toArray (obj) {
        if (!HAS.call(obj, 'length')) obj.length = Object.keys(obj).length;
        return Array.apply(void 0, obj);
    }

    function notifyReady () {
        fetch('http://localstorage/localstorage', {
            "method": "POST",
            "body": JSON.stringify({
                type: 'LOCAL_STORAGE',
                meta: 'ready'
            })
        });
    }

    document.addEventListener("DOMContentLoaded", onReady);

    function onReady() {
        document.removeEventListener("DOMContentLoaded", onReady);

        window.addEventListener('message', function (evt) {
            if (!evt.data || event.data.type != "LOCAL_STORAGE") return;
            if (event.data.meta == 'ready') notifyReady();
            else if (HAS.call(STORAGE, event.data.meta)) {
                fetch('http://localstorage/localstorage',  {
                    "method": "POST",
                    "body": JSON.stringify({
                        type: 'LOCAL_STORAGE',
                        meta: 'sync-cb',
                        payload: STORAGE[event.data.meta].apply(
                            void 0,
                            toArray(event.data.payload || {})
                        )
                    })
                });
            }
        });

        notifyReady();
    }
}
