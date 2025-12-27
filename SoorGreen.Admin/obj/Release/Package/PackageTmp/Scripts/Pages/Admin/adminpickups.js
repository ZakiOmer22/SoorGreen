
       // GLOBAL VARIABLES
       let currentView = 'grid';
       let currentPage = 1;
       const pickupsPerPage = 6;
       let filteredPickups = [];
       let allPickups = [];
       let allCollectors = [];
       let allCitizens = [];
       let currentViewPickupId = null;
       let currentDeletePickupId = null;
       let currentAssignPickupId = null;
       let currentCompletePickupId = null;

       // INITIALIZE
       document.addEventListener('DOMContentLoaded', function () {
           initializeEventListeners();
           loadPickupsFromServer();
           loadCollectorsFromServer();
           loadCitizensFromServer();
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
           document.getElementById('searchPickups').addEventListener('input', function (e) {
               applyFilters();
           });

           // Filter dropdowns
           document.getElementById('statusFilter').addEventListener('change', function (e) {
               applyFilters();
           });

           document.getElementById('wasteTypeFilter').addEventListener('change', function (e) {
               applyFilters();
           });

           document.getElementById('dateFilter').addEventListener('change', function (e) {
               applyFilters();
           });

           // Modal close buttons
           document.querySelector('#viewPickupModal .close-modal').addEventListener('click', closeViewPickupModal);
           document.querySelector('#assignCollectorModal .close-modal').addEventListener('click', closeAssignModal);
           document.querySelector('#completePickupModal .close-modal').addEventListener('click', closeCompleteModal);
           document.querySelector('#deletePickupModal .close-modal').addEventListener('click', closeDeleteModal);
           document.querySelector('#addPickupModal .close-modal').addEventListener('click', closeAddModal);

           document.getElementById('closeViewModalBtn').addEventListener('click', closeViewPickupModal);
           document.getElementById('cancelAssignBtn').addEventListener('click', closeAssignModal);
           document.getElementById('cancelCompleteBtn').addEventListener('click', closeCompleteModal);
           document.getElementById('cancelDeleteBtn').addEventListener('click', closeDeleteModal);
           document.getElementById('cancelAddBtn').addEventListener('click', closeAddModal);

           document.getElementById('confirmAssignBtn').addEventListener('click', confirmAssign);
           document.getElementById('confirmCompleteBtn').addEventListener('click', confirmComplete);
           document.getElementById('confirmDeleteBtn').addEventListener('click', confirmDelete);
           document.getElementById('confirmAddBtn').addEventListener('click', confirmAddPickup);

           // Add pickup button
           document.getElementById('addPickupBtn').addEventListener('click', openAddModal);

           // Close modals when clicking outside
           document.getElementById('viewPickupModal').addEventListener('click', function (e) {
               if (e.target === this) closeViewPickupModal();
           });
           document.getElementById('assignCollectorModal').addEventListener('click', function (e) {
               if (e.target === this) closeAssignModal();
           });
           document.getElementById('completePickupModal').addEventListener('click', function (e) {
               if (e.target === this) closeCompleteModal();
           });
           document.getElementById('deletePickupModal').addEventListener('click', function (e) {
               if (e.target === this) closeDeleteModal();
           });
           document.getElementById('addPickupModal').addEventListener('click', function (e) {
               if (e.target === this) closeAddModal();
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

           renderPickups();
       }

       function loadPickupsFromServer() {
           showLoading();

           const pickupsData = document.getElementById('<%= hfPickupsData.ClientID %>').value;

           if (pickupsData && pickupsData !== '') {
               try {
                   allPickups = JSON.parse(pickupsData);
                   filteredPickups = [...allPickups];

                   renderPickups();
                   updatePagination();
                   updatePageInfo();
                   hideLoading();

                   if (filteredPickups.length > 0) {
                       showSuccess('Loaded ' + filteredPickups.length + ' pickups from database');
                   } else {
                       showInfo('No pickups found in database');
                   }

               } catch (e) {
                   console.error('Error parsing pickup data:', e);
                   showError('Error loading pickup data from database');
                   hideLoading();
               }
           } else {
               showError('No pickup data available from database');
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

       function loadCitizensFromServer() {
           const citizensData = document.getElementById('<%= hfCitizensList.ClientID %>').value;
           if (citizensData && citizensData !== '') {
               try {
                   allCitizens = JSON.parse(citizensData);
                   populateCitizenSelect();
               } catch (e) {
                   console.error('Error parsing citizens data:', e);
               }
           }
       }

       function populateCollectorSelect() {
           const select = document.getElementById('collectorSelect');
           select.innerHTML = '<option value="">Select a collector...</option>';

           allCollectors.forEach(collector => {
               const option = document.createElement('option');
               option.value = collector.Id;
               option.textContent = `${collector.FirstName} ${collector.LastName} (${collector.Status})`;
               select.appendChild(option);
           });
       }

       function populateCitizenSelect() {
           const select = document.getElementById('citizenSelect');
           select.innerHTML = '<option value="">Select a citizen...</option>';

           allCitizens.forEach(citizen => {
               const option = document.createElement('option');
               option.value = citizen.Id;
               option.textContent = `${citizen.FirstName} ${citizen.LastName} (${citizen.Phone})`;
               select.appendChild(option);
           });
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
           const searchTerm = document.getElementById('searchPickups').value.toLowerCase();
           const statusFilter = document.getElementById('statusFilter').value;
           const wasteTypeFilter = document.getElementById('wasteTypeFilter').value;

           filteredPickups = allPickups.filter(pickup => {
               const matchesSearch = !searchTerm ||
                   (pickup.Address && pickup.Address.toLowerCase().includes(searchTerm)) ||
                   (pickup.CitizenName && pickup.CitizenName.toLowerCase().includes(searchTerm)) ||
                   (pickup.CollectorName && pickup.CollectorName.toLowerCase().includes(searchTerm));

               const matchesStatus = statusFilter === 'all' || pickup.Status === statusFilter;
               const matchesWasteType = wasteTypeFilter === 'all' || pickup.WasteType === wasteTypeFilter;

               return matchesSearch && matchesStatus && matchesWasteType;
           });

           currentPage = 1;
           renderPickups();
           updatePagination();
           updatePageInfo();
       }

       function renderPickups() {
           if (currentView === 'grid') {
               renderGridView();
           } else {
               renderTableView();
           }
       }

       function renderGridView() {
           const grid = document.getElementById('pickupsGrid');
           const startIndex = (currentPage - 1) * pickupsPerPage;
           const endIndex = startIndex + pickupsPerPage;
           const pickupsToShow = filteredPickups.slice(startIndex, endIndex);

           grid.innerHTML = '';

           if (pickupsToShow.length === 0) {
               grid.innerHTML = `
                <div class="col-12 text-center py-5">
                    <i class="fas fa-truck-loading fa-3x mb-3" style="color: rgba(255, 255, 255, 0.5) !important;"></i>
                    <h4 style="color: rgba(255, 255, 255, 0.7) !important;">No pickups found</h4>
                    <p style="color: rgba(255, 255, 255, 0.5) !important;">Try adjusting your filters or search terms</p>
                </div>
            `;
               return;
           }

           pickupsToShow.forEach(pickup => {
               const pickupCard = createPickupCard(pickup);
               grid.appendChild(pickupCard);
           });
       }

       function renderTableView() {
           const tbody = document.getElementById('pickupsTableBody');
           const startIndex = (currentPage - 1) * pickupsPerPage;
           const endIndex = startIndex + pickupsPerPage;
           const pickupsToShow = filteredPickups.slice(startIndex, endIndex);

           tbody.innerHTML = '';

           if (pickupsToShow.length === 0) {
               tbody.innerHTML = `
                <tr>
                    <td colspan="9" class="text-center py-4">
                        <i class="fas fa-truck-loading fa-2x mb-2" style="color: rgba(255, 255, 255, 0.5) !important;"></i>
                        <h5 style="color: rgba(255, 255, 255, 0.7) !important;">No pickups found</h5>
                        <p style="color: rgba(255, 255, 255, 0.5) !important;">Try adjusting your filters or search terms</p>
                    </td>
                </tr>
            `;
               return;
           }

           pickupsToShow.forEach(pickup => {
               const row = createTableRow(pickup);
               tbody.appendChild(row);
           });
       }

       function createPickupCard(pickup) {
           const card = document.createElement('div');
           card.className = 'pickup-card';

           const creditsEarned = pickup.ActualWeight * (pickup.CreditRate || 5);

           card.innerHTML = `
            <div class="pickup-header">
                <div class="pickup-info">
                    <h3 class="pickup-title">Pickup #${pickup.PickupId}</h3>
                    <p class="pickup-address">${escapeHtml(pickup.Address || 'No address')}</p>
                    <div class="pickup-details">
                        <div class="detail-item">
                            <div class="detail-value">${pickup.EstimatedWeight || 0}kg</div>
                            <div class="detail-label">Estimated</div>
                        </div>
                        <div class="detail-item">
                            <div class="detail-value">${pickup.ActualWeight || 0}kg</div>
                            <div class="detail-label">Actual</div>
                        </div>
                        <div class="detail-item">
                            <div class="detail-value">${creditsEarned.toFixed(0)}</div>
                            <div class="detail-label">Credits</div>
                        </div>
                        <div class="detail-item">
                            <div class="detail-value">${pickup.WasteType || 'Unknown'}</div>
                            <div class="detail-label">Waste Type</div>
                        </div>
                    </div>
                </div>
                <div class="pickup-actions">
                    <button class="btn-action btn-view" data-pickup-id="${pickup.PickupId}" title="View Details">
                        <i class="fas fa-eye"></i>
                    </button>
                    ${pickup.Status === 'Requested' ? `
                        <button class="btn-action btn-assign" data-pickup-id="${pickup.PickupId}" title="Assign Collector">
                            <i class="fas fa-user-check"></i>
                        </button>
                    ` : ''}
                    ${pickup.Status === 'Assigned' ? `
                        <button class="btn-action btn-complete" data-pickup-id="${pickup.PickupId}" title="Complete Pickup">
                            <i class="fas fa-check-circle"></i>
                        </button>
                    ` : ''}
                    <button class="btn-action btn-delete" data-pickup-id="${pickup.PickupId}" title="Delete Pickup">
                        <i class="fas fa-trash"></i>
                    </button>
                </div>
            </div>
            <div class="pickup-meta">
                <div class="pickup-status">
                    <span class="status-badge status-${pickup.Status?.toLowerCase() || 'requested'}">${pickup.Status || 'Requested'}</span>
                    <span style="color: rgba(255, 255, 255, 0.5) !important;">
                        ${pickup.CitizenName || 'Unknown Citizen'} → ${pickup.CollectorName || 'Unassigned'}
                    </span>
                </div>
                <div class="small" style="color: rgba(255, 255, 255, 0.5) !important;">
                    ${formatDate(pickup.RequestedDate)}
                </div>
            </div>
        `;

           // Add event listeners to action buttons
           card.querySelector('.btn-view').addEventListener('click', function () {
               viewPickup(this.getAttribute('data-pickup-id'));
           });

           const assignBtn = card.querySelector('.btn-assign');
           if (assignBtn) {
               assignBtn.addEventListener('click', function () {
                   assignCollector(this.getAttribute('data-pickup-id'));
               });
           }

           const completeBtn = card.querySelector('.btn-complete');
           if (completeBtn) {
               completeBtn.addEventListener('click', function () {
                   completePickup(this.getAttribute('data-pickup-id'));
               });
           }

           card.querySelector('.btn-delete').addEventListener('click', function () {
               deletePickup(this.getAttribute('data-pickup-id'));
           });

           return card;
       }

       function createTableRow(pickup) {
           const row = document.createElement('tr');
           const creditsEarned = pickup.ActualWeight * (pickup.CreditRate || 5);

           row.innerHTML = `
            <td>${pickup.PickupId}</td>
            <td>
                <div class="d-flex align-items-center gap-3">
                    <div class="user-avatar">
                        ${escapeHtml((pickup.CitizenName ? pickup.CitizenName[0] : 'U') + (pickup.CitizenName ? pickup.CitizenName.split(' ')[1]?.[0] || '' : ''))}
                    </div>
                    <div>
                        <div class="fw-bold" style="color: #ffffff !important;">${escapeHtml(pickup.CitizenName || 'Unknown')}</div>
                    </div>
                </div>
            </td>
            <td>
                ${pickup.CollectorName ? `
                    <div class="d-flex align-items-center gap-3">
                        <div class="collector-avatar">
                            ${escapeHtml((pickup.CollectorName ? pickup.CollectorName[0] : 'C') + (pickup.CollectorName ? pickup.CollectorName.split(' ')[1]?.[0] || '' : ''))}
                        </div>
                        <div>
                            <div class="fw-bold" style="color: #ffffff !important;">${escapeHtml(pickup.CollectorName)}</div>
                        </div>
                    </div>
                ` : '<span style="color: rgba(255, 255, 255, 0.5) !important;">Unassigned</span>'}
            </td>
            <td>${escapeHtml(pickup.Address || 'No address')}</td>
            <td>${pickup.WasteType || 'Unknown'}</td>
            <td>
                <div style="color: #ffffff !important;">${pickup.ActualWeight || pickup.EstimatedWeight || 0}kg</div>
                ${pickup.ActualWeight ? `<div class="small" style="color: rgba(255, 255, 255, 0.6) !important;">${creditsEarned.toFixed(0)} credits</div>` : ''}
            </td>
            <td>
                <span class="status-badge status-${pickup.Status?.toLowerCase() || 'requested'}">${pickup.Status || 'Requested'}</span>
            </td>
            <td>${formatDate(pickup.RequestedDate)}</td>
            <td>
                <div class="pickup-actions">
                    <button class="btn-action btn-view" data-pickup-id="${pickup.PickupId}" title="View Details">
                        <i class="fas fa-eye"></i>
                    </button>
                    ${pickup.Status === 'Requested' ? `
                        <button class="btn-action btn-assign" data-pickup-id="${pickup.PickupId}" title="Assign Collector">
                            <i class="fas fa-user-check"></i>
                        </button>
                    ` : ''}
                    ${pickup.Status === 'Assigned' ? `
                        <button class="btn-action btn-complete" data-pickup-id="${pickup.PickupId}" title="Complete Pickup">
                            <i class="fas fa-check-circle"></i>
                        </button>
                    ` : ''}
                    <button class="btn-action btn-delete" data-pickup-id="${pickup.PickupId}" title="Delete Pickup">
                        <i class="fas fa-trash"></i>
                    </button>
                </div>
            </td>
        `;

           // Add event listeners to action buttons
           row.querySelector('.btn-view').addEventListener('click', function () {
               viewPickup(this.getAttribute('data-pickup-id'));
           });

           const assignBtn = row.querySelector('.btn-assign');
           if (assignBtn) {
               assignBtn.addEventListener('click', function () {
                   assignCollector(this.getAttribute('data-pickup-id'));
               });
           }

           const completeBtn = row.querySelector('.btn-complete');
           if (completeBtn) {
               completeBtn.addEventListener('click', function () {
                   completePickup(this.getAttribute('data-pickup-id'));
               });
           }

           row.querySelector('.btn-delete').addEventListener('click', function () {
               deletePickup(this.getAttribute('data-pickup-id'));
           });

           return row;
       }

       function updatePagination() {
           const pagination = document.getElementById('pagination');
           const totalPages = Math.ceil(filteredPickups.length / pickupsPerPage);

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
               link.addEventListener('click', function () {
                   const page = parseInt(this.getAttribute('data-page'));
                   changePage(page);
               });
           });

           document.getElementById('paginationInfo').textContent = `Page ${currentPage} of ${totalPages}`;
       }

       function changePage(page) {
           const totalPages = Math.ceil(filteredPickups.length / pickupsPerPage);
           if (page >= 1 && page <= totalPages) {
               currentPage = page;
               renderPickups();
               updatePagination();
           }
       }

       function updatePageInfo() {
           const startIndex = (currentPage - 1) * pickupsPerPage + 1;
           const endIndex = Math.min(currentPage * pickupsPerPage, filteredPickups.length);
           document.getElementById('pageInfo').textContent = `Showing ${startIndex}-${endIndex} of ${filteredPickups.length} pickups`;
       }

       function showLoading() {
           const grid = document.getElementById('pickupsGrid');
           if (grid) {
               grid.innerHTML = `
                <div class="col-12 text-center py-5">
                    <i class="fas fa-spinner fa-spin fa-2x mb-3" style="color: rgba(255, 255, 255, 0.5) !important;"></i>
                    <p style="color: rgba(255, 255, 255, 0.7) !important;">Loading pickups from database...</p>
                </div>
            `;
           }
       }

       function hideLoading() { }

       // View Pickup Modal Functions
       function viewPickup(pickupId) {
           const pickup = allPickups.find(p => p.PickupId === pickupId);
           if (pickup) {
               currentViewPickupId = pickupId;

               const creditsEarned = pickup.ActualWeight * (pickup.CreditRate || 5);

               // Populate modal with pickup data
               document.getElementById('viewPickupId').textContent = pickup.PickupId;
               document.getElementById('viewPickupStatus').innerHTML =
                   `<span class="status-badge status-${pickup.Status?.toLowerCase() || 'requested'}">${pickup.Status || 'Requested'}</span>`;
               document.getElementById('viewCitizenName').textContent = pickup.CitizenName || 'Unknown';
               document.getElementById('viewCollectorName').textContent = pickup.CollectorName || 'Unassigned';
               document.getElementById('viewWasteType').textContent = pickup.WasteType || 'Unknown';
               document.getElementById('viewEstimatedWeight').textContent = (pickup.EstimatedWeight || 0) + ' kg';
               document.getElementById('viewActualWeight').textContent = (pickup.ActualWeight || 'Not recorded') + (pickup.ActualWeight ? ' kg' : '');
               document.getElementById('viewCreditsEarned').textContent = pickup.ActualWeight ? creditsEarned.toFixed(0) + ' credits' : 'Not applicable';
               document.getElementById('viewRequestedDate').textContent = formatDateTime(pickup.RequestedDate);
               document.getElementById('viewScheduledDate').textContent = pickup.ScheduledDate ? formatDateTime(pickup.ScheduledDate) : 'Not scheduled';
               document.getElementById('viewCompletedDate').textContent = pickup.CompletedDate ? formatDateTime(pickup.CompletedDate) : 'Not completed';
               document.getElementById('viewPickupAddress').textContent = pickup.Address || 'No address';
               document.getElementById('viewPickupNotes').textContent = pickup.Notes || 'No notes';

               // Show modal
               document.getElementById('viewPickupModal').style.display = 'block';
           }
       }

       function closeViewPickupModal() {
           document.getElementById('viewPickupModal').style.display = 'none';
           currentViewPickupId = null;
       }

       // Assign Collector Modal Functions
       function assignCollector(pickupId) {
           currentAssignPickupId = pickupId;
           document.getElementById('assignCollectorModal').style.display = 'block';
       }

       function closeAssignModal() {
           document.getElementById('assignCollectorModal').style.display = 'none';
           currentAssignPickupId = null;
           // Reset form
           document.getElementById('collectorSelect').value = '';
           document.getElementById('scheduledDateTime').value = '';
           document.getElementById('assignmentNotes').value = '';
       }

       function confirmAssign() {
           const collectorId = document.getElementById('collectorSelect').value;
           const scheduledDate = document.getElementById('scheduledDateTime').value;
           const notes = document.getElementById('assignmentNotes').value;

           if (!collectorId) {
               showError('Please select a collector');
               return;
           }

           if (!scheduledDate) {
               showError('Please select a scheduled date and time');
               return;
           }

           const selectedCollector = allCollectors.find(c => c.Id === collectorId);

           // Use PageMethods with proper error handling
           PageMethods.AssignCollector(currentAssignPickupId, collectorId, scheduledDate, notes,
               function (response) {
                   if (response.startsWith('Success')) {
                       showSuccess(`Collector ${selectedCollector.FirstName} ${selectedCollector.LastName} assigned successfully`);
                       closeAssignModal();
                       document.getElementById('<%= btnLoadPickups.ClientID %>').click();
                   } else {
                       showError('Error assigning collector: ' + response);
                   }
               },
               function(error) {
                   showError('Error calling server: ' + error.get_message());
               }
           );
       }

       // Complete Pickup Modal Functions
       function completePickup(pickupId) {
           currentCompletePickupId = pickupId;
           const pickup = allPickups.find(p => p.PickupId === pickupId);
           if (pickup) {
               document.getElementById('confirmedWasteType').value = pickup.WasteType || 'Plastic';
           }
           document.getElementById('completePickupModal').style.display = 'block';
       }

       function closeCompleteModal() {
           document.getElementById('completePickupModal').style.display = 'none';
           currentCompletePickupId = null;
           // Reset form
           document.getElementById('actualWeight').value = '';
           document.getElementById('completionNotes').value = '';
       }

       function confirmComplete() {
           const actualWeight = document.getElementById('actualWeight').value;
           const confirmedWasteType = document.getElementById('confirmedWasteType').value;
           const completionNotes = document.getElementById('completionNotes').value;

           if (!actualWeight || actualWeight <= 0) {
               showError('Please enter a valid actual weight');
               return;
           }

           PageMethods.CompletePickup(currentCompletePickupId, parseFloat(actualWeight), confirmedWasteType, completionNotes,
               function(response) {
                   if (response.startsWith('Success')) {
                       showSuccess('Pickup completed successfully');
                       closeCompleteModal();
                       document.getElementById('<%= btnLoadPickups.ClientID %>').click();
                   } else {
                       showError('Error completing pickup: ' + response);
                   }
               },
               function(error) {
                   showError('Error calling server: ' + error.get_message());
               }
           );
       }

       // Delete Confirmation Modal Functions
       function deletePickup(pickupId) {
           const pickup = allPickups.find(p => p.PickupId === pickupId);
           if (pickup) {
               currentDeletePickupId = pickupId;
               document.getElementById('deletePickupId').textContent = `#${pickup.PickupId}`;
               document.getElementById('deletePickupModal').style.display = 'block';
           }
       }

       function closeDeleteModal() {
           document.getElementById('deletePickupModal').style.display = 'none';
           currentDeletePickupId = null;
       }

       function confirmDelete() {
           if (currentDeletePickupId) {
               PageMethods.DeletePickup(currentDeletePickupId,
                   function(response) {
                       if (response.startsWith('Success')) {
                           showSuccess('Pickup deleted successfully');
                           document.getElementById('<%= btnLoadPickups.ClientID %>').click();
                       } else {
                           showError('Error deleting pickup: ' + response);
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

       // Add New Pickup Modal Functions
       function openAddModal() {
           document.getElementById('addPickupModal').style.display = 'block';
       }

       function closeAddModal() {
           document.getElementById('addPickupModal').style.display = 'none';
           // Reset form
           document.getElementById('citizenSelect').value = '';
           document.getElementById('newWasteType').value = 'Plastic';
           document.getElementById('estimatedWeight').value = '';
           document.getElementById('pickupAddress').value = '';
           document.getElementById('pickupNotes').value = '';
       }

       function confirmAddPickup() {
           const citizenId = document.getElementById('citizenSelect').value;
           const wasteType = document.getElementById('newWasteType').value;
           const estimatedWeight = document.getElementById('estimatedWeight').value;
           const address = document.getElementById('pickupAddress').value;
           const notes = document.getElementById('pickupNotes').value;

           if (!citizenId || !estimatedWeight || !address) {
               showError('Please fill in all required fields');
               return;
           }

           if (estimatedWeight <= 0) {
               showError('Please enter a valid estimated weight');
               return;
           }

           // Call your server-side method to create pickup
           PageMethods.CreatePickup(citizenId, wasteType, parseFloat(estimatedWeight), address, notes,
               function(response) {
                   if (response.startsWith('Success')) {
                       showSuccess('Pickup created successfully');
                       closeAddModal();
                       document.getElementById('<%= btnLoadPickups.ClientID %>').click();
                   } else {
                       showError('Error creating pickup: ' + response);
                   }
               },
               function (error) {
                   showError('Error calling server: ' + error.get_message());
               }
           );
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
