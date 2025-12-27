using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Web;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;

namespace SoorGreen.Collectors
{
    public partial class PickupVerification : System.Web.UI.Page
    {
        // Use properties with ViewState persistence
        protected string CurrentUserId
        {
            get
            {
                if (ViewState["CurrentUserId"] != null)
                    return ViewState["CurrentUserId"].ToString();
                else if (Session["UserID"] != null)
                {
                    ViewState["CurrentUserId"] = Session["UserID"].ToString();
                    return Session["UserID"].ToString();
                }
                return string.Empty;
            }
            set
            {
                ViewState["CurrentUserId"] = value;
            }
        }

        protected string PickupId
        {
            get
            {
                if (ViewState["PickupId"] != null)
                    return ViewState["PickupId"].ToString();
                else if (hdnPickupId.Value != null)
                {
                    ViewState["PickupId"] = hdnPickupId.Value;
                    return hdnPickupId.Value;
                }
                return string.Empty;
            }
            set
            {
                ViewState["PickupId"] = value;
                hdnPickupId.Value = value;
            }
        }

        private string BeforePhotoUrl = "";
        private string ProcessPhotoUrl = "";
        private string AfterPhotoUrl = "";

        protected void Page_Load(object sender, EventArgs e)
        {
            // Always get user ID from session if available
            if (Session["UserID"] != null)
            {
                CurrentUserId = Session["UserID"].ToString();
            }

            if (!IsPostBack)
            {
                // Check if user is logged in
                if (Session["UserID"] == null)
                {
                    Response.Redirect("~/Login.aspx?returnUrl=" + Server.UrlEncode(Request.Url.AbsolutePath));
                    return;
                }

                string pickupIdFromQuery = Request.QueryString["pickupId"];

                if (string.IsNullOrEmpty(pickupIdFromQuery))
                {
                    ShowErrorMessage("No pickup ID provided in URL");
                    Response.Redirect("ActivePickups.aspx");
                    return;
                }

                PickupId = pickupIdFromQuery;
                hdnPickupId.Value = pickupIdFromQuery;
                LoadPickupDetails();
                LoadVerificationHistory();
                CalculateInitialCredits();
                LoadDraftData();
            }
            else
            {
                // On postback, get PickupId from hidden field
                if (!string.IsNullOrEmpty(hdnPickupId.Value))
                {
                    PickupId = hdnPickupId.Value;
                }
            }
        }

        private void LoadPickupDetails()
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(GetConnectionString()))
                {
                    string query = @"
                        SELECT 
                            p.PickupId,
                            p.ReportId,
                            p.Status,
                            p.ScheduledAt,
                            wr.EstimatedKg,
                            wr.Address,
                            wr.Landmark,
                            wr.Lat,
                            wr.Lng,
                            wr.PhotoUrl,
                            wr.CreatedAt,
                            wr.UserId,
                            wt.Name as WasteType,
                            wt.WasteTypeId,
                            wt.CreditPerKg,
                            u.FullName as CitizenName,
                            u.Phone as CitizenPhone,
                            u.Email as CitizenEmail,
                            c.FullName as CollectorName
                        FROM PickupRequests p
                        JOIN WasteReports wr ON p.ReportId = wr.ReportId
                        JOIN WasteTypes wt ON wr.WasteTypeId = wt.WasteTypeId
                        JOIN Users u ON wr.UserId = u.UserId
                        LEFT JOIN Users c ON p.CollectorId = c.UserId
                        WHERE p.PickupId = @PickupId";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@PickupId", PickupId);

                        conn.Open();
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                hdnReportId.Value = reader["ReportId"].ToString();
                                hdnWasteTypeId.Value = reader["WasteTypeId"].ToString();

                                lblPickupId.Text = "Pickup ID: " + reader["PickupId"].ToString();

                                lblCitizenName.InnerText = reader["CitizenName"].ToString();
                                lblCitizenPhone.InnerText = reader["CitizenPhone"].ToString();
                                lblCitizenEmail.InnerText = reader["CitizenEmail"] != DBNull.Value ? reader["CitizenEmail"].ToString() : "N/A";
                                lblAddress.InnerText = reader["Address"].ToString();
                                lblLandmark.InnerText = reader["Landmark"] != DBNull.Value ? reader["Landmark"].ToString() : "N/A";

