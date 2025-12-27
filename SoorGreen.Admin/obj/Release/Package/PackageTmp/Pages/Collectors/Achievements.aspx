<%@ Page Title="Achievements" Language="C#" MasterPageFile="~/Pages/Collectors/Site.Master"
    AutoEventWireup="true" Inherits="SoorGreen.Collectors.Achievements" Codebehind="Achievements.aspx.cs" %>

<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
    <link href='<%= ResolveUrl("~/Content/Pages/Collectors/collectorsroute.css") %>' rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        /* Achievements Specific Styles - 4 COLUMNS ON DESKTOP */
        .achievement-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 1.5rem;
            margin-top: 1.5rem;
        }

        /* REMOVE THE #rptAchievements FIX - IT'S NOT WORKING */
        /* #rptAchievements {
            display: grid !important;
            grid-template-columns: repeat(4, 1fr) !important;
            gap: 1.5rem !important;
            margin-top: 1.5rem !important;
        } */

        .achievement-card {
            background: var(--route-glass-bg);
            backdrop-filter: blur(15px);
            border-radius: 16px;
            padding: 1.25rem;
            border: 1px solid var(--route-glass-border);
            transition: all 0.3s ease;
            position: relative;
            overflow: hidden;
            height: 100%;
            display: flex;
            flex-direction: column;
        }

            .achievement-card:hover {
                transform: translateY(-5px);
                box-shadow: 0 12px 24px rgba(0, 0, 0, 0.15);
                border-color: var(--primary-color);
            }

            .achievement-card.locked {
                opacity: 0.7;
                filter: grayscale(50%);
            }

            .achievement-card.completed {
                border-color: #10b981;
                background: linear-gradient(135deg, rgba(16, 185, 129, 0.1), rgba(59, 130, 246, 0.1));
            }

            .achievement-card.in-progress {
                border-color: #3b82f6;
                background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(168, 85, 247, 0.1));
            }

        .achievement-icon {
            width: 50px;
            height: 50px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.25rem;
            margin-bottom: 0.75rem;
            background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
            color: white;
            flex-shrink: 0;
        }

            .achievement-icon.bronze {
                background: linear-gradient(135deg, #cd7f32, #b87333);
            }

            .achievement-icon.silver {
                background: linear-gradient(135deg, #c0c0c0, #a9a9a9);
            }

            .achievement-icon.gold {
                background: linear-gradient(135deg, #ffd700, #daa520);
            }

            .achievement-icon.platinum {
                background: linear-gradient(135deg, #e5e4e2, #bdc3c7);
            }

        .achievement-badge {
            position: absolute;
            top: 0.75rem;
            right: 0.75rem;
            width: 32px;
            height: 32px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 0.9rem;
            color: white;
            z-index: 2;
        }

            .achievement-badge.completed {
                background: #10b981;
            }

            .achievement-badge.in-progress {
                background: #3b82f6;
            }

            .achievement-badge.locked {
                background: #6b7280;
            }

        .achievement-title {
            font-size: 1rem;
            font-weight: 700;
            color: var(--text-primary);
            margin-bottom: 0.5rem;
            line-height: 1.3;
            flex-grow: 0;
        }

        .achievement-description {
            color: var(--text-secondary);
            font-size: 0.8rem;
            margin-bottom: 0.75rem;
            line-height: 1.4;
            flex-grow: 1;
        }

        .achievement-progress {
            margin-top: auto;
            padding-top: 0.75rem;
        }

        .progress-label {
            display: flex;
            justify-content: space-between;
            margin-bottom: 0.5rem;
            font-size: 0.75rem;
            color: var(--text-secondary);
        }

        .progress-bar {
            height: 5px;
            background: rgba(255, 255, 255, 0.1);
            border-radius: 3px;
            overflow: hidden;
        }

        .progress-fill {
            height: 100%;
            background: linear-gradient(90deg, var(--primary-color), var(--secondary-color));
            border-radius: 3px;
            transition: width 0.5s ease;
        }

        .achievement-reward {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            margin-top: 0.75rem;
            padding-top: 0.75rem;
            border-top: 1px solid rgba(255, 255, 255, 0.1);
            color: #fbbf24;
            font-weight: 600;
            font-size: 0.8rem;
            flex-shrink: 0;
        }

        /* Stats Overview */
        .stats-overview {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 1rem;
            margin-bottom: 2rem;
        }

        .stat-item {
            background: var(--route-glass-bg);
            border-radius: 12px;
            padding: 1rem;
            text-align: center;
        }

            .stat-item .stat-value {
                font-size: 2rem;
                font-weight: 700;
                color: var(--text-primary);
                line-height: 1;
            }

            .stat-item .stat-label {
                font-size: 0.85rem;
                color: var(--text-secondary);
                margin-top: 0.5rem;
            }

        /* Level System */
        .level-container {
            background: var(--route-glass-bg);
            border-radius: 16px;
            padding: 2rem;
            margin-bottom: 2rem;
            border: 1px solid var(--route-glass-border);
        }

        .level-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 1.5rem;
        }

        .level-info {
            display: flex;
            align-items: center;
            gap: 1rem;
        }

        .level-icon {
            width: 80px;
            height: 80px;
            border-radius: 50%;
            background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 2.5rem;
            color: white;
            font-weight: 700;
        }

        .level-details h3 {
            margin: 0;
            font-size: 1.5rem;
            color: var(--text-primary);
        }

        .level-details p {
            margin: 0.25rem 0 0 0;
            color: var(--text-secondary);
        }

        .xp-progress {
            margin-top: 1.5rem;
        }

        .xp-stats {
            display: flex;
            justify-content: space-between;
            margin-bottom: 0.5rem;
            font-size: 0.9rem;
            color: var(--text-secondary);
        }

        .xp-bar {
            height: 12px;
            background: rgba(255, 255, 255, 0.1);
            border-radius: 6px;
            overflow: hidden;
        }

        .xp-fill {
            height: 100%;
            background: linear-gradient(90deg, #10b981, #3b82f6);
            border-radius: 6px;
            transition: width 1s ease;
        }

        /* Milestones */
        .milestones-container {
            background: var(--route-glass-bg);
            border-radius: 16px;
            padding: 2rem;
            margin-bottom: 2rem;
            border: 1px solid var(--route-glass-border);
        }

        .milestone-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
            gap: 1rem;
            margin-top: 1rem;
        }

        .milestone-item {
            padding: 1rem;
            border-radius: 12px;
            background: rgba(255, 255, 255, 0.05);
            border-left: 4px solid var(--primary-color);
        }

            .milestone-item.completed {
                border-left-color: #10b981;
                background: rgba(16, 185, 129, 0.1);
            }

        /* Category Tabs */
        .category-tabs {
            display: flex;
            gap: 0.5rem;
            margin-bottom: 2rem;
            flex-wrap: wrap;
            justify-content: center;
        }

        .category-tab {
            padding: 0.75rem 1.5rem;
            border-radius: 50px;
            background: var(--route-glass-bg);
            border: 1px solid var(--route-glass-border);
            color: var(--text-secondary);
            cursor: pointer;
            transition: all 0.3s ease;
            font-weight: 600;
            font-size: 0.9rem;
            white-space: nowrap;
        }

            .category-tab:hover {
                background: rgba(59, 130, 246, 0.1);
                color: var(--primary-color);
            }

            .category-tab.active {
                background: var(--primary-color);
                color: white;
                border-color: var(--primary-color);
            }

        /* RESPONSIVE BREAKPOINTS - EXACTLY AS YOU WANTED */
        /* Desktop (≥1200px) - 4 columns */
        @media (min-width: 1200px) {
            .achievement-grid {
                grid-template-columns: repeat(4, 1fr);
                gap: 1.5rem;
            }
        }

        /* Large Tablet (992px-1199px) - 4 columns but smaller gap */
        @media (min-width: 992px) and (max-width: 1199px) {
            .achievement-grid {
                grid-template-columns: repeat(4, 1fr);
                gap: 1.25rem;
            }

            .achievement-card {
                padding: 1rem;
            }

            .achievement-icon {
                width: 48px;
                height: 48px;
                font-size: 1.1rem;
            }

            .achievement-title {
                font-size: 0.95rem;
            }

            .achievement-description {
                font-size: 0.78rem;
            }
        }

        /* Tablet (768px-991px) - 3 columns */
        @media (min-width: 768px) and (max-width: 991px) {
            .achievement-grid {
                grid-template-columns: repeat(3, 1fr);
                gap: 1.25rem;
            }

            .achievement-card {
                padding: 1rem;
            }

            .achievement-icon {
                width: 48px;
                height: 48px;
                font-size: 1.1rem;
            }

            .achievement-title {
                font-size: 0.95rem;
            }

            .achievement-description {
                font-size: 0.78rem;
            }
        }

        /* Small Tablet (576px-767px) - 2 columns */
        @media (min-width: 576px) and (max-width: 767px) {
            .achievement-grid {
                grid-template-columns: repeat(2, 1fr);
                gap: 1rem;
            }

            .achievement-card {
                padding: 1rem;
            }

            .achievement-icon {
                width: 44px;
                height: 44px;
                font-size: 1rem;
            }

            .achievement-title {
                font-size: 0.9rem;
            }

            .achievement-description {
                font-size: 0.75rem;
            }

            .stats-overview {
                grid-template-columns: repeat(2, 1fr);
            }
        }

        /* Mobile (<576px) - 1 column */
        @media (max-width: 575px) {
            .achievement-grid {
                grid-template-columns: 1fr;
                gap: 1rem;
                max-width: 350px;
                margin-left: auto;
                margin-right: auto;
            }

            .achievement-card {
                padding: 1rem;
            }

            .level-header {
                flex-direction: column;
                align-items: flex-start;
                gap: 1rem;
            }

            .milestone-grid {
                grid-template-columns: 1fr;
            }

            .stats-overview {
                grid-template-columns: repeat(2, 1fr);
            }
        }

        /* For very small screens */
        @media (max-width: 380px) {
            .achievement-grid {
                max-width: 100%;
            }

            .stats-overview {
                grid-template-columns: 1fr;
            }

            .category-tabs {
                gap: 0.25rem;
            }

            .category-tab {
                padding: 0.5rem 0.75rem;
                font-size: 0.75rem;
                flex: 1;
                min-width: 0;
                text-align: center;
            }
        }
    </style>
</asp:Content>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Achievements - Collectors Portal
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <div class="route-container" id="pageContainer">
        <!-- Page Header -->
        <div class="page-header-glass mb-4">
            <div class="d-flex justify-content-between align-items-center">
                <div>
                    <h1 class="page-title-glass mb-2">
                        <i class="fas fa-trophy me-3 text-warning"></i>Collector Achievements
                    </h1>
                    <p class="page-subtitle-glass mb-0">Track your progress, earn rewards, and level up</p>
                </div>
                <div class="d-flex gap-2">
                    <asp:LinkButton ID="btnRefresh" runat="server" CssClass="action-btn primary"
                        OnClick="btnRefresh_Click">
                        <i class="fas fa-sync-alt me-2"></i>Refresh
                    </asp:LinkButton>
                    <asp:LinkButton ID="btnViewLeaderboard" runat="server" CssClass="action-btn secondary"
                        OnClick="btnViewLeaderboard_Click">
                        <i class="fas fa-chart-line me-2"></i>Leaderboard
                    </asp:LinkButton>
                </div>
            </div>
        </div>

        <!-- Level Progress -->
        <div class="level-container">
            <div class="level-header">
                <div class="level-info">
                    <div class="level-icon">
                        <asp:Label ID="lblCurrentLevel" runat="server" Text="1"></asp:Label>
                    </div>
                    <div class="level-details">
                        <h3>
                            <asp:Label ID="lblCollectorName" runat="server" Text="Collector"></asp:Label>
                        </h3>
                        <p>
                            Level
                            <asp:Label ID="lblLevelNumber" runat="server" Text="1"></asp:Label>
                            Collector
                        </p>
                    </div>
                </div>
                <div class="text-end">
                    <div class="stat-value">
                        <asp:Label ID="lblTotalXP" runat="server" Text="0"></asp:Label>
                    </div>
                    <div class="stat-label">Total XP</div>
                </div>
            </div>
            <div class="xp-progress">
                <div class="xp-stats">
                    <span>XP:
                        <asp:Label ID="lblCurrentXP" runat="server" Text="0"></asp:Label>/<asp:Label ID="lblNextLevelXP" runat="server" Text="100"></asp:Label></span>
                    <span>
                        <asp:Label ID="lblXPToNext" runat="server" Text="100"></asp:Label>
                        XP to next level</span>
                </div>
                <div class="xp-bar">
                    <div class="xp-fill" id="xpFill" runat="server" style="width: 0%"></div>
                </div>
            </div>
        </div>

        <!-- Quick Stats Overview -->
        <div class="stats-overview mb-4">
            <div class="stat-item">
                <div class="stat-value">
                    <asp:Label ID="lblTotalPickups" runat="server" Text="0"></asp:Label>
                </div>
                <div class="stat-label">Total Pickups</div>
            </div>
            <div class="stat-item">
                <div class="stat-value">
                    <asp:Label ID="lblTotalWeight" runat="server" Text="0"></asp:Label>
                </div>
                <div class="stat-label">Kg Collected</div>
            </div>
            <div class="stat-item">
                <div class="stat-value">
                    <asp:Label ID="lblCompletionRate" runat="server" Text="0%"></asp:Label>
                </div>
                <div class="stat-label">Completion Rate</div>
            </div>
            <div class="stat-item">
                <div class="stat-value">
                    <asp:Label ID="lblStreakDays" runat="server" Text="0"></asp:Label>
                </div>
                <div class="stat-label">Day Streak</div>
            </div>
        </div>

        <!-- Category Tabs -->
        <div class="category-tabs">
            <asp:LinkButton ID="btnTabAll" runat="server" CssClass="category-tab active"
                CommandName="Filter" CommandArgument="all" OnCommand="CategoryTab_Command">
                <i class="fas fa-star me-1"></i>All Achievements
            </asp:LinkButton>
            <asp:LinkButton ID="btnTabCollection" runat="server" CssClass="category-tab"
                CommandName="Filter" CommandArgument="collection" OnCommand="CategoryTab_Command">
                <i class="fas fa-trash-restore me-1"></i>Collection
            </asp:LinkButton>
            <asp:LinkButton ID="btnTabEfficiency" runat="server" CssClass="category-tab"
                CommandName="Filter" CommandArgument="efficiency" OnCommand="CategoryTab_Command">
                <i class="fas fa-bolt me-1"></i>Efficiency
            </asp:LinkButton>
            <asp:LinkButton ID="btnTabConsistency" runat="server" CssClass="category-tab"
                CommandName="Filter" CommandArgument="consistency" OnCommand="CategoryTab_Command">
                <i class="fas fa-calendar-check me-1"></i>Consistency
            </asp:LinkButton>
            <asp:LinkButton ID="btnTabSpecial" runat="server" CssClass="category-tab"
                CommandName="Filter" CommandArgument="special" OnCommand="CategoryTab_Command">
                <i class="fas fa-crown me-1"></i>Special
            </asp:LinkButton>
        </div>
        
        <!-- THE FIX: WRAP THE REPEATER IN THE GRID CONTAINER -->
        <div class="achievement-grid">
            <asp:Repeater ID="rptAchievements" runat="server">
                <ItemTemplate>
                    <div class='achievement-card <%# Eval("Status") %>'>
                        <div class='achievement-badge <%# Eval("Status") %>'>
                            <i class='<%# GetAchievementBadgeIcon(Eval("Status").ToString()) %>'></i>
                        </div>
                        <div class="achievement-icon">
                            <i class='<%# GetAchievementIcon(Eval("Title").ToString()) %>'></i>
                        </div>
                        <h4 class="achievement-title"><%# Eval("Title") %></h4>
                        <p class="achievement-description"><%# Eval("Description") %></p>

                        <div class="achievement-progress">
                            <div class="progress-label">
                                <span>Progress</span>
                                <span><%# Eval("CurrentProgress") %>/<%# Eval("Target") %></span>
                            </div>
                            <div class="progress-bar">
                                <div class="progress-fill" style='width: <%# GetProgressPercentage(Eval("CurrentProgress"), Eval("Target")) %>%'></div>
                            </div>
                        </div>

                        <div class="achievement-reward">
                            <i class="fas fa-gem"></i>
                            <span>+<%# Eval("RewardXP") %> XP</span>
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>
        <br />
        <!-- Recent Milestones -->
        <div class="milestones-container">
            <h3 class="mb-3"><i class="fas fa-flag-checkered me-2"></i>Recent Milestones</h3>
            <div class="milestone-grid">
                <asp:Repeater ID="rptMilestones" runat="server">
                    <ItemTemplate>
                        <div class='milestone-item <%# (bool)Eval("IsCompleted") ? "completed" : "" %>'>
                            <div class="d-flex align-items-center gap-2 mb-1">
                                <i class='<%# GetMilestoneIcon(Eval("Title").ToString()) %>'></i>
                                <strong><%# Eval("Title") %></strong>
                            </div>
                            <div class="text-muted small"><%# Eval("Description") %></div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </div>

        <!-- Quick Actions -->
        <div class="route-summary-section">
            <div class="summary-card-glass">
                <h4 class="mb-4"><i class="fas fa-bolt me-2"></i>Quick Actions</h4>
                <div class="row g-3">
                    <div class="col-md-3">
                        <asp:LinkButton ID="btnViewCertificates" runat="server" CssClass="action-btn primary w-100 py-3"
                            OnClick="btnViewCertificates_Click">
                            <i class="fas fa-award me-2 fa-lg"></i>
                            <div class="d-block">View Certificates</div>
                            <small class="opacity-75">Your collection badges</small>
                        </asp:LinkButton>
                    </div>
                    <div class="col-md-3">
                        <asp:LinkButton ID="btnShareAchievements" runat="server" CssClass="action-btn success w-100 py-3"
                            OnClick="btnShareAchievements_Click">
                            <i class="fas fa-share-alt me-2 fa-lg"></i>
                            <div class="d-block">Share Progress</div>
                            <small class="opacity-75">Share on social media</small>
                        </asp:LinkButton>
                    </div>
                    <div class="col-md-3">
                        <asp:LinkButton ID="btnSetGoals" runat="server" CssClass="action-btn info w-100 py-3"
                            OnClick="btnSetGoals_Click">
                            <i class="fas fa-bullseye me-2 fa-lg"></i>
                            <div class="d-block">Set Goals</div>
                            <small class="opacity-75">Set new targets</small>
                        </asp:LinkButton>
                    </div>
                    <div class="col-md-3">
                        <asp:LinkButton ID="btnViewHistory" runat="server" CssClass="action-btn secondary w-100 py-3"
                            OnClick="btnViewHistory_Click">
                            <i class="fas fa-history me-2 fa-lg"></i>
                            <div class="d-block">Progress History</div>
                            <small class="opacity-75">View your journey</small>
                        </asp:LinkButton>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

    <script>
        document.addEventListener('DOMContentLoaded', function () {
            const tabs = document.querySelectorAll('.category-tab');
            tabs.forEach(tab => {
                tab.addEventListener('click', function () {
                    tabs.forEach(t => t.classList.remove('active'));
                    this.classList.add('active');
                });
            });

            const xpFill = document.getElementById('<%= xpFill.ClientID %>');
            if (xpFill) {
                const width = xpFill.style.width;
                xpFill.style.width = '0%';
                setTimeout(() => {
                    xpFill.style.width = width;
                }, 100);
            }
        });

        function showToast(message, type) {
            const toast = document.createElement('div');
            toast.className = `toast-notification toast-${type}`;
            toast.innerHTML = `
                <div class="toast-icon">
                    <i class="${type === 'success' ? 'fas fa-check-circle' : 'fas fa-info-circle'}"></i>
                </div>
                <div class="toast-message">${message}</div>
                <button class="toast-close" onclick="this.parentElement.remove()">
                    <i class="fas fa-times"></i>
                </button>
            `;

            document.body.appendChild(toast);
            setTimeout(() => toast.remove(), 5000);
        }
    </script>
</asp:Content>