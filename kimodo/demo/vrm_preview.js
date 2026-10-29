function installKimodoVrm(url) {
    if (window.__kimodoVrm) return;
    const origin = new URL(url).origin;
    const iframe = document.createElement('iframe');
    iframe.id = 'kimodo-vrm-preview';
    iframe.title = 'Kimodo VRoid motion preview';
    iframe.src = url;
    iframe.style.cssText = 'position:absolute;inset:0;width:100%;height:100%;border:0;z-index:1;display:none';
    const motions = new Map();
    let ready = false, enabled = false, currentFrame = 0;
    let keys = Promise.resolve();
    const post = data => iframe.contentWindow?.postMessage(data, origin);
    function mount() {
        const canvas = document.querySelector('canvas[data-engine]') || document.querySelector('canvas');
        if (!canvas) { setTimeout(mount, 100); return; }
        const holder = canvas.parentElement;
        holder.style.position = 'relative';
        holder.appendChild(iframe);
        const resize = () => {
            const rect = canvas.getBoundingClientRect();
            const timelineCanvas = [...document.querySelectorAll('canvas')].find(item => item !== canvas && item.parentElement.style.position === 'fixed');
            const bottom = timelineCanvas ? Math.min(rect.bottom, timelineCanvas.getBoundingClientRect().top) : rect.bottom;
            iframe.style.height = Math.max(100, bottom - rect.top) + 'px';
        };
        new ResizeObserver(resize).observe(holder);
        window.addEventListener('resize', resize);
        setInterval(resize, 1000);
        resize();
    }
    window.__kimodoVrm = {
        send(data) {
            if (data.action === 'visible') {
                enabled = data.enabled; iframe.style.display = enabled ? 'block' : 'none'; return;
            }
            if (data.action === 'clear') motions.clear();
            if (data.action === 'motion') motions.set(data.id, data);
            if (data.action === 'frame') currentFrame = data.frame;
            if (ready) post(data);
        },
    };
    window.addEventListener('message', event => {
        if (event.origin !== origin || event.source !== iframe.contentWindow || event.data?.channel !== 'kimodo-vrm') return;
        if (event.data.action === 'ready') {
            ready = true;
            post({channel:'kimodo-vrm', action:'clear'});
            for (const motion of motions.values()) post(motion);
            post({channel:'kimodo-vrm', action:'frame', frame:currentFrame});
            iframe.style.display = enabled ? 'block' : 'none';
        } else if (event.data.action === 'key') {
            // Viser coalesces keyboard messages within 20ms. Preserve the
            // down/up pair so a quick Space tap cannot leave it held down.
            const data = event.data;
            keys = keys.then(() => new Promise(resolve => {
                document.dispatchEvent(new KeyboardEvent(data.eventType || 'keydown', {key:data.key, code:data.code, bubbles:true}));
                setTimeout(resolve, 50);
            }));
        }
    });
    mount();
}
