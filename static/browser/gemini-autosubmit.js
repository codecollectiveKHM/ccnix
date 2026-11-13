// ==UserScript==
// @name        Gemini ?q= autosubmit
// @match       https://gemini.google.com/*
// @run-at      document-idle
// @grant       GM_notification
// @version     1.2
// ==/UserScript==

(async () => {
  const q = new URLSearchParams(location.search).get('q');
  if (!q) return;
  history.replaceState(null, '', location.pathname);

  const SEL_BOX  = 'rich-textarea div[contenteditable="true"], div.ql-editor[contenteditable="true"]';
  const SEL_SEND = 'button.send-button, button[aria-label*="send" i]';
  const SEL_STOP = 'button[aria-label*="stop" i]';

  const until = (fn, ms = 60000) => new Promise((res, rej) => {
    const deadline = Date.now() + ms;
    const id = setInterval(() => {
      let v; try { v = fn(); } catch { v = null; }
      if (v) { clearInterval(id); res(v); }
      else if (Date.now() > deadline) { clearInterval(id); rej(Error('timeout')); }
    }, 200);
  });

  try {
    const box = await until(() => document.querySelector(SEL_BOX));
    box.focus();
    const sel = getSelection();
    sel.selectAllChildren(box);
    sel.collapseToEnd();
    document.execCommand('insertText', false, q);

    const send = await until(() => {
      const b = document.querySelector(SEL_SEND);
      return b && !b.disabled && b.getAttribute('aria-disabled') !== 'true' ? b : null;
    }).catch(() => null);
    if (send) send.click();
    else box.dispatchEvent(new KeyboardEvent('keydown',
      { key: 'Enter', keyCode: 13, bubbles: true }));

    await until(() => document.querySelector(SEL_STOP), 15000);        // streaming started
    await until(() => !document.querySelector(SEL_STOP), 300000);      // streaming done
    GM_notification({ title: 'Gemini', text: q.slice(0, 80) });
  } catch {
    console.warn('[gemini-q] timed out');
  }
})();
