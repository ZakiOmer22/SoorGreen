
    let allReports = [];
    let currentPage = 1;
    const pageSize = 10;
    let currentReportId = null;

    document.addEventListener('DOMContentLoaded', function () {
        loadInitialData();
    setupEventListeners();
        });


    function setupEventListeners() {
        // Apply filters button
        document.getElementById('applyFiltersBtn').addEventListener('click', function (e) {
            e.preventDefault();
            filterReports();
        });

    // Pagination
    document.getElementById('prevPageBtn').addEventListener('click', function (e) {
        e.preventDefault();
                if (currentPage > 1) {
        currentPage--;
    renderReports();
                }
            });

    document.getElementById('nextPageBtn').addEventListener('click', function (e) {
        e.preventDefault();
    const totalPages = Math.ceil(allReports.length / pageSize);
    if (currentPage < totalPages) {
        currentPage++;
    renderReports();
                }
            });

            // Close modals
            document.querySelectorAll('.close-modal').forEach(btn => {
        btn.addEventListener('click', function (e) {
            e.preventDefault();
            this.closest('.modal-overlay').style.display = 'none';
        });
            });

    document.getElementById('closeReportModalBtn').addEventListener('click', function (e) {
        e.preventDefault();
    document.getElementById('viewReportModal').style.display = 'none';
            });

    document.getElementById('cancelDeleteBtn').addEventListener('click', function (e) {
        e.preventDefault();
    document.getElementById('deleteConfirmationModal').style.display = 'none';
            });

    // Confirm delete
    document.getElementById('confirmDeleteBtn').addEventListener('click', function (e) {
        e.preventDefault();
    deleteReport(currentReportId);
            });

    // Generate report button
    document.getElementById('generateReportBtn').addEventListener('click', function (e) {
        e.preventDefault();
    generateReport();
            });

    // Enter key in search
    document.getElementById('searchReports').addEventListener('keypress', function (e) {
                if (e.key === 'Enter') {
        e.preventDefault();
    filterReports();
                }
            });
        }

    function filterReports() {
            const searchTerm = document.getElementById('searchReports').value.toLowerCase();
    const statusFilter = document.getElementById('statusFilter').value;
    const wasteTypeFilter = document.getElementById('wasteTypeFilter').value;


    let filteredReports = allReports;

    // Filter by search term
    if (searchTerm) {
        filteredReports = filteredReports.filter(report =>
            report.WasteType.toLowerCase().includes(searchTerm) ||
            report.Location.toLowerCase().includes(searchTerm) ||
            report.ReportId.toLowerCase().includes(searchTerm)
        );
            }

    // Filter by status
    if (statusFilter !== 'all') {
        filteredReports = filteredReports.filter(report =>
            report.Status.toLowerCase() === statusFilter.toLowerCase()
        );
            }

    // Filter by waste type
    if (wasteTypeFilter !== 'all') {
        filteredReports = filteredReports.filter(report =>
            report.WasteType.toLowerCase() === wasteTypeFilter.toLowerCase()
        );
            }

    allReports = filteredReports;
    currentPage = 1;
    renderReports();
        }

    function renderReports() {
            const tbody = document.getElementById('reportsTableBody');
    const emptyState = document.getElementById('reportsEmptyState');

    tbody.innerHTML = '';

    if (allReports.length === 0) {
        tbody.style.display = 'none';
    emptyState.style.display = 'block';
    updatePagination();
    return;
            }

    tbody.style.display = '';
    emptyState.style.display = 'none';

    // Calculate pagination
    const startIndex = (currentPage - 1) * pageSize;
    const endIndex = Math.min(startIndex + pageSize, allReports.length);
    const pageReports = allReports.slice(startIndex, endIndex);

            pageReports.forEach(report => {
        tbody.appendChild(createReportRow(report));
            });

    updatePagination();
        }

    function createReportRow(report) {
            const row = document.createElement('tr');
    const wasteType = report.WasteType || 'plastic';
    const wasteTypeClass = 'waste-' + wasteType.toLowerCase();
    const wasteIcon = getWasteIcon(wasteType);

    row.innerHTML = `
    <td>${report.ReportId}</td>
    <td>
        <div class="waste-info">
            <div class="waste-icon ${wasteTypeClass}">
                <i class="${wasteIcon}"></i>
            </div>
            <span>${report.WasteType}</span>
        </div>
    </td>
    <td>${report.Weight} kg</td>
    <td>${report.Location}</td>
    <td><span class="status-badge status-${report.Status.toLowerCase()}">${report.Status}</span></td>
    <td>${new Date(report.ReportedDate).toLocaleDateString()}</td>
    <td class="text-success">${report.XPEarned} XP</td>
    <td>
        <button class="btn-action btn-view" data-id="${report.ReportId}"><i class="fas fa-eye"></i></button>
        ${(report.Status === 'Pending' || report.Status === 'Scheduled') ? `
                    <button class="btn-action btn-edit" data-id="${report.ReportId}"><i class="fas fa-edit"></i></button>
                    <button class="btn-action btn-delete" data-id="${report.ReportId}"><i class="fas fa-trash"></i></button>
                    ` : ''}
    </td>
    `;

    // Add event listeners
    row.querySelector('.btn-view').addEventListener('click', function (e) {
        e.preventDefault();
    viewReport(this.getAttribute('data-id'));
            });

    if (report.Status === 'Pending' || report.Status === 'Scheduled') {
        row.querySelector('.btn-edit').addEventListener('click', function (e) {
            e.preventDefault();
            editReport(this.getAttribute('data-id'));
        });

    row.querySelector('.btn-delete').addEventListener('click', function (e) {
        e.preventDefault();
    confirmDelete(this.getAttribute('data-id'));
                });
            }

    return row;
        }

    function getWasteIcon(wasteType) {
            const icons = {
        'plastic': 'fas fa-wine-bottle',
    'paper': 'fas fa-newspaper',
    'glass': 'fas fa-wine-bottle',
    'metal': 'fas fa-cube',
    'ewaste': 'fas fa-laptop',
    'organic': 'fas fa-leaf'
            };
    return icons[wasteType.toLowerCase()] || 'fas fa-trash';
        }

    function viewReport(reportId) {
            const report = allReports.find(r => r.ReportId === reportId);
    if (report) {
        document.getElementById('viewReportId').textContent = report.ReportId;
    document.getElementById('viewReportStatus').textContent = report.Status;
    document.getElementById('viewWasteType').textContent = report.WasteType;
    document.getElementById('viewWeight').textContent = report.Weight + ' kg';
    document.getElementById('viewLocation').textContent = report.Location;
    document.getElementById('viewReportedDate').textContent = new Date(report.ReportedDate).toLocaleDateString();
    document.getElementById('viewXPEarned').textContent = report.XPEarned + ' XP';
    document.getElementById('viewDescription').textContent = report.Description;
    document.getElementById('viewInstructions').textContent = report.Instructions;

    document.getElementById('viewReportModal').style.display = 'block';
            }
        }

    function editReport(reportId) {
        showNotification('Edit functionality would be implemented here', 'info');
        }

    function confirmDelete(reportId) {
        currentReportId = reportId;
            const report = allReports.find(r => r.ReportId === reportId);
    if (report) {
        document.getElementById('deleteModalMessage').textContent =
        `Are you sure you want to delete report ${reportId}? This action cannot be undone.`;
    document.getElementById('deleteConfirmationModal').style.display = 'block';
            }
        }

    function deleteReport(reportId) {
        showNotification('Report ' + reportId + ' deleted successfully', 'success');
    document.getElementById('deleteConfirmationModal').style.display = 'none';

            // Remove from local array and re-render
            allReports = allReports.filter(r => r.ReportId !== reportId);
    renderReports();
        }

    function generateReport() {
        showNotification('Generating report... This would download a PDF file.', 'info');
        }

    function updatePagination() {
            const totalPages = Math.ceil(allReports.length / pageSize);
    const startItem = (currentPage - 1) * pageSize + 1;
    const endItem = Math.min(currentPage * pageSize, allReports.length);

    document.getElementById('pageInfo').textContent =
    `Showing ${startItem}-${endItem} of ${allReports.length} reports`;

    document.getElementById('prevPageBtn').disabled = currentPage === 1;
    document.getElementById('nextPageBtn').disabled = currentPage === totalPages || totalPages === 0;
        }

    function showNotification(message, type) {
            // Remove any existing notifications
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

            // Auto remove after 5 seconds
            setTimeout(() => {
                if (notification.parentElement) {
        notification.remove();
                }
            }, 5000);
        }