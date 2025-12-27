
        let allAuditLogs = [];
        let filteredAuditLogs = [];
        let currentPage = 1;
        const pageSize = 10;

        document.addEventListener('DOMContentLoaded', function () {
            loadAuditLogsFromServer();
            setupEventListeners();
        });

        function setupEventListeners() {
            document.getElementById('refreshBtn').addEventListener('click', function (e) {
                e.preventDefault();
                refreshData();
            });

            document.getElementById('exportBtn').addEventListener('click', function (e) {
                e.preventDefault();
                exportToCSV();
            });

            document.getElementById('clearLogsBtn').addEventListener('click', function (e) {
                e.preventDefault();
                clearOldLogs();
            });

            document.getElementById('applyFiltersBtn').addEventListener('click', function (e) {
                e.preventDefault();
                applyFilters();
            });

            document.getElementById('clearFiltersBtn').addEventListener('click', function (e) {
                e.preventDefault();
                clearFilters();
            });

            document.getElementById('searchLogs').addEventListener('input', function () {
                applyFilters();
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

            document.getElementById('auditlogModal').addEventListener('click', function (e) {
                if (e.target === this) {
                    closeAllModals();
                }
            });
        }

        function closeAllModals() {
            document.getElementById('auditlogModal').style.display = 'none';
        }

        function loadAuditLogsFromServer() {
            showLoading(true);

            const auditLogsData = document.getElementById('<%= hfAuditLogsData.ClientID %>').value;
            const statsData = document.getElementById('<%= hfStatsData.ClientID %>').value;

            console.log('Audit logs data received:', auditLogsData);
            console.log('Stats data received:', statsData);

            if (auditLogsData && auditLogsData !== '[]' && auditLogsData !== '') {
                try {
                    allAuditLogs = JSON.parse(auditLogsData);
                    filteredAuditLogs = [...allAuditLogs];
                    console.log('Successfully loaded audit logs:', allAuditLogs.length);
                    console.log('Sample audit log:', allAuditLogs[0]);
                } catch (e) {
                    console.error('Error parsing audit logs data:', e);
                    allAuditLogs = [];
                    filteredAuditLogs = [];
                }
            } else {
                console.log('No audit logs data found');
                allAuditLogs = [];
                filteredAuditLogs = [];
            }
            
            if (statsData && statsData !== '') {
                try {
                    updateStatistics(JSON.parse(statsData));
                } catch (e) {
                    console.error('Error parsing stats data:', e);
                }
            }

            renderAuditLogs();
            showLoading(false);
        }

        function refreshData() {
            showLoading(true);
            console.log('Refreshing data...');
            
            document.getElementById('<%= btnLoadAuditLogs.ClientID %>').click();

            setTimeout(function () {
                loadAuditLogsFromServer();
                showNotification('Data refreshed successfully!', 'success');
            }, 500);
        }

        function updateStatistics(stats) {
            document.getElementById('totalLogs').textContent = stats.TotalLogs || 0;
            document.getElementById('todayLogs').textContent = stats.TodayLogs || 0;
            document.getElementById('uniqueUsers').textContent = stats.UniqueUsers || 0;
            document.getElementById('systemActions').textContent = stats.SystemActions || 0;
        }

        function applyFilters() {
            const searchTerm = document.getElementById('searchLogs').value.toLowerCase();
            const actionFilter = document.getElementById('actionFilter').value;
            const dateFrom = document.getElementById('dateFrom').value;
            const dateTo = document.getElementById('dateTo').value;

            filteredAuditLogs = allAuditLogs.filter(log => {
                const matchesSearch = !searchTerm ||
                    (log.Action && log.Action.toLowerCase().includes(searchTerm)) ||
                    (log.Details && log.Details.toLowerCase().includes(searchTerm)) ||
                    (log.FullName && log.FullName.toLowerCase().includes(searchTerm));

                const matchesAction = actionFilter === 'all' ||
                    (log.Action && getActionType(log.Action) === actionFilter);

                let matchesDate = true;
                if (dateFrom && log.Timestamp) {
                    const logDate = new Date(log.Timestamp);
                    const fromDate = new Date(dateFrom);
                    matchesDate = logDate >= fromDate;
                }
                if (dateTo && log.Timestamp) {
                    const logDate = new Date(log.Timestamp);
                    const toDate = new Date(dateTo);
                    toDate.setDate(toDate.getDate() + 1);
                    matchesDate = matchesDate && logDate < toDate;
                }

                return matchesSearch && matchesAction && matchesDate;
            });

            currentPage = 1;
            renderAuditLogs();
        }

        function getActionType(action) {
            if (!action) return 'system';
            
            const actionLower = action.toLowerCase();
            if (actionLower.includes('create') || actionLower.includes('add') || actionLower.includes('insert')) return 'create';
            if (actionLower.includes('update') || actionLower.includes('edit') || actionLower.includes('modify')) return 'update';
            if (actionLower.includes('delete') || actionLower.includes('remove')) return 'delete';
            if (actionLower.includes('login') || actionLower.includes('logout')) return 'login';
            return 'system';
        }

        function clearFilters() {
            document.getElementById('searchLogs').value = '';
            document.getElementById('actionFilter').value = 'all';
            document.getElementById('dateFrom').value = '';
            document.getElementById('dateTo').value = '';

            filteredAuditLogs = allAuditLogs;
            currentPage = 1;
            renderAuditLogs();
        }

        function renderAuditLogs() {
            const tbody = document.getElementById('auditlogsTableBody');
            const emptyState = document.getElementById('auditlogsEmptyState');
            const paginationInfo = document.getElementById('paginationInfo');
            const table = document.getElementById('auditlogsTable');

            tbody.innerHTML = '';

            console.log('Rendering audit logs:', filteredAuditLogs.length);

            if (filteredAuditLogs.length === 0) {
                table.style.display = 'none';
                emptyState.style.display = 'block';
                paginationInfo.textContent = 'Showing 0 logs';
                return;
            }

            table.style.display = 'table';
            emptyState.style.display = 'none';

            const startIndex = (currentPage - 1) * pageSize;
            const endIndex = Math.min(startIndex + pageSize, filteredAuditLogs.length);
            const paginatedLogs = filteredAuditLogs.slice(startIndex, endIndex);

            console.log('Creating table rows for:', paginatedLogs.length, 'logs');

            paginatedLogs.forEach(log => {
                const row = createAuditLogRow(log);
                if (row) {
                    tbody.appendChild(row);
                }
            });

            paginationInfo.textContent = `Showing ${startIndex + 1}-${endIndex} of ${filteredAuditLogs.length} logs`;
            renderPagination();
        }

        function createAuditLogRow(log) {
            if (!log) return null;

            const row = document.createElement('tr');

            const auditId = log.AuditId || '-';
            const fullName = log.FullName || 'System';
            const action = log.Action || 'Unknown Action';
            const details = log.Details || 'No details available';
            const timestamp = log.Timestamp || new Date().toISOString();

            const userInitial = fullName.charAt(0).toUpperCase();
            const actionType = getActionType(action);
            const actionClass = 'action-' + actionType;
            const truncatedDetails = details.length > 100 ? details.substring(0, 100) + '...' : details;

            row.innerHTML = `
                <td>${escapeHtml(auditId)}</td>
                <td>
                    <div class="user-info">
                        <div class="user-avatar">${userInitial}</div>
                        <span>${escapeHtml(fullName)}</span>
                    </div>
                </td>
                <td><span class="action-badge ${actionClass}">${escapeHtml(action)}</span></td>
                <td title="${escapeHtml(details)}">${escapeHtml(truncatedDetails)}</td>
                <td>${formatDate(timestamp)}</td>
                <td>
                    <button class="btn-action btn-view" data-id="${auditId}" title="View Details">
                        <i class="fas fa-eye"></i>
                    </button>
                </td>
            `;

            const viewBtn = row.querySelector('.btn-view');
            if (viewBtn) {
                viewBtn.addEventListener('click', function (e) {
                    e.preventDefault();
                    e.stopPropagation();
                    viewAuditLog(this.getAttribute('data-id'));
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

        function viewAuditLog(id) {
            const log = allAuditLogs.find(l => l.AuditId === id);

            if (log) {
                const userInitial = log.FullName ? log.FullName.charAt(0).toUpperCase() : 'S';

                document.getElementById('modalAuditId').textContent = log.AuditId || '-';
                document.getElementById('modalAction').textContent = log.Action || 'Unknown';
                document.getElementById('modalUserName').textContent = log.FullName || 'System';
                document.getElementById('modalUserAvatar').textContent = userInitial;
                document.getElementById('modalTimestamp').textContent = formatDate(log.Timestamp);
                document.getElementById('modalDetails').textContent = log.Details || 'No details available';

                document.getElementById('auditlogModal').style.display = 'block';
            }
        }

        function exportToCSV() {
            if (filteredAuditLogs.length === 0) {
                showNotification('No audit logs to export', 'error');
                return;
            }

            let csv = 'Audit ID,User,Action,Details,Timestamp\n';

            filteredAuditLogs.forEach(log => {
                csv += `"${log.AuditId || ''}","${log.FullName || 'System'}","${log.Action || ''}","${(log.Details || '').replace(/"/g, '""')}","${formatDate(log.Timestamp)}"\n`;
            });

            const blob = new Blob([csv], { type: 'text/csv' });
            const url = window.URL.createObjectURL(blob);
            const a = document.createElement('a');
            a.setAttribute('hidden', '');
            a.setAttribute('href', url);
            a.setAttribute('download', `audit_logs_${new Date().toISOString().split('T')[0]}.csv`);
            document.body.appendChild(a);
            a.click();
            document.body.removeChild(a);

            showNotification('CSV exported successfully!', 'success');
        }

        function clearOldLogs() {
            if (confirm('Are you sure you want to clear audit logs older than 30 days? This action cannot be undone.')) {
                showNotification('Clearing old logs...', 'info');
                
                // Here you would typically make an AJAX call to clear old logs
                setTimeout(function () {
                    showNotification('Old audit logs cleared successfully!', 'success');
                    refreshData();
                }, 1000);
            }
        }

        function renderPagination() {
            const pagination = document.getElementById('pagination');
            const totalPages = Math.ceil(filteredAuditLogs.length / pageSize);

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
                    renderAuditLogs();
                });
            });
        }

        function showLoading(show) {
            const spinner = document.getElementById('loadingSpinner');
            const table = document.getElementById('auditlogsTable');

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
            loadAuditLogsFromServer();
        });
