globalThis.fullScreenEnabled = false;
globalThis.isFullScreen = function () {
  return globalThis.fullScreenEnabled;
};
globalThis.setFullScreen = function (enabled) {
  globalThis.fullScreenEnabled = enabled;
  const container = document.querySelector("#flutter-container");
  // Apply styles for non full-screen and full-screen modes
  if (enabled) {
    container.classList.add("full-screen");
    container.classList.remove("non-full-screen");
  } else {
    container.classList.add("non-full-screen");
    container.classList.remove("full-screen");
  }
};
