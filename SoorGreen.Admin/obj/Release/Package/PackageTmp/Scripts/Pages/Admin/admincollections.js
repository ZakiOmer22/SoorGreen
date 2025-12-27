
    let currentView = 'grid';
    let currentPage = 1;
    let filteredCollections = [];
    let allCollections = [];
    let allCollectors = [];
    let allCitizens = [];
    let allWasteTypes = [];
    let currentViewCollectionId = null;

    document.addEventListener('DOMContentLoaded', function () {
        loadCollectionsFromServer();
    setupEventListeners();
       });

    function setupEventListeners() {
        // View buttons
        document.querySelectorAll('.view-btn').forEach(btn => {
            btn.addEventListener('click', function () {
                const view = this.getAttribute('data-view');
                changeView(view);
            });
        });

    // Filter button
    document.getElementById('applyFiltersBtn').addEventListener('click', function () {
        applyFilters();
           });

    // Search input
    document.getElementById('searchCollections').addEventListener('input', function () {
        applyFilters();
           });

    // Filter dropdowns
    document.getElementById('statusFilter').addEventListener('change', function () {
        applyFilters();
           });

    document.getElementById('dateFilter').addEventListener('change', function () {
        applyFilters();
           });

    // Add collection button
    document.getElementById('addCollectionBtn').addEventListener('click', function () {
        showAddCollectionModal();
           });

           // Close modals
           document.querySelectorAll('.close-modal').forEach(btn => {
        btn.addEventListener('click', function () {
            this.closest('.modal-overlay').style.display = 'none';
        });
           });

    // Close view modal
    document.getElementById('closeViewModalBtn').addEventListener('click', function () {
        document.getElementById('viewCollectionModal').style.display = 'none';
           });

    // Cancel add collection
    document.getElementById('cancelAddBtn').addEventListener('click', function () {
        document.getElementById('addCollectionModal').style.display = 'none';
           });

    // Add collection
    document.getElementById('confirmAddBtn').addEventListener('click', function () {
        addNewCollection();
           });

    // Assign collector button in view modal
    document.getElementById('assignCollectorBtn').addEventListener('click', function () {
        showAssignCollectorModal();
           });

    // Complete collection button in view modal
    document.getElementById('completeCollectionBtn').addEventListener('click', function () {
        showCompleteCollectionModal();
           });

    // Delete collection button in view modal
    document.getElementById('deleteCollectionBtn').addEventListener('click', function () {
        showDeleteConfirmationModal();
           });

    // Cancel assign collector
    document.getElementById('cancelAssignBtn').addEventListener('click', function () {
        document.getElementById('assignCollectorModal').style.display = 'none';
           });

    // Confirm assign collector
    document.getElementById('confirmAssignBtn').addEventListener('click', function () {
        assignCollector();
           });

    // Cancel complete collection
    document.getElementById('cancelCompleteBtn').addEventListener('click', function () {
        document.getElementById('completeCollectionModal').style.display = 'none';
           });

    // Confirm complete collection
    document.getElementById('confirmCompleteBtn').addEventListener('click', function () {
        completeCollection();
           });

    // Cancel delete
    document.getElementById('cancelDeleteBtn').addEventListener('click', function () {
        document.getElementById('deleteCollectionModal').style.display = 'none';
           });

    // Confirm delete
    document.getElementById('confirmDeleteBtn').addEventListener('click', function () {
        deleteCollection();
           });

    // Generate report
    document.getElementById('generateReportBtn').addEventListener('click', function () {
        generateReport();
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
       }

    function applyFilters() {
           const searchTerm = document.getElementById('searchCollections').value.toLowerCase();
    const statusFilter = document.getElementById('statusFilter').value;
    const dateFilter = document.getElementById('dateFilter').value;

           filteredCollections = allCollections.filter(collection => {
               // Search filter
               const matchesSearch = !searchTerm ||
    (collection.Address && collection.Address.toLowerCase().includes(searchTerm)) ||
    (collection.CitizenName && collection.CitizenName.toLowerCase().includes(searchTerm)) ||
    (collection.CollectorName && collection.CollectorName.toLowerCase().includes(searchTerm)) ||
    (collection.WasteTypeName && collection.WasteTypeName.toLowerCase().includes(searchTerm));

    // Status filter
    const matchesStatus = statusFilter === 'all' ||
    (collection.Status && collection.Status.toLowerCase() === statusFilter.toLowerCase());

    // Date filter (simplified)
    let matchesDate = true;
    if (dateFilter !== 'all' && collection.CreatedAt) {
                   const createdDate = new Date(collection.CreatedAt);
    const today = new Date();

    if (dateFilter === 'today') {
        matchesDate = createdDate.toDateString() === today.toDateString();
                   } else if (dateFilter === 'week') {
                       const weekAgo = new Date(today);
    weekAgo.setDate(today.getDate() - 7);
                       matchesDate = createdDate >= weekAgo;
                   } else if (dateFilter === 'month') {
                       const monthAgo = new Date(today);
    monthAgo.setMonth(today.getMonth() - 1);
                       matchesDate = createdDate >= monthAgo;
                   }
               }

    return matchesSearch && matchesStatus && matchesDate;
           });

    renderCollections();
       }

    function loadCollectionsFromServer() {
           const collectionsData = document.getElementById('<%= hfCollectionsData.ClientID %>').value;
    const statsData = document.getElementById('<%= hfStatsData.ClientID %>').value;
    const collectorsData = document.getElementById('<%= hfCollectorsData.ClientID %>').value;
    const citizensData = document.getElementById('<%= hfCitizensData.ClientID %>').value;
    const wasteTypesData = document.getElementById('<%= hfWasteTypesData.ClientID %>').value;

    if (collectionsData) {
        allCollections = JSON.parse(collectionsData);
    filteredCollections = allCollections;
           }
    if (collectorsData) allCollectors = JSON.parse(collectorsData);
    if (citizensData) allCitizens = JSON.parse(citizensData);
    if (wasteTypesData) allWasteTypes = JSON.parse(wasteTypesData);
    if (statsData) updateStatistics(JSON.parse(statsData));

    renderCollections();
       }

    function updateStatistics(stats) {
        document.getElementById('totalCollections').textContent = stats.TotalCollections || 0;
    document.getElementById('pendingCollections').textContent = stats.PendingCollections || 0;
    document.getElementById('completedToday').textContent = stats.CompletedToday || 0;
    document.getElementById('totalWeight').textContent = (stats.TotalWeight || 0) + 'kg';
       }

    function renderCollections() {
           const grid = document.getElementById('collectionsGrid');
    const tbody = document.getElementById('collectionsTableBody');

    grid.innerHTML = '';
    tbody.innerHTML = '';

    if (filteredCollections.length === 0) {
        grid.innerHTML = '<div class="col-12 text-center py-5"><i class="fas fa-trash-alt fa-3x mb-3" style="color: rgba(255, 255, 255, 0.5) !important;"></i><h4 style="color: rgba(255, 255, 255, 0.7) !important;">No collections found</h4></div>';
    tbody.innerHTML = '<tr><td colspan="9" class="text-center py-4">No collections found</td></tr>';
    return;
           }

           filteredCollections.forEach(collection => {
        grid.appendChild(createCollectionCard(collection));
    tbody.appendChild(createTableRow(collection));
           });
       }

    function createCollectionCard(collection) {
           const card = document.createElement('div');
    card.className = 'collection-card';

    // Get initials for avatar
    const citizenInitial = collection.CitizenName ? collection.CitizenName.charAt(0).toUpperCase() : 'C';
    const collectorInitial = collection.CollectorName ? collection.CollectorName.charAt(0).toUpperCase() : 'N';

    card.innerHTML = `
    <div class="collection-header">
        <div class="collection-info">
            <h3 class="collection-title">${escapeHtml(collection.WasteTypeName || 'Unknown')}</h3>
            <p class="collection-address">${escapeHtml(collection.Address || 'No address')}</p>
        </div>
        <div class="collection-actions">
            <button class="btn-action btn-view" data-id="${collection.PickupId}"><i class="fas fa-eye"></i></button>
            <button class="btn-action btn-assign" data-id="${collection.PickupId}"><i class="fas fa-user-plus"></i></button>
            <button class="btn-action btn-complete" data-id="${collection.PickupId}"><i class="fas fa-check"></i></button>
            <button class="btn-action btn-delete" data-id="${collection.PickupId}"><i class="fas fa-trash"></i></button>
        </div>
    </div>
    <div class="collection-details">
        <div class="detail-item">
            <div class="detail-value">${collection.EstimatedKg || 0}kg</div>
            <div class="detail-label">Estimated Weight</div>
        </div>
        <div class="detail-item">
            <div class="detail-value">${collection.VerifiedKg || '-'}</div>
            <div class="detail-label">Verified Weight</div>
        </div>
        <div class="detail-item">
            <div class="detail-value">${collection.CreditsEarned || 0}</div>
            <div class="detail-label">Credits</div>
        </div>
    </div>
    <div class="collection-meta">
        <div class="collection-status">
            <span class="status-badge status-${(collection.Status || 'requested').toLowerCase()}">${collection.Status || 'Requested'}</span>
            <div class="collector-info">
                <div class="user-avatar small">${citizenInitial}</div>
                <span>${escapeHtml(collection.CitizenName || 'Unknown')}</span>
            </div>
            ${collection.CollectorName ? `
                       <div class="collector-info">
                           <div class="user-avatar small">${collectorInitial}</div>
                           <span>${escapeHtml(collection.CollectorName)}</span>
                       </div>
                       ` : ''}
        </div>
        <span>ID: ${collection.PickupId}</span>
    </div>
    `;

    // Add event listeners to action buttons
    card.querySelector('.btn-view').addEventListener('click', function () {
        viewCollection(this.getAttribute('data-id'));
           });
    card.querySelector('.btn-assign').addEventListener('click', function () {
        currentViewCollectionId = this.getAttribute('data-id');
    showAssignCollectorModal();
           });
    card.querySelector('.btn-complete').addEventListener('click', function () {
        currentViewCollectionId = this.getAttribute('data-id');
    showCompleteCollectionModal();
           });
    card.querySelector('.btn-delete').addEventListener('click', function () {
        currentViewCollectionId = this.getAttribute('data-id');
    showDeleteConfirmationModal();
           });

    return card;
       }

    function createTableRow(collection) {
           const row = document.createElement('tr');

    // Get initials for avatar
    const citizenInitial = collection.CitizenName ? collection.CitizenName.charAt(0).toUpperCase() : 'C';
    const collectorInitial = collection.CollectorName ? collection.CollectorName.charAt(0).toUpperCase() : 'N';

    row.innerHTML = `
    <td>${collection.PickupId}</td>
    <td>
        <div class="collector-info">
            <div class="user-avatar small">${citizenInitial}</div>
            <span>${escapeHtml(collection.CitizenName || 'Unknown')}</span>
        </div>
    </td>
    <td>
        ${collection.CollectorName ? `
                   <div class="collector-info">
                       <div class="user-avatar small">${collectorInitial}</div>
                       <span>${escapeHtml(collection.CollectorName)}</span>
                   </div>
                   ` : 'Not assigned'}
    </td>
    <td>${escapeHtml(collection.Address || 'No address')}</td>
    <td>${escapeHtml(collection.WasteTypeName || 'Unknown')}</td>
    <td>${collection.EstimatedKg || 0}kg</td>
    <td><span class="status-badge status-${(collection.Status || 'requested').toLowerCase()}">${collection.Status || 'Requested'}</span></td>
    <td>${collection.CreatedAt ? new Date(collection.CreatedAt).toLocaleDateString() : '-'}</td>
    <td>
        <button class="btn-action btn-view" data-id="${collection.PickupId}"><i class="fas fa-eye"></i></button>
        <button class="btn-action btn-assign" data-id="${collection.PickupId}"><i class="fas fa-user-plus"></i></button>
        <button class="btn-action btn-complete" data-id="${collection.PickupId}"><i class="fas fa-check"></i></button>
        <button class="btn-action btn-delete" data-id="${collection.PickupId}"><i class="fas fa-trash"></i></button>
    </td>
    `;

    // Add event listeners to action buttons
    row.querySelector('.btn-view').addEventListener('click', function () {
        viewCollection(this.getAttribute('data-id'));
           });
    row.querySelector('.btn-assign').addEventListener('click', function () {
        currentViewCollectionId = this.getAttribute('data-id');
    showAssignCollectorModal();
           });
    row.querySelector('.btn-complete').addEventListener('click', function () {
        currentViewCollectionId = this.getAttribute('data-id');
    showCompleteCollectionModal();
           });
    row.querySelector('.btn-delete').addEventListener('click', function () {
        currentViewCollectionId = this.getAttribute('data-id');
    showDeleteConfirmationModal();
           });

    return row;
       }

    function viewCollection(id) {
           const collection = allCollections.find(c => c.PickupId === id);
    if (collection) {
        currentViewCollectionId = id;

    // Get initials for avatars
    const citizenInitial = collection.CitizenName ? collection.CitizenName.charAt(0).toUpperCase() : 'C';
    const collectorInitial = collection.CollectorName ? collection.CollectorName.charAt(0).toUpperCase() : 'N';

    document.getElementById('viewPickupId').textContent = collection.PickupId;
    document.getElementById('viewCollectionStatus').textContent = collection.Status || 'Requested';
    document.getElementById('viewCitizenName').textContent = collection.CitizenName || 'Unknown';
    document.getElementById('viewCitizenAvatar').textContent = citizenInitial;
    document.getElementById('viewCollectorName').textContent = collection.CollectorName || 'Not assigned';
    document.getElementById('viewCollectorAvatar').textContent = collectorInitial;
    document.getElementById('viewWasteType').textContent = collection.WasteTypeName || 'Unknown';
    document.getElementById('viewCollectionAddress').textContent = collection.Address || 'No address';
    document.getElementById('viewEstimatedWeight').textContent = (collection.EstimatedKg || 0) + ' kg';
    document.getElementById('viewVerifiedWeight').textContent = collection.VerifiedKg ? collection.VerifiedKg + ' kg' : '-';
    document.getElementById('viewCreditsEarned').textContent = collection.CreditsEarned || 0;
    document.getElementById('viewCreatedAt').textContent = collection.CreatedAt ? new Date(collection.CreatedAt).toLocaleString() : '-';
    document.getElementById('viewCompletedAt').textContent = collection.CompletedAt ? new Date(collection.CompletedAt).toLocaleString() : '-';

    document.getElementById('viewCollectionModal').style.display = 'block';
           }
       }

    function showAddCollectionModal() {
           // Populate citizen dropdown
           const citizenSelect = document.getElementById('addCitizenSelect');
    citizenSelect.innerHTML = '<option value="">-- Select Citizen --</option>';
           allCitizens.forEach(citizen => {
               const option = document.createElement('option');
    option.value = citizen.UserId;
    option.textContent = citizen.FullName;
    citizenSelect.appendChild(option);
           });

    // Populate waste type dropdown
    const wasteTypeSelect = document.getElementById('addWasteTypeSelect');
    wasteTypeSelect.innerHTML = '<option value="">-- Select Waste Type --</option>';
           allWasteTypes.forEach(wasteType => {
               const option = document.createElement('option');
    option.value = wasteType.WasteTypeId;
    option.textContent = wasteType.Name;
    wasteTypeSelect.appendChild(option);
           });

    document.getElementById('addCollectionModal').style.display = 'block';
       }

    function addNewCollection() {
           const citizenId = document.getElementById('addCitizenSelect').value;
    const wasteTypeId = document.getElementById('addWasteTypeSelect').value;
    const address = document.getElementById('addAddress').value;
    const estimatedWeight = document.getElementById('addEstimatedWeight').value;
    const scheduleDate = document.getElementById('addScheduleDate').value;
    const notes = document.getElementById('addNotes').value;

    if (!citizenId || !wasteTypeId || !address || !estimatedWeight) {
        showNotification('Please fill in all required fields', 'error');
    return;
           }

    // Call server method to add collection
    PageMethods.AddCollection(citizenId, wasteTypeId, address, estimatedWeight, scheduleDate, notes,
    function (response) {
        showNotification('Collection added successfully!', 'success');
    document.getElementById('addCollectionModal').style.display = 'none';
    // Refresh collections
    document.getElementById('<%= btnLoadCollections.ClientID %>').click();
               },
    function (error) {
        showNotification('Error adding collection: ' + error, 'error');
               }
    );
       }

    function showAssignCollectorModal() {
           // Populate collector dropdown
           const collectorSelect = document.getElementById('collectorSelect');
    collectorSelect.innerHTML = '<option value="">-- Select Collector --</option>';
           allCollectors.forEach(collector => {
               const option = document.createElement('option');
    option.value = collector.UserId;
    option.textContent = collector.FullName;
    collectorSelect.appendChild(option);
           });

    document.getElementById('assignCollectorModal').style.display = 'block';
       }

    function assignCollector() {
           const collectorId = document.getElementById('collectorSelect').value;
    const scheduleDateTime = document.getElementById('scheduleDateTime').value;

    if (!collectorId) {
        showNotification('Please select a collector', 'error');
    return;
           }

    // Call server method to assign collector
    PageMethods.AssignCollector(currentViewCollectionId, collectorId, scheduleDateTime,
    function (response) {
        showNotification('Collector assigned successfully!', 'success');
    document.getElementById('assignCollectorModal').style.display = 'none';
    document.getElementById('viewCollectionModal').style.display = 'none';
    // Refresh collections
    document.getElementById('<%= btnLoadCollections.ClientID %>').click();
               },
    function (error) {
        showNotification('Error assigning collector: ' + error, 'error');
               }
    );
       }

    function showCompleteCollectionModal() {
        document.getElementById('completeCollectionModal').style.display = 'block';
       }

    function completeCollection() {
           const verifiedWeight = document.getElementById('verifiedWeight').value;
    const materialType = document.getElementById('materialTypeSelect').value;
    const notes = document.getElementById('completionNotes').value;

    if (!verifiedWeight) {
        showNotification('Please enter the verified weight', 'error');
    return;
           }

    // Call server method to complete collection
    PageMethods.CompleteCollection(currentViewCollectionId, verifiedWeight, materialType, notes,
    function (response) {
        showNotification('Collection marked as complete!', 'success');
    document.getElementById('completeCollectionModal').style.display = 'none';
    document.getElementById('viewCollectionModal').style.display = 'none';
    // Refresh collections
    document.getElementById('<%= btnLoadCollections.ClientID %>').click();
               },
    function (error) {
        showNotification('Error completing collection: ' + error, 'error');
               }
    );
       }

    function showDeleteConfirmationModal() {
           const collection = allCollections.find(c => c.PickupId === currentViewCollectionId);
    if (collection) {
        document.getElementById('deleteCollectionInfo').textContent =
        `Collection ID: ${collection.PickupId} - ${collection.WasteTypeName || 'Unknown'} waste at ${collection.Address || 'Unknown address'}`;
           }
    document.getElementById('deleteCollectionModal').style.display = 'block';
       }

    function deleteCollection() {
        // Call server method to delete collection
        PageMethods.DeleteCollection(currentViewCollectionId,
            function (response) {
                showNotification('Collection deleted successfully!', 'success');
                document.getElementById('deleteCollectionModal').style.display = 'none';
                document.getElementById('viewCollectionModal').style.display = 'none';
                // Refresh collections
                document.getElementById('<%= btnLoadCollections.ClientID %>').click();
            },
            function (error) {
                showNotification('Error deleting collection: ' + error, 'error');
            }
        );
       }

    function generateReport() {
        showNotification('Report generation started. You will be notified when it is ready.', 'info');
           // In a real implementation, this would trigger report generation
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

    // Escape HTML to prevent text corruption
    function escapeHtml(unsafe) {
           if (!unsafe) return '';
    return unsafe.toString()
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
               .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#039;");
       }
