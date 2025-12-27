
       // GLOBAL VARIABLES
       let currentView = 'grid';
       let currentPage = 1;
       const usersPerPage = 6;
       let filteredUsers = [];
       let allUsers = [];
       let currentViewUserId = null;
       let currentDeleteUserId = null;

       // INITIALIZE
       document.addEventListener('DOMContentLoaded', function () {
           initializeEventListeners();
           loadUsersFromServer();
       });

       function initializeEventListeners() {
           // View buttons
           document.querySelectorAll('.view-btn').forEach(btn => {
               btn.addEventListener('click', function (e) {
                   e.preventDefault();
                   const view = this.getAttribute('data-view');
                   changeView(view);
               });
           });

           // Filter button
           document.getElementById('applyFiltersBtn').addEventListener('click', function (e) {
               e.preventDefault();
               applyFilters();
           });

           // Search input
           document.getElementById('searchUsers').addEventListener('input', function (e) {
               applyFilters();
           });

           // Filter dropdowns
           document.getElementById('statusFilter').addEventListener('change', function (e) {
               applyFilters();
           });

           document.getElementById('dateFilter').addEventListener('change', function (e) {
               applyFilters();
           });

           // Modal close buttons
           document.querySelector('#viewUserModal .close-modal').addEventListener('click', closeViewUserModal);
           document.querySelector('#deleteUserModal .close-modal').addEventListener('click', closeDeleteModal);
           document.getElementById('closeViewModalBtn').addEventListener('click', closeViewUserModal);
           document.getElementById('cancelDeleteBtn').addEventListener('click', closeDeleteModal);
           document.getElementById('confirmDeleteBtn').addEventListener('click', confirmDelete);

           // Close modals when clicking outside
           document.getElementById('viewUserModal').addEventListener('click', function (e) {
               if (e.target === this) closeViewUserModal();
           });
           document.getElementById('deleteUserModal').addEventListener('click', function (e) {
               if (e.target === this) closeDeleteModal();
           });
       }

       function changeView(view) {
           currentView = view;

           // Update active button
           document.querySelectorAll('.view-btn').forEach(btn => {
               btn.classList.remove('active');
               if (btn.getAttribute('data-view') === view) {
                   btn.classList.add('active');
               }
           });

           // Show/hide views
           document.getElementById('gridView').style.display = view === 'grid' ? 'block' : 'none';
           document.getElementById('tableView').style.display = view === 'table' ? 'block' : 'none';

           renderUsers();
       }

       function loadUsersFromServer() {
           showLoading();

           const usersData = document.getElementById('<%= hfUsersData.ClientID %>').value;

        if (usersData && usersData !== '') {
            try {
                allUsers = JSON.parse(usersData);
                // Filter to show only citizens/customers
                filteredUsers = allUsers.filter(user => user.UserType === 'customer');

                renderUsers();
                updatePagination();
                updatePageInfo();
                hideLoading();

                if (filteredUsers.length > 0) {
                    showSuccess('Loaded ' + filteredUsers.length + ' citizens from database');
                } else {
                    showInfo('No citizens found in database');
                }

            } catch (e) {
                console.error('Error parsing user data:', e);
                showError('Error loading citizen data from database');
                hideLoading();
            }
        } else {
            showError('No citizen data available from database');
            hideLoading();
        }
    }

    function showNotification(message, type = 'info') {
        const existingNotifications = document.querySelectorAll('.custom-notification');
        existingNotifications.forEach(notif => notif.remove());

        const notification = document.createElement('div');
        notification.className = `custom-notification notification-${type}`;

        const icons = {
            error: 'fas fa-exclamation-circle',
            success: 'fas fa-check-circle',
            info: 'fas fa-info-circle'
        };

        notification.innerHTML = `
            <i class="${icons[type]}"></i>
            <span>${message}</span>
            <button onclick="this.parentElement.remove()">&times;</button>
        `;

        document.body.appendChild(notification);

        setTimeout(() => {
            if (notification.parentElement) {
                notification.remove();
            }
        }, 5000);
    }

    function showError(message) {
        showNotification(message, 'error');
    }

    function showSuccess(message) {
        showNotification(message, 'success');
    }

    function showInfo(message) {
        showNotification(message, 'info');
    }

    function applyFilters() {
        const searchTerm = document.getElementById('searchUsers').value.toLowerCase();
        const statusFilter = document.getElementById('statusFilter').value;

        filteredUsers = allUsers.filter(user => {
            const matchesSearch = !searchTerm ||
                (user.FirstName && user.FirstName.toLowerCase().includes(searchTerm)) ||
                (user.LastName && user.LastName.toLowerCase().includes(searchTerm)) ||
                (user.Email && user.Email.toLowerCase().includes(searchTerm)) ||
                (user.Phone && user.Phone.includes(searchTerm));

            const matchesStatus = statusFilter === 'all' || user.Status === statusFilter;
            const isCitizen = user.UserType === 'customer';

            return matchesSearch && matchesStatus && isCitizen;
        });

        currentPage = 1;
        renderUsers();
        updatePagination();
        updatePageInfo();
    }

    function renderUsers() {
        if (currentView === 'grid') {
            renderGridView();
        } else {
            renderTableView();
        }
    }

    function renderGridView() {
        const grid = document.getElementById('usersGrid');
        const startIndex = (currentPage - 1) * usersPerPage;
        const endIndex = startIndex + usersPerPage;
        const usersToShow = filteredUsers.slice(startIndex, endIndex);

        grid.innerHTML = '';

        if (usersToShow.length === 0) {
            grid.innerHTML = `
                <div class="col-12 text-center py-5">
                    <i class="fas fa-users fa-3x mb-3" style="color: rgba(255, 255, 255, 0.5) !important;"></i>
                    <h4 style="color: rgba(255, 255, 255, 0.7) !important;">No citizens found</h4>
                    <p style="color: rgba(255, 255, 255, 0.5) !important;">Try adjusting your filters or search terms</p>
                </div>
            `;
            return;
        }

        usersToShow.forEach(user => {
            const userCard = createUserCard(user);
            grid.appendChild(userCard);
        });
    }

    function renderTableView() {
        const tbody = document.getElementById('usersTableBody');
        const startIndex = (currentPage - 1) * usersPerPage;
        const endIndex = startIndex + usersPerPage;
        const usersToShow = filteredUsers.slice(startIndex, endIndex);

        tbody.innerHTML = '';

        if (usersToShow.length === 0) {
            tbody.innerHTML = `
                <tr>
                    <td colspan="7" class="text-center py-4">
                        <i class="fas fa-users fa-2x mb-2" style="color: rgba(255, 255, 255, 0.5) !important;"></i>
                        <h5 style="color: rgba(255, 255, 255, 0.7) !important;">No citizens found</h5>
                        <p style="color: rgba(255, 255, 255, 0.5) !important;">Try adjusting your filters or search terms</p>
                    </td>
                </tr>
            `;
            return;
        }

        usersToShow.forEach(user => {
            const row = createTableRow(user);
            tbody.appendChild(row);
        });
    }

    function createUserCard(user) {
        const card = document.createElement('div');
        card.className = 'user-card';

        const completionRate = user.TotalPickups > 0
            ? Math.round((user.CompletedPickups / user.TotalPickups) * 100)
            : 0;

        card.innerHTML = `
            <div class="user-header">
                <div class="user-info">
                    <h3 class="user-name">${escapeHtml(user.FirstName || '')} ${escapeHtml(user.LastName || '')}</h3>
                    <p class="user-email">${escapeHtml(user.Email || 'No email')}</p>
                    <div class="user-stats">
                        <div class="stat-item">
                            <div class="stat-value">${user.TotalPickups || 0}</div>
                            <div class="stat-label">Total Pickups</div>
                        </div>
                        <div class="stat-item">
                            <div class="stat-value">${completionRate}%</div>
                            <div class="stat-label">Completion</div>
                        </div>
                        <div class="stat-item">
                            <div class="stat-value">${user.Credits || 0}</div>
                            <div class="stat-label">Credits</div>
                        </div>
                    </div>
                </div>
                <div class="user-actions">
                    <button class="btn-action btn-view" data-user-id="${user.Id}" title="View Details">
                        <i class="fas fa-eye"></i>
                    </button>
                    <button class="btn-action btn-edit" data-user-id="${user.Id}" title="Edit Citizen">
                        <i class="fas fa-edit"></i>
                    </button>
                    <button class="btn-action btn-delete" data-user-id="${user.Id}" title="Delete Citizen">
                        <i class="fas fa-trash"></i>
                    </button>
                </div>
            </div>
            <div class="user-meta">
                <div class="user-status">
                    <span class="status-badge status-${user.Status || 'inactive'}">${capitalizeFirst(user.Status || 'inactive')}</span>
                    <span style="color: rgba(255, 255, 255, 0.5) !important;">• Citizen</span>
                </div>
                <div class="small" style="color: rgba(255, 255, 255, 0.5) !important;">
                    Joined ${formatDate(user.RegistrationDate)}
                </div>
            </div>
        `;

        // Add event listeners to action buttons
        card.querySelector('.btn-view').addEventListener('click', function() {
            viewUser(this.getAttribute('data-user-id'));
        });
        card.querySelector('.btn-edit').addEventListener('click', function() {
            editUser(this.getAttribute('data-user-id'));
        });
        card.querySelector('.btn-delete').addEventListener('click', function() {
            deleteUser(this.getAttribute('data-user-id'));
        });

        return card;
    }

    function createTableRow(user) {
        const row = document.createElement('tr');
        const completionRate = user.TotalPickups > 0
            ? Math.round((user.CompletedPickups / user.TotalPickups) * 100)
            : 0;

        row.innerHTML = `
            <td>
                <div class="d-flex align-items-center gap-3">
                    <div class="user-avatar">
                        ${escapeHtml((user.FirstName ? user.FirstName[0] : 'U') + (user.LastName ? user.LastName[0] : ''))}
                    </div>
                    <div>
                        <div class="fw-bold" style="color: #ffffff !important;">${escapeHtml(user.FirstName || '')} ${escapeHtml(user.LastName || '')}</div>
                        <div class="small" style="color: rgba(255, 255, 255, 0.6) !important;">${escapeHtml(user.Email || 'No email')}</div>
                    </div>
                </div>
            </td>
            <td>${escapeHtml(user.Phone || 'No phone')}</td>
            <td>
                <span class="status-badge status-${user.Status || 'inactive'}">${capitalizeFirst(user.Status || 'inactive')}</span>
            </td>
            <td>
                <div style="color: #ffffff !important;">${user.CompletedPickups || 0}/${user.TotalPickups || 0}</div>
                <div class="small" style="color: rgba(255, 255, 255, 0.6) !important;">${completionRate}% completed</div>
            </td>
            <td>
                <div class="fw-bold" style="color: #ffffff !important;">${user.Credits || 0}</div>
            </td>
            <td>${formatDate(user.RegistrationDate)}</td>
            <td>
                <div class="user-actions">
                    <button class="btn-action btn-view" data-user-id="${user.Id}" title="View Details">
                        <i class="fas fa-eye"></i>
                    </button>
                    <button class="btn-action btn-edit" data-user-id="${user.Id}" title="Edit Citizen">
                        <i class="fas fa-edit"></i>
                    </button>
                    <button class="btn-action btn-delete" data-user-id="${user.Id}" title="Delete Citizen">
                        <i class="fas fa-trash"></i>
                    </button>
                </div>
            </td>
        `;

        // Add event listeners to action buttons
        row.querySelector('.btn-view').addEventListener('click', function() {
            viewUser(this.getAttribute('data-user-id'));
        });
        row.querySelector('.btn-edit').addEventListener('click', function() {
            editUser(this.getAttribute('data-user-id'));
        });
        row.querySelector('.btn-delete').addEventListener('click', function() {
            deleteUser(this.getAttribute('data-user-id'));
        });

        return row;
    }

    function updatePagination() {
        const pagination = document.getElementById('pagination');
        const totalPages = Math.ceil(filteredUsers.length / usersPerPage);

        pagination.innerHTML = '';

        if (totalPages <= 1) return;

        const prevLi = document.createElement('li');
        prevLi.className = `page-item ${currentPage === 1 ? 'disabled' : ''}`;
        prevLi.innerHTML = `<a class="page-link" href="javascript:void(0)" data-page="${currentPage - 1}">Previous</a>`;
        pagination.appendChild(prevLi);

        for (let i = 1; i <= totalPages; i++) {
            const li = document.createElement('li');
            li.className = `page-item ${currentPage === i ? 'active' : ''}`;
            li.innerHTML = `<a class="page-link" href="javascript:void(0)" data-page="${i}">${i}</a>`;
            pagination.appendChild(li);
        }

        const nextLi = document.createElement('li');
        nextLi.className = `page-item ${currentPage === totalPages ? 'disabled' : ''}`;
        nextLi.innerHTML = `<a class="page-link" href="javascript:void(0)" data-page="${currentPage + 1}">Next</a>`;
        pagination.appendChild(nextLi);

        // Add event listeners to pagination links
        pagination.querySelectorAll('.page-link').forEach(link => {
            link.addEventListener('click', function() {
                const page = parseInt(this.getAttribute('data-page'));
                changePage(page);
            });
        });

        document.getElementById('paginationInfo').textContent = `Page ${currentPage} of ${totalPages}`;
    }

    function changePage(page) {
        const totalPages = Math.ceil(filteredUsers.length / usersPerPage);
        if (page >= 1 && page <= totalPages) {
            currentPage = page;
            renderUsers();
            updatePagination();
        }
    }

    function updatePageInfo() {
        const startIndex = (currentPage - 1) * usersPerPage + 1;
        const endIndex = Math.min(currentPage * usersPerPage, filteredUsers.length);
        document.getElementById('pageInfo').textContent = `Showing ${startIndex}-${endIndex} of ${filteredUsers.length} citizens`;
    }

    function showLoading() {
        const grid = document.getElementById('usersGrid');
        if (grid) {
            grid.innerHTML = `
                <div class="col-12 text-center py-5">
                    <i class="fas fa-spinner fa-spin fa-2x mb-3" style="color: rgba(255, 255, 255, 0.5) !important;"></i>
                    <p style="color: rgba(255, 255, 255, 0.7) !important;">Loading citizens from database...</p>
                </div>
            `;
        }
    }

    function hideLoading() { }

    // View User Modal Functions
    function viewUser(userId) {
        const user = allUsers.find(u => u.Id === userId);
        if (user) {
            currentViewUserId = userId;
            
            // Populate modal with user data
            document.getElementById('viewUserAvatar').innerHTML = 
                escapeHtml((user.FirstName ? user.FirstName[0] : 'U') + (user.LastName ? user.LastName[0] : ''));
            document.getElementById('viewUserName').textContent = `${user.FirstName || ''} ${user.LastName || ''}`;
            document.getElementById('viewUserEmail').textContent = user.Email || 'No email';
            document.getElementById('viewUserPhone').textContent = user.Phone || 'No phone';
            document.getElementById('viewUserType').textContent = 'Citizen';
            document.getElementById('viewUserStatus').innerHTML = 
                `<span class="status-badge status-${user.Status || 'inactive'}">${capitalizeFirst(user.Status || 'inactive')}</span>`;
            document.getElementById('viewUserCredits').textContent = user.Credits || 0;
            document.getElementById('viewUserRegDate').textContent = formatDate(user.RegistrationDate);
            document.getElementById('viewUserAddress').textContent = user.Address || 'No address';
            
            // Show modal
            document.getElementById('viewUserModal').style.display = 'block';
        }
    }

    function closeViewUserModal() {
        document.getElementById('viewUserModal').style.display = 'none';
        currentViewUserId = null;
    }

    // Delete Confirmation Modal Functions
    function deleteUser(userId) {
        const user = allUsers.find(u => u.Id === userId);
        if (user) {
            currentDeleteUserId = userId;
            document.getElementById('deleteUserName').textContent = `${user.FirstName || ''} ${user.LastName || ''}`;
            document.getElementById('deleteUserModal').style.display = 'block';
        }
    }

    function closeDeleteModal() {
        document.getElementById('deleteUserModal').style.display = 'none';
        currentDeleteUserId = null;
    }

    function confirmDelete() {
        if (currentDeleteUserId) {
            PageMethods.DeleteUser(currentDeleteUserId, function(response) {
                if (response.startsWith('Success')) {
                    showSuccess('Citizen deleted successfully');
                    document.getElementById('<%= btnLoadUsers.ClientID %>').click();
                } else {
                    showError('Error deleting citizen: ' + response);
                }
                closeDeleteModal();
            });
           }
       }

       function editUser(userId) {
           showInfo('Edit functionality will be implemented soon');
       }

       function formatDate(dateString) {
           if (!dateString) return 'Unknown';
           try {
               return new Date(dateString).toLocaleDateString();
           } catch (e) {
               return dateString;
           }
       }

       function capitalizeFirst(string) {
           if (!string) return 'Unknown';
           return string.charAt(0).toUpperCase() + string.slice(1);
       }

       function escapeHtml(unsafe) {
           if (!unsafe) return '';
           return unsafe
               .toString()
               .replace(/&/g, "&amp;")
               .replace(/</g, "&lt;")
               .replace(/>/g, "&gt;")
               .replace(/"/g, "&quot;")
               .replace(/'/g, "&#039;");
       }
