
// Global variables
let allCollectors = [];
let filteredCollectors = [];
let currentPage = 1;
const itemsPerPage = 12;

// DOM Elements
const elements = {
    searchInput: document.getElementById('searchCollectors'),
    statusFilter: document.getElementById('statusFilter'),
    availabilityFilter: document.getElementById('availabilityFilter'),
    dateFilter: document.getElementById('dateFilter'),
    applyFiltersBtn: document.getElementById('applyFiltersBtn'),
    gridView: document.getElementById('gridView'),
    tableView: document.getElementById('tableView'),
    viewBtns: document.querySelectorAll('.view-btn'),
    collectorsGrid: document.getElementById('collectorsGrid'),
    collectorsTableBody: document.getElementById('collectorsTableBody'),
    pagination: document.getElementById('pagination'),
    paginationInfo: document.getElementById('paginationInfo'),
    pageInfo: document.getElementById('pageInfo'),
    
    // Modals
    viewCollectorModal: document.getElementById('viewCollectorModal'),
    deleteCollectorModal: document.getElementById('deleteCollectorModal'),
    closeViewModalBtn: document.getElementById('closeViewModalBtn'),
    cancelDeleteBtn: document.getElementById('cancelDeleteBtn'),
    confirmDeleteBtn: document.getElementById('confirmDeleteBtn'),
    
    // Hidden fields
    hfCollectorsData: document.getElementById('<%= hfCollectorsData.ClientID %>'),
    hfCurrentPage: document.getElementById('<%= hfCurrentPage.ClientID %>')
};

// Initialize the page
document.addEventListener('DOMContentLoaded', function() {
    initializePage();
    setupEventListeners();
});

function initializePage() {
    try {
        // Parse collectors data from hidden field
        const collectorsData = elements.hfCollectorsData.value;
        if (collectorsData && collectorsData !== '[]') {
            allCollectors = JSON.parse(collectorsData);
            filteredCollectors = [...allCollectors];
            
            // Update page info
            updatePageInfo();
            
            // Load first page
            loadCollectors();
        } else {
            showNoDataMessage();
        }
    } catch (error) {
        console.error('Error initializing collectors:', error);
        showNoDataMessage();
    }
}

function setupEventListeners() {
    // Search input with debounce
    let searchTimeout;
    elements.searchInput.addEventListener('input', function() {
        clearTimeout(searchTimeout);
        searchTimeout = setTimeout(applyFilters, 300);
    });
    
    // Filter change events
    elements.statusFilter.addEventListener('change', applyFilters);
    elements.availabilityFilter.addEventListener('change', applyFilters);
    elements.dateFilter.addEventListener('change', applyFilters);
    elements.applyFiltersBtn.addEventListener('click', applyFilters);
    
    // View toggle buttons
    elements.viewBtns.forEach(btn => {
        btn.addEventListener('click', function() {
            elements.viewBtns.forEach(b => b.classList.remove('active'));
            this.classList.add('active');
            
            const view = this.getAttribute('data-view');
            toggleView(view);
        });
    });
    
    // Modal close buttons
    elements.closeViewModalBtn.addEventListener('click', closeViewCollectorModal);
    elements.cancelDeleteBtn.addEventListener('click', closeDeleteCollectorModal);
    
    // Close modals when clicking overlay
    document.querySelectorAll('.modal-overlay').forEach(modal => {
        modal.addEventListener('click', function(e) {
            if (e.target === this) {
                this.style.display = 'none';
            }
        });
    });
    
    // Close modals when clicking X
    document.querySelectorAll('.close-modal').forEach(btn => {
        btn.addEventListener('click', function() {
            this.closest('.modal-overlay').style.display = 'none';
        });
    });
    
    // Confirm delete
    elements.confirmDeleteBtn.addEventListener('click', confirmDeleteCollector);
}

function toggleView(view) {
    if (view === 'grid') {
        elements.gridView.style.display = 'block';
        elements.tableView.style.display = 'none';
    } else {
        elements.gridView.style.display = 'none';
        elements.tableView.style.display = 'block';
    }
    loadCollectors();
}

