(function () {
  "use strict";

  var shell = document.getElementById("terminal_shell");
  var maximizeButton = document.getElementById("maximize_btn");
  var maximizeText = document.getElementById("maximize_text");
  var tocButton = document.getElementById("toc_toggle");
  var tocPanel = document.getElementById("popup_toc");
  var previousButton = document.getElementById("previous_btn");
  var nextButton = document.getElementById("next_btn");

  function reducedMotion() {
    return window.matchMedia("(prefers-reduced-motion: reduce)").matches;
  }

  function scrollPage(multiplier) {
    window.scrollBy({
      top: window.innerHeight * multiplier,
      behavior: reducedMotion() ? "auto" : "smooth"
    });
  }

  if (maximizeButton && shell) {
    maximizeButton.addEventListener("click", function () {
      var expanded = shell.classList.toggle("is_maximized");
      maximizeButton.setAttribute("aria-pressed", String(expanded));
      maximizeButton.title = expanded ? "Restaurar terminal" : "Expandir terminal";
      if (maximizeText) maximizeText.textContent = expanded ? "Restaurar" : "Expandir";
    });
  }

  if (previousButton) previousButton.addEventListener("click", function () { scrollPage(-0.88); });
  if (nextButton) nextButton.addEventListener("click", function () { scrollPage(0.88); });

  function closeToc() {
    if (!tocPanel || !tocButton) return;
    tocPanel.hidden = true;
    tocButton.setAttribute("aria-expanded", "false");
    tocButton.title = "Abrir indice do conteudo";
  }

  if (tocButton && tocPanel) {
    tocButton.addEventListener("click", function () {
      var willOpen = tocPanel.hidden;
      tocPanel.hidden = !willOpen;
      tocButton.setAttribute("aria-expanded", String(willOpen));
      tocButton.title = willOpen ? "Fechar indice do conteudo" : "Abrir indice do conteudo";
    });

    tocPanel.addEventListener("click", function (event) {
      if (event.target.closest("a")) closeToc();
    });

    document.addEventListener("keydown", function (event) {
      if (event.key === "Escape" && !tocPanel.hidden) {
        closeToc();
        tocButton.focus();
      }
    });
  }
})();
