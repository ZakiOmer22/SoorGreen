
        let allTransactions = [];
        let filteredTransactions = [];
        let currentPage = 1;
        const pageSize = 10;

        document.addEventListener('DOMContentLoaded', function () {
            loadTransactionsFromServer();
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

            document.getElementById('applyFiltersBtn').addEventListener('click', function (e) {
                e.preventDefault();
                applyFilters();
            });

            document.getElementById('clearFiltersBtn').addEventListener('click', function (e) {
                e.preventDefault();
                clearFilters();
            });

            document.getElementById('searchTransactions').addEventListener('input', function () {
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

            document.getElementById('transactionModal').addEventListener('click', function (e) {
                if (e.target === this) {
                    closeAllModals();
                }
            });
        }

        function closeAllModals() {
            document.getElementById('transactionModal').style.display = 'none';
        }

        function loadTransactionsFromServer() {
            showLoading(true);

            const transactionsData = document.getElementById('<%= hfTransactionsData.ClientID %>').value;
        const statsData = document.getElementById('<%= hfStatsData.ClientID %>').value;

        console.log('Transactions data received:', transactionsData);
        console.log('Stats data received:', statsData);

        if (transactionsData && transactionsData !== '[]' && transactionsData !== '') {
            try {
                allTransactions = JSON.parse(transactionsData);
                filteredTransactions = [...allTransactions];
                console.log('Successfully loaded transactions:', allTransactions.length);
                console.log('Sample transaction:', allTransactions[0]);
            } catch (e) {
                console.error('Error parsing transactions data:', e);
                allTransactions = [];
                filteredTransactions = [];
            }
        } else {
            console.log('No transactions data found');
            allTransactions = [];
            filteredTransactions = [];
        }
        
        if (statsData && statsData !== '') {
            try {
                updateStatistics(JSON.parse(statsData));
            } catch (e) {
                console.error('Error parsing stats data:', e);
            }
        }

        renderTransactions();
        showLoading(false);
    }

    function refreshData() {
        showLoading(true);
        console.log('Refreshing data...');
        
        document.getElementById('<%= btnLoadTransactions.ClientID %>').click();

            setTimeout(function () {
                loadTransactionsFromServer();
                showNotification('Data refreshed successfully!', 'success');
            }, 500);
        }

        function updateStatistics(stats) {
            document.getElementById('totalTransactions').textContent = stats.TotalTransactions || 0;
            document.getElementById('totalCredits').textContent = stats.TotalCredits || 0;
            document.getElementById('avgTransaction').textContent = (stats.AvgTransaction || 0).toFixed(2);
            document.getElementById('todayTransactions').textContent = stats.TodayTransactions || 0;
        }

        function applyFilters() {
            const searchTerm = document.getElementById('searchTransactions').value.toLowerCase();
            const typeFilter = document.getElementById('typeFilter').value;
            const dateFrom = document.getElementById('dateFrom').value;
            const dateTo = document.getElementById('dateTo').value;

            filteredTransactions = allTransactions.filter(transaction => {
                const matchesSearch = !searchTerm ||
                    (transaction.FullName && transaction.FullName.toLowerCase().includes(searchTerm)) ||
                    (transaction.Reference && transaction.Reference.toLowerCase().includes(searchTerm)) ||
                    (transaction.Type && transaction.Type.toLowerCase().includes(searchTerm));

                const matchesType = typeFilter === 'all' ||
                    (transaction.Type && transaction.Type.toLowerCase() === typeFilter.toLowerCase());

                let matchesDate = true;
                if (dateFrom && transaction.CreatedAt) {
                    const transactionDate = new Date(transaction.CreatedAt);
                    const fromDate = new Date(dateFrom);
                    matchesDate = transactionDate >= fromDate;
                }
                if (dateTo && transaction.CreatedAt) {
                    const transactionDate = new Date(transaction.CreatedAt);
                    const toDate = new Date(dateTo);
                    toDate.setDate(toDate.getDate() + 1);
                    matchesDate = matchesDate && transactionDate < toDate;
                }

                return matchesSearch && matchesType && matchesDate;
            });

            currentPage = 1;
            renderTransactions();
        }

        function clearFilters() {
            document.getElementById('searchTransactions').value = '';
            document.getElementById('typeFilter').value = 'all';
            document.getElementById('dateFrom').value = '';
            document.getElementById('dateTo').value = '';

            filteredTransactions = allTransactions;
            currentPage = 1;
            renderTransactions();
        }

        function renderTransactions() {
            const tbody = document.getElementById('transactionsTableBody');
            const emptyState = document.getElementById('transactionsEmptyState');
            const paginationInfo = document.getElementById('paginationInfo');
            const table = document.getElementById('transactionsTable');

            tbody.innerHTML = '';

            console.log('Rendering transactions:', filteredTransactions.length);

            if (filteredTransactions.length === 0) {
                table.style.display = 'none';
                emptyState.style.display = 'block';
                paginationInfo.textContent = 'Showing 0 transactions';
                return;
            }

            table.style.display = 'table';
            emptyState.style.display = 'none';

            const startIndex = (currentPage - 1) * pageSize;
            const endIndex = Math.min(startIndex + pageSize, filteredTransactions.length);
            const paginatedTransactions = filteredTransactions.slice(startIndex, endIndex);

            console.log('Creating table rows for:', paginatedTransactions.length, 'transactions');

            paginatedTransactions.forEach(transaction => {
                const row = createTransactionRow(transaction);
                if (row) {
                    tbody.appendChild(row);
                }
            });

            paginationInfo.textContent = `Showing ${startIndex + 1}-${endIndex} of ${filteredTransactions.length} transactions`;
            renderPagination();
        }

        function createTransactionRow(transaction) {
            if (!transaction) return null;

            const row = document.createElement('tr');

            // Safely extract values with proper fallbacks
            const transactionId = transaction.RewardId || transaction.TransactionId || '-';
            const fullName = transaction.FullName || 'Unknown User';
            const amount = parseFloat(transaction.Amount) || 0;
            const type = transaction.Type || 'Unknown';
            const reference = transaction.Reference || '-';
            const createdAt = transaction.CreatedAt || new Date().toISOString();

            const userInitial = fullName.charAt(0).toUpperCase();
            const isPositive = amount > 0;
            const typeClass = 'type-' + type.toLowerCase().replace(/\s+/g, '-');

            row.innerHTML = `
            <td>${escapeHtml(transactionId)}</td>
            <td>
                <div class="user-info">
                    <div class="user-avatar">${userInitial}</div>
                    <span>${escapeHtml(fullName)}</span>
                </div>
            </td>
            <td class="${isPositive ? 'credit-positive' : 'credit-negative'}">
                ${isPositive ? '+' : ''}${amount} credits
            </td>
            <td><span class="type-badge ${typeClass}">${escapeHtml(type)}</span></td>
            <td>${escapeHtml(reference)}</td>
            <td>${formatDate(createdAt)}</td>
            <td>
                <button class="btn-action btn-view" data-id="${transactionId}" title="View Details">
                    <i class="fas fa-eye"></i>
                </button>
            </td>
        `;

            // Add event listener to view button
            const viewBtn = row.querySelector('.btn-view');
            if (viewBtn) {
                viewBtn.addEventListener('click', function (e) {
                    e.preventDefault();
                    e.stopPropagation();
                    viewTransaction(this.getAttribute('data-id'));
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

        function viewTransaction(id) {
            const transaction = allTransactions.find(t =>
                (t.RewardId === id) || (t.TransactionId === id)
            );

            if (transaction) {
                const userInitial = transaction.FullName ? transaction.FullName.charAt(0).toUpperCase() : 'U';

                document.getElementById('modalTransactionId').textContent = transaction.RewardId || transaction.TransactionId || '-';
                document.getElementById('modalType').textContent = transaction.Type || 'Credit';
                document.getElementById('modalUserName').textContent = transaction.FullName || 'Unknown';
                document.getElementById('modalUserAvatar').textContent = userInitial;
                document.getElementById('modalUserPhone').textContent = transaction.Phone || '-';
                document.getElementById('modalAmount').textContent = (transaction.Amount || 0) + ' credits';
                document.getElementById('modalReference').textContent = transaction.Reference || '-';
                document.getElementById('modalDate').textContent = formatDate(transaction.CreatedAt);
                document.getElementById('modalNotes').textContent = transaction.Notes || 'No additional notes';

                document.getElementById('transactionModal').style.display = 'block';
            }
        }

        function renderPagination() {
            const pagination = document.getElementById('pagination');
            const totalPages = Math.ceil(filteredTransactions.length / pageSize);

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
                    renderTransactions();
                });
            });
        }

        function exportToCSV() {
            if (filteredTransactions.length === 0) {
                showNotification('No transactions to export', 'error');
                return;
            }

            let csv = 'Transaction ID,User,Amount,Type,Reference,Date\n';

            filteredTransactions.forEach(transaction => {
                csv += `"${transaction.RewardId || ''}","${transaction.FullName || ''}",${transaction.Amount || 0},"${transaction.Type || ''}","${transaction.Reference || ''}","${formatDate(transaction.CreatedAt)}"\n`;
            });

            const blob = new Blob([csv], { type: 'text/csv' });
            const url = window.URL.createObjectURL(blob);
            const a = document.createElement('a');
            a.setAttribute('hidden', '');
            a.setAttribute('href', url);
            a.setAttribute('download', `transactions_${new Date().toISOString().split('T')[0]}.csv`);
            document.body.appendChild(a);
            a.click();
            document.body.removeChild(a);

            showNotification('CSV exported successfully!', 'success');
        }

        function showLoading(show) {
            const spinner = document.getElementById('loadingSpinner');
            const table = document.getElementById('transactionsTable');

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
            loadTransactionsFromServer();
        });