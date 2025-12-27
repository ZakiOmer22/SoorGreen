
        // GLOBAL VARIABLES
        let currentView = 'grid';
        let currentPage = 1;
        const notificationsPerPage = 6;
        let filteredNotifications = [];
        let allNotifications = [];
        let allUsers = [];
        let currentNotificationId = null;
        let currentDeleteNotificationId = null;

        // INITIALIZE
        document.addEventListener('DOMContentLoaded', function () {
            initializeEventListeners();
            loadNotificationsFromServer();
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
            document.getElementById('searchNotifications').addEventListener('input', function (e) {
                applyFilters();
            });

            // Filter dropdowns
            document.getElementById('statusFilter').addEventListener('change', function (e) {
                applyFilters();
            });

            document.getElementById('typeFilter').addEventListener('change', function (e) {
                applyFilters();
            });

            document.getElementById('dateFilter').addEventListener('change', function (e) {
                applyFilters();
            });

            // Action buttons
            document.getElementById('refreshBtn').addEventListener('click', function (e) {
                e.preventDefault();
                refreshData();
            });

            document.getElementById('sendNotificationBtn').addEventListener('click', function (e) {
                e.preventDefault();
                openSendNotificationModal();
            });

            document.getElementById('markAllReadBtn').addEventListener('click', function (e) {
                e.preventDefault();
                markAllAsRead();
            });

            document.getElementById('clearFiltersBtn').addEventListener('click', function (e) {
                e.preventDefault();
                clearFilters();
            });

            // Modal buttons
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

            document.getElementById('cancelSendBtn').addEventListener('click', function (e) {
                e.preventDefault();
                closeAllModals();
            });

            document.getElementById('cancelDeleteBtn').addEventListener('click', function (e) {
                e.preventDefault();
                closeAllModals();
            });

            document.getElementById('markAsReadBtn').addEventListener('click', function (e) {
                e.preventDefault();
                markAsRead(currentNotificationId);
            });

            document.getElementById('deleteNotificationBtn').addEventListener('click', function (e) {
                e.preventDefault();
                openDeleteModal(currentNotificationId);
            });

            document.getElementById('sendNowBtn').addEventListener('click', function (e) {
                e.preventDefault();
                sendNotification();
            });

            document.getElementById('confirmDeleteBtn').addEventListener('click', function (e) {
                e.preventDefault();
                confirmDelete();
            });

            // Close modals when clicking outside
            document.getElementById('notificationModal').addEventListener('click', function (e) {
                if (e.target === this) closeAllModals();
            });

            document.getElementById('sendNotificationModal').addEventListener('click', function (e) {
                if (e.target === this) closeAllModals();
            });

            document.getElementById('deleteModal').addEventListener('click', function (e) {
                if (e.target === this) closeAllModals();
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

            renderNotifications();
        }

        function loadNotificationsFromServer() {
            showLoading(true);

            const notificationsData = document.getElementById('<%= hfNotificationsData.ClientID %>').value;
            const statsData = document.getElementById('<%= hfStatsData.ClientID %>').value;
            const usersData = document.getElementById('<%= hfUsersData.ClientID %>').value;

            console.log('Notifications data received:', notificationsData);

            if (notificationsData && notificationsData !== '[]' && notificationsData !== '') {
                try {
                    allNotifications = JSON.parse(notificationsData);
                    filteredNotifications = [...allNotifications];
                    console.log('Successfully loaded notifications:', allNotifications.length);
                } catch (e) {
                    console.error('Error parsing notifications data:', e);
                    allNotifications = [];
                    filteredNotifications = [];
                }
            } else {
                console.log('No notifications data found');
                allNotifications = [];
                filteredNotifications = [];
            }
            
            if (statsData && statsData !== '') {
                try {
                    updateStatistics(JSON.parse(statsData));
                } catch (e) {
                    console.error('Error parsing stats data:', e);
                }
            }

            if (usersData && usersData !== '') {
                try {
                    allUsers = JSON.parse(usersData);
                    populateUserSelect();
                } catch (e) {
                    console.error('Error parsing users data:', e);
                    allUsers = [];
                }
            }

            renderNotifications();
            showLoading(false);
        }

        function updateStatistics(stats) {
            document.getElementById('totalNotifications').textContent = stats.TotalNotifications || 0;
            document.getElementById('unreadNotifications').textContent = stats.UnreadNotifications || 0;
            document.getElementById('todayNotifications').textContent = stats.TodayNotifications || 0;
            document.getElementById('sentThisWeek').textContent = stats.SentThisWeek || 0;
        }

        function populateUserSelect() {
            const userSelect = document.getElementById('userSelect');
            userSelect.innerHTML = '<option value="all">All Users</option>';
            
            allUsers.forEach(user => {
                const option = document.createElement('option');
                option.value = user.UserId;
                option.textContent = user.FullName + ' (' + user.Phone + ')';
                userSelect.appendChild(option);
            });
        }

        function applyFilters() {
            const searchTerm = document.getElementById('searchNotifications').value.toLowerCase();
            const statusFilter = document.getElementById('statusFilter').value;
            const typeFilter = document.getElementById('typeFilter').value;
            const dateFilter = document.getElementById('dateFilter').value;

            filteredNotifications = allNotifications.filter(notification => {
                // Search filter
                const matchesSearch = !searchTerm ||
                    (notification.Title && notification.Title.toLowerCase().includes(searchTerm)) ||
                    (notification.Message && notification.Message.toLowerCase().includes(searchTerm)) ||
                    (notification.FullName && notification.FullName.toLowerCase().includes(searchTerm));

                // Status filter
                const matchesStatus = statusFilter === 'all' || 
                    (statusFilter === 'unread' && !notification.IsRead) ||
                    (statusFilter === 'read' && notification.IsRead);

                // Type filter
                const matchesType = typeFilter === 'all' || 
                    (notification.Type && notification.Type.toLowerCase() === typeFilter.toLowerCase());

                // Date filter
                let matchesDate = true;
                if (dateFilter !== 'all' && notification.CreatedAt) {
                    const notificationDate = new Date(notification.CreatedAt);
                    const today = new Date();
                    
                    switch (dateFilter) {
                        case 'today':
                            matchesDate = notificationDate.toDateString() === today.toDateString();
                            break;
                        case 'week':
                            const weekAgo = new Date(today);
                            weekAgo.setDate(today.getDate() - 7);
                            matchesDate = notificationDate >= weekAgo;
                            break;
                        case 'month':
                            const monthAgo = new Date(today);
                            monthAgo.setMonth(today.getMonth() - 1);
                            matchesDate = notificationDate >= monthAgo;
                            break;
                    }
                }

                return matchesSearch && matchesStatus && matchesType && matchesDate;
            });

            currentPage = 1;
            renderNotifications();
            updatePageInfo();
        }

        function clearFilters() {
            document.getElementById('searchNotifications').value = '';
            document.getElementById('statusFilter').value = 'all';
            document.getElementById('typeFilter').value = 'all';
            document.getElementById('dateFilter').value = 'all';

            filteredNotifications = allNotifications;
            currentPage = 1;
            renderNotifications();
            updatePageInfo();
        }

        function renderNotifications() {
            if (currentView === 'grid') {
                renderGridView();
            } else {
                renderTableView();
            }
            updatePagination();
        }

        function renderGridView() {
            const gridContainer = document.getElementById('notificationsGrid');
            const emptyState = document.getElementById('notificationsEmptyState');

            gridContainer.innerHTML = '';

            const startIndex = (currentPage - 1) * notificationsPerPage;
            const endIndex = Math.min(startIndex + notificationsPerPage, filteredNotifications.length);
            const currentNotifications = filteredNotifications.slice(startIndex, endIndex);

            if (currentNotifications.length === 0) {
                gridContainer.style.display = 'none';
                emptyState.style.display = 'block';
                return;
            }

            gridContainer.style.display = 'grid';
            emptyState.style.display = 'none';

            currentNotifications.forEach(notification => {
                const card = createNotificationCard(notification);
                if (card) {
                    gridContainer.appendChild(card);
                }
            });
        }

        function renderTableView() {
            const tableBody = document.getElementById('notificationsTableBody');
            const emptyState = document.getElementById('notificationsEmptyState');
            const table = document.getElementById('notificationsTable');

            tableBody.innerHTML = '';

            const startIndex = (currentPage - 1) * notificationsPerPage;
            const endIndex = Math.min(startIndex + notificationsPerPage, filteredNotifications.length);
            const currentNotifications = filteredNotifications.slice(startIndex, endIndex);

            if (currentNotifications.length === 0) {
                table.style.display = 'none';
                emptyState.style.display = 'block';
                return;
            }

            table.style.display = 'table';
            emptyState.style.display = 'none';

            currentNotifications.forEach(notification => {
                const row = createTableRow(notification);
                if (row) {
                    tableBody.appendChild(row);
                }
            });
        }

        function createNotificationCard(notification) {
            if (!notification) return null;

            const card = document.createElement('div');
            const isUnread = !notification.IsRead;
            const cardClass = isUnread ? 'notification-card unread' : 'notification-card';
            
            card.className = cardClass;
            
            const statusClass = isUnread ? 'status-unread' : 'status-read';
            const statusText = isUnread ? 'Unread' : 'Read';
            const userInitial = notification.FullName ? notification.FullName.charAt(0).toUpperCase() : 'U';
            const notificationType = notification.Type || 'system';
            const truncatedMessage = notification.Message && notification.Message.length > 150 ? 
                notification.Message.substring(0, 150) + '...' : notification.Message;

            card.innerHTML = `
                <div class="notification-header">
                    <div class="notification-info">
                        <h3 class="notification-title">${escapeHtml(notification.Title || 'No Title')}</h3>
                        <p class="notification-user">
                            <i class="fas fa-user me-2"></i>${escapeHtml(notification.FullName || 'System')}
                        </p>
                    </div>
                    <div class="notification-actions">
                        <a href="#" class="btn-action btn-view view-notification" data-id="${notification.NotificationId}">
                            <i class="fas fa-eye me-1"></i>View
                        </a>
                        ${isUnread ? `
                            <a href="#" class="btn-action btn-mark-read mark-read-notification" data-id="${notification.NotificationId}">
                                <i class="fas fa-check me-1"></i>Mark Read
                            </a>
                        ` : ''}
                        <a href="#" class="btn-action btn-delete delete-notification" data-id="${notification.NotificationId}">
                            <i class="fas fa-trash me-1"></i>Delete
                        </a>
                    </div>
                </div>
                
                <div class="notification-content">
                    <div class="notification-message">
                        ${escapeHtml(truncatedMessage || 'No message provided')}
                    </div>
                </div>
                
                <div class="notification-details">
                    <div class="detail-item">
                        <div class="detail-value">${notificationType}</div>
                        <div class="detail-label">Type</div>
                    </div>
                    <div class="detail-item">
                        <div class="detail-value">${formatTimeAgo(notification.CreatedAt)}</div>
                        <div class="detail-label">Sent</div>
                    </div>
                </div>
                
                <div class="notification-meta">
                    <div class="notification-status">
                        <span class="status-badge ${statusClass}">${statusText}</span>
                        <small>${formatDate(notification.CreatedAt)}</small>
                    </div>
                    <div class="notification-type">
                        <i class="fas fa-${getNotificationIcon(notificationType)} me-1"></i>${notificationType}
                    </div>
                </div>
            `;
            
            // Add event listeners
            card.querySelector('.view-notification').addEventListener('click', function(e) {
                e.preventDefault();
                viewNotificationDetails(this.getAttribute('data-id'));
            });

            if (card.querySelector('.mark-read-notification')) {
                card.querySelector('.mark-read-notification').addEventListener('click', function(e) {
                    e.preventDefault();
                    markAsRead(this.getAttribute('data-id'));
                });
            }

            card.querySelector('.delete-notification').addEventListener('click', function(e) {
                e.preventDefault();
                openDeleteModal(this.getAttribute('data-id'));
            });

            return card;
        }

        function createTableRow(notification) {
            if (!notification) return null;

            const row = document.createElement('tr');
            const isUnread = !notification.IsRead;
            const rowClass = isUnread ? 'unread' : '';
            
            if (isUnread) {
                row.className = 'unread';
            }
            
            const statusClass = isUnread ? 'status-unread' : 'status-read';
            const statusText = isUnread ? 'Unread' : 'Read';
            const userInitial = notification.FullName ? notification.FullName.charAt(0).toUpperCase() : 'S';
            const notificationType = notification.Type || 'system';

            row.innerHTML = `
                <td>${notification.NotificationId}</td>
                <td>
                    <div class="user-info">
                        <div class="user-avatar">${userInitial}</div>
                        ${escapeHtml(notification.FullName || 'System')}
                    </div>
                </td>
                <td>${escapeHtml(notification.Title || 'No Title')}</td>
                <td>
                    <div class="notification-type">
                        <i class="fas fa-${getNotificationIcon(notificationType)} me-1"></i>${notificationType}
                    </div>
                </td>
                <td><span class="status-badge ${statusClass}">${statusText}</span></td>
                <td>${formatTimeAgo(notification.CreatedAt)}</td>
                <td>
                    <div class="d-flex gap-1">
                        <a href="#" class="btn-action btn-view view-notification" data-id="${notification.NotificationId}" title="View Details">
                            <i class="fas fa-eye"></i>
                        </a>
                        ${isUnread ? `
                            <a href="#" class="btn-action btn-mark-read mark-read-notification" data-id="${notification.NotificationId}" title="Mark as Read">
                                <i class="fas fa-check"></i>
                            </a>
                        ` : ''}
                        <a href="#" class="btn-action btn-delete delete-notification" data-id="${notification.NotificationId}" title="Delete">
                            <i class="fas fa-trash"></i>
                        </a>
                    </div>
                </td>
            `;
            
            // Add event listeners
            row.querySelector('.view-notification').addEventListener('click', function(e) {
                e.preventDefault();
                viewNotificationDetails(this.getAttribute('data-id'));
            });

            if (row.querySelector('.mark-read-notification')) {
                row.querySelector('.mark-read-notification').addEventListener('click', function(e) {
                    e.preventDefault();
                    markAsRead(this.getAttribute('data-id'));
                });
            }

            row.querySelector('.delete-notification').addEventListener('click', function(e) {
                e.preventDefault();
                openDeleteModal(this.getAttribute('data-id'));
            });

            return row;
        }

        function getNotificationIcon(type) {
            const icons = {
                'system': 'cog',
                'pickup': 'truck',
                'reward': 'gift',
                'alert': 'exclamation-triangle',
                'info': 'info-circle'
            };
            return icons[type.toLowerCase()] || 'bell';
        }

        function viewNotificationDetails(notificationId) {
            const notification = allNotifications.find(n => n.NotificationId === notificationId);
            if (!notification) return;
            
            currentNotificationId = notificationId;
            
            const userInitial = notification.FullName ? notification.FullName.charAt(0).toUpperCase() : 'S';
            const isUnread = !notification.IsRead;
            const notificationType = notification.Type || 'system';

            document.getElementById('modalNotificationId').textContent = notification.NotificationId || '-';
            document.getElementById('modalStatus').textContent = isUnread ? 'Unread' : 'Read';
            document.getElementById('modalUserName').textContent = notification.FullName || 'System';
            document.getElementById('modalUserAvatar').textContent = userInitial;
            document.getElementById('modalType').textContent = notificationType;
            document.getElementById('modalSentDate').textContent = formatDate(notification.CreatedAt);
            document.getElementById('modalReadStatus').textContent = isUnread ? 'No' : 'Yes';
            document.getElementById('modalTitle').textContent = notification.Title || 'No Title';
            document.getElementById('modalMessage').textContent = notification.Message || 'No message provided';
            
            // Show/hide mark as read button
            const markAsReadBtn = document.getElementById('markAsReadBtn');
            if (isUnread) {
                markAsReadBtn.style.display = 'inline-block';
            } else {
                markAsReadBtn.style.display = 'none';
            }
            
            document.getElementById('notificationModal').style.display = 'block';
        }

        function markAsRead(notificationId) {
            showLoading(true);

            // Simulate API call
            setTimeout(() => {
                const notificationIndex = allNotifications.findIndex(n => n.NotificationId === notificationId);
                if (notificationIndex !== -1) {
                    allNotifications[notificationIndex].IsRead = true;
                    showNotification('Notification marked as read!', 'success');
                    closeAllModals();
                    refreshData();
                }
                showLoading(false);
            }, 500);
        }

        function markAllAsRead() {
            if (confirm('Are you sure you want to mark all notifications as read?')) {
                showLoading(true);
                
                // Simulate API call
                setTimeout(() => {
                    allNotifications.forEach(notification => {
                        notification.IsRead = true;
                    });
                    showNotification('All notifications marked as read!', 'success');
                    refreshData();
                    showLoading(false);
                }, 800);
            }
        }

        function openSendNotificationModal() {
            document.getElementById('sendNotificationModal').style.display = 'block';
            
            // Clear form
            document.getElementById('userSelect').value = 'all';
            document.getElementById('notificationType').value = 'system';
            document.getElementById('notificationTitle').value = '';
            document.getElementById('notificationMessage').value = '';
        }

        function sendNotification() {
            const userId = document.getElementById('userSelect').value;
            const type = document.getElementById('notificationType').value;
            const title = document.getElementById('notificationTitle').value.trim();
            const message = document.getElementById('notificationMessage').value.trim();

            if (!title || !message) {
                showNotification('Please fill in both title and message', 'error');
                return;
            }

            showLoading(true);

            // Simulate API call
            setTimeout(() => {
                // Create new notification
                const newNotificationId = 'NO' + (allNotifications.length + 1).toString().padStart(2, '0');
                const userName = userId === 'all' ? 'All Users' : 
                    (allUsers.find(u => u.UserId === userId)?.FullName || 'User');
                
                const newNotification = {
                    NotificationId: newNotificationId,
                    UserId: userId,
                    FullName: userName,
                    Title: title,
                    Message: message,
                    Type: type,
                    IsRead: false,
                    CreatedAt: new Date().toISOString()
                };
                
                allNotifications.unshift(newNotification);
                
                showNotification('Notification sent successfully!', 'success');
                closeAllModals();
                refreshData();
                showLoading(false);
            }, 800);
        }

        function openDeleteModal(notificationId) {
            document.getElementById('deleteModal').style.display = 'block';
            currentDeleteNotificationId = notificationId;
            document.getElementById('deleteNotificationId').textContent = notificationId;
        }

        function confirmDelete() {
            if (currentDeleteNotificationId) {
                showLoading(true);

                // Simulate API call
                setTimeout(() => {
                    const notificationIndex = allNotifications.findIndex(n => n.NotificationId === currentDeleteNotificationId);
                    if (notificationIndex !== -1) {
                        allNotifications.splice(notificationIndex, 1);
                        showNotification('Notification deleted successfully!', 'success');
                        closeAllModals();
                        refreshData();
                    }
                    showLoading(false);
                }, 800);
            }
        }

        function refreshData() {
            showLoading(true);
            document.getElementById('<%= btnLoadNotifications.ClientID %>').click();

            setTimeout(function () {
                loadNotificationsFromServer();
                showNotification('Data refreshed successfully!', 'success');
            }, 500);
        }

        function closeAllModals() {
            document.getElementById('notificationModal').style.display = 'none';
            document.getElementById('sendNotificationModal').style.display = 'none';
            document.getElementById('deleteModal').style.display = 'none';
            currentNotificationId = null;
            currentDeleteNotificationId = null;
        }

        function updatePagination() {
            const pagination = document.getElementById('pagination');
            const totalPages = Math.ceil(filteredNotifications.length / notificationsPerPage);

            pagination.innerHTML = '';

            if (totalPages <= 1) return;

            // Previous button
            const prevLi = document.createElement('li');
            prevLi.className = `page-item ${currentPage === 1 ? 'disabled' : ''}`;
            prevLi.innerHTML = `
                <a class="page-link" href="#" aria-label="Previous">
                    <span aria-hidden="true">&laquo;</span>
                </a>
            `;
            if (currentPage > 1) {
                prevLi.querySelector('a').addEventListener('click', function (e) {
                    e.preventDefault();
                    currentPage--;
                    renderNotifications();
                    updatePagination();
                    updatePageInfo();
                });
            }
            pagination.appendChild(prevLi);

            // Page numbers
            for (let i = 1; i <= totalPages; i++) {
                const pageLi = document.createElement('li');
                pageLi.className = `page-item ${i === currentPage ? 'active' : ''}`;
                pageLi.innerHTML = `<a class="page-link" href="#">${i}</a>`;

                pageLi.querySelector('a').addEventListener('click', function (e) {
                    e.preventDefault();
                    currentPage = i;
                    renderNotifications();
                    updatePagination();
                    updatePageInfo();
                });

                pagination.appendChild(pageLi);
            }

            // Next button
            const nextLi = document.createElement('li');
            nextLi.className = `page-item ${currentPage === totalPages ? 'disabled' : ''}`;
            nextLi.innerHTML = `
                <a class="page-link" href="#" aria-label="Next">
                    <span aria-hidden="true">&raquo;</span>
                </a>
            `;
            if (currentPage < totalPages) {
                nextLi.querySelector('a').addEventListener('click', function (e) {
                    e.preventDefault();
                    currentPage++;
                    renderNotifications();
                    updatePagination();
                    updatePageInfo();
                });
            }
            pagination.appendChild(nextLi);
        }

        function updatePageInfo() {
            const startIndex = (currentPage - 1) * notificationsPerPage + 1;
            const endIndex = Math.min(startIndex + notificationsPerPage - 1, filteredNotifications.length);
            const total = filteredNotifications.length;

            document.getElementById('pageInfo').textContent =
                total > 0 ? `Showing ${startIndex}-${endIndex} of ${total} notifications` : 'Showing 0 notifications';

            document.getElementById('paginationInfo').textContent =
                total > 0 ? `Page ${currentPage} of ${Math.ceil(total / notificationsPerPage)}` : 'Page 1 of 1';
        }

        // Utility Functions
        function formatDate(dateString) {
            if (!dateString) return '-';
            try {
                const date = new Date(dateString);
                return date.toLocaleDateString() + ' ' + date.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
            } catch (e) {
                return '-';
            }
        }

        function formatTimeAgo(dateString) {
            if (!dateString) return '-';
            try {
                const date = new Date(dateString);
                const now = new Date();
                const diffMs = now - date;
                const diffMins = Math.floor(diffMs / 60000);
                const diffHours = Math.floor(diffMs / 3600000);
                const diffDays = Math.floor(diffMs / 86400000);

                if (diffMins < 1) return 'Just now';
                if (diffMins < 60) return `${diffMins}m ago`;
                if (diffHours < 24) return `${diffHours}h ago`;
                if (diffDays < 7) return `${diffDays}d ago`;
                return formatDate(dateString);
            } catch (e) {
                return '-';
            }
        }

        function showLoading(show) {
            const spinner = document.getElementById('loadingSpinner');
            const gridView = document.getElementById('gridView');
            const tableView = document.getElementById('tableView');

            if (show) {
                spinner.style.display = 'block';
                gridView.style.display = 'none';
                tableView.style.display = 'none';
            } else {
                spinner.style.display = 'none';
                if (currentView === 'grid') {
                    gridView.style.display = 'block';
                } else {
                    tableView.style.display = 'block';
                }
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

        // ASP.NET AJAX support
        var prm = Sys.WebForms.PageRequestManager.getInstance();
        prm.add_endRequest(function () {
            initializeEventListeners();
            loadNotificationsFromServer();
        });