                                object lat = reader["Lat"];
                                object lng = reader["Lng"];
                                if (lat != DBNull.Value && lng != DBNull.Value)
                                {
                                    lblCoordinates.InnerText = lat.ToString() + ", " + lng.ToString();
                                }
                                else
                                {
                                    lblCoordinates.InnerText = "Coordinates not available";
                                }

                                lblWasteType.InnerText = reader["WasteType"].ToString();
                                lblEstimatedWeight.InnerText = reader["EstimatedKg"].ToString();

                                wasteTypeBadge.Attributes["class"] = "waste-type-badge-large " + reader["WasteType"].ToString().ToLower();

                                txtVerifiedWeight.Text = reader["EstimatedKg"].ToString();
                                ddlMaterialType.SelectedValue = reader["WasteType"].ToString();

                                object photoUrl = reader["PhotoUrl"];
                                if (photoUrl != DBNull.Value && !string.IsNullOrEmpty(photoUrl.ToString()))
                                {
                                    imgWastePhoto.Src = photoUrl.ToString();
                                    imgWastePhoto.Visible = true;
                                    lblNoPhoto.Visible = false;
                                }
                                else
                                {
                                    imgWastePhoto.Visible = false;
                                    lblNoPhoto.Visible = true;
                                }

                                string citizenName = reader["CitizenName"].ToString();
                                string encodedName = System.Web.HttpUtility.UrlEncode(citizenName);
                                string avatarUrl = "https://ui-avatars.com/api/?name=" + encodedName + "&background=10b981&color=fff&size=100";
                                imgCitizenAvatar.Src = avatarUrl;

                                string status = reader["Status"].ToString();
                                lblVerificationStatus.Text = status;
                                lblVerificationStatus.CssClass = "status-badge " + GetStatusClass(status);