function applyFilters() {
    const searchTerm = elements.searchInput.value.toLowerCase();
    const statusFilter = elements.statusFilter.value;
    const availabilityFilter = elements.availabilityFilter.value;
    const dateFilter = elements.dateFilter.value;
    
    filteredCollectors = allCollectors.filter(collector => {
        // Search filter
        const matchesSearch = searchTerm === '' ||
            collector.FirstName.toLowerCase().includes(searchTerm) ||
            collector.LastName.toLowerCase().includes(searchTerm) ||
            collector.Email.toLowerCase().includes(searchTerm) ||
            collector.Phone.toLowerCase().includes(searchTerm);
        
        // Status filter
        const matchesStatus = statusFilter === 'all' || collector.Status === statusFilter;
        
        // Availability filter
        const matchesAvailability = availabilityFilter === 'all' || 
            collector.Availability === availabilityFilter;
        
        // Date filter
        let matchesDate = true;
        if (dateFilter !== 'all') {
            const regDate = new Date(collector.RegistrationDate);
            const now = new Date();
            
            switch(dateFilter) {
                case 'today':
                    matchesDate = regDate.toDateString() === now.toDateString();
                    break;
                case 'week':
                    const weekAgo = new Date(now.setDate(now.getDate() - 7));
                    matchesDate = regDate >= weekAgo;
                    break;
                case 'month':
                    const monthAgo = new Date(now.setMonth(now.getMonth() - 1));
                    matchesDate = regDate >= monthAgo;
                    break;
                case 'year':
                    const yearAgo = new Date(now.setFullYear(now.getFullYear() - 1));
                    matchesDate = regDate >= yearAgo;
                    break;
            }
        }
        
        return matchesSearch && matchesStatus && matchesAvailability && matchesDate;
    });
    
    currentPage = 1;
    updatePageInfo();
    loadCollectors();
}

function loadCollectors() {
    const startIndex = (currentPage - 1) * itemsPerPage;
    const endIndex = startIndex + itemsPerPage;
    const currentCollectors = filteredCollectors.slice(startIndex, endIndex);
    
    // Clear current content
    elements.collectorsGrid.innerHTML = '';
    elements.collectorsTableBody.innerHTML = '';
    
    if (currentCollectors.length === 0) {
        showNoDataMessage();
        return;
    }
    
    // Render based on current view
    if (elements.gridView.style.display !== 'none') {
        renderGridView(currentCollectors);
    } else {
        renderTableView(currentCollectors);
    }
    
    renderPagination();
}

function renderGridView(collectors) {
    collectors.forEach(collector => {
        const card = createCollectorCard(collector);
        elements.collectorsGrid.appendChild(card);
    });
}

function renderTableView(collectors) {
    collectors.forEach(collector => {
        const row = createCollectorTableRow(collector);
        elements.collectorsTableBody.appendChild(row);
    });
}

