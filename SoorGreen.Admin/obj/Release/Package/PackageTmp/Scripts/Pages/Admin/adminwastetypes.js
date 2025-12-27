
       // GLOBAL VARIABLES
       let currentView = 'grid';
       let currentPage = 1;
       const typesPerPage = 6;
       let filteredTypes = [];
       let allTypes = [];
       let currentViewTypeId = null;
       let currentDeleteTypeId = null;
       let currentEditTypeId = null;
       let isEditing = false;

       // INITIALIZE
       document.addEventListener('DOMContentLoaded', function () {
           initializeEventListeners();
           loadTypesFromServer();
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
           document.getElementById('searchTypes').addEventListener('input', function (e) {
               applyFilters();
           });

           // Filter dropdowns
           document.getElementById('creditFilter').addEventListener('change', function (e) {
               applyFilters();
           });

           document.getElementById('statusFilter').addEventListener('change', function (e) {
               applyFilters();
           });

           // Modal close buttons
           document.querySelector('#viewTypeModal .close-modal').addEventListener('click', closeViewTypeModal);
           document.querySelector('#editTypeModal .close-modal').addEventListener('click', closeEditTypeModal);
           document.querySelector('#deleteTypeModal .close-modal').addEventListener('click', closeDeleteModal);

           document.getElementById('closeViewModalBtn').addEventListener('click', closeViewTypeModal);
           document.getElementById('cancelEditBtn').addEventListener('click', closeEditTypeModal);
           document.getElementById('cancelDeleteBtn').addEventListener('click', closeDeleteModal);

           document.getElementById('editTypeBtn').addEventListener('click', openEditTypeModal);
           document.getElementById('confirmEditBtn').addEventListener('click', confirmSaveType);
           document.getElementById('confirmDeleteBtn').addEventListener('click', confirmDelete);

           // Add type button
           document.getElementById('addTypeBtn').addEventListener('click', openAddTypeModal);

           // Close modals when clicking outside
           document.getElementById('viewTypeModal').addEventListener('click', function (e) {
               if (e.target === this) closeViewTypeModal();
           });
           document.getElementById('editTypeModal').addEventListener('click', function (e) {
               if (e.target === this) closeEditTypeModal();
           });
           document.getElementById('deleteTypeModal').addEventListener('click', function (e) {
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

           renderTypes();
       }

       function loadTypesFromServer() {
           showLoading();

           const typesData = document.getElementById('<%= hfTypesData.ClientID %>').value;
           const statsData = document.getElementById('<%= hfStatsData.ClientID %>').value;

           if (typesData && typesData !== '') {
               try {
                   allTypes = JSON.parse(typesData);
                   filteredTypes = [...allTypes];

                   // Update statistics
                   if (statsData && statsData !== '') {
                       const stats = JSON.parse(statsData);
                       updateStatistics(stats);
                   }

                   renderTypes();
                   updatePagination();
                   updatePageInfo();
                   hideLoading();

                   if (filteredTypes.length > 0) {
                       showSuccess('Loaded ' + filteredTypes.length + ' waste types from database');
                   } else {
                       showInfo('No waste types found in database');
                   }

               } catch (e) {
                   console.error('Error parsing type data:', e);
                   showError('Error loading waste type data from database');
                   hideLoading();
               }
           } else {
               showError('No waste type data available from database');
               hideLoading();
           }
       }

       function updateStatistics(stats) {
           document.getElementById('totalTypes').textContent = stats.TotalTypes || 0;
           document.getElementById('avgCreditRate').textContent = (stats.AverageCreditRate || 0).toFixed(2);
           document.getElementById('highestCredit').textContent = (stats.HighestCreditRate || 0).toFixed(2);
           document.getElementById('activeTypes').textContent = stats.ActiveTypes || 0;
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
           const searchTerm = document.getElementById('searchTypes').value.toLowerCase();
           const creditFilter = document.getElementById('creditFilter').value;
           const statusFilter = document.getElementById('statusFilter').value;

           filteredTypes = allTypes.filter(type => {
               const matchesSearch = !searchTerm ||
                   (type.Name && type.Name.toLowerCase().includes(searchTerm)) ||
                   (type.Description && type.Description.toLowerCase().includes(searchTerm));

               const matchesCredit = creditFilter === 'all' || 
                   (creditFilter === 'low' && type.CreditPerKg <= 0.25) ||
                   (creditFilter === 'medium' && type.CreditPerKg > 0.25 && type.CreditPerKg <= 0.75) ||
                   (creditFilter === 'high' && type.CreditPerKg > 0.75);

               const matchesStatus = statusFilter === 'all' || 
                   (statusFilter === 'active' && type.Status === 'Active') ||
                   (statusFilter === 'inactive' && type.Status === 'Inactive');

               return matchesSearch && matchesCredit && matchesStatus;
           });

           currentPage = 1;
           renderTypes();
           updatePagination();
           updatePageInfo();
       }

       function renderTypes() {
           if (currentView === 'grid') {
               renderGridView();
           } else {
               renderTableView();
           }
       }

       function renderGridView() {
           const grid = document.getElementById('typesGrid');
           const startIndex = (currentPage - 1) * typesPerPage;
           const endIndex = startIndex + typesPerPage;
           const typesToShow = filteredTypes.slice(startIndex, endIndex);

           grid.innerHTML = '';

           if (typesToShow.length === 0) {
               grid.innerHTML = '<div class="col-12 text-center py-5"><i class="fas fa-trash-alt fa-3x mb-3" style="color: rgba(255, 255, 255, 0.5) !important;"></i><h4 style="color: rgba(255, 255, 255, 0.7) !important;">No waste types found</h4><p style="color: rgba(255, 255, 255, 0.5) !important;">Try adjusting your filters or search terms</p></div>';
               return;
           }

           typesToShow.forEach(type => {
               const typeCard = createTypeCard(type);
               grid.appendChild(typeCard);
           });
       }

       function renderTableView() {
           const tbody = document.getElementById('typesTableBody');
           const startIndex = (currentPage - 1) * typesPerPage;
           const endIndex = startIndex + typesPerPage;
           const typesToShow = filteredTypes.slice(startIndex, endIndex);

           tbody.innerHTML = '';

           if (typesToShow.length === 0) {
               tbody.innerHTML = '<tr><td colspan="7" class="text-center py-4"><i class="fas fa-trash-alt fa-2x mb-2" style="color: rgba(255, 255, 255, 0.5) !important;"></i><h5 style="color: rgba(255, 255, 255, 0.7) !important;">No waste types found</h5><p style="color: rgba(255, 255, 255, 0.5) !important;">Try adjusting your filters or search terms</p></td></tr>';
               return;
           }

           typesToShow.forEach(type => {
               const row = createTableRow(type);
               tbody.appendChild(row);
           });
       }

       function createTypeCard(type) {
           const card = document.createElement('div');
           card.className = 'type-card';

           const statusClass = type.Status === 'Active' ? 'status-active' : 'status-inactive';
           const totalCredits = (type.TotalWeight || 0) * (type.CreditPerKg || 0);

           card.innerHTML = '<div class="type-header"><div class="type-info"><h3 class="type-title">' + escapeHtml(type.Name || 'Unknown') + '</h3><p class="type-description">' + escapeHtml(type.Description || 'No description available') + '</p><div class="type-details"><div class="detail-item"><div class="detail-value">' + (type.CreditPerKg || 0) + '</div><div class="detail-label">Credits/kg</div></div><div class="detail-item"><div class="detail-value">' + (type.ReportsCount || 0) + '</div><div class="detail-label">Reports</div></div><div class="detail-item"><div class="detail-value">' + (type.TotalWeight || 0) + 'kg</div><div class="detail-label">Total Weight</div></div><div class="detail-item"><div class="detail-value">' + totalCredits.toFixed(0) + '</div><div class="detail-label">Total Credits</div></div></div></div><div class="type-actions"><button class="btn-action btn-view" data-type-id="' + type.WasteTypeId + '" title="View Details"><i class="fas fa-eye"></i></button><button class="btn-action btn-edit" data-type-id="' + type.WasteTypeId + '" title="Edit Type"><i class="fas fa-edit"></i></button><button class="btn-action btn-delete" data-type-id="' + type.WasteTypeId + '" title="Delete Type"><i class="fas fa-trash"></i></button></div></div><div class="type-meta"><div class="type-status"><span class="status-badge ' + statusClass + '">' + (type.Status || 'Active') + '</span><span style="color: rgba(255, 255, 255, 0.5) !important;">ID: ' + type.WasteTypeId + '</span></div><div class="small" style="color: rgba(255, 255, 255, 0.5) !important;">Avg: ' + (type.AverageWeight || 0) + 'kg per report</div></div>';

           // Add event listeners
           card.querySelector('.btn-view').addEventListener('click', function () {
               viewType(this.getAttribute('data-type-id'));
           });

           card.querySelector('.btn-edit').addEventListener('click', function () {
               editType(this.getAttribute('data-type-id'));
           });

           card.querySelector('.btn-delete').addEventListener('click', function () {
               deleteType(this.getAttribute('data-type-id'));
           });

           return card;
       }

       function createTableRow(type) {
           const row = document.createElement('tr');
           const statusClass = type.Status === 'Active' ? 'status-active' : 'status-inactive';
           const totalCredits = (type.TotalWeight || 0) * (type.CreditPerKg || 0);

           row.innerHTML = '<td>' + type.WasteTypeId + '</td><td><div class="fw-bold" style="color: #ffffff !important;">' + escapeHtml(type.Name || 'Unknown') + '</div><div class="small" style="color: rgba(255, 255, 255, 0.6) !important;">' + escapeHtml(type.Description || 'No description') + '</div></td><td><div style="color: #ffffff !important;">' + (type.CreditPerKg || 0) + ' credits/kg</div><div class="small" style="color: rgba(255, 255, 255, 0.6) !important;">Total: ' + totalCredits.toFixed(0) + ' credits</div></td><td><span class="status-badge ' + statusClass + '">' + (type.Status || 'Active') + '</span></td><td>' + (type.ReportsCount || 0) + '</td><td>' + (type.TotalWeight || 0) + ' kg</td><td><div class="type-actions"><button class="btn-action btn-view" data-type-id="' + type.WasteTypeId + '" title="View Details"><i class="fas fa-eye"></i></button><button class="btn-action btn-edit" data-type-id="' + type.WasteTypeId + '" title="Edit Type"><i class="fas fa-edit"></i></button><button class="btn-action btn-delete" data-type-id="' + type.WasteTypeId + '" title="Delete Type"><i class="fas fa-trash"></i></button></div></td>';

           // Add event listeners
           row.querySelector('.btn-view').addEventListener('click', function () {
               viewType(this.getAttribute('data-type-id'));
           });

           row.querySelector('.btn-edit').addEventListener('click', function () {
               editType(this.getAttribute('data-type-id'));
           });

           row.querySelector('.btn-delete').addEventListener('click', function () {
               deleteType(this.getAttribute('data-type-id'));
           });

           return row;
       }

       function updatePagination() {
           const pagination = document.getElementById('pagination');
           const totalPages = Math.ceil(filteredTypes.length / typesPerPage);

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
           const totalPages = Math.ceil(filteredTypes.length / typesPerPage);
           if (page >= 1 && page <= totalPages) {
               currentPage = page;
               renderTypes();
               updatePagination();
           }
       }

       function updatePageInfo() {
           const startIndex = (currentPage - 1) * typesPerPage + 1;
           const endIndex = Math.min(currentPage * typesPerPage, filteredTypes.length);
           document.getElementById('pageInfo').textContent = 'Showing ' + startIndex + '-' + endIndex + ' of ' + filteredTypes.length + ' types';
       }

       function showLoading() {
           const grid = document.getElementById('typesGrid');
           if (grid) {
               grid.innerHTML = '<div class="col-12 text-center py-5"><i class="fas fa-spinner fa-spin fa-2x mb-3" style="color: rgba(255, 255, 255, 0.5) !important;"></i><p style="color: rgba(255, 255, 255, 0.7) !important;">Loading waste types from database...</p></div>';
           }
       }

       function hideLoading() { }

       // View Type Modal Functions
       function viewType(typeId) {
           const type = allTypes.find(t => t.WasteTypeId === typeId);
           if (type) {
               currentViewTypeId = typeId;

               // Populate modal with type data
               document.getElementById('viewTypeId').textContent = type.WasteTypeId;
               document.getElementById('viewTypeName').textContent = type.Name || 'Unknown';
               document.getElementById('viewTypeDescription').textContent = type.Description || 'No description available';
               document.getElementById('viewCreditRate').textContent = (type.CreditPerKg || 0) + ' credits per kg';
               document.getElementById('viewReportsCount').textContent = type.ReportsCount || 0;
               document.getElementById('viewTotalWeight').textContent = (type.TotalWeight || 0) + ' kg';
               document.getElementById('viewAvgWeight').textContent = (type.AverageWeight || 0) + ' kg';
               document.getElementById('viewTotalCredits').textContent = ((type.TotalWeight || 0) * (type.CreditPerKg || 0)).toFixed(0) + ' credits';
               
               const statusElement = document.getElementById('viewTypeStatus');
               statusElement.innerHTML = '<span class="status-badge ' + (type.Status === 'Active' ? 'status-active' : 'status-inactive') + '">' + (type.Status || 'Active') + '</span>';

               // Show modal
               document.getElementById('viewTypeModal').style.display = 'block';
           }
       }

       function closeViewTypeModal() {
           document.getElementById('viewTypeModal').style.display = 'none';
           currentViewTypeId = null;
       }

       // Edit Type Modal Functions
       function openAddTypeModal() {
           isEditing = false;
           currentEditTypeId = null;
           document.getElementById('editModalTitle').textContent = 'Add New Waste Type';
           document.getElementById('typeName').value = '';
           document.getElementById('creditRate').value = '';
           document.getElementById('typeStatus').value = 'Active';
           document.getElementById('typeDescription').value = '';
           document.getElementById('typeColor').value = '#20c997';
           document.getElementById('editTypeModal').style.display = 'block';
       }

       function openEditTypeModal() {
           if (currentViewTypeId) {
               const type = allTypes.find(t => t.WasteTypeId === currentViewTypeId);
               if (type) {
                   isEditing = true;
                   currentEditTypeId = currentViewTypeId;
                   document.getElementById('editModalTitle').textContent = 'Edit Waste Type';
                   document.getElementById('typeName').value = type.Name || '';
                   document.getElementById('creditRate').value = type.CreditPerKg || '';
                   document.getElementById('typeStatus').value = type.Status || 'Active';
                   document.getElementById('typeDescription').value = type.Description || '';
                   document.getElementById('typeColor').value = type.Color || '#20c997';
                   document.getElementById('editTypeModal').style.display = 'block';
                   closeViewTypeModal();
               }
           }
       }

       function editType(typeId) {
           const type = allTypes.find(t => t.WasteTypeId === typeId);
           if (type) {
               isEditing = true;
               currentEditTypeId = typeId;
               document.getElementById('editModalTitle').textContent = 'Edit Waste Type';
               document.getElementById('typeName').value = type.Name || '';
               document.getElementById('creditRate').value = type.CreditPerKg || '';
               document.getElementById('typeStatus').value = type.Status || 'Active';
               document.getElementById('typeDescription').value = type.Description || '';
               document.getElementById('typeColor').value = type.Color || '#20c997';
               document.getElementById('editTypeModal').style.display = 'block';
           }
       }

       function closeEditTypeModal() {
           document.getElementById('editTypeModal').style.display = 'none';
           currentEditTypeId = null;
           isEditing = false;
       }

       function confirmSaveType() {
           const name = document.getElementById('typeName').value;
           const creditRate = document.getElementById('creditRate').value;
           const status = document.getElementById('typeStatus').value;
           const description = document.getElementById('typeDescription').value;
           const color = document.getElementById('typeColor').value;

           if (!name || !creditRate) {
               showError('Please fill in all required fields');
               return;
           }

           if (creditRate <= 0) {
               showError('Please enter a valid credit rate');
               return;
           }

           if (isEditing && currentEditTypeId) {
               // Update existing type
               PageMethods.UpdateWasteType(currentEditTypeId, name, parseFloat(creditRate), status, description, color,
                   function(response) {
                       if (response.startsWith('Success')) {
                           showSuccess('Waste type updated successfully');
                           closeEditTypeModal();
                           document.getElementById('<%= btnLoadTypes.ClientID %>').click();
                       } else {
                           showError('Error updating waste type: ' + response);
                       }
                   },
                   function(error) {
                       showError('Error calling server: ' + error.get_message());
                   }
               );
           } else {
               // Create new type
               PageMethods.CreateWasteType(name, parseFloat(creditRate), status, description, color,
                   function(response) {
                       if (response.startsWith('Success')) {
                           showSuccess('Waste type created successfully');
                           closeEditTypeModal();
                           document.getElementById('<%= btnLoadTypes.ClientID %>').click();
                       } else {
                           showError('Error creating waste type: ' + response);
                       }
                   },
                   function(error) {
                       showError('Error calling server: ' + error.get_message());
                   }
               );
           }
       }

       // Delete Confirmation Modal Functions
       function deleteType(typeId) {
           const type = allTypes.find(t => t.WasteTypeId === typeId);
           if (type) {
               currentDeleteTypeId = typeId;
               document.getElementById('deleteTypeName').textContent = type.Name || 'Unknown';
               document.getElementById('deleteTypeModal').style.display = 'block';
           }
       }

       function closeDeleteModal() {
           document.getElementById('deleteTypeModal').style.display = 'none';
           currentDeleteTypeId = null;
       }

       function confirmDelete() {
           if (currentDeleteTypeId) {
               PageMethods.DeleteWasteType(currentDeleteTypeId,
                   function(response) {
                       if (response.startsWith('Success')) {
                           showSuccess('Waste type deleted successfully');
                           document.getElementById('<%= btnLoadTypes.ClientID %>').click();
                       } else {
                           showError('Error deleting waste type: ' + response);
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

       function escapeHtml(unsafe) {
           if (!unsafe) return '';
           return unsafe.toString()
               .replace(/&/g, "&amp;")
               .replace(/</g, "&lt;")
               .replace(/>/g, "&gt;")
               .replace(/"/g, "&quot;")
               .replace(/'/g, "&#039;");
       }
