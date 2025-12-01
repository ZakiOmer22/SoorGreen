
        // Load data from hidden fields on page load
        document.addEventListener('DOMContentLoaded', function () {
            const leaderboardData = JSON.parse(document.getElementById('<%= hfLeaderboardData.ClientID %>').value);
            const statsData = JSON.parse(document.getElementById('<%= hfStatsData.ClientID %>').value);
            const currentTab = document.getElementById('<%= hfCurrentTab.ClientID %>').value;
            const currentPeriod = document.getElementById('<%= hfCurrentPeriod.ClientID %>').value;

            // Set filter values
            document.getElementById('tabFilter').value = currentTab;
            document.getElementById('periodFilter').value = currentPeriod;

            updateLeaderboardTable(leaderboardData);
            updateStats(statsData);
            setupEventListeners();
        });

        function setupEventListeners() {
            document.getElementById('tabFilter').addEventListener('change', function () {
                applyFilters();
            });

            document.getElementById('periodFilter').addEventListener('change', function () {
                applyFilters();
            });
        }

        function updateLeaderboardTable(data) {
            const tbody = document.getElementById('leaderboardTableBody');

            if (!data || data.length === 0) {
                document.getElementById('emptyState').style.display = 'block';
                document.querySelector('.table-responsive').style.display = 'none';
                document.getElementById('paginationContainer').style.display = 'none';
                document.getElementById('resultsInfo').textContent = 'Showing 0 users';
                return;
            }

            let html = '';

            data.forEach(function (user) {
                const rankClass = user.rank <= 3 ? 'rank-' + user.rank : 'rank-other';
                const userClass = user.isCurrentUser ? 'current-user' : '';

                html += `
                <tr class="${userClass}">
                    <td>
                        <div class="rank-badge ${rankClass}">
                            ${user.rank}
                        </div>
                    </td>
                    <td>
                        <div class="d-flex align-items-center gap-3">
                            <div class="user-avatar">${user.avatar || 'US'}</div>
                            <div>
                                <div class="fw-bold text-light">${user.name || 'Anonymous User'}</div>
                                <div class="text-muted small">${user.email || ''}</div>
                            </div>
                        </div>
                    </td>
                    <td>
                        <span class="level-badge">Level ${user.level || 1}</span>
                    </td>
                    <td>
                        <span class="xp-badge">
                            <i class="fas fa-star"></i>
                            ${user.xp || 0}
                        </span>
                    </td>
                    <td>${user.pickups || 0}</td>
                    <td>${user.achievements || 0}</td>
                    <td>${(user.co2Reduced || 0).toFixed(1)}T</td>
                </tr>
            `;
            });

            tbody.innerHTML = html;
            document.getElementById('emptyState').style.display = 'none';
            document.querySelector('.table-responsive').style.display = 'block';
            document.getElementById('paginationContainer').style.display = data.length > 0 ? 'flex' : 'none';
            document.getElementById('resultsInfo').textContent = 'Showing ' + data.length + ' users';
        }

        function updateStats(stats) {
            if (!stats) return;

            document.getElementById('totalUsers').textContent = stats.TotalUsers || 0;
            document.getElementById('totalXP').textContent = formatNumber(stats.TotalXP || 0);
            document.getElementById('totalPickups').textContent = formatNumber(stats.TotalPickups || 0);
            document.getElementById('co2Reduced').textContent = formatNumber(stats.TotalCO2Reduced || 0) + 'T';
        }

        function formatNumber(number) {
            if (number >= 1000000) {
                return (number / 1000000).toFixed(1) + 'M';
            } else if (number >= 1000) {
                return (number / 1000).toFixed(1) + 'K';
            }
            return number;
        }

        function applyFilters() {
            showNotification('Applying filters...', 'info');
            document.getElementById('<%= btnApplyFilters.ClientID %>').click();
        }

        function clearFilters() {
            document.getElementById('tabFilter').value = 'global';
            document.getElementById('periodFilter').value = 'all';
            applyFilters();
        }

        function changePage(direction) {
            showNotification('Loading page...', 'info');
        }

        function showNotification(message, type) {
            const existingNotifications = document.querySelectorAll('.custom-notification');
            existingNotifications.forEach(function (notification) {
                notification.remove();
            });

            const notification = document.createElement('div');
            notification.className = 'custom-notification notification-' + type;
            notification.innerHTML = `
                <i class="fas ${type === 'success' ? 'fa-check-circle' : type === 'error' ? 'fa-exclamation-circle' : 'fa-info-circle'}"></i>
                <span>${message}</span>
                <button onclick="this.parentElement.remove()">&times;</button>
            `;

            document.body.appendChild(notification);

            setTimeout(function () {
                if (notification.parentElement) {
                    notification.remove();
                }
            }, 5000);
        }