function createCollectorCard(collector) {
    const card = document.createElement('div');
    card.className = 'collector-card';
    card.setAttribute('data-id', collector.Id);
    
    // Calculate success rate
    const successRate = collector.TotalPickups > 0 ? 
        Math.round((collector.CompletedPickups / collector.TotalPickups) * 100) : 0;
    
    const initials = (collector.FirstName.charAt(0) + (collector.LastName?.charAt(0) || '')).toUpperCase();
    
    card.innerHTML = `
        <div class="collector-header">
            <div class="collector-avatar">${initials}</div>
            <div class="collector-info">
                <h4 class="collector-name">${collector.FirstName} ${collector.LastName}</h4>
                <p class="collector-email">${collector.Email}</p>
            </div>
        </div>
        
        <div class="collector-details">
            <div class="detail-item">
                <span class="detail-label">Phone</span>
                <span class="detail-value">${collector.Phone || 'N/A'}</span>
            </div>
            <div class="detail-item">
                <span class="detail-label">User Type</span>
                <span class="detail-value">${collector.UserType}</span>
            </div>
            <div class="detail-item">
                <span class="detail-label">Status</span>
                <span class="status-badge status-${collector.Status}">${capitalizeFirst(collector.Status)}</span>
            </div>
            <div class="detail-item">
                <span class="detail-label">Availability</span>
                <span class="availability-badge availability-${collector.Availability}">${capitalizeFirst(collector.Availability)}</span>
            </div>
            <div class="detail-item">
                <span class="detail-label">Rating</span>
                <span class="detail-value">${collector.Rating} <span class="rating">★</span></span>
            </div>
            <div class="detail-item">
                <span class="detail-label">Earnings</span>
                <span class="detail-value">$${collector.Earnings.toFixed(2)}</span>
            </div>
        </div>
        
        <div class="collector-actions">
            <button class="btn-action" onclick="viewCollectorDetails('${collector.Id}')">
                <i class="fas fa-eye me-1"></i> View
            </button>
            <button class="btn-action" onclick="editCollector('${collector.Id}')">
                <i class="fas fa-edit me-1"></i> Edit
            </button>
            <button class="btn-action btn-danger" onclick="openDeleteModal('${collector.Id}', '${collector.FirstName} ${collector.LastName}')">
                <i class="fas fa-trash me-1"></i> Delete
            </button>
        </div>
    `;
    
    return card;
}

function createCollectorTableRow(collector) {
    const row = document.createElement('tr');
    const initials = (collector.FirstName.charAt(0) + (collector.LastName?.charAt(0) || '')).toUpperCase();
    const successRate = collector.TotalPickups > 0 ? 
        Math.round((collector.CompletedPickups / collector.TotalPickups) * 100) : 0;
    
    row.innerHTML = `
        <td>
            <div style="display: flex; align-items: center;">
                <div class="collector-avatar" style="width: 40px; height: 40px; font-size: 1rem; margin-right: 10px;">
                    ${initials}
                </div>
                <div>
                    <div style="font-weight: 600;">${collector.FirstName} ${collector.LastName}</div>
                    <div style="font-size: 0.9rem; color: #6c757d;">${collector.UserType}</div>
                </div>
            </div>
        </td>
        <td>
            <div>${collector.Email}</div>
            <div style="font-size: 0.9rem; color: #6c757d;">${collector.Phone || 'N/A'}</div>
        </td>
        <td><span class="status-badge status-${collector.Status}">${capitalizeFirst(collector.Status)}</span></td>
        <td><span class="availability-badge availability-${collector.Availability}">${capitalizeFirst(collector.Availability)}</span></td>
        <td>${collector.CompletedPickups} (${successRate}%)</td>
        <td><span class="rating">${'★'.repeat(Math.floor(collector.Rating))}${collector.Rating % 1 ? '½' : ''}</span> (${collector.Rating})</td>
        <td>$${collector.Earnings.toFixed(2)}</td>
        <td>${formatDate(collector.RegistrationDate)}</td>
        <td>
            <div style="display: flex; gap: 5px;">
                <button class="btn-action" onclick="viewCollectorDetails('${collector.Id}')" title="View">
                    <i class="fas fa-eye"></i>
                </button>
                <button class="btn-action" onclick="editCollector('${collector.Id}')" title="Edit">
                    <i class="fas fa-edit"></i>
                </button>
                <button class="btn-action btn-danger" onclick="openDeleteModal('${collector.Id}', '${collector.FirstName} ${collector.LastName}')" title="Delete">
                    <i class="fas fa-trash"></i>
                </button>
            </div>
        </td>
    `;
    
    return row;
}

