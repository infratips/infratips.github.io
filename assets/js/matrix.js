(function () {
  "use strict";

  var canvas = document.getElementById("matrix_canvas");
  if (!canvas) return;

  var context = canvas.getContext("2d", { alpha: false });
  var toggle = document.getElementById("matrix_toggle");
  var toggleText = document.getElementById("matrix_toggle_text");
  var icon = toggle ? toggle.querySelector("i") : null;
  var reduceMotion = window.matchMedia("(prefers-reduced-motion: reduce)");
  var storageKey = "infratips.matrix.state";
  var glyphs = "01<>/{}[]$# Linux Cloud DevOps IaC ".split("");
  var drops = [];
  var animationFrame = null;
  var lastFrame = 0;
  var width = 0;
  var height = 0;
  var fontSize = 14;
  var frameInterval = 45;
  var preference = readPreference();

  function readPreference() {
    try {
      return window.localStorage.getItem(storageKey);
    } catch (error) {
      return null;
    }
  }

  function writePreference(value) {
    try {
      window.localStorage.setItem(storageKey, value);
    } catch (error) {
      // The visual preference remains valid for the current page.
    }
  }

  function isPaused() {
    if (preference === "running") return false;
    if (preference === "paused") return true;
    return reduceMotion.matches;
  }

  function updateControl() {
    var paused = isPaused();
    document.documentElement.dataset.matrixState = paused ? "paused" : "running";
    if (!toggle) return;
    toggle.setAttribute("aria-pressed", String(paused));
    toggle.title = paused ? "Ativar efeito Matrix" : "Pausar efeito Matrix";
    if (toggleText) toggleText.textContent = paused ? "Ativar Matrix" : "Pausar Matrix";
    if (icon) icon.className = paused ? "fa fa-play" : "fa fa-pause";
  }

  function resizeCanvas() {
    var ratio = Math.min(window.devicePixelRatio || 1, 2);
    width = window.innerWidth;
    height = window.innerHeight;
    fontSize = width <= 800 ? 16 : 14;
    frameInterval = width <= 800 ? 80 : 45;
    canvas.width = Math.floor(width * ratio);
    canvas.height = Math.floor(height * ratio);
    canvas.style.width = width + "px";
    canvas.style.height = height + "px";
    context.setTransform(ratio, 0, 0, ratio, 0, 0);
    drops = Array.from({ length: Math.ceil(width / fontSize) }, function () {
      return Math.floor(Math.random() * (height / fontSize));
    });
    drawFrame(true);
  }

  function drawFrame(reset) {
    context.fillStyle = reset ? "#000" : "rgba(0, 0, 0, 0.09)";
    context.fillRect(0, 0, width, height);
    context.fillStyle = "#2b8508";
    context.font = fontSize + "px 'Fira Code', monospace";

    for (var index = 0; index < drops.length; index += 1) {
      var glyph = glyphs[Math.floor(Math.random() * glyphs.length)];
      context.fillText(glyph, index * fontSize, drops[index] * fontSize);
      if (drops[index] * fontSize > height && Math.random() > 0.985) drops[index] = 0;
      drops[index] += 1;
    }
  }

  function animate(timestamp) {
    if (isPaused() || document.hidden) {
      animationFrame = null;
      return;
    }
    if (timestamp - lastFrame >= frameInterval) {
      drawFrame(false);
      lastFrame = timestamp;
    }
    animationFrame = window.requestAnimationFrame(animate);
  }

  function start() {
    updateControl();
    if (!isPaused() && !document.hidden && animationFrame === null) {
      animationFrame = window.requestAnimationFrame(animate);
    }
  }

  function stop() {
    if (animationFrame !== null) window.cancelAnimationFrame(animationFrame);
    animationFrame = null;
  }

  if (toggle) {
    toggle.addEventListener("click", function () {
      preference = isPaused() ? "running" : "paused";
      writePreference(preference);
      if (isPaused()) stop();
      else start();
      updateControl();
    });
  }

  reduceMotion.addEventListener("change", function () {
    if (preference === null) {
      if (isPaused()) stop();
      else start();
      updateControl();
    }
  });

  document.addEventListener("visibilitychange", function () {
    if (document.hidden) stop();
    else start();
  });

  var resizeFrame = null;
  window.addEventListener("resize", function () {
    if (resizeFrame !== null) window.cancelAnimationFrame(resizeFrame);
    resizeFrame = window.requestAnimationFrame(function () {
      resizeCanvas();
      resizeFrame = null;
    });
  });

  resizeCanvas();
  start();
})();
