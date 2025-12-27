
        let currentPage = 1;
        const itemsPerPage = 5;

        // Initialize when page loads
        document.addEventListener('DOMContentLoaded', function () {
            initializeFilters();
            loadReportData();
            initializeCharts();
            setupEventListeners();
        });

        function initializeFilters() {
            // Set default dates
            const today = new Date();
            const lastWeek = new Date(today.getTime() - 7 * 24 * 60 * 60 * 1000);
            
            document.getElementById('startDate').valueAsDate = lastWeek;
            document.getElementById('endDate').valueAsDate = today;
        }

        function setupEventListeners() {
            // Show/hide custom date range
            document.getElementById('dateRange').addEventListener('change', function() {
                const customRange = document.getElementById('customDateRange');
                customRange.style.display = this.value === 'custom' ? 'block' : 'none';
            });

            // Generate report on filter change
            document.getElementById('reportType').addEventListener('change', generateReport);
            document.getElementById('statusFilter').addEventListener('change', generateReport);
        }

        function generateReport() {
            showLoading();
            
            // Simulate API call delay
            setTimeout(() => {
                loadReportData();
                updateCharts();
                hideLoading();
                showSuccess('Report generated successfully!');
            }, 1000);
        }

        function loadReportData() {
            // Update summary stats
            document.getElementById('totalPickups').textContent = sampleData.summary.totalPickups.toLocaleString();
            document.getElementById('completedPickups').textContent = sampleData.summary.completedPickups.toLocaleString();
            document.getElementById('pendingPickups').textContent = sampleData.summary.pendingPickups.toLocaleString();
            document.getElementById('totalRevenue').textContent = '$' + sampleData.summary.totalRevenue.toLocaleString();
            document.getElementById('avgRating').textContent = sampleData.summary.avgRating.toFixed(1);

            // Populate detailed table
            populateTable();
        }

        function populateTable() {
            const tbody = document.getElementById('reportTableBody');
            const statusFilter = document.getElementById('statusFilter').value;
            
            // Filter data based on status
            let filteredData = sampleData.pickups;
            if (statusFilter !== 'all') {
                filteredData = sampleData.pickups.filter(item => item.status === statusFilter);
            }

            // Calculate pagination
            const totalPages = Math.ceil(filteredData.length / itemsPerPage);
            const startIndex = (currentPage - 1) * itemsPerPage;
            const endIndex = startIndex + itemsPerPage;
            const pageData = filteredData.slice(startIndex, endIndex);

            // Clear existing rows
            tbody.innerHTML = '';

            // Populate rows
            pageData.forEach(item => {
                const row = document.createElement('tr');
                row.innerHTML = `
                    <td>${item.id}</td>
                    <td>${item.user}</td>
                    <td>${formatDate(item.date)}</td>
                    <td>${item.type}</td>
                    <td>${item.weight} kg</td>
                    <td><span class="status-badge status-${item.status}">${capitalizeFirst(item.status)}</span></td>
                    <td>${item.credits}</td>
                    <td>
                        <button class="btn-report" onclick="viewDetails('${item.id}')" title="View Details">
                            <i class="fas fa-eye"></i>
                        </button>
                        <button class="btn-report" onclick="editItem('${item.id}')" title="Edit">
                            <i class="fas fa-edit"></i>
                        </button>
                    </td>
                `;
                tbody.appendChild(row);
            });

            // Update pagination
            updatePagination(filteredData.length, totalPages);
            
            // Update table info
            document.getElementById('tableInfo').textContent = 
                `Showing ${startIndex + 1} to ${Math.min(endIndex, filteredData.length)} of ${filteredData.length} entries`;
        }

        function updatePagination(totalItems, totalPages) {
            const pagination = document.getElementById('pagination');
            pagination.innerHTML = '';

            // Previous button
            const prevLi = document.createElement('li');
            prevLi.className = `page-item ${currentPage === 1 ? 'disabled' : ''}`;
            prevLi.innerHTML = `<a class="page-link" href="#" onclick="changePage(${currentPage - 1})">Previous</a>`;
            pagination.appendChild(prevLi);

            // Page numbers
            for (let i = 1; i <= totalPages; i++) {
                const li = document.createElement('li');
                li.className = `page-item ${currentPage === i ? 'active' : ''}`;
                li.innerHTML = `<a class="page-link" href="#" onclick="changePage(${i})">${i}</a>`;
                pagination.appendChild(li);
            }

            // Next button
            const nextLi = document.createElement('li');
            nextLi.className = `page-item ${currentPage === totalPages ? 'disabled' : ''}`;
            nextLi.innerHTML = `<a class="page-link" href="#" onclick="changePage(${currentPage + 1})">Next</a>`;
            pagination.appendChild(nextLi);
        }

        function changePage(page) {
            currentPage = page;
            populateTable();
        }

        function initializeCharts() {
            // Waste Category Chart
            const wasteCtx = document.getElementById('wasteCategoryChart').getContext('2d');
            new Chart(wasteCtx, {
                type: 'doughnut',
                data: {
                    labels: ['Plastic', 'Paper', 'Glass', 'Metal', 'Organic', 'E-Waste'],
                    datasets: [{
                        data: [35, 25, 15, 12, 8, 5],
                        backgroundColor: [
                            '#198754', '#0dcaf0', '#ffc107', '#dc3545', '#6f42c1', '#fd7e14'
                        ],
                        borderWidth: 0
                    }]
                },
                options: {
                    responsive: true,
                    plugins: {
                        legend: {
                            position: 'bottom',
                            labels: { color: 'rgba(255, 255, 255, 0.7)' }
                        }
                    }
                }
            });

            // Pickup Status Chart
            const statusCtx = document.getElementById('pickupStatusChart').getContext('2d');
            new Chart(statusCtx, {
                type: 'pie',
                data: {
                    labels: ['Completed', 'Pending', 'Cancelled'],
                    datasets: [{
                        data: [82, 16, 2],
                        backgroundColor: ['#198754', '#ffc107', '#dc3545'],
                        borderWidth: 0
                    }]
                },
                options: {
                    responsive: true,
                    plugins: {
                        legend: {
                            position: 'bottom',
                            labels: { color: 'rgba(255, 255, 255, 0.7)' }
                        }
                    }
                }
            });

            // Initialize other charts
            updateCharts();
        }

        function updateCharts() {
            // Monthly Trend Chart
            const trendCtx = document.getElementById('monthlyTrendChart').getContext('2d');
            new Chart(trendCtx, {
                type: 'line',
                data: {
                    labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'],
                    datasets: [{
                        label: 'Pickup Requests',
                        data: [120, 150, 180, 200, 240, 280, 320, 300, 280, 320, 350, 400],
                        borderColor: '#0dcaf0',
                        backgroundColor: 'rgba(13, 202, 240, 0.1)',
                        borderWidth: 2,
                        fill: true,
                        tension: 0.4
                    }]
                },
                options: {
                    responsive: true,
                    scales: {
                        y: {
                            beginAtZero: true,
                            grid: { color: 'rgba(255, 255, 255, 0.1)' },
                            ticks: { color: 'rgba(255, 255, 255, 0.7)' }
                        },
                        x: {
                            grid: { color: 'rgba(255, 255, 255, 0.1)' },
                            ticks: { color: 'rgba(255, 255, 255, 0.7)' }
                        }
                    }
                }
            });

            // User Distribution Chart
            const userCtx = document.getElementById('userDistributionChart').getContext('2d');
            new Chart(userCtx, {
                type: 'bar',
                data: {
                    labels: ['Residential', 'Commercial', 'Industrial', 'Institutional'],
                    datasets: [{
                        label: 'Users',
                        data: [450, 280, 120, 80],
                        backgroundColor: 'rgba(25, 135, 84, 0.6)',
                        borderColor: '#198754',
                        borderWidth: 1
                    }]
                },
                options: {
                    responsive: true,
                    scales: {
                        y: {
                            beginAtZero: true,
                            grid: { color: 'rgba(255, 255, 255, 0.1)' },
                            ticks: { color: 'rgba(255, 255, 255, 0.7)' }
                        },
                        x: {
                            grid: { color: 'rgba(255, 255, 255, 0.1)' },
                            ticks: { color: 'rgba(255, 255, 255, 0.7)' }
                        }
                    }
                }
            });
        }

        // Utility functions
        function formatDate(dateString) {
            return new Date(dateString).toLocaleDateString();
        }

        function capitalizeFirst(string) {
            return string.charAt(0).toUpperCase() + string.slice(1);
        }

        function showLoading() {
            // Implement loading indicator
            console.log('Loading...');
        }

        function hideLoading() {
            // Hide loading indicator
            console.log('Loading complete');
        }

        function showSuccess(message) {
            // Simple success notification
            alert(message); // Replace with toast notification
        }

        // Action functions
        function viewDetails(id) {
            alert(`View details for ${id}`);
            // Implement detail view modal
        }

        function editItem(id) {
            alert(`Edit item ${id}`);
            // Implement edit functionality
        }

        function exportToPDF() {
            alert('Exporting to PDF...');
            // Implement PDF export
        }

        function exportToExcel() {
            alert('Exporting to Excel...');
            // Implement Excel export
        }

        function exportTableToCSV() {
            alert('Exporting table to CSV...');
            // Implement CSV export
        }
