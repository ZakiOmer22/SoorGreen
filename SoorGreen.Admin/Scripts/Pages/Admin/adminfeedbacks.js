
        // GLOBAL VARIABLES
        let currentView = 'grid';
        let currentPage = 1;
        const feedbacksPerPage = 6;
        let filteredFeedbacks = [];
        let allFeedbacks = [];
        let currentFeedbackId = null;
        let currentDeleteFeedbackId = null;

        // INITIALIZE
        document.addEventListener('DOMContentLoaded', function () {
            initializeEventListeners();
            loadFeedbacksFromServer();
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
            document.getElementById('searchFeedbacks').addEventListener('input', function (e) {
                applyFilters();
            });

            // Filter dropdowns
            document.getElementById('statusFilter').addEventListener('change', function (e) {
                applyFilters();
            });

            document.getElementById('ratingFilter').addEventListener('change', function (e) {
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

            document.getElementById('exportBtn').addEventListener('click', function (e) {
                e.preventDefault();
                exportToCSV();
            });

            document.getElementById('markAllReviewedBtn').addEventListener('click', function (e) {
                e.preventDefault();
                markAllReviewed();
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

            document.getElementById('cancelDeleteBtn').addEventListener('click', function (e) {
                e.preventDefault();
                closeAllModals();
            });

            document.getElementById('saveResponseBtn').addEventListener('click', function (e) {
                e.preventDefault();
                saveResponse();
            });

            document.getElementById('deleteFeedbackBtn').addEventListener('click', function (e) {
                e.preventDefault();
                openDeleteModal(currentFeedbackId);
            });

            document.getElementById('confirmDeleteBtn').addEventListener('click', function (e) {
                e.preventDefault();
                confirmDelete();
            });

            // Close modals when clicking outside
            document.getElementById('feedbackModal').addEventListener('click', function (e) {
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

            renderFeedbacks();
        }

        function loadFeedbacksFromServer() {
            showLoading(true);

            const feedbacksData = document.getElementById('<%= hfFeedbacksData.ClientID %>').value;
            const statsData = document.getElementById('<%= hfStatsData.ClientID %>').value;

            console.log('Feedbacks data received:', feedbacksData);
            console.log('Stats data received:', statsData);

            if (feedbacksData && feedbacksData !== '[]' && feedbacksData !== '') {
                try {
                    allFeedbacks = JSON.parse(feedbacksData);
                    filteredFeedbacks = [...allFeedbacks];
                    console.log('Successfully loaded feedbacks:', allFeedbacks.length);
                } catch (e) {
                    console.error('Error parsing feedbacks data:', e);
                    allFeedbacks = [];
                    filteredFeedbacks = [];
                }
            } else {
                console.log('No feedbacks data found');
                allFeedbacks = [];
                filteredFeedbacks = [];
            }
            
            if (statsData && statsData !== '') {
                try {
                    updateStatistics(JSON.parse(statsData));
                } catch (e) {
                    console.error('Error parsing stats data:', e);
                }
            }

            renderFeedbacks();
            showLoading(false);
        }

        function updateStatistics(stats) {
            document.getElementById('totalFeedbacks').textContent = stats.TotalFeedbacks || 0;
            document.getElementById('pendingFeedbacks').textContent = stats.PendingFeedbacks || 0;
            document.getElementById('averageRating').textContent = stats.AverageRating || '0.0';
            document.getElementById('resolvedFeedbacks').textContent = stats.ResolvedFeedbacks || 0;
        }

        function applyFilters() {
            const searchTerm = document.getElementById('searchFeedbacks').value.toLowerCase();
            const statusFilter = document.getElementById('statusFilter').value;
            const ratingFilter = document.getElementById('ratingFilter').value;
            const dateFilter = document.getElementById('dateFilter').value;

            filteredFeedbacks = allFeedbacks.filter(feedback => {
                // Search filter
                const matchesSearch = !searchTerm ||
                    (feedback.Subject && feedback.Subject.toLowerCase().includes(searchTerm)) ||
                    (feedback.Message && feedback.Message.toLowerCase().includes(searchTerm)) ||
                    (feedback.FullName && feedback.FullName.toLowerCase().includes(searchTerm));

                // Status filter
                const matchesStatus = statusFilter === 'all' || feedback.Status === statusFilter;

                // Rating filter
                const matchesRating = ratingFilter === 'all' || feedback.Rating == ratingFilter;

                // Date filter
                let matchesDate = true;
                if (dateFilter !== 'all' && feedback.SubmittedDate) {
                    const feedbackDate = new Date(feedback.SubmittedDate);
                    const today = new Date();
                    
                    switch (dateFilter) {
                        case 'today':
                            matchesDate = feedbackDate.toDateString() === today.toDateString();
                            break;
                        case 'week':
                            const weekAgo = new Date(today);
                            weekAgo.setDate(today.getDate() - 7);
                            matchesDate = feedbackDate >= weekAgo;
                            break;
                        case 'month':
                            const monthAgo = new Date(today);
                            monthAgo.setMonth(today.getMonth() - 1);
                            matchesDate = feedbackDate >= monthAgo;
                            break;
                        case 'year':
                            const yearAgo = new Date(today);
                            yearAgo.setFullYear(today.getFullYear() - 1);
                            matchesDate = feedbackDate >= yearAgo;
                            break;
                    }
                }

                return matchesSearch && matchesStatus && matchesRating && matchesDate;
            });

            currentPage = 1;
            renderFeedbacks();
            updatePageInfo();
        }

        function clearFilters() {
            document.getElementById('searchFeedbacks').value = '';
            document.getElementById('statusFilter').value = 'all';
            document.getElementById('ratingFilter').value = 'all';
            document.getElementById('dateFilter').value = 'all';

            filteredFeedbacks = allFeedbacks;
            currentPage = 1;
            renderFeedbacks();
            updatePageInfo();
        }

        function renderFeedbacks() {
            if (currentView === 'grid') {
                renderGridView();
            } else {
                renderTableView();
            }
            updatePagination();
        }

        function renderGridView() {
            const gridContainer = document.getElementById('feedbacksGrid');
            const emptyState = document.getElementById('feedbacksEmptyState');

            gridContainer.innerHTML = '';

            const startIndex = (currentPage - 1) * feedbacksPerPage;
            const endIndex = Math.min(startIndex + feedbacksPerPage, filteredFeedbacks.length);
            const currentFeedbacks = filteredFeedbacks.slice(startIndex, endIndex);

            if (currentFeedbacks.length === 0) {
                gridContainer.style.display = 'none';
                emptyState.style.display = 'block';
                return;
            }

            gridContainer.style.display = 'grid';
            emptyState.style.display = 'none';

            currentFeedbacks.forEach(feedback => {
                const card = createFeedbackCard(feedback);
                if (card) {
                    gridContainer.appendChild(card);
                }
            });
        }

        function renderTableView() {
            const tableBody = document.getElementById('feedbacksTableBody');
            const emptyState = document.getElementById('feedbacksEmptyState');
            const table = document.getElementById('feedbacksTable');

            tableBody.innerHTML = '';

            const startIndex = (currentPage - 1) * feedbacksPerPage;
            const endIndex = Math.min(startIndex + feedbacksPerPage, filteredFeedbacks.length);
            const currentFeedbacks = filteredFeedbacks.slice(startIndex, endIndex);

            if (currentFeedbacks.length === 0) {
                table.style.display = 'none';
                emptyState.style.display = 'block';
                return;
            }

            table.style.display = 'table';
            emptyState.style.display = 'none';

            currentFeedbacks.forEach(feedback => {
                const row = createTableRow(feedback);
                if (row) {
                    tableBody.appendChild(row);
                }
            });
        }

        function createFeedbackCard(feedback) {
            if (!feedback) return null;

            const card = document.createElement('div');
            card.className = 'feedback-card';
            
            const statusClass = `status-${feedback.Status.toLowerCase()}`;
            const userInitial = feedback.FullName ? feedback.FullName.charAt(0).toUpperCase() : 'U';
            const ratingStars = getRatingStars(feedback.Rating);
            const truncatedMessage = feedback.Message && feedback.Message.length > 150 ? 
                feedback.Message.substring(0, 150) + '...' : feedback.Message;

            card.innerHTML = `
                <div class="feedback-header">
                    <div class="feedback-info">
                        <h3 class="feedback-title">${escapeHtml(feedback.Subject || 'No Subject')}</h3>
                        <p class="feedback-user">
                            <i class="fas fa-user me-2"></i>${escapeHtml(feedback.FullName || 'Anonymous')}
                        </p>
                    </div>
                    <div class="feedback-actions">
                        <a href="#" class="btn-action btn-view view-feedback" data-id="${feedback.FeedbackId}">
                            <i class="fas fa-eye me-1"></i>View
                        </a>
                        <a href="#" class="btn-action btn-reply reply-feedback" data-id="${feedback.FeedbackId}">
                            <i class="fas fa-reply me-1"></i>Reply
                        </a>
                        ${feedback.Status !== 'Resolved' ? `
                            <a href="#" class="btn-action btn-resolve resolve-feedback" data-id="${feedback.FeedbackId}">
                                <i class="fas fa-check me-1"></i>Resolve
                            </a>
                        ` : ''}
                    </div>
                </div>
                
                <div class="feedback-content">
                    <div class="feedback-message">
                        ${escapeHtml(truncatedMessage || 'No message provided')}
                    </div>
                </div>
                
                <div class="feedback-details">
                    <div class="detail-item">
                        <div class="detail-value">${feedback.Rating || 0}</div>
                        <div class="detail-label">Rating</div>
                    </div>
                    <div class="detail-item">
                        <div class="detail-value">${feedback.Category || 'General'}</div>
                        <div class="detail-label">Category</div>
                    </div>
                </div>
                
                <div class="feedback-meta">
                    <div class="feedback-status">
                        <span class="status-badge ${statusClass}">${feedback.Status}</span>
                        <small>${formatDate(feedback.SubmittedDate)}</small>
                    </div>
                    <div class="rating-stars">
                        ${ratingStars}
                    </div>
                </div>
            `;
            
            // Add event listeners
            card.querySelector('.view-feedback').addEventListener('click', function(e) {
                e.preventDefault();
                viewFeedbackDetails(this.getAttribute('data-id'));
            });

            card.querySelector('.reply-feedback').addEventListener('click', function(e) {
                e.preventDefault();
                viewFeedbackDetails(this.getAttribute('data-id'));
            });

            if (card.querySelector('.resolve-feedback')) {
                card.querySelector('.resolve-feedback').addEventListener('click', function(e) {
                    e.preventDefault();
                    resolveFeedback(this.getAttribute('data-id'));
                });
            }

            return card;
        }

        function createTableRow(feedback) {
            if (!feedback) return null;

            const row = document.createElement('tr');
            
            const statusClass = `status-${feedback.Status.toLowerCase()}`;
            const userInitial = feedback.FullName ? feedback.FullName.charAt(0).toUpperCase() : 'U';
            const ratingStars = getRatingStars(feedback.Rating);

            row.innerHTML = `
                <td>${feedback.FeedbackId}</td>
                <td>
                    <div class="user-info">
                        <div class="user-avatar">${userInitial}</div>
                        ${escapeHtml(feedback.FullName || 'Anonymous')}
                    </div>
                </td>
                <td>${escapeHtml(feedback.Subject || 'No Subject')}</td>
                <td>
                    <div class="rating-stars">
                        ${ratingStars}
                    </div>
                </td>
                <td><span class="status-badge ${statusClass}">${feedback.Status}</span></td>
                <td>${formatDate(feedback.SubmittedDate)}</td>
                <td>
                    <div class="d-flex gap-1">
                        <a href="#" class="btn-action btn-view view-feedback" data-id="${feedback.FeedbackId}" title="View Details">
                            <i class="fas fa-eye"></i>
                        </a>
                        <a href="#" class="btn-action btn-reply reply-feedback" data-id="${feedback.FeedbackId}" title="Reply">
                            <i class="fas fa-reply"></i>
                        </a>
                        ${feedback.Status !== 'Resolved' ? `
                            <a href="#" class="btn-action btn-resolve resolve-feedback" data-id="${feedback.FeedbackId}" title="Resolve">
                                <i class="fas fa-check"></i>
                            </a>
                        ` : ''}
                    </div>
                </td>
            `;
            
            // Add event listeners
            row.querySelector('.view-feedback').addEventListener('click', function(e) {
                e.preventDefault();
                viewFeedbackDetails(this.getAttribute('data-id'));
            });

            row.querySelector('.reply-feedback').addEventListener('click', function(e) {
                e.preventDefault();
                viewFeedbackDetails(this.getAttribute('data-id'));
            });

            if (row.querySelector('.resolve-feedback')) {
                row.querySelector('.resolve-feedback').addEventListener('click', function(e) {
                    e.preventDefault();
                    resolveFeedback(this.getAttribute('data-id'));
                });
            }

            return row;
        }

        function getRatingStars(rating) {
            if (!rating) return '<i class="far fa-star"></i>'.repeat(5);
            
            const fullStars = Math.floor(rating);
            const halfStar = rating % 1 >= 0.5;
            const emptyStars = 5 - fullStars - (halfStar ? 1 : 0);
            
            let stars = '';
            
            // Full stars
            for (let i = 0; i < fullStars; i++) {
                stars += '<i class="fas fa-star"></i>';
            }
            
            // Half star
            if (halfStar) {
                stars += '<i class="fas fa-star-half-alt"></i>';
            }
            
            // Empty stars
            for (let i = 0; i < emptyStars; i++) {
                stars += '<i class="far fa-star"></i>';
            }
            
            return stars;
        }

        function viewFeedbackDetails(feedbackId) {
            const feedback = allFeedbacks.find(f => f.FeedbackId === feedbackId);
            if (!feedback) return;
            
            currentFeedbackId = feedbackId;
            
            const userInitial = feedback.FullName ? feedback.FullName.charAt(0).toUpperCase() : 'U';
            const ratingStars = getRatingStars(feedback.Rating);

            document.getElementById('modalFeedbackId').textContent = feedback.FeedbackId || '-';
            document.getElementById('modalStatus').textContent = feedback.Status || '-';
            document.getElementById('modalUserName').textContent = feedback.FullName || 'Anonymous';
            document.getElementById('modalUserAvatar').textContent = userInitial;
            document.getElementById('modalRating').innerHTML = `${ratingStars} (${feedback.Rating || 0}/5)`;
            document.getElementById('modalSubmittedDate').textContent = formatDate(feedback.SubmittedDate);
            document.getElementById('modalCategory').textContent = feedback.Category || 'General';
            document.getElementById('modalSubject').textContent = feedback.Subject || 'No Subject';
            document.getElementById('modalMessage').textContent = feedback.Message || 'No message provided';
            
            // Set current status in dropdown
            document.getElementById('updateStatus').value = feedback.Status || 'Pending';
            
            // Clear reply textarea
            document.getElementById('adminReply').value = '';
            
            // Show/hide previous replies
            const previousReplies = document.getElementById('previousReplies');
            const previousReplyContent = document.getElementById('previousReplyContent');
            
            if (feedback.AdminReply) {
                previousReplies.style.display = 'block';
                previousReplyContent.innerHTML = `
                    <p><strong>Admin Response:</strong></p>
                    <p>${escapeHtml(feedback.AdminReply)}</p>
                    <small class="text-muted">Last updated: ${formatDate(feedback.AdminReplyDate)}</small>
                `;
            } else {
                previousReplies.style.display = 'none';
            }
            
            document.getElementById('feedbackModal').style.display = 'block';
        }

        function resolveFeedback(feedbackId) {
            if (confirm('Are you sure you want to mark this feedback as resolved?')) {
                // Simulate API call
                showLoading(true);
                
                setTimeout(() => {
                    const feedbackIndex = allFeedbacks.findIndex(f => f.FeedbackId === feedbackId);
                    if (feedbackIndex !== -1) {
                        allFeedbacks[feedbackIndex].Status = 'Resolved';
                        showNotification('Feedback marked as resolved!', 'success');
                        refreshData();
                    }
                    showLoading(false);
                }, 500);
            }
        }

        function saveResponse() {
            const reply = document.getElementById('adminReply').value.trim();
            const newStatus = document.getElementById('updateStatus').value;

            if (!reply && newStatus === 'Pending') {
                showNotification('Please enter a response or change the status', 'error');
                return;
            }

            showLoading(true);

            // Simulate API call
            setTimeout(() => {
                const feedbackIndex = allFeedbacks.findIndex(f => f.FeedbackId === currentFeedbackId);
                if (feedbackIndex !== -1) {
                    if (reply) {
                        allFeedbacks[feedbackIndex].AdminReply = reply;
                        allFeedbacks[feedbackIndex].AdminReplyDate = new Date().toISOString();
                    }
                    allFeedbacks[feedbackIndex].Status = newStatus;
                    
                    showNotification('Response saved successfully!', 'success');
                    closeAllModals();
                    refreshData();
                }
                showLoading(false);
            }, 800);
        }

        function openDeleteModal(feedbackId) {
            document.getElementById('deleteModal').style.display = 'block';
            currentDeleteFeedbackId = feedbackId;
            document.getElementById('deleteFeedbackId').textContent = feedbackId;
        }

        function confirmDelete() {
            if (currentDeleteFeedbackId) {
                showLoading(true);

                // Simulate API call
                setTimeout(() => {
                    const feedbackIndex = allFeedbacks.findIndex(f => f.FeedbackId === currentDeleteFeedbackId);
                    if (feedbackIndex !== -1) {
                        allFeedbacks.splice(feedbackIndex, 1);
                        showNotification('Feedback deleted successfully!', 'success');
                        closeAllModals();
                        refreshData();
                    }
                    showLoading(false);
                }, 800);
            }
        }

        function markAllReviewed() {
            if (confirm('Are you sure you want to mark all pending feedbacks as reviewed?')) {
                showLoading(true);
                
                // Simulate API call
                setTimeout(() => {
                    allFeedbacks.forEach(feedback => {
                        if (feedback.Status === 'Pending') {
                            feedback.Status = 'Reviewed';
                        }
                    });
                    showNotification('All pending feedbacks marked as reviewed!', 'success');
                    refreshData();
                    showLoading(false);
                }, 800);
            }
        }

        function exportToCSV() {
            if (filteredFeedbacks.length === 0) {
                showNotification('No feedbacks to export', 'error');
                return;
            }

            let csv = 'Feedback ID,User,Subject,Rating,Category,Status,Submitted Date,Message\n';

            filteredFeedbacks.forEach(feedback => {
                csv += `"${feedback.FeedbackId || ''}","${feedback.FullName || 'Anonymous'}","${feedback.Subject || ''}","${feedback.Rating || 0}","${feedback.Category || 'General'}","${feedback.Status || 'Pending'}","${formatDate(feedback.SubmittedDate)}","${(feedback.Message || '').replace(/"/g, '""')}"\n`;
            });

            const blob = new Blob([csv], { type: 'text/csv' });
            const url = window.URL.createObjectURL(blob);
            const a = document.createElement('a');
            a.setAttribute('hidden', '');
            a.setAttribute('href', url);
            a.setAttribute('download', `feedbacks_${new Date().toISOString().split('T')[0]}.csv`);
            document.body.appendChild(a);
            a.click();
            document.body.removeChild(a);

            showNotification('CSV exported successfully!', 'success');
        }

        function refreshData() {
            showLoading(true);
            document.getElementById('<%= btnLoadFeedbacks.ClientID %>').click();

            setTimeout(function () {
                loadFeedbacksFromServer();
                showNotification('Data refreshed successfully!', 'success');
            }, 500);
        }

        function closeAllModals() {
            document.getElementById('feedbackModal').style.display = 'none';
            document.getElementById('deleteModal').style.display = 'none';
            currentFeedbackId = null;
            currentDeleteFeedbackId = null;
        }

        function updatePagination() {
            const pagination = document.getElementById('pagination');
            const totalPages = Math.ceil(filteredFeedbacks.length / feedbacksPerPage);

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
                    renderFeedbacks();
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
                    renderFeedbacks();
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
                    renderFeedbacks();
                    updatePagination();
                    updatePageInfo();
                });
            }
            pagination.appendChild(nextLi);
        }

        function updatePageInfo() {
            const startIndex = (currentPage - 1) * feedbacksPerPage + 1;
            const endIndex = Math.min(startIndex + feedbacksPerPage - 1, filteredFeedbacks.length);
            const total = filteredFeedbacks.length;

            document.getElementById('pageInfo').textContent =
                total > 0 ? `Showing ${startIndex}-${endIndex} of ${total} feedbacks` : 'Showing 0 feedbacks';

            document.getElementById('paginationInfo').textContent =
                total > 0 ? `Page ${currentPage} of ${Math.ceil(total / feedbacksPerPage)}` : 'Page 1 of 1';
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
            loadFeedbacksFromServer();
        });
