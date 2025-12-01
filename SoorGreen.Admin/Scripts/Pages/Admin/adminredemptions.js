
       let currentTab = 'redemptions';
       let allRedemptions = [];
       let allTransactions = [];
       let allUsers = [];
       let currentAction = null;
       let currentRedemptionId = null;

       document.addEventListener('DOMContentLoaded', function () {
           loadRewardsFromServer();
           setupEventListeners();
       });

       function setupEventListeners() {
           // Tab switching
           document.querySelectorAll('.tab').forEach(tab => {
               tab.addEventListener('click', function (e) {
                   e.preventDefault();
                   const tabName = this.getAttribute('data-tab');
                   switchTab(tabName);
               });
           });

           // Add credits button
           document.getElementById('addCreditsBtn').addEventListener('click', function (e) {
               e.preventDefault();
               showAddCreditsModal();
           });

           // Close modals
           document.querySelectorAll('.close-modal').forEach(btn => {
               btn.addEventListener('click', function (e) {
                   e.preventDefault();
                   this.closest('.modal-overlay').style.display = 'none';
               });
           });

           // Modal close buttons
           document.getElementById('closeRedemptionModalBtn').addEventListener('click', function (e) {
               e.preventDefault();
               document.getElementById('viewRedemptionModal').style.display = 'none';
           });

           document.getElementById('cancelAddCreditsBtn').addEventListener('click', function (e) {
               e.preventDefault();
               document.getElementById('addCreditsModal').style.display = 'none';
           });

           document.getElementById('cancelActionBtn').addEventListener('click', function (e) {
               e.preventDefault();
               document.getElementById('actionConfirmationModal').style.display = 'none';
           });

           // Action buttons
           document.getElementById('approveRedemptionBtn').addEventListener('click', function (e) {
               e.preventDefault();
               showActionConfirmation('approve');
           });

           document.getElementById('rejectRedemptionBtn').addEventListener('click', function (e) {
               e.preventDefault();
               showActionConfirmation('reject');
           });

           // Confirm actions
           document.getElementById('confirmAddCreditsBtn').addEventListener('click', function (e) {
               e.preventDefault();
               addCreditsToUser();
           });

           document.getElementById('confirmActionBtn').addEventListener('click', function (e) {
               e.preventDefault();
               processRedemptionAction();
           });
       }

       function switchTab(tabName) {
           currentTab = tabName;

           // Update active tab
           document.querySelectorAll('.tab').forEach(tab => {
               tab.classList.remove('active');
               if (tab.getAttribute('data-tab') === tabName) {
                   tab.classList.add('active');
               }
           });

           // Show active tab content
           document.querySelectorAll('.tab-content').forEach(content => {
               content.classList.remove('active');
               if (content.id === tabName + 'Tab') {
                   content.classList.add('active');
               }
           });

           // Render appropriate content
           switch (tabName) {
               case 'redemptions':
                   renderRedemptions();
                   break;
               case 'transactions':
                   renderTransactions();
                   break;
               case 'users':
                   renderUsers();
                   break;
           }
       }

       function loadRewardsFromServer() {
           const redemptionsData = document.getElementById('<%= hfRedemptionsData.ClientID %>').value;
           const transactionsData = document.getElementById('<%= hfTransactionsData.ClientID %>').value;
           const usersData = document.getElementById('<%= hfUsersData.ClientID %>').value;
           const statsData = document.getElementById('<%= hfStatsData.ClientID %>').value;

           if (redemptionsData) {
               allRedemptions = JSON.parse(redemptionsData);
           }
           if (transactionsData) {
               allTransactions = JSON.parse(transactionsData);
           }
           if (usersData) {
               allUsers = JSON.parse(usersData);
           }
           if (statsData) updateStatistics(JSON.parse(statsData));

           renderRedemptions();
       }

       function updateStatistics(stats) {
           document.getElementById('totalCredits').textContent = stats.TotalCredits || 0;
           document.getElementById('pendingRedemptions').textContent = stats.PendingRedemptions || 0;
           document.getElementById('totalUsers').textContent = stats.TotalUsers || 0;
           document.getElementById('avgCredits').textContent = stats.AvgCredits || 0;
       }

       function renderRedemptions() {
           const tbody = document.getElementById('redemptionsTableBody');
           const emptyState = document.getElementById('redemptionsEmptyState');
           
           tbody.innerHTML = '';

           if (allRedemptions.length === 0) {
               tbody.style.display = 'none';
               emptyState.style.display = 'block';
               return;
           }

           tbody.style.display = '';
           emptyState.style.display = 'none';

           allRedemptions.forEach(redemption => {
               tbody.appendChild(createRedemptionRow(redemption));
           });
       }

       function renderTransactions() {
           const tbody = document.getElementById('transactionsTableBody');
           const emptyState = document.getElementById('transactionsEmptyState');
           
           tbody.innerHTML = '';

           if (allTransactions.length === 0) {
               tbody.style.display = 'none';
               emptyState.style.display = 'block';
               return;
           }

           tbody.style.display = '';
           emptyState.style.display = 'none';

           allTransactions.forEach(transaction => {
               tbody.appendChild(createTransactionRow(transaction));
           });
       }

       function renderUsers() {
           const tbody = document.getElementById('usersTableBody');
           const emptyState = document.getElementById('usersEmptyState');
           
           tbody.innerHTML = '';

           if (allUsers.length === 0) {
               tbody.style.display = 'none';
               emptyState.style.display = 'block';
               return;
           }

           tbody.style.display = '';
           emptyState.style.display = 'none';

           allUsers.forEach(user => {
               tbody.appendChild(createUserRow(user));
           });
       }

       function createRedemptionRow(redemption) {
           const row = document.createElement('tr');
           const userInitial = redemption.FullName ? redemption.FullName.charAt(0).toUpperCase() : 'U';
           
           row.innerHTML = `
               <td>${redemption.RedemptionId}</td>
               <td>
                   <div class="user-info">
                       <div class="user-avatar">${userInitial}</div>
                       <span>${escapeHtml(redemption.FullName || 'Unknown')}</span>
                   </div>
               </td>
               <td class="credit-negative">-${redemption.Amount || 0} credits</td>
               <td>${escapeHtml(redemption.Method || 'Unknown')}</td>
               <td><span class="status-badge status-${(redemption.Status || 'pending').toLowerCase()}">${redemption.Status || 'Pending'}</span></td>
               <td>${redemption.RequestedAt ? new Date(redemption.RequestedAt).toLocaleDateString() : '-'}</td>
               <td>
                   <button class="btn-action btn-view" data-id="${redemption.RedemptionId}"><i class="fas fa-eye"></i></button>
                   ${redemption.Status === 'Pending' ? `
                   <button class="btn-action btn-approve" data-id="${redemption.RedemptionId}"><i class="fas fa-check"></i></button>
                   <button class="btn-action btn-reject" data-id="${redemption.RedemptionId}"><i class="fas fa-times"></i></button>
                   ` : ''}
               </td>
           `;

           // Add event listeners
           row.querySelector('.btn-view').addEventListener('click', function (e) {
               e.preventDefault();
               viewRedemption(this.getAttribute('data-id'));
           });

           if (redemption.Status === 'Pending') {
               row.querySelector('.btn-approve').addEventListener('click', function (e) {
                   e.preventDefault();
                   currentRedemptionId = this.getAttribute('data-id');
                   showActionConfirmation('approve');
               });

               row.querySelector('.btn-reject').addEventListener('click', function (e) {
                   e.preventDefault();
                   currentRedemptionId = this.getAttribute('data-id');
                   showActionConfirmation('reject');
               });
           }

           return row;
       }

       function createTransactionRow(transaction) {
           const row = document.createElement('tr');
           const userInitial = transaction.FullName ? transaction.FullName.charAt(0).toUpperCase() : 'U';
           const isPositive = transaction.Amount > 0;
           
           row.innerHTML = `
               <td>${transaction.RewardId}</td>
               <td>
                   <div class="user-info">
                       <div class="user-avatar">${userInitial}</div>
                       <span>${escapeHtml(transaction.FullName || 'Unknown')}</span>
                   </div>
               </td>
               <td class="${isPositive ? 'credit-positive' : 'credit-negative'}">
                   ${isPositive ? '+' : ''}${transaction.Amount || 0} credits
               </td>
               <td>${escapeHtml(transaction.Type || 'Unknown')}</td>
               <td>${escapeHtml(transaction.Reference || '-')}</td>
               <td>${transaction.CreatedAt ? new Date(transaction.CreatedAt).toLocaleDateString() : '-'}</td>
           `;

           return row;
       }

       function createUserRow(user) {
           const row = document.createElement('tr');
           const userInitial = user.FullName ? user.FullName.charAt(0).toUpperCase() : 'U';
           const status = user.IsVerified ? 'Verified' : 'Pending';
           
           row.innerHTML = `
               <td>
                   <div class="user-info">
                       <div class="user-avatar">${userInitial}</div>
                       <span>${escapeHtml(user.FullName || 'Unknown')}</span>
                   </div>
               </td>
               <td>${user.Phone || '-'}</td>
               <td>${user.Email || '-'}</td>
               <td class="credit-positive">${user.XP_Credits || 0} credits</td>
               <td>${user.CreatedAt ? new Date(user.CreatedAt).toLocaleDateString() : '-'}</td>
               <td><span class="status-badge status-${status.toLowerCase()}">${status}</span></td>
           `;

           return row;
       }

       function viewRedemption(id) {
           const redemption = allRedemptions.find(r => r.RedemptionId === id);
           if (redemption) {
               currentRedemptionId = id;
               const userInitial = redemption.FullName ? redemption.FullName.charAt(0).toUpperCase() : 'U';
               
               document.getElementById('viewRedemptionId').textContent = redemption.RedemptionId;
               document.getElementById('viewRedemptionStatus').textContent = redemption.Status || 'Pending';
               document.getElementById('viewUserName').textContent = redemption.FullName || 'Unknown';
               document.getElementById('viewUserAvatar').textContent = userInitial;
               document.getElementById('viewUserPhone').textContent = redemption.Phone || '-';
               document.getElementById('viewRedemptionAmount').textContent = (redemption.Amount || 0) + ' credits';
               document.getElementById('viewRedemptionMethod').textContent = redemption.Method || 'Unknown';
               document.getElementById('viewRequestedAt').textContent = redemption.RequestedAt ? new Date(redemption.RequestedAt).toLocaleString() : '-';
               
               // Show/hide action buttons based on status
               const canTakeAction = redemption.Status === 'Pending';
               document.getElementById('approveRedemptionBtn').style.display = canTakeAction ? 'block' : 'none';
               document.getElementById('rejectRedemptionBtn').style.display = canTakeAction ? 'block' : 'none';
               
               document.getElementById('viewRedemptionModal').style.display = 'block';
           }
       }

       function showAddCreditsModal() {
           const userSelect = document.getElementById('userSelect');
           userSelect.innerHTML = '<option value="">-- Select User --</option>';
           
           allUsers.forEach(user => {
               const option = document.createElement('option');
               option.value = user.UserId;
               option.textContent = `${user.FullName} (${user.Phone}) - ${user.XP_Credits || 0} credits`;
               userSelect.appendChild(option);
           });
           
           // Reset form
           document.getElementById('creditAmount').value = '';
           document.getElementById('creditNotes').value = '';
           
           document.getElementById('addCreditsModal').style.display = 'block';
       }

       function addCreditsToUser() {
           const userId = document.getElementById('userSelect').value;
           const amount = parseFloat(document.getElementById('creditAmount').value);
           const notes = document.getElementById('creditNotes').value;
           
           if (!userId || !amount || amount <= 0) {
               showNotification('Please select a user and enter a valid amount', 'error');
               return;
           }
           
           // Call server method to add credits
           PageMethods.AddCreditsToUser(userId, amount, 'bonus', notes,
               function (response) {
                   showNotification('Credits added successfully!', 'success');
                   document.getElementById('addCreditsModal').style.display = 'none';
                   // Refresh data
                   document.getElementById('<%= btnLoadRewards.ClientID %>').click();
               },
               function (error) {
                   showNotification('Error adding credits: ' + error, 'error');
               }
           );
       }

       function showActionConfirmation(action) {
           currentAction = action;
           const redemption = allRedemptions.find(r => r.RedemptionId === currentRedemptionId);
           
           if (redemption) {
               if (action === 'approve') {
                   document.getElementById('actionModalTitle').textContent = 'Approve Redemption';
                   document.getElementById('actionModalMessage').textContent = 
                       `Are you sure you want to approve ${redemption.Amount || 0} credits redemption for ${redemption.FullName || 'this user'}?`;
                   document.getElementById('rejectionReasonContainer').style.display = 'none';
               } else {
                   document.getElementById('actionModalTitle').textContent = 'Reject Redemption';
                   document.getElementById('actionModalMessage').textContent = 
                       `Are you sure you want to reject ${redemption.Amount || 0} credits redemption for ${redemption.FullName || 'this user'}?`;
                   document.getElementById('rejectionReasonContainer').style.display = 'block';
               }
               
               document.getElementById('actionConfirmationModal').style.display = 'block';
           }
       }

       function processRedemptionAction() {
           let rejectionReason = null;
           
           if (currentAction === 'reject') {
               rejectionReason = document.getElementById('rejectionReason').value;
               if (!rejectionReason) {
                   showNotification('Please provide a reason for rejection', 'error');
                   return;
               }
           }
           
           // Call server method to process redemption
           PageMethods.ProcessRedemption(currentRedemptionId, currentAction, rejectionReason,
               function (response) {
                   showNotification(`Redemption ${currentAction === 'approve' ? 'approved' : 'rejected'} successfully!`, 'success');
                   document.getElementById('actionConfirmationModal').style.display = 'none';
                   document.getElementById('viewRedemptionModal').style.display = 'none';
                   // Refresh data
                   document.getElementById('<%= btnLoadRewards.ClientID %>').click();
               },
               function (error) {
                   showNotification(`Error processing redemption: ${error}`, 'error');
               }
           );
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