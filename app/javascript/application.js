// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "channels"

document.addEventListener("turbo:load", function() {
  const rows = document.querySelectorAll(".message-row[data-href]");
  rows.forEach(row => {
    row.addEventListener("click", () => {
      window.location = row.dataset.href;
    });
  });
});
