'use strict';
const form = document.querySelector('#mode-form');
const save = form.querySelector('button');
const statusText = document.querySelector('#status');
const names = {carplay: 'CarPlay', mirroring: 'Screen Mirroring', unknown: 'Not confirmed'};
let state;
function render(value) {
  state = value;
  form.elements.mode.value = state.selected;
  form.querySelector('[value="mirroring"]').disabled = !state.available.mirroring;
  document.querySelector('#unavailable').hidden = state.available.mirroring;
  document.querySelector('#lab').hidden = !state.lab;
  document.querySelector('#active').textContent = `Active mode: ${names[state.active]}`;
  document.querySelector('#mirror-scope').hidden = state.active !== 'mirroring' || state.lab;
  if (state.error === 'start_failed') {
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
  save.disabled = true;
}
async function responseJSON(response) {
  const data = await response.json();
  if (!response.ok) throw new Error(data.message || 'Unable to save connection mode.');
  return data;
}
form.addEventListener('change', () => {save.disabled = !state || form.elements.mode.value === state.selected;});
form.addEventListener('submit', async event => {
  event.preventDefault(); save.disabled = true;
  try {
    const body = new URLSearchParams({mode: form.elements.mode.value});
    render(await responseJSON(await fetch('/api/mode', {method: 'POST', headers: {'X-SmartBox-Mode': '1'}, body})));
    if (!state.pending) statusText.textContent = 'Connection mode saved.';
  } catch (error) {statusText.textContent = error.message; save.disabled = false;}
});
fetch('/api/mode', {cache: 'no-store'}).then(responseJSON).then(render).catch(() => {
  statusText.textContent = 'Cannot reach the adapter’s mode service. Reload to try again.';
});
async function receiverStatus() {
  const target = document.querySelector('#mirror-status');
  if (!state || state.active !== 'mirroring' || state.lab) {target.hidden = true; return;}
  target.hidden = false;
  try {
    const value = await responseJSON(await fetch('/api/mirror', {cache: 'no-store'}));
    if (/^\d{4}$/.test(value.pin)) target.textContent = `Choose SmartBox Mirror on your iPhone. AirPlay pairing code: ${value.pin}`;
    else if (value.state === 'forwarding_unverified') target.textContent = `Sending video to the car (${value.frames_forwarded} frames). Check the car display for the picture.`;
    else if (value.state === 'waiting') target.textContent = 'On your iPhone, open Screen Mirroring and select SmartBox Mirror. Keep this page open for the pairing code.';
    else if (value.state === 'waiting_for_stock_app') target.textContent = 'Waiting for the adapter’s CarPlay transport to start.';
    else target.textContent = 'The receiver is preparing the connection.';
  } catch (_) {target.textContent = 'Receiver status is unavailable.';}
}
setInterval(receiverStatus, 1000);
