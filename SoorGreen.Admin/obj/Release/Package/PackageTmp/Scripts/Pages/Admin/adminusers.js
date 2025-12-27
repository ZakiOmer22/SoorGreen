/********************************************
 *  NOTIFICATION SYSTEM
 ********************************************/
function showNotification(message, type = 'info') {
    const existing = document.querySelectorAll('.custom-notification');
    existing.forEach(n => n.remove());

    const notification = document.createElement('div');
    notification.className = `custom-notification notification-${type}`;

    const icons = {
        error: "fas fa-exclamation-circle",
        success: "fas fa-check-circle",
        info: "fas fa-info-circle"
    };

    notification.innerHTML = `
        <i class="${icons[type]}"></i>
        <span>${message}</span>
        <button onclick="this.parentElement.remove()">&times;</button>
    `;

    document.body.appendChild(notification);

    setTimeout(() => {
        if (notification.parentElement) notification.remove();
    }, 5000);
}

function showError(msg) { showNotification(msg, "error"); }
function showSuccess(msg) { showNotification(msg, "success"); }
function showInfo(msg) { showNotification(msg, "info"); }

/********************************************
 *  VIEW SWITCHING
 ********************************************/
let currentView = "grid";

function changeView(view) {
    currentView = view;

    document.querySelectorAll(".view-btn").forEach(btn =>
        btn.classList.remove("active")
    );
    event.target.classList.add("active");

    document.getElementById("gridView").style.display = (view === "grid") ? "block" : "none";
    document.getElementById("tableView").style.display = (view === "table") ? "block" : "none";
}

/********************************************
 *  MODALS
 ********************************************/
function openUserModal() {
    document.getElementById("userModal").style.display = "block";
}

function closeUserModal() {
    document.getElementById("userModal").style.display = "none";
    document.getElementById("userForm").reset();
}

function closeViewUserModal() {
    document.getElementById("viewUserModal").style.display = "none";
}

function closeDeleteModal() {
    document.getElementById("deleteUserModal").style.display = "none";
}

/********************************************
 *  PAGE UTILITIES
 ********************************************/
window.onclick = function (event) {
    ["viewUserModal", "deleteUserModal", "userModal"].forEach(id => {
        const modal = document.getElementById(id);
        if (event.target === modal) modal.style.display = "none";
    });
};

function showLoading(containerId = "usersGrid") {
    const container = document.getElementById(containerId);
    container.innerHTML = `
        <div class="col-12 text-center py-5">
            <i class="fas fa-spinner fa-spin fa-2x"></i>
            <p>Loading...</p>
        </div>`;
}

function hideLoading(containerId = "usersGrid") {
    const container = document.getElementById(containerId);
    if (container) container.innerHTML = "";
}
