
       // GLOBAL VARIABLES
       let currentView = 'grid';
       let currentPage = 1;
       const reportsPerPage = 6;
       let filteredReports = [];
       let allReports = [];
       let allCollectors = [];
       let currentViewReportId = null;
       let currentDeleteReportId = null;
       let currentCreatePickupReportId = null;

       // INITIALIZE
       document.addEventListener('DOMContentLoaded', function () {
           initializeEventListeners();
           loadReportsFromServer();
           loadCollectorsFromServer();
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
           document.getElementById('searchReports').addEventListener('input', function (e) {
               applyFilters();
           });

           // Filter dropdowns
           document.getElementById('wasteTypeFilter').addEventListener('change', function (e) {
               applyFilters();
           });

           document.getElementById('dateFilter').addEventListener('change', function (e) {
               applyFilters();
           });

           document.getElementById('pickupFilter').addEventListener('change', function (e) {
               applyFilters();
           });

           // Modal close buttons
           document.querySelector('#viewReportModal .close-modal').addEventListener('click', closeViewReportModal);
           document.querySelector('#createPickupModal .close-modal').addEventListener('click', closeCreatePickupModal);
           document.querySelector('#deleteReportModal .close-modal').addEventListener('click', closeDeleteModal);

           document.getElementById('closeViewModalBtn').addEventListener('click', closeViewReportModal);
           document.getElementById('cancelCreatePickupBtn').addEventListener('click', closeCreatePickupModal);
           document.getElementById('cancelDeleteBtn').addEventListener('click', closeDeleteModal);

           document.getElementById('createPickupBtn').addEventListener('click', openCreatePickupModal);
           document.getElementById('confirmCreatePickupBtn').addEventListener('click', confirmCreatePickup);
           document.getElementById('confirmDeleteBtn').addEventListener('click', confirmDelete);

           // Close modals when clicking outside
           document.getElementById('viewReportModal').addEventListener('click', function (e) {
               if (e.target === this) closeViewReportModal();
           });
           document.getElementById('createPickupModal').addEventListener('click', function (e) {
               if (e.target === this) closeCreatePickupModal();
           });
           document.getElementById('deleteReportModal').addEventListener('click', function (e) {
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

           renderReports();
       }

       function loadReportsFromServer() {
           showLoading();

           const reportsData = document.getElementById('<%= hfReportsData.ClientID %>').value;

           if (reportsData && reportsData !== '') {
               try {
                   allReports = JSON.parse(reportsData);
                   filteredReports = [...allReports];

                   renderReports();
                   updatePagination();
                   updatePageInfo();
                   hideLoading();

                   if (filteredReports.length > 0) {
                       showSuccess('Loaded ' + filteredReports.length + ' waste reports from database');
                   } else {
                       showInfo('No waste reports found in database');
                   }

               } catch (e) {
                   console.error('Error parsing report data:', e);
                   showError('Error loading waste report data from database');
                   hideLoading();
               }
           } else {
               showError('No waste report data available from database');
               hideLoading();
           }
       }

       function loadCollectorsFromServer() {
           const collectorsData = document.getElementById('<%= hfCollectorsList.ClientID %>').value;
           if (collectorsData && collectorsData !== '') {
               try {
                   allCollectors = JSON.parse(collectorsData);
                   populateCollectorSelect();
               } catch (e) {
                   console.error('Error parsing collectors data:', e);
               }
           }
       }

       function populateCollectorSelect() {
           const select = document.getElementById('collectorSelect');
           select.innerHTML = '<option value="">Select a collector...</option>';

           allCollectors.forEach(collector => {
               const option = document.createElement('option');
               option.value = collector.Id;
               option.textContent = collector.FirstName + ' ' + collector.LastName + ' (' + collector.Status + ')';
               select.appendChild(option);
           });
       }

       function showNotification(message, type = 'info') {
           const existingNotifications = document.querySelectorAll('.custom-notification');
           existingNotifications.forEach(notif => notif.remove());

           const notification = document.createElement('div');
           notification.className = 'custom-notification notification-' + type;

           const icons = {
               error: 'fas fa-exclamation-circle',
               success: 'fas fa-check-circle',
               info: 'fas fa-info-circle'
           };

           notification.innerHTML = '<i class="' + icons[type] + '"></i><span>' + message + '</span><button onclick="this.parentElement.remove()">&times;</button>';

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
           const searchTerm = document.getElementById('searchReports').value.toLowerCase();
           const wasteTypeFilter = document.getElementById('wasteTypeFilter').value;
           const pickupFilter = document.getElementById('pickupFilter').value;

           filteredReports = allReports.filter(report => {
               const matchesSearch = !searchTerm ||
                   (report.Address && report.Address.toLowerCase().includes(searchTerm)) ||
                   (report.CitizenName && report.CitizenName.toLowerCase().includes(searchTerm)) ||
                   (report.WasteType && report.WasteType.toLowerCase().includes(searchTerm));

               const matchesWasteType = wasteTypeFilter === 'all' || report.WasteType === wasteTypeFilter;
               
               const hasPickup = report.PickupId && report.PickupId !== '';
               const matchesPickupFilter = 
                   pickupFilter === 'all' || 
                   (pickupFilter === 'with' && hasPickup) || 
                   (pickupFilter === 'without' && !hasPickup);

               return matchesSearch && matchesWasteType && matchesPickupFilter;
           });

           currentPage = 1;
           renderReports();
           updatePagination();
           updatePageInfo();
       }

       function renderReports() {
           if (currentView === 'grid') {
               renderGridView();
           } else {
               renderTableView();
           }
       }

       function renderGridView() {
           const grid = document.getElementById('reportsGrid');
           const startIndex = (currentPage - 1) * reportsPerPage;
           const endIndex = startIndex + reportsPerPage;
           const reportsToShow = filteredReports.slice(startIndex, endIndex);

           grid.innerHTML = '';

           if (reportsToShow.length === 0) {
               grid.innerHTML = '<div class="col-12 text-center py-5"><i class="fas fa-trash-alt fa-3x mb-3" style="color: rgba(255, 255, 255, 0.5) !important;"></i><h4 style="color: rgba(255, 255, 255, 0.7) !important;">No waste reports found</h4><p style="color: rgba(255, 255, 255, 0.5) !important;">Try adjusting your filters or search terms</p></div>';
               return;
           }

           reportsToShow.forEach(report => {
               const reportCard = createReportCard(report);
               grid.appendChild(reportCard);
           });
       }

       function renderTableView() {
           const tbody = document.getElementById('reportsTableBody');
           const startIndex = (currentPage - 1) * reportsPerPage;
           const endIndex = startIndex + reportsPerPage;
           const reportsToShow = filteredReports.slice(startIndex, endIndex);

           tbody.innerHTML = '';

           if (reportsToShow.length === 0) {
               tbody.innerHTML = '<tr><td colspan="8" class="text-center py-4"><i class="fas fa-trash-alt fa-2x mb-2" style="color: rgba(255, 255, 255, 0.5) !important;"></i><h5 style="color: rgba(255, 255, 255, 0.7) !important;">No waste reports found</h5><p style="color: rgba(255, 255, 255, 0.5) !important;">Try adjusting your filters or search terms</p></td></tr>';
               return;
           }

           reportsToShow.forEach(report => {
               const row = createTableRow(report);
               tbody.appendChild(row);
           });
       }

       function createReportCard(report) {
           const card = document.createElement('div');
           card.className = 'report-card';

           const hasPickup = report.PickupId && report.PickupId !== '';
           const status = hasPickup ? 'Pickup Created' : 'Reported';
           const statusClass = hasPickup ? 'status-pickup-created' : 'status-reported';

           card.innerHTML = '<div class="report-header"><div class="report-info"><h3 class="report-title">Report #' + report.ReportId + '</h3><p class="report-address">' + escapeHtml(report.Address || 'No address') + '</p><div class="report-details"><div class="detail-item"><div class="detail-value">' + (report.EstimatedWeight || 0) + 'kg</div><div class="detail-label">Weight</div></div><div class="detail-item"><div class="detail-value">' + (report.WasteType || 'Unknown') + '</div><div class="detail-label">Waste Type</div></div><div class="detail-item"><div class="detail-value">' + (report.CreditRate || 0) + '</div><div class="detail-label">Credits/kg</div></div></div></div><div class="report-actions"><button class="btn-action btn-view" data-report-id="' + report.ReportId + '" title="View Details"><i class="fas fa-eye"></i></button>' + (!hasPickup ? '<button class="btn-action btn-create-pickup" data-report-id="' + report.ReportId + '" title="Create Pickup"><i class="fas fa-truck"></i></button>' : '') + '<button class="btn-action btn-delete" data-report-id="' + report.ReportId + '" title="Delete Report"><i class="fas fa-trash"></i></button></div></div><div class="report-meta"><div class="report-status"><span class="status-badge ' + statusClass + '">' + status + '</span><span style="color: rgba(255, 255, 255, 0.5) !important;">' + (report.CitizenName || 'Unknown Citizen') + '</span></div><div class="small" style="color: rgba(255, 255, 255, 0.5) !important;">' + formatDate(report.RequestedDate) + '</div></div>';

           // Add event listeners
           card.querySelector('.btn-view').addEventListener('click', function () {
               viewReport(this.getAttribute('data-report-id'));
           });

           if (!hasPickup) {
               card.querySelector('.btn-create-pickup').addEventListener('click', function () {
                   createPickup(this.getAttribute('data-report-id'));
               });
           }

           card.querySelector('.btn-delete').addEventListener('click', function () {
               deleteReport(this.getAttribute('data-report-id'));
           });

           return card;
       }

       function createTableRow(report) {
           const row = document.createElement('tr');
           const hasPickup = report.PickupId && report.PickupId !== '';
           const status = hasPickup ? 'Pickup Created' : 'Reported';
           const statusClass = hasPickup ? 'status-pickup-created' : 'status-reported';

           row.innerHTML = '<td>' + report.ReportId + '</td><td><div class="d-flex align-items-center gap-3"><div class="user-avatar">' + escapeHtml((report.CitizenName ? report.CitizenName[0] : 'U') + (report.CitizenName ? report.CitizenName.split(' ')[1] ? report.CitizenName.split(' ')[1][0] : '' : '')) + '</div><div><div class="fw-bold" style="color: #ffffff !important;">' + escapeHtml(report.CitizenName || 'Unknown') + '</div></div></div></td><td>' + (report.WasteType || 'Unknown') + '</td><td><div style="color: #ffffff !important;">' + (report.EstimatedWeight || 0) + 'kg</div></td><td>' + escapeHtml(report.Address || 'No address') + '</td><td>' + formatDate(report.RequestedDate) + '</td><td><span class="status-badge ' + statusClass + '">' + status + '</span></td><td><div class="report-actions"><button class="btn-action btn-view" data-report-id="' + report.ReportId + '" title="View Details"><i class="fas fa-eye"></i></button>' + (!hasPickup ? '<button class="btn-action btn-create-pickup" data-report-id="' + report.ReportId + '" title="Create Pickup"><i class="fas fa-truck"></i></button>' : '') + '<button class="btn-action btn-delete" data-report-id="' + report.ReportId + '" title="Delete Report"><i class="fas fa-trash"></i></button></div></td>';

           // Add event listeners
           row.querySelector('.btn-view').addEventListener('click', function () {
               viewReport(this.getAttribute('data-report-id'));
           });

           if (!hasPickup) {
               row.querySelector('.btn-create-pickup').addEventListener('click', function () {
                   createPickup(this.getAttribute('data-report-id'));
               });
           }

           row.querySelector('.btn-delete').addEventListener('click', function () {
               deleteReport(this.getAttribute('data-report-id'));
           });

           return row;
       }

       function updatePagination() {
           const pagination = document.getElementById('pagination');
           const totalPages = Math.ceil(filteredReports.length / reportsPerPage);

           pagination.innerHTML = '';

           if (totalPages <= 1) return;

           const prevLi = document.createElement('li');
           prevLi.className = 'page-item ' + (currentPage === 1 ? 'disabled' : '');
           prevLi.innerHTML = '<a class="page-link" href="javascript:void(0)" data-page="' + (currentPage - 1) + '">Previous</a>';
           pagination.appendChild(prevLi);

           for (let i = 1; i <= totalPages; i++) {
               const li = document.createElement('li');
               li.className = 'page-item ' + (currentPage === i ? 'active' : '');
               li.innerHTML = '<a class="page-link" href="javascript:void(0)" data-page="' + i + '">' + i + '</a>';
               pagination.appendChild(li);
           }

           const nextLi = document.createElement('li');
           nextLi.className = 'page-item ' + (currentPage === totalPages ? 'disabled' : '');
           nextLi.innerHTML = '<a class="page-link" href="javascript:void(0)" data-page="' + (currentPage + 1) + '">Next</a>';
           pagination.appendChild(nextLi);

           // Add event listeners to pagination links
           pagination.querySelectorAll('.page-link').forEach(link => {
               link.addEventListener('click', function () {
                   const page = parseInt(this.getAttribute('data-page'));
                   changePage(page);
               });
           });

           document.getElementById('paginationInfo').textContent = 'Page ' + currentPage + ' of ' + totalPages;
       }

       function changePage(page) {
           const totalPages = Math.ceil(filteredReports.length / reportsPerPage);
           if (page >= 1 && page <= totalPages) {
               currentPage = page;
               renderReports();
               updatePagination();
           }
       }

       function updatePageInfo() {
           const startIndex = (currentPage - 1) * reportsPerPage + 1;
           const endIndex = Math.min(currentPage * reportsPerPage, filteredReports.length);
           document.getElementById('pageInfo').textContent = 'Showing ' + startIndex + '-' + endIndex + ' of ' + filteredReports.length + ' reports';
       }

       function showLoading() {
           const grid = document.getElementById('reportsGrid');
           if (grid) {
               grid.innerHTML = '<div class="col-12 text-center py-5"><i class="fas fa-spinner fa-spin fa-2x mb-3" style="color: rgba(255, 255, 255, 0.5) !important;"></i><p style="color: rgba(255, 255, 255, 0.7) !important;">Loading waste reports from database...</p></div>';
           }
       }

       function hideLoading() { }

       // View Report Modal Functions
       function viewReport(reportId) {
           const report = allReports.find(r => r.ReportId === reportId);
           if (report) {
               currentViewReportId = reportId;

               // Populate modal with report data
               document.getElementById('viewReportId').textContent = report.ReportId;
               document.getElementById('viewCitizenName').textContent = report.CitizenName || 'Unknown';
               document.getElementById('viewWasteType').textContent = report.WasteType || 'Unknown';
               document.getElementById('viewEstimatedWeight').textContent = (report.EstimatedWeight || 0) + ' kg';
               document.getElementById('viewCreditRate').textContent = (report.CreditRate || 0) + ' credits/kg';
               document.getElementById('viewReportedDate').textContent = formatDateTime(report.RequestedDate);
               document.getElementById('viewPickupStatus').textContent = (report.PickupId && report.PickupId !== '') ? 'Pickup Created' : 'No Pickup';
               document.getElementById('viewPickupId').textContent = report.PickupId || 'Not assigned';
               document.getElementById('viewReportAddress').textContent = report.Address || 'No address';
               document.getElementById('viewReportNotes').textContent = report.Notes || 'No notes';

               // Handle photo preview
               const photoPreviewContainer = document.getElementById('photoPreviewContainer');
               const photoPreview = document.getElementById('photoPreview');
               if (report.Notes && (report.Notes.startsWith('http') || report.Notes.startsWith('https'))) {
                   photoPreview.src = report.Notes;
                   photoPreviewContainer.style.display = 'block';
               } else {
                   photoPreviewContainer.style.display = 'none';
               }

               // Show/hide create pickup button
               const createPickupBtn = document.getElementById('createPickupBtn');
               if (report.PickupId && report.PickupId !== '') {
                   createPickupBtn.style.display = 'none';
               } else {
                   createPickupBtn.style.display = 'block';
               }

               // Show modal
               document.getElementById('viewReportModal').style.display = 'block';
           }
       }

       function closeViewReportModal() {
           document.getElementById('viewReportModal').style.display = 'none';
           currentViewReportId = null;
       }

       // Create Pickup Modal Functions
       function createPickup(reportId) {
           currentCreatePickupReportId = reportId;
           document.getElementById('createPickupModal').style.display = 'block';
       }

       function openCreatePickupModal() {
           if (currentViewReportId) {
               currentCreatePickupReportId = currentViewReportId;
               document.getElementById('createPickupModal').style.display = 'block';
           }
       }

       function closeCreatePickupModal() {
           document.getElementById('createPickupModal').style.display = 'none';
           currentCreatePickupReportId = null;
           // Reset form
           document.getElementById('collectorSelect').value = '';
           document.getElementById('scheduledDateTime').value = '';
           document.getElementById('pickupNotes').value = '';
       }

       function confirmCreatePickup() {
           const collectorId = document.getElementById('collectorSelect').value;
           const scheduledDate = document.getElementById('scheduledDateTime').value;
           const notes = document.getElementById('pickupNotes').value;

           if (!collectorId) {
               showError('Please select a collector');
               return;
           }

           if (!scheduledDate) {
               showError('Please select a scheduled date and time');
               return;
           }

           const selectedCollector = allCollectors.find(c => c.Id === collectorId);

           PageMethods.CreatePickupFromReport(currentCreatePickupReportId, collectorId, scheduledDate, notes,
               function(response) {
                   if (response.startsWith('Success')) {
                       showSuccess('Pickup created successfully from waste report');
                       closeCreatePickupModal();
                       closeViewReportModal();
                       document.getElementById('<%= btnLoadReports.ClientID %>').click();
                   } else {
                       showError('Error creating pickup: ' + response);
                   }
               },
               function(error) {
                   showError('Error calling server: ' + error.get_message());
               }
           );
       }

       // Delete Confirmation Modal Functions
       function deleteReport(reportId) {
           const report = allReports.find(r => r.ReportId === reportId);
           if (report) {
               currentDeleteReportId = reportId;
               document.getElementById('deleteReportId').textContent = '#' + report.ReportId;
               document.getElementById('deleteReportModal').style.display = 'block';
           }
       }

       function closeDeleteModal() {
           document.getElementById('deleteReportModal').style.display = 'none';
           currentDeleteReportId = null;
       }

       function confirmDelete() {
           if (currentDeleteReportId) {
               PageMethods.DeleteWasteReport(currentDeleteReportId,
                   function(response) {
                       if (response.startsWith('Success')) {
                           showSuccess('Waste report deleted successfully');
                           document.getElementById('<%= btnLoadReports.ClientID %>').click();
                       } else {
                           showError('Error deleting waste report: ' + response);
                       }
                       closeDeleteModal();
                   },
                   function(error) {
                       showError('Error calling server: ' + error.get_message());
                       closeDeleteModal();
                   }
               );
           }
       }

       function formatDate(dateString) {
           if (!dateString) return 'Unknown';
           try {
               return new Date(dateString).toLocaleDateString();
           } catch (e) {
               return dateString;
           }
       }

       function formatDateTime(dateString) {
           if (!dateString) return 'Unknown';
           try {
               return new Date(dateString).toLocaleString();
           } catch (e) {
               return dateString;
           }
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
