// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "./controllers"
import "./channels"
import * as bootstrap from "bootstrap"

 // Auto-refresh inbox every 4 seconds (only on pages with #messages)
function setupMessagesPolling(interval = 4000) {
  const messagesContainer = document.getElementById("messages");
  if (!messagesContainer) return;

  let inFlight = false;
  async function refreshMessages() {
    if (inFlight) return;
    inFlight = true;
    try {
      const params = new URLSearchParams(window.location.search);
      const resp = await fetch(`/messages?${params.toString()}`, {
        headers: { "X-Requested-With": "XMLHttpRequest" },
        cache: "no-cache"
      });
      if (!resp.ok) return;
      const html = await resp.text();
      if (messagesContainer) {
        messagesContainer.innerHTML = html;
      }
    } catch (e) {
      // Ignore errors silently
    } finally {
      inFlight = false;
    }
  }

  // Initial load + periodic refresh
  refreshMessages();
  setInterval(refreshMessages, interval);
}
setupMessagesPolling();

document.addEventListener("click", (event) => {
  const row = event.target.closest("tr.message-row");
  if (!row) return;
  // Allow default behavior for interactive elements
  if (event.target.closest("a, button, input, textarea, select, label")) return;
  const href = row.getAttribute("data-href");
  if (href) {
    event.preventDefault();
    if (window.Turbo && typeof window.Turbo.visit === "function") {
      window.Turbo.visit(href);
    } else {
      window.location.href = href;
    }
  }
});

document.addEventListener("keydown", (event) => {
  if (!(event.key === "Enter" || event.key === " ")) return;
  const row = event.target.closest("tr.message-row");
  if (!row) return;
  const href = row.getAttribute("data-href");
  if (href) {
    event.preventDefault();
    if (window.Turbo && typeof window.Turbo.visit === "function") {
      window.Turbo.visit(href);
    } else {
      window.location.href = href;
    }
  }
});
