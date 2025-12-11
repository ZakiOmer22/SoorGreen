<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ViewSQL.aspx.cs" Inherits="SoorGreen.Main.ViewSQL" %>

<!DOCTYPE html>
<html>
<head runat="server">
    <title>Full SQL Script - SoorGreen</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.8.0/styles/vs2015.min.css" rel="stylesheet" />
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            margin: 0;
            padding: 20px;
            background: #0a192f;
            color: #ffffff;
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
        }
        .header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            padding-bottom: 10px;
            border-bottom: 2px solid #00d4aa;
        }
        .sql-container {
            background: #1e1e1e;
            border-radius: 10px;
            padding: 20px;
            overflow: auto;
            max-height: 80vh;
        }
        .btn {
            background: linear-gradient(135deg, #00d4aa, #0984e3);
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 5px;
            cursor: pointer;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 8px;
        }
        .btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(0,212,170,0.3);
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="container">
            <div class="header">
                <h1><i class="fas fa-database"></i> SoorGreenDB Complete SQL Script</h1>
                <a href="Default.aspx" class="btn">
                    <i class="fas fa-arrow-left"></i> Back to Home
                </a>
            </div>
            
            <div class="sql-container">
                <pre><code class="language-sql" id="sqlCode" runat="server"></code></pre>
            </div>
            
            <div style="margin-top: 20px; text-align: center;">
                <asp:Button ID="btnDownload" runat="server" Text="Download SQL Script" 
                    CssClass="btn" OnClick="btnDownload_Click" />
                <asp:Button ID="btnCopy" runat="server" Text="Copy to Clipboard" 
                    CssClass="btn" OnClick="btnCopy_Click" />
            </div>
        </div>
    </form>
    
    <script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.8.0/highlight.min.js"></script>
    <script>
        hljs.highlightAll();
        
        function copyToClipboard() {
            const sqlCode = document.getElementById('sqlCode').innerText;
            navigator.clipboard.writeText(sqlCode).then(() => {
                alert('SQL script copied to clipboard!');
            });
        }
    </script>
</body>
</html>