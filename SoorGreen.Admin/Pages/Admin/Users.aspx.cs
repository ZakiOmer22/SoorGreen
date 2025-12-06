using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Security.Cryptography;
using System.Text;
using System.Web.Configuration;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace SoorGreen.Admin.Admin
{
    public partial class Users : System.Web.UI.Page
    {
        private string connectionString = WebConfigurationManager.ConnectionStrings["SoorGreenDBConnectionString"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindUsers();
                SetViewMode();
            }
        }

        private void BindUsers()
        {
            try
            {
                string query = @"SELECT u.UserId, u.FullName, u.Email, u.Phone, 
                                u.XP_Credits, u.IsVerified, u.RoleId, u.CreatedAt
                                FROM Users u WHERE 1=1";

                List<SqlParameter> parameters = new List<SqlParameter>();

                // Apply search filter
                if (!string.IsNullOrEmpty(txtSearch.Text))
                {
                    query += " AND (u.FullName LIKE @search OR u.Email LIKE @search OR u.Phone LIKE @search OR u.UserId LIKE @search)";
                    parameters.Add(new SqlParameter("@search", "%" + txtSearch.Text + "%"));
                }

                // Apply status filter
                if (ddlStatus.SelectedValue != "all")
                {
                    string status = ddlStatus.SelectedValue;
                    query += " AND u.IsVerified = @status";
                    parameters.Add(new SqlParameter("@status", status == "active"));
                }

                // Apply type filter
                if (ddlType.SelectedValue != "all")
                {
                    query += " AND u.RoleId = @role";
                    parameters.Add(new SqlParameter("@role", ddlType.SelectedValue));
                }

                query += " ORDER BY u.CreatedAt DESC";

                // Get data from database
                DataTable dt = GetDataTable(query, parameters.ToArray());

                // Bind to repeater for grid view
                rptUsersGrid.DataSource = dt;
                rptUsersGrid.DataBind();

                // Bind to gridview for table view
                gvUsers.DataSource = dt;
                gvUsers.DataBind();

                // Update stats
                UpdateStats(dt);

                // Update user count
                lblUserCount.Text = dt.Rows.Count.ToString();

                // Set active view
                string view = Request.QueryString["view"];
                if (!string.IsNullOrEmpty(view))
                {
                    if (view == "grid")
                    {
                        btnGridView.CssClass = "view-btn active";
                        btnTableView.CssClass = "view-btn";
                        pnlGridView.Visible = true;
                        pnlTableView.Visible = false;
                    }
                    else if (view == "table")
                    {
                        btnGridView.CssClass = "view-btn";
                        btnTableView.CssClass = "view-btn active";
                        pnlGridView.Visible = false;
                        pnlTableView.Visible = true;
                    }
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Error", "Failed to load users: " + ex.Message, "error");
            }
        }

        private DataTable GetDataTable(string query, SqlParameter[] parameters = null)
        {
            DataTable dt = new DataTable();

            using (SqlConnection conn = new SqlConnection(connectionString))
            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                if (parameters != null)
                {
                    cmd.Parameters.AddRange(parameters);
                }

                conn.Open();
                using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                {
                    da.Fill(dt);
                }
            }

            return dt;
        }

        private int ExecuteNonQuery(string query, SqlParameter[] parameters = null)
        {
            using (SqlConnection conn = new SqlConnection(connectionString))
            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                if (parameters != null)
                {
                    cmd.Parameters.AddRange(parameters);
                }

                conn.Open();
                return cmd.ExecuteNonQuery();
            }
        }

        private void UpdateStats(DataTable dt)
        {
            int totalUsers = dt.Rows.Count;
            int activeUsers = 0;
            decimal totalCredits = 0;

            foreach (DataRow row in dt.Rows)
            {
                if (row["IsVerified"] != DBNull.Value && Convert.ToBoolean(row["IsVerified"]))
                    activeUsers++;

                if (row["XP_Credits"] != DBNull.Value)
                    totalCredits += Convert.ToDecimal(row["XP_Credits"]);
            }

            statTotal.InnerText = totalUsers.ToString();
            statActive.InnerText = activeUsers.ToString();
            statCredits.InnerText = totalCredits.ToString("N2");
        }

        protected void btnApplyFilters_Click(object sender, EventArgs e)
        {
            BindUsers();
        }

        protected void btnClearFilters_Click(object sender, EventArgs e)
        {
            txtSearch.Text = "";
            ddlStatus.SelectedValue = "all";
            ddlType.SelectedValue = "all";
            BindUsers();
        }

        protected void btnRefresh_Click(object sender, EventArgs e)
        {
            BindUsers();
        }

        protected void btnGridView_Click(object sender, EventArgs e)
        {
            Response.Redirect("Users.aspx?view=grid");
        }

        protected void btnTableView_Click(object sender, EventArgs e)
        {
            Response.Redirect("Users.aspx?view=table");
        }

        protected void btnExportCSV_Click(object sender, EventArgs e)
        {
            // Export to CSV logic here
            ShowMessage("Info", "Export feature coming soon!", "info");
        }

        // Helper methods for role display
        public string GetRoleClass(string roleId)
        {
            switch (roleId)
            {
                case "CITZ": return "citizen";
                case "R001": return "collector";
                case "ADMIN": return "admin";
                default: return "";
            }
        }

        public string GetRoleIcon(string roleId)
        {
            switch (roleId)
            {
                case "CITZ": return "fas fa-user";
                case "R001": return "fas fa-truck";
                case "ADMIN": return "fas fa-shield-alt";
                default: return "fas fa-user";
            }
        }

        public string GetRoleDisplayName(string roleId)
        {
            switch (roleId)
            {
                case "CITZ": return "Citizen";
                case "R001": return "Collector";
                case "ADMIN": return "Admin";
                default: return roleId;
            }
        }

        protected void rptUsersGrid_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
            {
                // Get user stats
                DataRowView row = (DataRowView)e.Item.DataItem;
                string userId = row["UserId"].ToString();

                // You can add logic here to get report, pickup, and kg counts
                // For now, setting placeholder values
                Label lblReports = (Label)e.Item.FindControl("lblReports");
                Label lblPickups = (Label)e.Item.FindControl("lblPickups");
                Label lblKg = (Label)e.Item.FindControl("lblKg");

                if (lblReports != null) lblReports.Text = "0";
                if (lblPickups != null) lblPickups.Text = "0";
                if (lblKg != null) lblKg.Text = "0.0";
            }
        }

        protected void rptUsersGrid_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "Edit")
            {
                string userId = e.CommandArgument.ToString();
                LoadUserForEdit(userId);
            }
            else if (e.CommandName == "ResetPassword")
            {
                string[] args = e.CommandArgument.ToString().Split('|');
                string userId = args[0];
                string userName = args[1];

                // Reset password logic here
                ResetUserPassword(userId, userName);
            }
            else if (e.CommandName == "Delete")
            {
                string[] args = e.CommandArgument.ToString().Split('|');
                string userId = args[0];
                string userName = args[1];

                // Delete user logic here
                DeleteUser(userId, userName);
            }
        }

        protected void gvUsers_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "Edit")
            {
                string userId = e.CommandArgument.ToString();
                LoadUserForEdit(userId);
            }
            else if (e.CommandName == "ResetPassword")
            {
                string[] args = e.CommandArgument.ToString().Split('|');
                string userId = args[0];
                string userName = args[1];

                // Reset password logic here
                ResetUserPassword(userId, userName);
            }
            else if (e.CommandName == "Delete")
            {
                string[] args = e.CommandArgument.ToString().Split('|');
                string userId = args[0];
                string userName = args[1];

                // Delete user logic here
                DeleteUser(userId, userName);
            }
        }

        private void LoadUserForEdit(string userId)
        {
            // Load user data for editing
            string query = "SELECT * FROM Users WHERE UserId = @userId";
            SqlParameter[] parameters = { new SqlParameter("@userId", userId) };

            DataTable dt = GetDataTable(query, parameters);

            if (dt.Rows.Count > 0)
            {
                DataRow row = dt.Rows[0];

                hfEditUserId.Value = userId;
                txtEditFullName.Text = row["FullName"].ToString();
                txtEditEmail.Text = row["Email"] != DBNull.Value ? row["Email"].ToString() : "";
                txtEditPhone.Text = row["Phone"].ToString();
                txtEditCredits.Text = Convert.ToDecimal(row["XP_Credits"]).ToString("N2");
                ddlEditStatus.SelectedValue = Convert.ToBoolean(row["IsVerified"]).ToString();
                ddlEditRole.SelectedValue = row["RoleId"].ToString();

                // Show modal - FIXED: Set the attributes properly
                divModalBackdrop.Style["display"] = "block";
                divModalBackdrop.Attributes["class"] = "modal-backdrop active";

                divEditModal.Style["display"] = "block";
                divEditModal.Attributes["class"] = "modal-dialog active";

                // Register startup script to show modal
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ShowModal", "showModal();", true);
            }
        }

        protected void btnSaveEdit_Click(object sender, EventArgs e)
        {
            if (Page.IsValid)
            {
                try
                {
                    string userId = hfEditUserId.Value;

                    string query = @"UPDATE Users SET 
                                    FullName = @fullName,
                                    Email = @email,
                                    Phone = @phone,
                                    XP_Credits = @credits,
                                    IsVerified = @status,
                                    RoleId = @role
                                    WHERE UserId = @userId";

                    SqlParameter[] parameters = {
                        new SqlParameter("@fullName", txtEditFullName.Text),
                        new SqlParameter("@email", string.IsNullOrEmpty(txtEditEmail.Text) ? (object)DBNull.Value : txtEditEmail.Text),
                        new SqlParameter("@phone", txtEditPhone.Text),
                        new SqlParameter("@credits", decimal.Parse(txtEditCredits.Text)),
                        new SqlParameter("@status", bool.Parse(ddlEditStatus.SelectedValue)),
                        new SqlParameter("@role", ddlEditRole.SelectedValue),
                        new SqlParameter("@userId", userId)
                    };

                    ExecuteNonQuery(query, parameters);

                    ShowMessage("Success", "User updated successfully!", "success");
                    CloseModal();
                    BindUsers();
                }
                catch (Exception ex)
                {
                    ShowMessage("Error", "Failed to update user: " + ex.Message, "error");
                }
            }
        }

        protected void btnResetPassword_Click(object sender, EventArgs e)
        {
            string userId = hfEditUserId.Value;

            if (!string.IsNullOrEmpty(userId))
            {
                // Get user name for confirmation
                string query = "SELECT FullName FROM Users WHERE UserId = @userId";
                SqlParameter[] parameters = { new SqlParameter("@userId", userId) };
                DataTable dt = GetDataTable(query, parameters);

                if (dt.Rows.Count > 0)
                {
                    string userName = dt.Rows[0]["FullName"].ToString();
                    ResetUserPassword(userId, userName);
                    CloseModal();
                }
            }
        }

        private void ResetUserPassword(string userId, string userName)
        {
            try
            {
                // Simple SHA256 hashing for password reset
                string defaultPassword = "password123";
                string hashedPassword = ComputeSHA256Hash(defaultPassword);

                string query = "UPDATE Users SET PasswordHash = @hash WHERE UserId = @userId";
                SqlParameter[] parameters = {
                    new SqlParameter("@hash", hashedPassword),
                    new SqlParameter("@userId", userId)
                };

                ExecuteNonQuery(query, parameters);

                ShowMessage("Success", "Password reset for " + userName + " to default (password123)", "success");

                // Refresh the page
                BindUsers();
            }
            catch (Exception ex)
            {
                ShowMessage("Error", "Failed to reset password: " + ex.Message, "error");
            }
        }

        private void DeleteUser(string userId, string userName)
        {
            try
            {
                string query = "DELETE FROM Users WHERE UserId = @userId";
                SqlParameter[] parameters = { new SqlParameter("@userId", userId) };

                int rowsAffected = ExecuteNonQuery(query, parameters);

                if (rowsAffected > 0)
                {
                    ShowMessage("Success", "User " + userName + " deleted successfully", "success");
                    BindUsers();
                }
                else
                {
                    ShowMessage("Error", "User not found or could not be deleted", "error");
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Error", "Failed to delete user: " + ex.Message, "error");
            }
        }

        // Simple SHA256 hash function
        private string ComputeSHA256Hash(string input)
        {
            using (SHA256 sha256 = SHA256.Create())
            {
                byte[] bytes = sha256.ComputeHash(Encoding.UTF8.GetBytes(input));
                StringBuilder builder = new StringBuilder();

                for (int i = 0; i < bytes.Length; i++)
                {
                    builder.Append(bytes[i].ToString("x2"));
                }

                return builder.ToString();
            }
        }

        protected void btnCloseModal_Click(object sender, EventArgs e)
        {
            CloseModal();
        }

        protected void btnCancelEdit_Click(object sender, EventArgs e)
        {
            CloseModal();
        }

        private void CloseModal()
        {
            // Hide modal elements
            divModalBackdrop.Style["display"] = "none";
            divModalBackdrop.Attributes["class"] = "modal-backdrop";

            divEditModal.Style["display"] = "none";
            divEditModal.Attributes["class"] = "modal-dialog";

            // Clear edit fields
            hfEditUserId.Value = "";
            txtEditFullName.Text = "";
            txtEditEmail.Text = "";
            txtEditPhone.Text = "";
            txtEditCredits.Text = "";

            // Clear validation errors
            rfvFullName.Enabled = false;
            rfvPhone.Enabled = false;
            revEmail.Enabled = false;
            rvCredits.Enabled = false;
        }

        protected void btnShowModal_Click(object sender, EventArgs e)
        {
            // This is used to trigger modal via server-side
        }

        protected void btnThemeToggle_Click(object sender, EventArgs e)
        {
            // Theme toggle logic here
            string currentTheme = "light";
            if (Request.Cookies["theme"] != null && Request.Cookies["theme"].Value != null)
            {
                currentTheme = Request.Cookies["theme"].Value;
            }

            string newTheme = currentTheme == "light" ? "dark" : "light";

            Response.Cookies["theme"].Value = newTheme;
            Response.Cookies["theme"].Expires = DateTime.Now.AddDays(30);

            Response.Redirect(Request.Url.AbsoluteUri);
        }

        private void SetViewMode()
        {
            string view = Request.QueryString["view"];
            if (!string.IsNullOrEmpty(view))
            {
                if (view == "grid")
                {
                    btnGridView.CssClass = "view-btn active";
                    btnTableView.CssClass = "view-btn";
                    pnlGridView.Visible = true;
                    pnlTableView.Visible = false;
                }
                else if (view == "table")
                {
                    btnGridView.CssClass = "view-btn";
                    btnTableView.CssClass = "view-btn active";
                    pnlGridView.Visible = false;
                    pnlTableView.Visible = true;
                }
            }
        }

        private void ShowMessage(string title, string message, string type)
        {
            pnlMessage.Visible = true;
            litMessageTitle.Text = title;
            litMessageText.Text = message;

            divMessage.Attributes["class"] = "message-alert " + type + " show";
            iconMessage.Attributes["class"] = GetMessageIcon(type);
        }

        private string GetMessageIcon(string type)
        {
            switch (type)
            {
                case "success": return "fas fa-check-circle";
                case "error": return "fas fa-exclamation-circle";
                case "info": return "fas fa-info-circle";
                default: return "fas fa-info-circle";
            }
        }
    }
}