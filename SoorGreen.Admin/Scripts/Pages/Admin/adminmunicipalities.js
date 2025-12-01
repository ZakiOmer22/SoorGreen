
        let allMunicipalities = [];
        let filteredMunicipalities = [];
        let currentPage = 1;
        const pageSize = 10;
        let editingMunicipalityId = null;

        document.addEventListener('DOMContentLoaded', function () {
            loadMunicipalitiesFromServer();
            setupEventListeners();
        });

        function setupEventListeners() {
            document.getElementById('refreshBtn').addEventListener('click', function (e) {
                e.preventDefault();
                refreshData();
            });

            document.getElementById('addMunicipalityBtn').addEventListener('click', function (e) {
                e.preventDefault();
                openAddMunicipalityModal();
            });

            document.getElementById('applyFiltersBtn').addEventListener('click', function (e) {
                e.preventDefault();
                applyFilters();
            });

            document.getElementById('clearFiltersBtn').addEventListener('click', function (e) {
                e.preventDefault();
                clearFilters();
            });

            document.getElementById('searchMunicipalities').addEventListener('input', function () {
                applyFilters();
            });

            document.getElementById('saveMunicipalityBtn').addEventListener('click', function (e) {
                e.preventDefault();
                saveMunicipality();
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

            document.getElementById('municipalityModal').addEventListener('click', function (e) {
                if (e.target === this) {
                    closeAllModals();
                }
            });
        }

        function closeAllModals() {
            document.getElementById('municipalityModal').style.display = 'none';
            editingMunicipalityId = null;
        }

        function loadMunicipalitiesFromServer() {
            showLoading(true);

            const municipalitiesData = document.getElementById('<%= hfMunicipalitiesData.ClientID %>').value;
            const statsData = document.getElementById('<%= hfStatsData.ClientID %>').value;

            console.log('Municipalities data:', municipalitiesData);
            console.log('Stats data:', statsData);

            if (municipalitiesData && municipalitiesData !== '[]' && municipalitiesData !== '') {
                try {
                    allMunicipalities = JSON.parse(municipalitiesData);
                    filteredMunicipalities = [...allMunicipalities];
                    console.log('Loaded municipalities:', allMunicipalities);
                } catch (e) {
                    console.error('Error parsing municipalities data:', e);
                    allMunicipalities = [];
                    filteredMunicipalities = [];
                }
            } else {
                console.log('No municipalities data found');
                allMunicipalities = [];
                filteredMunicipalities = [];
            }
            
            if (statsData && statsData !== '') {
                try {
                    updateStatistics(JSON.parse(statsData));
                } catch (e) {
                    console.error('Error parsing stats data:', e);
                }
            }

            renderMunicipalities();
            showLoading(false);
        }

        function refreshData() {
            showLoading(true);
            console.log('Refreshing data...');
            
            document.getElementById('<%= btnLoadMunicipalities.ClientID %>').click();

            setTimeout(function () {
                loadMunicipalitiesFromServer();
                showNotification('Data refreshed successfully!', 'success');
            }, 500);
        }

        function updateStatistics(stats) {
            document.getElementById('totalMunicipalities').textContent = stats.TotalMunicipalities || 0;
            document.getElementById('totalUsers').textContent = stats.TotalUsers || 0;
            document.getElementById('totalReports').textContent = stats.TotalReports || 0;
            document.getElementById('avgUsers').textContent = (stats.AvgUsers || 0).toFixed(1);
        }

        function applyFilters() {
            const searchTerm = document.getElementById('searchMunicipalities').value.toLowerCase();
            const sortFilter = document.getElementById('sortFilter').value;

            filteredMunicipalities = allMunicipalities.filter(municipality => {
                const matchesSearch = !searchTerm ||
                    (municipality.Name && municipality.Name.toLowerCase().includes(searchTerm));

                return matchesSearch;
            });

            // Apply sorting
            switch (sortFilter) {
                case 'name_desc':
                    filteredMunicipalities.sort((a, b) => b.Name.localeCompare(a.Name));
                    break;
                case 'users':
                    filteredMunicipalities.sort((a, b) => (b.UserCount || 0) - (a.UserCount || 0));
                    break;
                case 'reports':
                    filteredMunicipalities.sort((a, b) => (b.ReportCount || 0) - (a.ReportCount || 0));
                    break;
                default: // 'name'
                    filteredMunicipalities.sort((a, b) => a.Name.localeCompare(b.Name));
                    break;
            }

            currentPage = 1;
            renderMunicipalities();
        }

        function clearFilters() {
            document.getElementById('searchMunicipalities').value = '';
            document.getElementById('sortFilter').value = 'name';

            filteredMunicipalities = allMunicipalities;
            currentPage = 1;
            renderMunicipalities();
        }

        function renderMunicipalities() {
            const tbody = document.getElementById('municipalitiesTableBody');
            const emptyState = document.getElementById('municipalitiesEmptyState');
            const paginationInfo = document.getElementById('paginationInfo');
            const table = document.getElementById('municipalitiesTable');

            tbody.innerHTML = '';

            console.log('Rendering municipalities:', filteredMunicipalities.length);

            if (filteredMunicipalities.length === 0) {
                table.style.display = 'none';
                emptyState.style.display = 'block';
                paginationInfo.textContent = 'Showing 0 municipalities';
                return;
            }

            table.style.display = 'table';
            emptyState.style.display = 'none';

            const startIndex = (currentPage - 1) * pageSize;
            const endIndex = Math.min(startIndex + pageSize, filteredMunicipalities.length);
            const paginatedMunicipalities = filteredMunicipalities.slice(startIndex, endIndex);

            console.log('Creating table rows for:', paginatedMunicipalities.length, 'municipalities');

            paginatedMunicipalities.forEach(municipality => {
                const row = createMunicipalityRow(municipality);
                if (row) {
                    tbody.appendChild(row);
                }
            });

            paginationInfo.textContent = `Showing ${startIndex + 1}-${endIndex} of ${filteredMunicipalities.length} municipalities`;
            renderPagination();
        }

        function createMunicipalityRow(municipality) {
            if (!municipality) return null;

            const row = document.createElement('tr');

            const municipalityId = municipality.MunicipalityId || '-';
            const name = municipality.Name || 'Unknown Municipality';
            const userCount = municipality.UserCount || 0;
            const reportCount = municipality.ReportCount || 0;
            const totalCredits = municipality.TotalCredits || 0;

            const municipalityInitial = name.charAt(0).toUpperCase();

            row.innerHTML = `
                <td>
                    <div class="municipality-info">
                        <div class="municipality-avatar">${municipalityInitial}</div>
                        <div>
                            <div style="font-weight: 600; color: #ffffff !important;">${escapeHtml(name)}</div>
                            <div style="font-size: 0.8rem; color: rgba(255, 255, 255, 0.6) !important;">ID: ${escapeHtml(municipalityId)}</div>
                        </div>
                    </div>
                </td>
                <td>
                    <span class="user-count">${userCount} users</span>
                </td>
                <td>
                    <span class="report-count">${reportCount} reports</span>
                </td>
                <td style="color: #198754 !important; font-weight: 600;">${totalCredits} credits</td>
                <td>
                    <button class="btn-action btn-edit me-1" data-id="${municipalityId}" title="Edit Municipality">
                        <i class="fas fa-edit"></i>
                    </button>
                    <button class="btn-action btn-delete" data-id="${municipalityId}" title="Delete Municipality">
                        <i class="fas fa-trash"></i>
                    </button>
                </td>
            `;

            const editBtn = row.querySelector('.btn-edit');
            if (editBtn) {
                editBtn.addEventListener('click', function (e) {
                    e.preventDefault();
                    e.stopPropagation();
                    editMunicipality(this.getAttribute('data-id'));
                });
            }

            const deleteBtn = row.querySelector('.btn-delete');
            if (deleteBtn) {
                deleteBtn.addEventListener('click', function (e) {
                    e.preventDefault();
                    e.stopPropagation();
                    deleteMunicipality(this.getAttribute('data-id'), name);
                });
            }

            return row;
        }

        function openAddMunicipalityModal() {
            document.getElementById('modalTitle').textContent = 'Add Municipality';
            document.getElementById('modalMunicipalityId').value = '';
            document.getElementById('modalMunicipalityId').disabled = false;
            document.getElementById('modalName').value = '';

            editingMunicipalityId = null;
            document.getElementById('municipalityModal').style.display = 'block';
        }

        function editMunicipality(municipalityId) {
            const municipality = allMunicipalities.find(m => m.MunicipalityId === municipalityId);
            if (municipality) {
                document.getElementById('modalTitle').textContent = 'Edit Municipality';
                document.getElementById('modalMunicipalityId').value = municipality.MunicipalityId || '';
                document.getElementById('modalMunicipalityId').disabled = true;
                document.getElementById('modalName').value = municipality.Name || '';

                editingMunicipalityId = municipalityId;
                document.getElementById('municipalityModal').style.display = 'block';
            }
        }

        function deleteMunicipality(municipalityId, name) {
            if (confirm(`Are you sure you want to delete municipality "${name}"? This action cannot be undone.`)) {
                showNotification('Deleting municipality...', 'info');

                PageMethods.DeleteMunicipality(municipalityId, onMunicipalityDeleted, onMunicipalityError);
            }
        }

        function onMunicipalityDeleted(result) {
            if (result === 'SUCCESS') {
                showNotification('Municipality deleted successfully!', 'success');
                refreshData();
            } else {
                showNotification('Error deleting municipality: ' + result, 'error');
            }
        }

        function saveMunicipality() {
            const municipalityId = document.getElementById('modalMunicipalityId').value.trim();
            const name = document.getElementById('modalName').value.trim();

            if (!municipalityId) {
                showNotification('Please enter a Municipality ID', 'error');
                return;
            }

            if (!name) {
                showNotification('Please enter a Municipality Name', 'error');
                return;
            }

            if (municipalityId.length !== 4) {
                showNotification('Municipality ID must be exactly 4 characters', 'error');
                return;
            }

            const action = editingMunicipalityId ? 'edit' : 'add';

            showNotification('Saving municipality...', 'info');

            PageMethods.SaveMunicipality(municipalityId, name, action, onMunicipalitySaved, onMunicipalityError);
        }

        function onMunicipalitySaved(result) {
            if (result === 'SUCCESS') {
                const action = editingMunicipalityId ? 'updated' : 'added';
                showNotification(`Municipality ${action} successfully!`, 'success');
                closeAllModals();
                refreshData();
            } else {
                showNotification('Error saving municipality: ' + result, 'error');
            }
        }

        function onMunicipalityError(error) {
            showNotification('Error: ' + error.get_message(), 'error');
        }

        function renderPagination() {
            const pagination = document.getElementById('pagination');
            const totalPages = Math.ceil(filteredMunicipalities.length / pageSize);

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
                    renderMunicipalities();
                });
            });
        }

        function showLoading(show) {
            const spinner = document.getElementById('loadingSpinner');
            const table = document.getElementById('municipalitiesTable');

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
            loadMunicipalitiesFromServer();
        });