function renderPagination() {
    elements.pagination.innerHTML = '';
    const totalPages = Math.ceil(filteredCollectors.length / itemsPerPage);
    
    // Previous button
    const prevLi = document.createElement('li');
    prevLi.className = `page-item ${currentPage === 1 ? 'disabled' : ''}`;
    prevLi.innerHTML = `<a class="page-link" href="#" onclick="changePage(${currentPage - 1})">&laquo;</a>`;
    elements.pagination.appendChild(prevLi);
    
    // Page numbers
    const maxVisiblePages = 5;
    let startPage = Math.max(1, currentPage - Math.floor(maxVisiblePages / 2));
    let endPage = Math.min(totalPages, startPage + maxVisiblePages - 1);
    
    if (endPage - startPage + 1 < maxVisiblePages) {
        startPage = Math.max(1, endPage - maxVisiblePages + 1);
    }
    
    for (let i = startPage; i <= endPage; i++) {
        const pageLi = document.createElement('li');
        pageLi.className = `page-item ${i === currentPage ? 'active' : ''}`;
        pageLi.innerHTML = `<a class="page-link" href="#" onclick="changePage(${i})">${i}</a>`;
        elements.pagination.appendChild(pageLi);
    }
    
    // Next button
    const nextLi = document.createElement('li');
    nextLi.className = `page-item ${currentPage === totalPages ? 'disabled' : ''}`;
    nextLi.innerHTML = `<a class="page-link" href="#" onclick="changePage(${currentPage + 1})">&raquo;</a>`;
    elements.pagination.appendChild(nextLi);
    
    // Update pagination info
    const startItem = (currentPage - 1) * itemsPerPage + 1;
    const endItem = Math.min(currentPage * itemsPerPage, filteredCollectors.length);
    elements.paginationInfo.textContent = `Page ${currentPage} of ${totalPages} (${startItem}-${endItem} of ${filteredCollectors.length})`;
}

function changePage(page) {
    currentPage = page;
    elements.hfCurrentPage.value = page;
    loadCollectors();
    window.scrollTo({ top: 0, behavior: 'smooth' });
}

function updatePageInfo() {
    const startItem = (currentPage - 1) * itemsPerPage + 1;
    const endItem = Math.min(currentPage * itemsPerPage, filteredCollectors.length);
    elements.pageInfo.textContent = `Showing ${filteredCollectors.length > 0 ? startItem : 0}-${endItem} of ${filteredCollectors.length} collectors`;
}

function showNoDataMessage() {
    const message = '<div class="text-center py-5" style="color: #6c757d;"><i class="fas fa-users fa-3x mb-3"></i><h4>No collectors found</h4><p>Try adjusting your filters or search terms</p></div>';
    
    if (elements.gridView.style.display !== 'none') {
        elements.collectorsGrid.innerHTML = message;
    } else {
        elements.collectorsTableBody.innerHTML = `<tr><td colspan="9">${message}</td></tr>`;
    }
    
    elements.pagination.innerHTML = '';
    elements.paginationInfo.textContent = 'Page 1 of 1';
}

// Collector Actions
function viewCollectorDetails(collectorId) {
    const collector = allCollectors.find(c => c.Id === collectorId);
    if (!collector) return;
    
    // Calculate derived values
    const successRate = collector.TotalPickups > 0 ? 
        Math.round((collector.CompletedPickups / collector.TotalPickups) * 100) : 0;
    const initials = (collector.FirstName.charAt(0) + (collector.LastName?.charAt(0) || '')).toUpperCase();
    
    // Update modal content
    document.getElementById('viewCollectorAvatar').textContent = initials;
    document.getElementById('viewTotalPickups').textContent = collector.TotalPickups;
    document.getElementById('viewSuccessRate').textContent = `${successRate}%`;
    document.getElementById('viewAvgRating').textContent = collector.Rating;
    document.getElementById('viewTotalEarnings').textContent = `$${collector.Earnings.toFixed(2)}`;
    document.getElementById('viewCollectorName').textContent = `${collector.FirstName} ${collector.LastName}`;
    document.getElementById('viewCollectorEmail').textContent = collector.Email;
    document.getElementById('viewCollectorPhone').textContent = collector.Phone || 'N/A';
    document.getElementById('viewCollectorType').textContent = collector.UserType;
    document.getElementById('viewCollectorStatus').textContent = capitalizeFirst(collector.Status);
    document.getElementById('viewCollectorAvailability').textContent = capitalizeFirst(collector.Availability);
    document.getElementById('viewCollectorRating').textContent = `${collector.Rating} ★`;
    document.getElementById('viewCollectorRegDate').textContent = formatDate(collector.RegistrationDate);
    document.getElementById('viewCollectorAddress').textContent = collector.Address || 'N/A';
    document.getElementById('viewCollectorVehicle').textContent = collector.VehicleInfo || 'N/A';
    
    // Show modal
    elements.viewCollectorModal.style.display = 'flex';
}

