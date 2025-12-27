
        let allUsers = [];
        let filteredUsers = [];
        let currentPage = 1;
        const pageSize = 10;

        document.addEventListener('DOMContentLoaded', function () {
            loadUsersFromServer();
            setupEventListeners();
        });

        function setupEventListeners() {
            document.getElementById('refreshBtn').addEventListener('click', function (e) {
                e.preventDefault();
                refreshData();
            });

            document.getElementById('addCreditBtn').addEventListener('click', function (e) {
                e.preventDefault();
                openAddCreditModal();
            });

            document.getElementById('applyFiltersBtn').addEventListener('click', function (e) {
                e.preventDefault();
                applyFilters();
            });

            document.getElementById('clearFiltersBtn').addEventListener('click', function (e) {
                e.preventDefault();
                clearFilters();
            });

            document.getElementById('searchUsers').addEventListener('input', function () {
                applyFilters();
            });

            document.getElementById('saveCreditBtn').addEventListener('click', function (e) {
                e.preventDefault();
                saveCredit();
            });

            document.querySelectorAll('.close-modal').forEach(btn => {
                btn.addEventListener('click', function (e) {
                    e.preventDefault();
                    closeAllModals();
                });
            });

            document.getElementById('closeModalBtn').addEventListener('click', function (e) {
                e.preventDefault();
                closeAllModals();
            });

            document.getElementById('creditModal').addEventListener('click', function (e) {
                if (e.target === this) {
                    closeAllModals();
                }
            });
        }

        function closeAllModals() {
            document.getElementById('creditModal').style.display = 'none';
        }

        function loadUsersFromServer() {
            showLoading(true);

            const usersData = document.getElementById('<%= hfUsersData.ClientID %>').value;
            const statsData = document.getElementById('<%= hfStatsData.ClientID %>').value;

            if (usersData && usersData !== '[]' && usersData !== '') {
                try {
                    allUsers = JSON.parse(usersData);
                    filteredUsers = [...allUsers];
                } catch (e) {
                    console.error('Error parsing users data:', e);
                    allUsers = [];
                    filteredUsers = [];
                }
            } else {
                allUsers = [];
                filteredUsers = [];
            }
            
            if (statsData && statsData !== '') {
                try {
                    updateStatistics(JSON.parse(statsData));
                } catch (e) {
                    console.error('Error parsing stats data:', e);
                }
            }

            renderUsers();
            showLoading(false);
        }

        function refreshData() {
            showLoading(true);
            document.getElementById('<%= btnLoadCredits.ClientID %>').click();

            setTimeout(function () {
                loadUsersFromServer();
                showNotification('Data refreshed successfully!', 'success');
            }, 500);
        }

        function updateStatistics(stats) {
            document.getElementById('totalUsers').textContent = stats.TotalUsers || 0;
            document.getElementById('totalCredits').textContent = stats.TotalCredits || 0;
            document.getElementById('avgCredits').textContent = (stats.AvgCredits || 0).toFixed(2);
            document.getElementById('activeUsers').textContent = stats.ActiveUsers || 0;
        }

        function applyFilters() {
            const searchTerm = document.getElementById('searchUsers').value.toLowerCase();
            const statusFilter = document.getElementById('statusFilter').value;
            const roleFilter = document.getElementById('roleFilter').value;

            filteredUsers = allUsers.filter(user => {
                const matchesSearch = !searchTerm ||
                    (user.FullName && user.FullName.toLowerCase().includes(searchTerm)) ||
                    (user.Phone && user.Phone.toLowerCase().includes(searchTerm)) ||
                    (user.Email && user.Email.toLowerCase().includes(searchTerm));

                const matchesStatus = statusFilter === 'all' ||
                    (statusFilter === 'active' && user.IsVerified) ||
                    (statusFilter === 'inactive' && !user.IsVerified);

                const matchesRole = roleFilter === 'all' ||
                    (user.RoleName && user.RoleName.toLowerCase() === roleFilter.toLowerCase());

                return matchesSearch && matchesStatus && matchesRole;
            });

            currentPage = 1;
            renderUsers();
        }

        function clearFilters() {
            document.getElementById('searchUsers').value = '';
            document.getElementById('statusFilter').value = 'all';
            document.getElementById('roleFilter').value = 'all';

            filteredUsers = allUsers;
            currentPage = 1;
            renderUsers();
        }

        function renderUsers() {
            const tbody = document.getElementById('creditsTableBody');
            const emptyState = document.getElementById('creditsEmptyState');
            const paginationInfo = document.getElementById('paginationInfo');
            const table = document.getElementById('creditsTable');

            tbody.innerHTML = '';

            if (filteredUsers.length === 0) {
                table.style.display = 'none';
                emptyState.style.display = 'block';
                paginationInfo.textContent = 'Showing 0 users';
                return;
            }

            table.style.display = 'table';
            emptyState.style.display = 'none';

            const startIndex = (currentPage - 1) * pageSize;
            const endIndex = Math.min(startIndex + pageSize, filteredUsers.length);
            const paginatedUsers = filteredUsers.slice(startIndex, endIndex);

            paginatedUsers.forEach(user => {
                const row = createUserRow(user);
                if (row) {
                    tbody.appendChild(row);
                }
            });

            paginationInfo.textContent = `Showing ${startIndex + 1}-${endIndex} of ${filteredUsers.length} users`;
            renderPagination();
        }

        function createUserRow(user) {
            if (!user) return null;

            const row = document.createElement('tr');

            const userId = user.UserId || '-';
            const fullName = user.FullName || 'Unknown User';
            const phone = user.Phone || '-';
            const credits = parseFloat(user.XP_Credits) || 0;
            const roleName = user.RoleName || 'Unknown';
            const isVerified = user.IsVerified;
            const lastLogin = user.LastLogin;

            const userInitial = fullName.charAt(0).toUpperCase();
            const statusClass = isVerified ? 'status-active' : 'status-inactive';
            const statusText = isVerified ? 'Active' : 'Inactive';

            row.innerHTML = `
                <td>${escapeHtml(userId)}</td>
                <td>
                    <div class="user-info">
                        <div class="user-avatar">${userInitial}</div>
                        <span>${escapeHtml(fullName)}</span>
                    </div>
                </td>
                <td>${escapeHtml(phone)}</td>
                <td class="credit-positive">${credits} credits</td>
                <td>${escapeHtml(roleName)}</td>
                <td><span class="status-badge ${statusClass}">${statusText}</span></td>
                <td>${formatDate(lastLogin)}</td>
                <td>
                    <button class="btn-action btn-adjust" data-id="${userId}" title="Adjust Credits">
                        <i class="fas fa-edit"></i>
                    </button>
                </td>
            `;

            const adjustBtn = row.querySelector('.btn-adjust');
            if (adjustBtn) {
                adjustBtn.addEventListener('click', function (e) {
                    e.preventDefault();
                    e.stopPropagation();
                    adjustUserCredits(this.getAttribute('data-id'));
                });
            }

            return row;
        }

        function formatDate(dateString) {
            if (!dateString) return '-';
            try {
                const date = new Date(dateString);
                return date.toLocaleDateString() + ' ' + date.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
            } catch (e) {
                return '-';
            }
        }

        function openAddCreditModal() {
            const userSelect = document.getElementById('modalUserId');
            userSelect.innerHTML = '<option value="">Select User</option>';
            
            allUsers.forEach(user => {
                const option = document.createElement('option');
                option.value = user.UserId;
                option.textContent = `${user.FullName} (${user.Phone}) - ${user.XP_Credits || 0} credits`;
                userSelect.appendChild(option);
            });

            document.getElementById('modalAmount').value = '';
            document.getElementById('modalType').value = 'Bonus';
            document.getElementById('modalReference').value = '';
            document.getElementById('modalNotes').value = '';

            document.getElementById('creditModal').style.display = 'block';
        }

        function adjustUserCredits(userId) {
            const user = allUsers.find(u => u.UserId === userId);
            if (user) {
                const userSelect = document.getElementById('modalUserId');
                userSelect.innerHTML = '';
                
                const option = document.createElement('option');
                option.value = user.UserId;
                option.textContent = `${user.FullName} (${user.Phone}) - ${user.XP_Credits || 0} credits`;
                option.selected = true;
                userSelect.appendChild(option);

                document.getElementById('modalAmount').value = '';
                document.getElementById('modalType').value = 'Adjustment';
                document.getElementById('modalReference').value = 'Manual Adjustment';
                document.getElementById('modalNotes').value = '';

                document.getElementById('creditModal').style.display = 'block';
            }
        }

        function saveCredit() {
            const userId = document.getElementById('modalUserId').value;
            const amount = parseFloat(document.getElementById('modalAmount').value);
            const type = document.getElementById('modalType').value;
            const reference = document.getElementById('modalReference').value;
            const notes = document.getElementById('modalNotes').value;

            if (!userId) {
                showNotification('Please select a user', 'error');
                return;
            }

            if (!amount || amount <= 0) {
                showNotification('Please enter a valid amount', 'error');
                return;
            }

            // Here you would typically make an AJAX call to save the credit
            console.log('Saving credit:', { userId, amount, type, reference, notes });
            
            showNotification('Credits added successfully!', 'success');
            closeAllModals();
            refreshData();
        }

        function renderPagination() {
            const pagination = document.getElementById('pagination');
            const totalPages = Math.ceil(filteredUsers.length / pageSize);

            pagination.innerHTML = '';

            if (totalPages <= 1) return;

            if (currentPage > 1) {
                const prevLi = document.createElement('li');
                prevLi.className = 'page-item';
                prevLi.innerHTML = `<a class="page-link" href="#" data-page="${currentPage - 1}">Previous</a>`;
                pagination.appendChild(prevLi);
            }

            for (let i = 1; i <= totalPages; i++) {
                const li = document.createElement('li');
                li.className = 'page-item' + (i === currentPage ? ' active' : '');
                li.innerHTML = `<a class="page-link" href="#" data-page="${i}">${i}</a>`;
                pagination.appendChild(li);
            }

            if (currentPage < totalPages) {
                const nextLi = document.createElement('li');
                nextLi.className = 'page-item';
                nextLi.innerHTML = `<a class="page-link" href="#" data-page="${currentPage + 1}">Next</a>`;
                pagination.appendChild(nextLi);
            }

            pagination.querySelectorAll('.page-link').forEach(link => {
                link.addEventListener('click', function (e) {
                    e.preventDefault();
                    currentPage = parseInt(this.getAttribute('data-page'));
                    renderUsers();
                });
            });
        }

        function showLoading(show) {
            const spinner = document.getElementById('loadingSpinner');
            const table = document.getElementById('creditsTable');

            if (show) {
                spinner.style.display = 'block';
                table.style.display = 'none';
            } else {
                spinner.style.display = 'none';
                table.style.display = 'table';
            }
        }

        function showNotification(message, type) {
            const existingNotifications = document.querySelectorAll('.custom-notification');
            existingNotifications.forEach(notification => notification.remove());

            const notification = document.createElement('div');
            notification.className = `custom-notification notification-${type}`;
            notification.innerHTML = `
                <i class="fas ${type === 'success' ? 'fa-check-circle' : type === 'error' ? 'fa-exclamation-circle' : 'fa-info-circle'}"></i>
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

        function escapeHtml(unsafe) {
            if (!unsafe) return '';
            return unsafe.toString()
                .replace(/&/g, "&amp;")
                .replace(/</g, "&lt;")
                .replace(/>/g, "&gt;")
                .replace(/"/g, "&quot;")
                .replace(/'/g, "&#039;");
        }

        var prm = Sys.WebForms.PageRequestManager.getInstance();
        prm.add_endRequest(function () {
            setupEventListeners();
            loadUsersFromServer();
        });
