<%@ Page Title="Collector Community" Language="C#" MasterPageFile="~/Pages/Collectors/Site.Master"
    AutoEventWireup="True" Inherits="SoorGreen.Collectors.Community" Codebehind="Community.aspx.cs" %>

<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
    Collector Community
    <link href='<%= ResolveUrl("~/Content/Pages/Collectors/collectorsroute.css") %>' rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        /* Community Styles */
        .community-container {
            background: rgba(255, 255, 255, 0.05);
            backdrop-filter: blur(10px);
            border-radius: 12px;
            border: 1px solid rgba(255, 255, 255, 0.1);
            padding: 20px;
            margin-bottom: 20px;
        }

        .community-stats {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
            gap: 15px;
            margin-bottom: 20px;
        }

        .stat-card {
            background: rgba(255, 255, 255, 0.05);
            border-radius: 10px;
            padding: 15px;
            text-align: center;
        }

            .stat-card .stat-value {
                font-size: 24px;
                font-weight: bold;
                color: #3b82f6;
            }

            .stat-card .stat-label {
                font-size: 12px;
                color: #94a3b8;
                margin-top: 5px;
            }

        .post-card {
            background: rgba(255, 255, 255, 0.05);
            border-radius: 10px;
            padding: 15px;
            margin-bottom: 15px;
            border: 1px solid rgba(255, 255, 255, 0.1);
        }

        .user-avatar {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-weight: bold;
            margin-right: 10px;
        }

        .post-actions {
            display: flex;
            gap: 20px;
            margin-top: 15px;
            padding-top: 15px;
            border-top: 1px solid rgba(255, 255, 255, 0.1);
        }

        .online-user {
            display: flex;
            align-items: center;
            padding: 10px;
            border-radius: 8px;
            margin-bottom: 10px;
            background: rgba(255, 255, 255, 0.03);
        }

        .event-card {
            background: rgba(255, 255, 255, 0.03);
            border-radius: 10px;
            padding: 15px;
            margin-bottom: 15px;
            border-left: 4px solid #10b981;
        }
        
        .create-post-container {
            background: rgba(255, 255, 255, 0.05);
            border-radius: 10px;
            padding: 20px;
            margin-bottom: 20px;
        }
        
        /* Tab styles */
        .community-tab {
            padding: 10px 20px;
            border: none;
            background: none;
            color: #94a3b8;
            cursor: pointer;
            font-weight: 500;
            border-bottom: 2px solid transparent;
        }
        
        .community-tab.active {
            color: #3b82f6;
            border-bottom: 2px solid #3b82f6;
        }
    </style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <div class="container-fluid py-4">
        <!-- Hidden fields for JavaScript data -->
        <asp:HiddenField ID="hfPostsData" runat="server" />
        <asp:HiddenField ID="hfStatsData" runat="server" />
        <asp:HiddenField ID="hfOnlineUsers" runat="server" />
        <asp:HiddenField ID="hfEvents" runat="server" />

        <!-- Page Header -->
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h2 class="mb-1">Collector Community</h2>
                <p class="text-muted mb-0">Connect with fellow collectors and share experiences</p>
            </div>
            <div>
                <asp:Button ID="btnRefresh" runat="server" Text="Refresh" 
                    CssClass="btn btn-primary" OnClick="btnRefresh_Click" />
            </div>
        </div>

        <!-- Stats Row - SERVER CONTROLS ADDED -->
        <div class="row mb-4">
            <div class="col-12">
                <div class="community-stats">
                    <div class="stat-card">
                        <asp:Label ID="lblTotalMembers" runat="server" Text="0" CssClass="stat-value"></asp:Label>
                        <div class="stat-label">Total Members</div>
                    </div>
                    <div class="stat-card">
                        <asp:Label ID="lblTotalPosts" runat="server" Text="0" CssClass="stat-value"></asp:Label>
                        <div class="stat-label">Total Reports</div>
                    </div>
                    <div class="stat-card">
                        <asp:Label ID="lblTotalComments" runat="server" Text="0 kg" CssClass="stat-value"></asp:Label>
                        <div class="stat-label">Total Recycled</div>
                    </div>
                    <div class="stat-card">
                        <asp:Label ID="lblTotalLikes" runat="server" Text="0 XP" CssClass="stat-value"></asp:Label>
                        <div class="stat-label">Total Credits</div>
                    </div>
                </div>
            </div>
        </div>

        <div class="row">
            <!-- Left Column - Posts Feed -->
            <div class="col-lg-8">
                <!-- Tabs - SERVER CONTROLS ADDED -->
                <div class="d-flex mb-3 border-bottom">
                    <asp:LinkButton ID="btnTabAll" runat="server" CommandArgument="all" 
                        OnCommand="CommunityTab_Command" CssClass="community-tab active">
                        All Posts
                    </asp:LinkButton>
                    <asp:LinkButton ID="btnTabPopular" runat="server" CommandArgument="popular" 
                        OnCommand="CommunityTab_Command" CssClass="community-tab">
                        Popular
                    </asp:LinkButton>
                    <asp:LinkButton ID="btnTabTips" runat="server" CommandArgument="tips" 
                        OnCommand="CommunityTab_Command" CssClass="community-tab">
                        Tips
                    </asp:LinkButton>
                    <asp:LinkButton ID="btnTabQuestions" runat="server" CommandArgument="questions" 
                        OnCommand="CommunityTab_Command" CssClass="community-tab">
                        Questions
                    </asp:LinkButton>
                    <asp:LinkButton ID="btnTabUpdates" runat="server" CommandArgument="updates" 
                        OnCommand="CommunityTab_Command" CssClass="community-tab">
                        Updates
                    </asp:LinkButton>
                </div>

                <!-- Create Post -->
                <div class="create-post-container">
                    <div class="d-flex align-items-start mb-3">
                        <div class="user-avatar" style="background: linear-gradient(135deg, #3b82f6, #8b5cf6)">
                            <!-- Current user initials will be set by server -->
                        </div>
                        <div class="flex-grow-1">
                            <asp:TextBox ID="txtPostContent" runat="server" TextMode="MultiLine" 
                                CssClass="form-control" placeholder="Share a tip, experience, or question..."
                                Rows="3"></asp:TextBox>
                        </div>
                    </div>
                    <div class="d-flex justify-content-end">
                        <asp:Button ID="btnSubmitPost" runat="server" Text="Post to Community" 
                            CssClass="btn btn-primary" OnClick="btnSubmitPost_Click" />
                    </div>
                </div>

                <!-- Posts Feed - SERVER CONTROLS ADDED -->
                <asp:Repeater ID="rptCommunityPosts" runat="server" OnItemDataBound="rptCommunityPosts_ItemDataBound">
                    <ItemTemplate>
                        <div class="post-card">
                            <div class="d-flex align-items-start mb-3">
                                <div class="user-avatar" style='<%# GetAvatarStyle(Eval("UserId").ToString()) %>'>
                                    <asp:Label ID="lblAuthorInitials" runat="server"></asp:Label>
                                </div>
                                <div class="flex-grow-1">
                                    <div class="d-flex justify-content-between align-items-start">
                                        <div>
                                            <h6 class="mb-0"><%# Eval("AuthorName") %></h6>
                                            <small class="text-muted">
                                                <i class="far fa-clock me-1"></i>
                                                <%# GetRelativeTime(Convert.ToDateTime(Eval("CreatedAt"))) %>
                                            </small>
                                        </div>
                                        <span class="badge bg-info"><%# Eval("PostType") %></span>
                                    </div>
                                    <p class="mt-3 mb-0"><%# Eval("Content") %></p>
                                </div>
                            </div>
                            
                            <div class="post-actions">
                                <asp:LinkButton ID="btnLike" runat="server" CommandName="Like" CommandArgument='<%# Eval("PostId") %>'
                                    CssClass="text-decoration-none text-muted">
                                    <i class="far fa-heart me-1"></i> Like (<%# Eval("LikeCount") %>)
                                </asp:LinkButton>
                                <asp:LinkButton ID="btnComment" runat="server" CommandName="Comment" CommandArgument='<%# Eval("PostId") %>'
                                    CssClass="text-decoration-none text-muted">
                                    <i class="far fa-comment me-1"></i> Comments (<%# Eval("CommentCount") %>)
                                </asp:LinkButton>
                                <asp:LinkButton ID="btnDelete" runat="server" CommandName="Delete" CommandArgument='<%# Eval("PostId") %>'
                                    CssClass="text-decoration-none text-danger" OnClientClick="return confirm('Delete this post?');">
                                    <i class="fas fa-trash-alt me-1"></i> Delete
                                </asp:LinkButton>
                            </div>
                        </div>
                    </ItemTemplate>
                    <FooterTemplate>
                        <asp:Label ID="lblNoPosts" runat="server" Visible="false" 
                            CssClass="text-center d-block text-muted p-4">
                            <i class="fas fa-comments fa-2x mb-3"></i><br>
                            No posts yet. Be the first to share!
                        </asp:Label>
                    </FooterTemplate>
                </asp:Repeater>

                <!-- Load More -->
                <div class="text-center mt-4">
                    <asp:Button ID="btnLoadMore" runat="server" Text="Load More Posts" 
                        CssClass="btn btn-outline-primary" OnClick="btnLoadMore_Click" />
                </div>
            </div>

            <!-- Right Column - Sidebar -->
            <div class="col-lg-4">
                <!-- Top Contributors - SERVER CONTROLS ADDED -->
                <div class="community-container mb-4">
                    <h6 class="mb-3"><i class="fas fa-trophy me-2 text-warning"></i>Top Contributors</h6>
                    <asp:Repeater ID="rptTopContributors" runat="server">
                        <ItemTemplate>
                            <div class="online-user">
                                <div class="user-avatar" style='<%# GetAvatarStyle(Eval("UserId").ToString()) %>'>
                                    <%# GetInitials(Eval("FullName").ToString()) %>
                                </div>
                                <div class="flex-grow-1">
                                    <div class="d-flex justify-content-between align-items-center">
                                        <strong><%# Eval("FullName") %></strong>
                                        <span class="badge bg-primary"><%# Eval("ReportCount") %> reports</span>
                                    </div>
                                    <small class="text-muted"><%# Eval("TotalCredits", "{0:N2}") %> XP</small>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>

                <!-- Quick Actions -->
                <div class="community-container">
                    <h6 class="mb-3"><i class="fas fa-bolt me-2 text-danger"></i>Quick Actions</h6>
                    <div class="d-grid gap-2">
                        <asp:Button ID="btnReportIssue" runat="server" 
                            CssClass="btn btn-outline-warning" Text="Report Issue" OnClick="btnReportIssue_Click" />
                        <button class="btn btn-outline-info" onclick="showHelp()">
                            <i class="fas fa-question-circle me-2"></i>Community Guidelines
                        </button>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Minimal JavaScript for guidelines -->
    <script>
        function showHelp() {
            alert('Community Guidelines:\n\n1. Be respectful to all collectors\n2. Share helpful tips and experiences\n3. No spam or self-promotion\n4. Keep discussions relevant to waste collection\n5. Help maintain a positive community environment');
        }
    </script>
</asp:Content>