                                // Store original waste report photo for reference
                                ViewState["OriginalPhotoUrl"] = photoUrl != DBNull.Value ? photoUrl.ToString() : "";
                            }
                            else
                            {
                                ShowErrorMessage("Pickup not found with ID: " + PickupId);
                                string script = "setTimeout(function() { window.location.href = 'ActivePickups.aspx'; }, 3000);";
                                ScriptManager.RegisterStartupScript(this, GetType(), "redirect", script, true);
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ShowErrorMessage("Error loading pickup: " + ex.Message);
            }
        }

        private void LoadVerificationHistory()
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(GetConnectionString()))
                {
                    string query = @"
                        SELECT 
                            pv.VerifiedAt,
                            pv.VerifiedKg,
                            pv.MaterialType,
                            pv.VerificationMethod,
                            c.FullName as CollectorName
                        FROM PickupVerifications pv
                        JOIN PickupRequests pr ON pv.PickupId = pr.PickupId
                        LEFT JOIN Users c ON pr.CollectorId = c.UserId
                        WHERE pv.PickupId = @PickupId
                        ORDER BY pv.VerifiedAt DESC";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@PickupId", PickupId);

                        conn.Open();
                        using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                        {
                            DataTable dt = new DataTable();
                            da.Fill(dt);

                            if (dt.Rows.Count > 0)
                            {
                                rptVerificationHistory.DataSource = dt;
                                rptVerificationHistory.DataBind();
                                pnlNoHistory.Visible = false;
                            }
                            else
                            {
                                rptVerificationHistory.DataSource = null;
                                rptVerificationHistory.DataBind();
                                pnlNoHistory.Visible = true;
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                pnlNoHistory.Visible = true;
                System.Diagnostics.Debug.WriteLine("Error loading verification history: " + ex.Message);
            }
        }

        private void LoadDraftData()
        {
            try
            {
                string draftKey = "Draft_" + PickupId + "_" + CurrentUserId;
                if (Session[draftKey] != null)
                {
                    string[] draftData = Session[draftKey].ToString().Split('|');
                    if (draftData.Length >= 5)
                    {
                        txtVerifiedWeight.Text = draftData[0];
                        ddlMaterialType.SelectedValue = draftData[1];
                        ddlVerificationMethod.SelectedValue = draftData[2];
                        txtNotes.Text = draftData[3];
                        BeforePhotoUrl = draftData[4];
                        ProcessPhotoUrl = draftData.Length > 5 ? draftData[5] : "";
                        AfterPhotoUrl = draftData.Length > 6 ? draftData[6] : "";

                        // Update photo previews if URLs exist
                        UpdatePhotoPreviews();
                    }
                    CalculateCredits();
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error loading draft: " + ex.Message);
            }
        }

        private void UpdatePhotoPreviews()
        {
            if (!string.IsNullOrEmpty(BeforePhotoUrl) && File.Exists(Server.MapPath(BeforePhotoUrl)))
            {
                imgBeforePreview.Src = BeforePhotoUrl;
                imgBeforePreview.Visible = true;
                btnRemoveBefore.Visible = true;
            }

            if (!string.IsNullOrEmpty(ProcessPhotoUrl) && File.Exists(Server.MapPath(ProcessPhotoUrl)))
            {
                imgProcessPreview.Src = ProcessPhotoUrl;
                imgProcessPreview.Visible = true;
                btnRemoveProcess.Visible = true;
            }

            if (!string.IsNullOrEmpty(AfterPhotoUrl) && File.Exists(Server.MapPath(AfterPhotoUrl)))
            {
                imgAfterPreview.Src = AfterPhotoUrl;
                imgAfterPreview.Visible = true;
                btnRemoveAfter.Visible = true;
            }
        }

        protected string BindVerifiedAt(object date)
        {
            if (date == null || date == DBNull.Value)
                return "N/A";

            return Convert.ToDateTime(date).ToString("MMM dd, yyyy HH:mm");
        }

        protected void rptVerificationHistory_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
            {
                Label lblVerifiedKg = (Label)e.Item.FindControl("lblVerifiedKg");
                if (lblVerifiedKg != null)
                {
                    try
                    {
                        DataRowView rowView = (DataRowView)e.Item.DataItem;
                        decimal weight = Convert.ToDecimal(rowView["VerifiedKg"]);
                        lblVerifiedKg.Text = weight.ToString("F1") + " kg";
                    }
                    catch { }
                }

                Label lblMaterialType = (Label)e.Item.FindControl("lblMaterialType");
                if (lblMaterialType != null)
                {
                    try
                    {
                        DataRowView rowView = (DataRowView)e.Item.DataItem;
                        string materialType = rowView["MaterialType"].ToString().ToLower();

                        Control parent = lblMaterialType.Parent;
                        if (parent is HtmlGenericControl)
                        {
                            HtmlGenericControl span = (HtmlGenericControl)parent;
                            span.Attributes["class"] = "waste-type-badge " + materialType;
                        }
                    }
                    catch { }
                }
            }
        }

        private void CalculateInitialCredits()
        {
            try
            {
                decimal weight = Convert.ToDecimal(txtVerifiedWeight.Text);
                string wasteType = ddlMaterialType.SelectedValue;
                decimal creditPerKg = GetCreditPerKg(wasteType);
                decimal credits = weight * creditPerKg;

                lblCreditValue.InnerText = credits.ToString("F1");
            }
            catch
            {
                lblCreditValue.InnerText = "0.0";
            }
        }

        private decimal GetCreditPerKg(string wasteType)
        {
            using (SqlConnection conn = new SqlConnection(GetConnectionString()))
            {
                string query = "SELECT CreditPerKg FROM WasteTypes WHERE Name = @WasteType";
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@WasteType", wasteType);
                    conn.Open();
                    object result = cmd.ExecuteScalar();
                    return (result != null && result != DBNull.Value) ? Convert.ToDecimal(result) : 1.5m;
                }
            }
        }

        private string GetStatusClass(string status)
        {
            return status.ToLower().Replace(" ", "-");
        }

        protected void btnBackToPickups_Click(object sender, EventArgs e)
        {
            Response.Redirect("ActivePickups.aspx");
        }

        protected void btnSkipVerification_Click(object sender, EventArgs e)
        {
            Response.Redirect("ActivePickups.aspx");
        }

        protected void btnOpenMaps_Click(object sender, EventArgs e)
        {
            try
            {
                string address = lblAddress.InnerText;
                if (!string.IsNullOrEmpty(address))
                {
                    string encodedAddress = System.Web.HttpUtility.UrlEncode(address);
                    string mapsUrl = "https://www.google.com/maps/search/?api=1&query=" + encodedAddress;

                    string script = "window.open('" + mapsUrl + "', '_blank');";
                    ScriptManager.RegisterStartupScript(this, GetType(), "OpenMaps", script, true);
                }
            }
            catch (Exception ex)
            {
                ShowErrorMessage("Error opening maps: " + ex.Message);
            }
        }

        protected void btnGetDirections_Click(object sender, EventArgs e)
        {
            try
            {
                string address = lblAddress.InnerText;
                if (!string.IsNullOrEmpty(address))
                {
                    string encodedAddress = System.Web.HttpUtility.UrlEncode(address);
                    string directionsUrl = "https://www.google.com/maps/dir/?api=1&destination=" + encodedAddress;

                    string script = "window.open('" + directionsUrl + "', '_blank');";
                    ScriptManager.RegisterStartupScript(this, GetType(), "GetDirections", script, true);
                }
            }
            catch (Exception ex)
            {
                ShowErrorMessage("Error getting directions: " + ex.Message);
            }
        }

        protected void btnWeight5kg_Click(object sender, EventArgs e)
        {
            txtVerifiedWeight.Text = "5";
            CalculateCredits();
        }

        protected void btnWeight10kg_Click(object sender, EventArgs e)
        {
            txtVerifiedWeight.Text = "10";
            CalculateCredits();
        }

        protected void btnWeight15kg_Click(object sender, EventArgs e)
        {
            txtVerifiedWeight.Text = "15";
            CalculateCredits();
        }

        protected void btnWeight20kg_Click(object sender, EventArgs e)
        {
            txtVerifiedWeight.Text = "20";
            CalculateCredits();
        }

        private void CalculateCredits()
        {
            CalculateInitialCredits();
        }

        protected void btnCompleteVerification_Click(object sender, EventArgs e)
        {
            // Use properties instead of fields
            string pickupId = PickupId;
            string currentUserId = CurrentUserId;

            if (string.IsNullOrEmpty(pickupId) || string.IsNullOrEmpty(currentUserId))
            {
                ShowErrorMessage("Invalid pickup or user information. Please login again.");
                Session.Clear();
                Response.Redirect("~/Login.aspx");
                return;
            }

            try
            {
                decimal verifiedWeight;
                if (!decimal.TryParse(txtVerifiedWeight.Text, out verifiedWeight))
                {
                    ShowErrorMessage("Please enter a valid weight.");
                    return;
                }

                string materialType = ddlMaterialType.SelectedValue;
                string verificationMethod = ddlVerificationMethod.SelectedValue;
                string notes = txtNotes.Text;

                decimal creditPerKg = GetCreditPerKg(materialType);
                decimal totalCredits = verifiedWeight * creditPerKg;

                using (SqlConnection conn = new SqlConnection(GetConnectionString()))
                {
                    conn.Open();

                    using (SqlTransaction transaction = conn.BeginTransaction())
                    {
                        try
                        {
                            // Validate pickup exists and is assigned to current collector
                            string validateQuery = @"
                                SELECT p.PickupId, p.CollectorId, p.Status 
                                FROM PickupRequests p
                                WHERE p.PickupId = @PickupId AND p.CollectorId = @CollectorId 
                                AND p.Status IN ('Requested', 'Assigned')";

                            using (SqlCommand validateCmd = new SqlCommand(validateQuery, conn, transaction))
                            {
                                validateCmd.Parameters.AddWithValue("@PickupId", pickupId);
                                validateCmd.Parameters.AddWithValue("@CollectorId", currentUserId);

                                object result = validateCmd.ExecuteScalar();
                                if (result == null)
                                {
                                    transaction.Rollback();
                                    ShowErrorMessage("You are not assigned to this pickup or it doesn't exist.");
                                    return;
                                }
                            }

                            // Generate VerificationId
                            string verificationId = GetNextVerificationId(conn, transaction);

                            string verificationQuery = @"
                                INSERT INTO PickupVerifications (VerificationId, PickupId, VerifiedKg, MaterialType, VerificationMethod, VerifiedAt)
                                VALUES (@VerificationId, @PickupId, @VerifiedKg, @MaterialType, @VerificationMethod, GETDATE())";

                            using (SqlCommand cmd = new SqlCommand(verificationQuery, conn, transaction))
                            {
                                cmd.Parameters.AddWithValue("@VerificationId", verificationId);
                                cmd.Parameters.AddWithValue("@PickupId", pickupId);
                                cmd.Parameters.AddWithValue("@VerifiedKg", verifiedWeight);
                                cmd.Parameters.AddWithValue("@MaterialType", materialType);
                                cmd.Parameters.AddWithValue("@VerificationMethod", verificationMethod);
                                cmd.ExecuteNonQuery();
                            }

                            // Save verification photos to MediaFiles table
                            SaveVerificationPhotos(conn, transaction, verificationId);

                            string citizenQuery = @"
                                SELECT wr.UserId 
                                FROM PickupRequests p
                                JOIN WasteReports wr ON p.ReportId = wr.ReportId
                                WHERE p.PickupId = @PickupId";

                            string citizenId = "";
                            using (SqlCommand cmd = new SqlCommand(citizenQuery, conn, transaction))
                            {
                                cmd.Parameters.AddWithValue("@PickupId", pickupId);
                                object result = cmd.ExecuteScalar();
                                citizenId = (result != null) ? result.ToString() : "";
                            }

                            if (string.IsNullOrEmpty(citizenId))
                            {
                                transaction.Rollback();
                                ShowErrorMessage("Could not find citizen information.");
                                return;
                            }

                            // Generate RewardId
                            string rewardId = GetNextRewardId(conn, transaction);

                            string rewardQuery = @"
                                INSERT INTO RewardPoints (RewardId, UserId, Amount, Type, Reference, CreatedAt)
                                VALUES (@RewardId, @UserId, @Amount, 'Credit', @Reference, GETDATE())";

                            using (SqlCommand cmd = new SqlCommand(rewardQuery, conn, transaction))
                            {
                                cmd.Parameters.AddWithValue("@RewardId", rewardId);
                                cmd.Parameters.AddWithValue("@UserId", citizenId);
                                cmd.Parameters.AddWithValue("@Amount", totalCredits);
                                cmd.Parameters.AddWithValue("@Reference", "Pickup Verification: " + pickupId);
                                cmd.ExecuteNonQuery();
                            }

                            string updateCreditsQuery = @"
                                UPDATE Users 
                                SET XP_Credits = XP_Credits + @Amount 
                                WHERE UserId = @UserId";

                            using (SqlCommand cmd = new SqlCommand(updateCreditsQuery, conn, transaction))
                            {
                                cmd.Parameters.AddWithValue("@UserId", citizenId);
                                cmd.Parameters.AddWithValue("@Amount", totalCredits);
                                cmd.ExecuteNonQuery();
                            }

                            string updatePickupQuery = @"
                                UPDATE PickupRequests 
                                SET Status = 'Collected', 
                                    CompletedAt = GETDATE()
                                WHERE PickupId = @PickupId";

                            using (SqlCommand cmd = new SqlCommand(updatePickupQuery, conn, transaction))
                            {
                                cmd.Parameters.AddWithValue("@PickupId", pickupId);
                                cmd.ExecuteNonQuery();
                            }

                            // Add activity log
                            AddUserActivity(conn, transaction, citizenId, "PickupComplete",
                                "Pickup " + pickupId + " completed - " + totalCredits.ToString("F1") + " credits earned",
                                totalCredits);

                            // Add collector activity log
                            AddUserActivity(conn, transaction, currentUserId, "CollectorPickupComplete",
                                "Completed pickup " + pickupId + " - " + verifiedWeight.ToString("F1") + "kg of " + materialType,
                                10); // 10 points for collector

                            // Clear draft data after successful completion
                            ClearDraftData();

                            transaction.Commit();

                            string successMessage = "Verification completed! " + verifiedWeight.ToString("F1") +
                                                  " kg of " + materialType + " collected. " +
                                                  "Citizen earned " + totalCredits.ToString("F1") + " credits.";

                            ScriptManager.RegisterStartupScript(this, GetType(), "success",
                                "alert('" + successMessage.Replace("'", "\\'") + "'); window.location.href='ActivePickups.aspx';", true);
                        }
                        catch (Exception ex)
                        {
                            transaction.Rollback();
                            ShowErrorMessage("Error: " + ex.Message);
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ShowErrorMessage("Error: " + ex.Message);
            }
        }

        private void SaveVerificationPhotos(SqlConnection conn, SqlTransaction transaction, string verificationId)
        {
            // Save Before Photo
            if (!string.IsNullOrEmpty(BeforePhotoUrl))
            {
                SaveMediaFile(conn, transaction, CurrentUserId, "PickupVerification", verificationId, BeforePhotoUrl, "image/jpeg", "Before");
            }

            // Save Process Photo
            if (!string.IsNullOrEmpty(ProcessPhotoUrl))
            {
                SaveMediaFile(conn, transaction, CurrentUserId, "PickupVerification", verificationId, ProcessPhotoUrl, "image/jpeg", "Process");
            }

            // Save After Photo
            if (!string.IsNullOrEmpty(AfterPhotoUrl))
            {
                SaveMediaFile(conn, transaction, CurrentUserId, "PickupVerification", verificationId, AfterPhotoUrl, "image/jpeg", "After");
            }
        }

        private void SaveMediaFile(SqlConnection conn, SqlTransaction transaction, string userId, string entityType, string entityId, string fileUrl, string fileType, string photoType)
        {
            string fileId = "MF_" + Guid.NewGuid().ToString("N").Substring(0, 20);

            string query = @"
                INSERT INTO MediaFiles (FileId, UserId, EntityType, EntityId, FileUrl, FileType, SizeBytes, CreatedAt)
                VALUES (@FileId, @UserId, @EntityType, @EntityId, @FileUrl, @FileType, @SizeBytes, GETDATE())";

            using (SqlCommand cmd = new SqlCommand(query, conn, transaction))
            {
                cmd.Parameters.AddWithValue("@FileId", fileId);
                cmd.Parameters.AddWithValue("@UserId", userId);
                cmd.Parameters.AddWithValue("@EntityType", entityType + "_" + photoType);
                cmd.Parameters.AddWithValue("@EntityId", entityId);
                cmd.Parameters.AddWithValue("@FileUrl", fileUrl);
                cmd.Parameters.AddWithValue("@FileType", fileType);

                // Get file size if file exists
                long fileSize = 0;
                string physicalPath = Server.MapPath(fileUrl);
                if (File.Exists(physicalPath))
                {
                    FileInfo fileInfo = new FileInfo(physicalPath);
                    fileSize = fileInfo.Length;
                }
                cmd.Parameters.AddWithValue("@SizeBytes", fileSize);

                cmd.ExecuteNonQuery();
            }
        }

        private string GetNextVerificationId(SqlConnection conn, SqlTransaction transaction)
        {
            string query = "SELECT 'PV' + RIGHT('00' + CAST(ISNULL(MAX(CAST(SUBSTRING(VerificationId, 3, 2) AS INT)), 0) + 1 AS VARCHAR(2)), 2) FROM PickupVerifications";
            using (SqlCommand cmd = new SqlCommand(query, conn, transaction))
            {
                object result = cmd.ExecuteScalar();
                return result != null ? result.ToString() : "PV01";
            }
        }

        private string GetNextRewardId(SqlConnection conn, SqlTransaction transaction)
        {
            string query = "SELECT 'RP' + RIGHT('00' + CAST(ISNULL(MAX(CAST(SUBSTRING(RewardId, 3, 2) AS INT)), 0) + 1 AS VARCHAR(2)), 2) FROM RewardPoints";
            using (SqlCommand cmd = new SqlCommand(query, conn, transaction))
            {
                object result = cmd.ExecuteScalar();
                return result != null ? result.ToString() : "RP01";
            }
        }

        private void AddUserActivity(SqlConnection conn, SqlTransaction transaction, string userId, string activityType, string description, decimal points)
        {
            string query = @"
                INSERT INTO UserActivities (UserId, ActivityType, Description, Points, Timestamp)
                VALUES (@UserId, @ActivityType, @Description, @Points, GETDATE())";

            using (SqlCommand cmd = new SqlCommand(query, conn, transaction))
            {
                cmd.Parameters.AddWithValue("@UserId", userId);
                cmd.Parameters.AddWithValue("@ActivityType", activityType);
                cmd.Parameters.AddWithValue("@Description", description);
                cmd.Parameters.AddWithValue("@Points", points);
                cmd.ExecuteNonQuery();
            }
        }

        protected void btnSaveDraft_Click(object sender, EventArgs e)
        {
            SaveDraft();
            ShowSuccessMessage("Draft saved successfully. You can continue later.");
        }

        private void SaveDraft()
        {
            try
            {
                string draftData = txtVerifiedWeight.Text + "|" +
                                 ddlMaterialType.SelectedValue + "|" +
                                 ddlVerificationMethod.SelectedValue + "|" +
                                 txtNotes.Text + "|" +
                                 BeforePhotoUrl + "|" +
                                 ProcessPhotoUrl + "|" +
                                 AfterPhotoUrl;

                string draftKey = "Draft_" + PickupId + "_" + CurrentUserId;
                Session[draftKey] = draftData;

                // Also save to database for persistence
                SaveDraftToDatabase(draftData);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error saving draft: " + ex.Message);
            }
        }

        private void SaveDraftToDatabase(string draftData)
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(GetConnectionString()))
                {
                    string query = @"
                        IF EXISTS (SELECT 1 FROM VerificationDrafts WHERE PickupId = @PickupId AND CollectorId = @CollectorId)
                        BEGIN
                            UPDATE VerificationDrafts 
                            SET DraftData = @DraftData, 
                                UpdatedAt = GETDATE()
                            WHERE PickupId = @PickupId AND CollectorId = @CollectorId
                        END
                        ELSE
                        BEGIN
                            INSERT INTO VerificationDrafts (PickupId, CollectorId, DraftData, CreatedAt, UpdatedAt)
                            VALUES (@PickupId, @CollectorId, @DraftData, GETDATE(), GETDATE())
                        END";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@PickupId", PickupId);
                        cmd.Parameters.AddWithValue("@CollectorId", CurrentUserId);
                        cmd.Parameters.AddWithValue("@DraftData", draftData);

                        conn.Open();
                        cmd.ExecuteNonQuery();
                    }
                }
            }
            catch (Exception ex)
            {
                // Log error but don't show to user
                System.Diagnostics.Debug.WriteLine("Error saving draft to database: " + ex.Message);
            }
        }

        private void ClearDraftData()
        {
            string draftKey = "Draft_" + PickupId + "_" + CurrentUserId;
            Session.Remove(draftKey);

            // Also delete from database
            ClearDraftFromDatabase();
        }

        private void ClearDraftFromDatabase()
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(GetConnectionString()))
                {
                    string query = "DELETE FROM VerificationDrafts WHERE PickupId = @PickupId AND CollectorId = @CollectorId";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@PickupId", PickupId);
                        cmd.Parameters.AddWithValue("@CollectorId", CurrentUserId);

                        conn.Open();
                        cmd.ExecuteNonQuery();
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error clearing draft from database: " + ex.Message);
            }
        }

        protected void btnCaptureBefore_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(CurrentUserId))
            {
                ShowErrorMessage("Session expired. Please login again.");
                Response.Redirect("~/Login.aspx");
                return;
            }

            if (fileUpload.HasFile)
            {
                UploadPhoto("Before");
            }
            else
            {
                ShowErrorMessage("Please select a file to upload.");
            }
        }

        protected void btnCaptureProcess_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(CurrentUserId))
            {
                ShowErrorMessage("Session expired. Please login again.");
                Response.Redirect("~/Login.aspx");
                return;
            }

            if (fileUpload.HasFile)
            {
                UploadPhoto("Process");
            }
            else
            {
                ShowErrorMessage("Please select a file to upload.");
            }
        }

        protected void btnCaptureAfter_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(CurrentUserId))
            {
                ShowErrorMessage("Session expired. Please login again.");
                Response.Redirect("~/Login.aspx");
                return;
            }

            if (fileUpload.HasFile)
            {
                UploadPhoto("After");
            }
            else
            {
                ShowErrorMessage("Please select a file to upload.");
            }
        }

        protected void btnRemoveBefore_Click(object sender, EventArgs e)
        {
            RemovePhoto("Before");
        }

        protected void btnRemoveProcess_Click(object sender, EventArgs e)
        {
            RemovePhoto("Process");
        }

        protected void btnRemoveAfter_Click(object sender, EventArgs e)
        {
            RemovePhoto("After");
        }

        private void UploadPhoto(string photoType)
        {
            if (fileUpload.HasFile)
            {
                try
                {
                    // Validate file type
                    string fileExtension = Path.GetExtension(fileUpload.FileName).ToLower();
                    string[] allowedExtensions = { ".jpg", ".jpeg", ".png", ".gif" };

                    if (Array.IndexOf(allowedExtensions, fileExtension) == -1)
                    {
                        ShowErrorMessage("Invalid file type. Please upload JPG, PNG, or GIF images only.");
                        return;
                    }

                    // Validate file size (max 5MB)
                    if (fileUpload.PostedFile.ContentLength > 5 * 1024 * 1024)
                    {
                        ShowErrorMessage("File size too large. Maximum size is 5MB.");
                        return;
                    }

                    // Create upload directory if it doesn't exist
                    string uploadDir = "~/Uploads/PickupVerifications/" + PickupId + "/";
                    string physicalDir = Server.MapPath(uploadDir);

                    if (!Directory.Exists(physicalDir))
                    {
                        Directory.CreateDirectory(physicalDir);
                    }

                    // Generate unique filename
                    string fileName = photoType + "_" + Guid.NewGuid().ToString("N") + fileExtension;
                    string filePath = Path.Combine(physicalDir, fileName);
                    string relativePath = uploadDir + fileName;

                    // Save the file
                    fileUpload.SaveAs(filePath);

                    // Update photo URL and preview
                    switch (photoType)
                    {
                        case "Before":
                            BeforePhotoUrl = relativePath;
                            imgBeforePreview.Src = relativePath;
                            imgBeforePreview.Visible = true;
                            btnRemoveBefore.Visible = true;
                            break;
                        case "Process":
                            ProcessPhotoUrl = relativePath;
                            imgProcessPreview.Src = relativePath;
                            imgProcessPreview.Visible = true;
                            btnRemoveProcess.Visible = true;
                            break;
                        case "After":
                            AfterPhotoUrl = relativePath;
                            imgAfterPreview.Src = relativePath;
                            imgAfterPreview.Visible = true;
                            btnRemoveAfter.Visible = true;
                            break;
                    }

                    ShowSuccessMessage(photoType + " photo uploaded successfully!");

                    // Auto-save draft after photo upload
                    SaveDraft();
                }
                catch (Exception ex)
                {
                    ShowErrorMessage("Error uploading photo: " + ex.Message);
                }
            }
            else
            {
                ShowErrorMessage("Please select a file to upload.");
            }
        }

        private void RemovePhoto(string photoType)
        {
            try
            {
                string filePath = "";
                string photoUrl = "";

                switch (photoType)
                {
                    case "Before":
                        photoUrl = BeforePhotoUrl;
                        BeforePhotoUrl = "";
                        imgBeforePreview.Visible = false;
                        btnRemoveBefore.Visible = false;
                        break;
                    case "Process":
                        photoUrl = ProcessPhotoUrl;
                        ProcessPhotoUrl = "";
                        imgProcessPreview.Visible = false;
                        btnRemoveProcess.Visible = false;
                        break;
                    case "After":
                        photoUrl = AfterPhotoUrl;
                        AfterPhotoUrl = "";
                        imgAfterPreview.Visible = false;
                        btnRemoveAfter.Visible = false;
                        break;
                }

                // Delete physical file if it exists
                if (!string.IsNullOrEmpty(photoUrl))
                {
                    filePath = Server.MapPath(photoUrl);
                    if (File.Exists(filePath))
                    {
                        File.Delete(filePath);
                    }
                }

                ShowSuccessMessage(photoType + " photo removed.");

                // Auto-save draft after photo removal
                SaveDraft();
            }
            catch (Exception ex)
            {
                ShowErrorMessage("Error removing photo: " + ex.Message);
            }
        }

        protected void txtVerifiedWeight_TextChanged(object sender, EventArgs e)
        {
            CalculateCredits();
            SaveDraft(); // Auto-save when weight changes
        }

        protected void ddlMaterialType_SelectedIndexChanged(object sender, EventArgs e)
        {
            CalculateCredits();
            SaveDraft(); // Auto-save when material type changes
        }

        protected void ddlVerificationMethod_SelectedIndexChanged(object sender, EventArgs e)
        {
            SaveDraft(); // Auto-save when verification method changes
        }

        protected void txtNotes_TextChanged(object sender, EventArgs e)
        {
            SaveDraft(); // Auto-save when notes change
        }

        private void ShowSuccessMessage(string message)
        {
            string script = "showNotification('success', '" + message.Replace("'", "\\'") + "');";
            ScriptManager.RegisterStartupScript(this, GetType(), "SuccessMessage", script, true);
        }

        private string GetConnectionString()
        {
            return ConfigurationManager.ConnectionStrings["SoorGreenDBConnectionString"].ConnectionString;
        }

        private void ShowErrorMessage(string message)
        {
            string script = "showNotification('error', '" + message.Replace("'", "\\'") + "');";
            ScriptManager.RegisterStartupScript(this, GetType(), "ErrorMessage", script, true);
        }
    }
}