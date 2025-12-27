<%@ Page Title="Leaderboard" Language="C#" MasterPageFile="~/Pages/Collectors/Site.Master"
    AutoEventWireup="true" Inherits="SoorGreen.Collectors.Leaderboard" Codebehind="Leaderboard.aspx.cs" %>

<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
    <link href='<%= ResolveUrl("~/Content/Pages/Collectors/collectorsroute.css") %>' rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        .leaderboard-container {
            background: var(--route-glass-bg);
            backdrop-filter: blur(15px);
            border-radius: 16px;
            border: 1px solid var(--route-glass-border);
            padding: 2rem;
            margin-bottom: 2rem;
        }

        .top-three-section {
            display: flex;
            justify-content: center;
            align-items: flex-end;
            gap: 2rem;
            margin: 3rem 0;
            position: relative;
        }

        .podium-position {
            display: flex;
            flex-direction: column;
            align-items: center;
            transition: transform 0.3s ease;
        }

            .podium-position:hover {
                transform: translateY(-10px);
            }

        .podium-stand {
            width: 100%;
            border-radius: 8px 8px 0 0;
            display: flex;
            flex-direction: column;
            align-items: center;
            padding: 1.5rem 1rem;
            position: relative;
        }

        .first-place {
            height: 180px;
            background: linear-gradient(135deg, #FFD700, #FFC800);
            order: 2;
            margin-bottom: 0;
        }

        .second-place {
            height: 150px;
            background: linear-gradient(135deg, #C0C0C0, #A9A9A9);
            order: 1;
            margin-bottom: 30px;
        }

        .third-place {
            height: 120px;
            background: linear-gradient(135deg, #CD7F32, #B87333);
            order: 3;
            margin-bottom: 60px;
        }

        .podium-number {
            font-size: 3rem;
            font-weight: 900;
            color: white;
            text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.3);
            margin-bottom: 0.5rem;
        }

        .podium-avatar {
            width: 80px;
            height: 80px;
            border-radius: 50%;
            border: 4px solid white;
            margin-bottom: 1rem;
            overflow: hidden;
            background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 2rem;
            font-weight: bold;
        }

        .podium-info {
            text-align: center;
            margin-top: 1rem;
        }

        .podium-name {
            font-weight: 700;
            color: var(--text-primary);
            font-size: 1.1rem;
            margin-bottom: 0.25rem;
        }

        .podium-stats {
            color: var(--text-secondary);
            font-size: 0.9rem;
        }

        .podium-badge {
            position: absolute;
            top: -20px;
            width: 40px;
            height: 40px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.2rem;
            color: white;
            border: 3px solid white;
        }

            .podium-badge.first {
                background: #FFD700;
                box-shadow: 0 4px 12px rgba(255, 215, 0, 0.3);
            }

            .podium-badge.second {
                background: #C0C0C0;
                box-shadow: 0 4px 12px rgba(192, 192, 192, 0.3);
            }

            .podium-badge.third {
                background: #CD7F32;
                box-shadow: 0 4px 12px rgba(205, 127, 50, 0.3);
            }

        .leaderboard-table {
            width: 100%;
            border-collapse: separate;
            border-spacing: 0;
            margin-top: 2rem;
        }

            .leaderboard-table thead th {
                background: rgba(59, 130, 246, 0.1);
                color: var(--text-primary);
                font-weight: 600;
                text-transform: uppercase;
                font-size: 0.85rem;
                letter-spacing: 0.5px;
                padding: 1rem 1.5rem;
                border-bottom: 2px solid var(--primary-color);
            }

            .leaderboard-table tbody tr {
                transition: all 0.3s ease;
                border-bottom: 1px solid rgba(255, 255, 255, 0.1);
            }

                .leaderboard-table tbody tr:hover {
                    background: rgba(59, 130, 246, 0.05);
                    transform: translateX(5px);
                }

                .leaderboard-table tbody tr.current-user {
                    background: rgba(16, 185, 129, 0.1);
                    border-left: 4px solid #10b981;
                }

            .leaderboard-table tbody td {
                padding: 1.25rem 1.5rem;
                vertical-align: middle;
            }

        .rank-cell {
            width: 80px;
            text-align: center;
            font-weight: 700;
            font-size: 1.2rem;
        }

        .collector-cell {
            display: flex;
            align-items: center;
            gap: 1rem;
        }

        .collector-avatar {
            width: 50px;
            height: 50px;
            border-radius: 50%;
            background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-weight: bold;
            font-size: 1.2rem;
        }

        .collector-info {
            flex: 1;
        }

        .collector-name {
            font-weight: 600;
            color: var(--text-primary);
            margin-bottom: 0.25rem;
        }

        .collector-level {
            font-size: 0.85rem;
            color: var(--text-secondary);
        }

        .stats-cell {
            text-align: center;
            font-weight: 600;
            color: var(--text-primary);
        }

        .badge-cell {
            text-align: center;
        }

        .rank-badge {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 36px;
            height: 36px;
            border-radius: 8px;
            font-weight: 700;
            font-size: 0.9rem;
        }

        .rank-1 {
            background: linear-gradient(135deg, #FFD700, #FFC800);
            color: #855e00;
        }

        .rank-2 {
            background: linear-gradient(135deg, #C0C0C0, #A9A9A9);
            color: #4a4a4a;
        }

        .rank-3 {
            background: linear-gradient(135deg, #CD7F32, #B87333);
            color: white;
        }

        .rank-4-10 {
            background: linear-gradient(135deg, #3b82f6, #1d4ed8);
            color: white;
        }

        .rank-other {
            background: rgba(255, 255, 255, 0.1);
            color: var(--text-secondary);
        }

        .time-period-selector {
            display: flex;
            gap: 0.5rem;
            margin-bottom: 2rem;
            flex-wrap: wrap;
        }

        .period-tab {
            padding: 0.75rem 1.5rem;
            border-radius: 50px;
            background: var(--route-glass-bg);
            border: 1px solid var(--route-glass-border);
            color: var(--text-secondary);
            cursor: pointer;
            transition: all 0.3s ease;
            font-weight: 600;
            font-size: 0.9rem;
        }

            .period-tab:hover {
                background: rgba(59, 130, 246, 0.1);
                color: var(--primary-color);
            }

            .period-tab.active {
                background: var(--primary-color);
                color: white;
                border-color: var(--primary-color);
            }

        .leaderboard-stats {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 1.5rem;
            margin-bottom: 2rem;
        }

        .stat-card-leaderboard {
            background: var(--route-glass-bg);
            border-radius: 12px;
            padding: 1.5rem;
            text-align: center;
            border: 1px solid var(--route-glass-border);
            transition: all 0.3s ease;
        }

            .stat-card-leaderboard:hover {
                transform: translateY(-5px);
                box-shadow: 0 8px 24px rgba(0, 0, 0, 0.15);
            }

            .stat-card-leaderboard .stat-icon {
                font-size: 2.5rem;
                margin-bottom: 1rem;
                opacity: 0.9;
            }

            .stat-card-leaderboard .stat-value {
                font-size: 2rem;
                font-weight: 700;
                color: var(--text-primary);
                margin-bottom: 0.5rem;
            }

            .stat-card-leaderboard .stat-label {
                font-size: 0.9rem;
                color: var(--text-secondary);
            }

        .current-user-highlight {
            background: rgba(16, 185, 129, 0.1);
            border-radius: 12px;
            padding: 1.5rem;
            margin-bottom: 2rem;
            border: 1px solid rgba(16, 185, 129, 0.3);
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

            .current-user-highlight .user-rank {
                display: flex;
                align-items: center;
                gap: 1rem;
            }

            .current-user-highlight .rank-number {
                font-size: 2.5rem;
                font-weight: 900;
                color: #10b981;
            }

            .current-user-highlight .rank-info h4 {
                margin: 0;
                color: var(--text-primary);
                font-size: 1.25rem;
            }

            .current-user-highlight .rank-info p {
                margin: 0.25rem 0 0 0;
                color: var(--text-secondary);
            }

            .current-user-highlight .rank-stats {
                display: flex;
                gap: 2rem;
            }

                .current-user-highlight .rank-stats .stat {
                    text-align: center;
                }

                    .current-user-highlight .rank-stats .stat .value {
                        font-size: 1.5rem;
                        font-weight: 700;
                        color: var(--text-primary);
                    }

                    .current-user-highlight .rank-stats .stat .label {
                        font-size: 0.85rem;
                        color: var(--text-secondary);
                    }

        .progress-to-next {
            margin-top: 1rem;
        }

            .progress-to-next .progress-label {
                display: flex;
                justify-content: space-between;
                margin-bottom: 0.5rem;
                font-size: 0.85rem;
                color: var(--text-secondary);
            }

            .progress-to-next .progress-bar {
                height: 6px;
                background: rgba(255, 255, 255, 0.1);
                border-radius: 3px;
                overflow: hidden;
            }

            .progress-to-next .progress-fill {
                height: 100%;
                background: linear-gradient(90deg, #10b981, #3b82f6);
                border-radius: 3px;
                transition: width 1s ease;
            }

        @media (max-width: 992px) {
            .top-three-section {
                flex-direction: column;
                align-items: center;
                gap: 1rem;
            }

            .podium-position {
                width: 100%;
                max-width: 300px;
            }

            .podium-stand {
                height: 120px !important;
                margin-bottom: 0 !important;
            }

            .leaderboard-table {
                display: block;
                overflow-x: auto;
            }

            .current-user-highlight {
                flex-direction: column;
                gap: 1.5rem;
                text-align: center;
            }

                .current-user-highlight .rank-stats {
                    justify-content: center;
                }
        }

        @media (max-width: 768px) {
            .leaderboard-stats {
                grid-template-columns: repeat(2, 1fr);
            }

            .collector-cell {
                flex-direction: column;
                text-align: center;
                gap: 0.5rem;
            }

            .collector-info {
                text-align: center;
            }
        }

        @media (max-width: 576px) {
            .leaderboard-stats {
                grid-template-columns: 1fr;
            }

            .time-period-selector {
                justify-content: center;
            }

            .period-tab {
                padding: 0.5rem 1rem;
                font-size: 0.8rem;
            }
        }

        @keyframes fadeInUp {
            from {
                opacity: 0;
                transform: translateY(20px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .leaderboard-table tbody tr {
            animation: fadeInUp 0.5s ease forwards;
            opacity: 0;
        }

            .leaderboard-table tbody tr:nth-child(1) { animation-delay: 0.1s; }
            .leaderboard-table tbody tr:nth-child(2) { animation-delay: 0.2s; }
            .leaderboard-table tbody tr:nth-child(3) { animation-delay: 0.3s; }
            .leaderboard-table tbody tr:nth-child(4) { animation-delay: 0.4s; }
            .leaderboard-table tbody tr:nth-child(5) { animation-delay: 0.5s; }
            .leaderboard-table tbody tr:nth-child(6) { animation-delay: 0.6s; }
            .leaderboard-table tbody tr:nth-child(7) { animation-delay: 0.7s; }
            .leaderboard-table tbody tr:nth-child(8) { animation-delay: 0.8s; }
            .leaderboard-table tbody tr:nth-child(9) { animation-delay: 0.9s; }
            .leaderboard-table tbody tr:nth-child(10) { animation-delay: 1.0s; }
    </style>
</asp:Content>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Leaderboard - Collectors Portal
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <div class="route-container" id="pageContainer">
        <div class="page-header-glass mb-4">
            <div class="d-flex justify-content-between align-items-center">
                <div>
                    <h1 class="page-title-glass mb-2">
                        <i class="fas fa-trophy me-3 text-warning"></i>Collector Leaderboard
                    </h1>
                    <p class="page-subtitle-glass mb-0">Compete with fellow collectors and climb the ranks</p>
                </div>
                <div class="d-flex gap-2">
                    <asp:LinkButton ID="btnRefresh" runat="server" CssClass="action-btn primary"
                        OnClick="btnRefresh_Click">
                        <i class="fas fa-sync-alt me-2"></i>Refresh
                    </asp:LinkButton>
                    <asp:LinkButton ID="btnViewAchievements" runat="server" CssClass="action-btn secondary"
                        OnClick="btnViewAchievements_Click">
                        <i class="fas fa-award me-2"></i>My Achievements
                    </asp:LinkButton>
                </div>
            </div>
        </div>

        <div class="time-period-selector">
            <asp:LinkButton ID="btnPeriodDaily" runat="server" CssClass="period-tab active"
                CommandName="Period" CommandArgument="daily" OnCommand="PeriodTab_Command">
                <i class="fas fa-calendar-day me-1"></i>Today
            </asp:LinkButton>
            <asp:LinkButton ID="btnPeriodWeekly" runat="server" CssClass="period-tab"
                CommandName="Period" CommandArgument="weekly" OnCommand="PeriodTab_Command">
                <i class="fas fa-calendar-week me-1"></i>This Week
            </asp:LinkButton>
            <asp:LinkButton ID="btnPeriodMonthly" runat="server" CssClass="period-tab"
                CommandName="Period" CommandArgument="monthly" OnCommand="PeriodTab_Command">
                <i class="fas fa-calendar-alt me-1"></i>This Month
            </asp:LinkButton>
            <asp:LinkButton ID="btnPeriodAllTime" runat="server" CssClass="period-tab"
                CommandName="Period" CommandArgument="alltime" OnCommand="PeriodTab_Command">
                <i class="fas fa-infinity me-1"></i>All Time
            </asp:LinkButton>
        </div>

        <div class="current-user-highlight">
            <div class="user-rank">
                <div class="rank-number">
                    <asp:Label ID="lblUserRank" runat="server" Text="#1"></asp:Label>
                </div>
                <div class="rank-info">
                    <h4>
                        <asp:Label ID="lblUserName" runat="server" Text="Your Position"></asp:Label>
                    </h4>
                    <p>Level <asp:Label ID="lblUserLevel" runat="server" Text="1"></asp:Label> Collector</p>
                </div>
            </div>
            <div class="rank-stats">
                <div class="stat">
                    <div class="value">
                        <asp:Label ID="lblUserPickups" runat="server" Text="0"></asp:Label>
                    </div>
                    <div class="label">Pickups</div>
                </div>
                <div class="stat">
                    <div class="value">
                        <asp:Label ID="lblUserWeight" runat="server" Text="0"></asp:Label>
                    </div>
                    <div class="label">Kg</div>
                </div>
                <div class="stat">
                    <div class="value">
                        <asp:Label ID="lblUserXP" runat="server" Text="0"></asp:Label>
                    </div>
                    <div class="label">XP</div>
                </div>
            </div>
        </div>

        <div class="leaderboard-stats">
            <div class="stat-card-leaderboard">
                <div class="stat-icon text-primary">
                    <i class="fas fa-users"></i>
                </div>
                <div class="stat-value">
                    <asp:Label ID="lblTotalCollectors" runat="server" Text="0"></asp:Label>
                </div>
                <div class="stat-label">Active Collectors</div>
            </div>
            <div class="stat-card-leaderboard">
                <div class="stat-icon text-success">
                    <i class="fas fa-trash-restore"></i>
                </div>
                <div class="stat-value">
                    <asp:Label ID="lblTotalPickups" runat="server" Text="0"></asp:Label>
                </div>
                <div class="stat-label">Total Pickups</div>
            </div>
            <div class="stat-card-leaderboard">
                <div class="stat-icon text-warning">
                    <i class="fas fa-weight-hanging"></i>
                </div>
                <div class="stat-value">
                    <asp:Label ID="lblTotalWeight" runat="server" Text="0"></asp:Label>
                </div>
                <div class="stat-label">Kg Collected</div>
            </div>
            <div class="stat-card-leaderboard">
                <div class="stat-icon text-info">
                    <i class="fas fa-leaf"></i>
                </div>
                <div class="stat-value">
                    <asp:Label ID="lblCO2Saved" runat="server" Text="0"></asp:Label>
                </div>
                <div class="stat-label">CO₂ Saved (kg)</div>
            </div>
        </div>

        <div class="leaderboard-container">
            <h3 class="text-center mb-4"><i class="fas fa-crown me-2 text-warning"></i>Top Collectors</h3>
            
            <div class="top-three-section">
                <div class="podium-position">
                    <div class="podium-badge second">
                        <i class="fas fa-medal"></i>
                    </div>
                    <div class="podium-stand second-place">
                        <div class="podium-number">2</div>
                        <div class="podium-avatar" id="avatarSecond" runat="server">
                            <asp:Label ID="lblSecondInitials" runat="server" Text="JS"></asp:Label>
                        </div>
                    </div>
                    <div class="podium-info">
                        <div class="podium-name">
                            <asp:Label ID="lblSecondName" runat="server" Text="John Smith"></asp:Label>
                        </div>
                        <div class="podium-stats">
                            <asp:Label ID="lblSecondStats" runat="server" Text="45 pickups • 850kg"></asp:Label>
                        </div>
                    </div>
                </div>

                <div class="podium-position">
                    <div class="podium-badge first">
                        <i class="fas fa-crown"></i>
                    </div>
                    <div class="podium-stand first-place">
                        <div class="podium-number">1</div>
                        <div class="podium-avatar" id="avatarFirst" runat="server">
                            <asp:Label ID="lblFirstInitials" runat="server" Text="SJ"></asp:Label>
                        </div>
                    </div>
                    <div class="podium-info">
                        <div class="podium-name">
                            <asp:Label ID="lblFirstName" runat="server" Text="Sarah Johnson"></asp:Label>
                        </div>
                        <div class="podium-stats">
                            <asp:Label ID="lblFirstStats" runat="server" Text="62 pickups • 1,200kg"></asp:Label>
                        </div>
                    </div>
                </div>

                <div class="podium-position">
                    <div class="podium-badge third">
                        <i class="fas fa-medal"></i>
                    </div>
                    <div class="podium-stand third-place">
                        <div class="podium-number">3</div>
                        <div class="podium-avatar" id="avatarThird" runat="server">
                            <asp:Label ID="lblThirdInitials" runat="server" Text="MW"></asp:Label>
                        </div>
                    </div>
                    <div class="podium-info">
                        <div class="podium-name">
                            <asp:Label ID="lblThirdName" runat="server" Text="Mike Wilson"></asp:Label>
                        </div>
                        <div class="podium-stats">
                            <asp:Label ID="lblThirdStats" runat="server" Text="38 pickups • 720kg"></asp:Label>
                        </div>
                    </div>
                </div>
            </div>

            <table class="leaderboard-table">
                <thead>
                    <tr>
                        <th class="rank-cell">Rank</th>
                        <th>Collector</th>
                        <th class="text-center">Pickups</th>
                        <th class="text-center">Weight (kg)</th>
                        <th class="text-center">XP</th>
                        <th class="text-center">Level</th>
                    </tr>
                </thead>
                <tbody>
                    <asp:Repeater ID="rptLeaderboard" runat="server" OnItemDataBound="rptLeaderboard_ItemDataBound">
                        <ItemTemplate>
                            <tr id="leaderboardRow" runat="server">
                                <td class="rank-cell">
                                    <div class='<%# GetRankBadgeClass(Container.ItemIndex + 1) %>'>
                                        <%# Container.ItemIndex + 1 %>
                                    </div>
                                </td>
                                <td>
                                    <div class="collector-cell">
                                        <div class="collector-avatar" style='<%# GetAvatarStyle(Eval("UserId").ToString()) %>'>
                                            <%# GetInitials(Eval("FullName").ToString()) %>
                                        </div>
                                        <div class="collector-info">
                                            <div class="collector-name">
                                                <%# Eval("FullName") %>
                                                <asp:Label ID="lblYouBadge" runat="server" CssClass="badge bg-success ms-2" Text="YOU" Visible="false"></asp:Label>
                                            </div>
                                            <div class="collector-level">
                                                Member since <%# GetJoinDate(Eval("CreatedAt")) %>
                                            </div>
                                        </div>
                                    </div>
                                </td>
                                <td class="stats-cell">
                                    <%# Eval("TotalPickups") %>
                                </td>
                                <td class="stats-cell">
                                    <%# Eval("TotalWeight", "{0:F0}") %>
                                </td>
                                <td class="stats-cell">
                                    <%# Eval("XP_Credits", "{0:F0}") %>
                                </td>
                                <td class="stats-cell">
                                    <span class="badge bg-primary">Lvl <%# CalculateLevel(Convert.ToDecimal(Eval("XP_Credits"))) %></span>
                                </td>
                            </tr>
                        </ItemTemplate>
                    </asp:Repeater>
                </tbody>
            </table>
        </div>

        <div class="leaderboard-container">
            <h4 class="mb-3"><i class="fas fa-chart-line me-2 text-success"></i>Your Progress to Next Rank</h4>
            <div class="progress-to-next">
                <div class="progress-label">
                    <span>Current Rank: <strong><asp:Label ID="lblCurrentRank" runat="server" Text="#1"></asp:Label></strong></span>
                    <span>Next Rank (<asp:Label ID="lblNextRankPosition" runat="server" Text="#1"></asp:Label>): <strong><asp:Label ID="lblNextRankXP" runat="server" Text="100"></asp:Label> XP needed</strong></span>
                </div>
                <div class="progress-bar">
                    <div class="progress-fill" id="rankProgressFill" runat="server" style="width: 0%"></div>
                </div>
            </div>
        </div>

        <div class="route-summary-section">
            <div class="summary-card-glass">
                <h4 class="mb-4"><i class="fas fa-bolt me-2"></i>Quick Actions</h4>
                <div class="row g-3">
                    <div class="col-md-3">
                        <asp:LinkButton ID="btnCompare" runat="server" CssClass="action-btn primary w-100 py-3"
                            OnClick="btnCompare_Click">
                            <i class="fas fa-balance-scale me-2 fa-lg"></i>
                            <div class="d-block">Compare</div>
                            <small class="opacity-75">Compare with others</small>
                        </asp:LinkButton>
                    </div>
                    <div class="col-md-3">
                        <asp:LinkButton ID="btnDownloadReport" runat="server" CssClass="action-btn success w-100 py-3"
                            OnClick="btnDownloadReport_Click">
                            <i class="fas fa-download me-2 fa-lg"></i>
                            <div class="d-block">Download Report</div>
                            <small class="opacity-75">Export leaderboard data</small>
                        </asp:LinkButton>
                    </div>
                    <div class="col-md-3">
                        <asp:LinkButton ID="btnViewRewards" runat="server" CssClass="action-btn warning w-100 py-3"
                            OnClick="btnViewRewards_Click">
                            <i class="fas fa-gift me-2 fa-lg"></i>
                            <div class="d-block">View Rewards</div>
                            <small class="opacity-75">Rank-based rewards</small>
                        </asp:LinkButton>
                    </div>
                    <div class="col-md-3">
                        <asp:LinkButton ID="btnShareRank" runat="server" CssClass="action-btn info w-100 py-3"
                            OnClick="btnShareRank_Click">
                            <i class="fas fa-share-alt me-2 fa-lg"></i>
                            <div class="d-block">Share Rank</div>
                            <small class="opacity-75">Share your progress</small>
                        </asp:LinkButton>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

    <script>
        document.addEventListener('DOMContentLoaded', function () {
            const periodTabs = document.querySelectorAll('.period-tab');
            periodTabs.forEach(tab => {
                tab.addEventListener('click', function () {
                    periodTabs.forEach(t => t.classList.remove('active'));
                    this.classList.add('active');
                });
            });

            const progressFill = document.getElementById('<%= rankProgressFill.ClientID %>');
            if (progressFill) {
                const width = progressFill.style.width;
                progressFill.style.width = '0%';
                setTimeout(() => {
                    progressFill.style.width = width;
                }, 100);
            }

            const podiumPositions = document.querySelectorAll('.podium-position');
            podiumPositions.forEach(position => {
                position.addEventListener('mouseenter', function () {
                    this.style.transform = 'translateY(-10px)';
                });
                position.addEventListener('mouseleave', function () {
                    this.style.transform = 'translateY(0)';
                });
            });

            window.showToast = function (message, type) {
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
            };
        });
    </script>
</asp:Content>