function editCollector(collectorId) {
    // Redirect to edit page or show edit modal
    alert(`Edit collector ${collectorId} - Implement edit functionality`);
    // window.location.href = `EditCollector.aspx?id=${collectorId}`;
}

function openDeleteModal(collectorId, collectorName) {
    document.getElementById('deleteCollectorName').textContent = collectorName;
    elements.deleteCollectorModal.style.display = 'flex';
    
    // Store the collector ID in the modal for later use
    elements.deleteCollectorModal.dataset.collectorId = collectorId;
}

function closeViewCollectorModal() {
    elements.viewCollectorModal.style.display = 'none';
}

function closeDeleteCollectorModal() {
    elements.deleteCollectorModal.style.display = 'none';
    delete elements.deleteCollectorModal.dataset.collectorId;
}

async function confirmDeleteCollector() {
    const collectorId = elements.deleteCollectorModal.dataset.collectorId;
    const collectorName = document.getElementById('deleteCollectorName').textContent;
    
    if (!collectorId) return;
    
    try {
        // Call WebMethod to delete collector
        const response = await fetch('<%= ResolveUrl("~/Pages/Admin/Collectors.aspx/DeleteCollector") %>', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ collectorId: collectorId })
        });
        
        const result = await response.json();
        
        if (result.d.includes('Success')) {
            alert(`Collector ${collectorName} deleted successfully`);
            
            // Remove from local arrays
            allCollectors = allCollectors.filter(c => c.Id !== collectorId);
            filteredCollectors = filteredCollectors.filter(c => c.Id !== collectorId);
            
            // Update UI
            updatePageInfo();
            loadCollectors();
            
            // Close modal
            closeDeleteCollectorModal();
        } else {
            alert(`Error deleting collector: ${result.d}`);
        }
    } catch (error) {
        console.error('Delete error:', error);
        alert('Error deleting collector. Please try again.');
    }
}

// Utility functions
function capitalizeFirst(str) {
    return str.charAt(0).toUpperCase() + str.slice(1);
}

function formatDate(dateString) {
    const date = new Date(dateString);
    return date.toLocaleDateString('en-US', {
        year: 'numeric',
        month: 'short',
        day: 'numeric'
    });
}

// Update status function (can be called from edit modal or actions)
async function updateCollectorStatus(collectorId, status) {
    try {
        const response = await fetch('<%= ResolveUrl("~/Pages/Admin/Collectors.aspx/UpdateCollectorStatus") %>', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                collectorId: collectorId,
                status: status
            })
        });
        
        const result = await response.json();
        
        if (result.d.includes('Success')) {
            // Update local data
            const collector = allCollectors.find(c => c.Id === collectorId);
            if (collector) {
                collector.Status = status;
            }
            
            // Refresh display
            applyFilters();
            return true;
        } else {
            alert(`Error updating status: ${result.d}`);
            return false;
        }
    } catch (error) {
        console.error('Update status error:', error);
        alert('Error updating status. Please try again.');
        return false;
    }
}

// Export/Print functionality (optional)
function exportCollectors(format) {
    // Implement export to CSV/Excel/PDF
    alert(`Export collectors as ${format} - Implement export functionality`);
}

// Refresh data from server
function refreshCollectors() {
    // Trigger the server-side button click
    document.getElementById('<%= btnLoadCollectors.ClientID %>').click();
    
    // Reload after a short delay to allow server processing
    setTimeout(() => {
        initializePage();
    }, 1000);
}