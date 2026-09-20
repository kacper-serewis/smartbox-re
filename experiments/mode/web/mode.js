'use strict';
const form = document.querySelector('#mode-form');
const save = form.querySelector('button');
const statusText = document.querySelector('#status');
const names = {carplay: 'CarPlay', mirroring: 'Screen Mirroring', unknown: 'Not confirmed'};
let state;
let watchingRestart = false;
function render(value) {
  state = value;
  form.elements.mode.value = state.selected;
  form.querySelector('[value="mirroring"]').disabled = !state.available.mirroring;
  document.querySelector('#unavailable').hidden = state.available.mirroring;
  document.querySelector('#lab').hidden = !state.lab;
  document.querySelector('#active').textContent = `Active mode: ${names[state.active]}`;
  document.querySelector('#mirror-scope').hidden = state.active !== 'mirroring' || state.lab;
  save.textContent = state.restart_on_save ? 'Save & restart' : 'Save mode';
  document.querySelector('#save-help').textContent = state.restart_on_save
    ? 'Saving remembers your choice and automatically restarts the adapter.'
    : 'Your choice is remembered. Restart the adapter to apply a change.';
  for (const input of form.querySelectorAll('input')) {
    input.disabled = state.restarting || (input.value === 'mirroring' && !state.available.mirroring);
  }
  if (state.restarting) {
    statusText.textContent = `${names[state.selected]} saved. Restarting the adapter… Reconnect to its Wi-Fi if needed.`;
    watchRestart();
  } else if (state.error === 'restart_failed') {
    statusText.textContent = 'Mode saved, but the adapter did not restart. Retry Save & restart or unplug and reconnect it.';
  } else if (state.error === 'start_failed') {
    statusText.textContent = state.active === 'carplay'
      ? 'Screen Mirroring could not start. CarPlay is active instead.'
      : 'Screen Mirroring could not start. Connection status is unavailable.';
  } else if (state.error === 'invalid_settings') {
    statusText.textContent = 'Saved setting could not be read. CarPlay is selected.';
  } else if (state.active === 'unknown') {
    statusText.textContent = `${names[state.selected]} selected. Connection status is unavailable.`;
  } else {
    statusText.textContent = state.pending ? `${names[state.selected]} selected. Restart the adapter to apply it.`
      : `${names[state.selected]} selected.`;
  }
  save.disabled = state.restarting || state.error !== 'restart_failed';
}
async function watchRestart() {
  if (watchingRestart) return;
  watchingRestart = true;
  const deadline = Date.now() + 120000;
  while (Date.now() < deadline) {
    await new Promise(resolve => setTimeout(resolve, 2000));
    try {
      const value = await responseJSON(await fetch('/api/mode', {cache: 'no-store', signal: AbortSignal.timeout(3000)}));
      if (!value.restarting) {
        watchingRestart = false;
        render(value);
        return;
      }
    } catch (_) { /* Wi-Fi normally drops during the reboot. */ }
  }
  watchingRestart = false;
  statusText.textContent = 'Cannot confirm the restart yet. Reconnect to the adapter’s Wi-Fi and reload this page.';
}
async function responseJSON(response) {
  const data = await response.json();
  if (!response.ok) throw new Error(data.message || 'Unable to save connection mode.');
  return data;
}
form.addEventListener('change', () => {save.disabled = !state || state.restarting ||
  (form.elements.mode.value === state.selected && state.error !== 'restart_failed');});
form.addEventListener('submit', async event => {
  event.preventDefault(); save.disabled = true;
  try {
    const body = new URLSearchParams({mode: form.elements.mode.value});
    render(await responseJSON(await fetch('/api/mode', {method: 'POST', headers: {'X-SmartBox-Mode': '1'}, body})));
    if (!state.pending && !state.restarting) statusText.textContent = 'Connection mode saved.';
  } catch (error) {statusText.textContent = error.message; save.disabled = false;}
});
fetch('/api/mode', {cache: 'no-store'}).then(responseJSON).then(render).catch(() => {
  statusText.textContent = 'Cannot reach the adapter’s mode service. Reload to try again.';
});
async function receiverStatus() {
  const target = document.querySelector('#mirror-status');
  if (!state || state.lab || state.restarting) {target.hidden = true; return;}
  target.hidden = state.active !== 'mirroring';
  try {
    const value = await responseJSON(await fetch('/api/mirror', {cache: 'no-store'}));
    if (value.state === 'recovery') {
      target.hidden = false;
      target.textContent = value.reason === 'original_app_failed'
        ? 'Recovery mode: mirroring is disabled. The original application also failed to stay running. Automatic retries have stopped.'
        : 'Recovery mode: mirroring is disabled after an application failure or incomplete startup. The original application is being used; check CarPlay on the car display.';
    }
    else if (/^\d{4}$/.test(value.pin)) target.textContent = `Choose SmartBox Mirror on your iPhone. AirPlay pairing code: ${value.pin}`;
    else if (value.state === 'forwarding_unverified') target.textContent = `Sending video to the car (${value.frames_forwarded} frames). Check the car display for the picture.`;
    else if (value.state === 'waiting') target.textContent = 'On your iPhone, open Screen Mirroring and select SmartBox Mirror. Keep this page open for the pairing code.';
    else if (value.state === 'waiting_for_stock_app') target.textContent = 'Waiting for the adapter’s CarPlay transport to start.';
    else target.textContent = 'The receiver is preparing the connection.';
  } catch (_) {target.textContent = 'Receiver status is unavailable.';}
}
setInterval(receiverStatus, 1000);
