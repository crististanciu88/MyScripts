# Path to the CSV file
$csvPath = "D:\servers.csv"

# Import the CSV data
$data = Import-Csv -Path $csvPath

# Start the HTML file
$html = @"
<html>
<head>
    <title>Server and Service Status</title>
    <style>
        table {
            border-collapse: collapse;
            width: 100%;
        }
        th, td {
            border: 1px solid black;
            padding: 8px;
            text-align: left;
        }
        th {
            background-color: #f2f2f2;
        }
        input {
            margin-bottom: 12px;
        }
    </style>
</head>
<body>
    <h1>Server and Service Status</h1>
    <input type="text" id="searchInput" onkeyup="searchTable()" placeholder="Search for servers or services..." />
    <table id="statusTable">
        <tr>
            <th>Server Name</th>
            <th>Service Name</th>
            <th>Status</th>
        </tr>
"@

# Add rows from CSV data
foreach ($row in $data) {
    $html += "<tr>
    <td>$($row.ServerName)</td>
    <td>$($row.ServiceName)</td>
    <td>$($row.Status)</td>
</tr>"
}

# Closing HTML tags
$html += @"
    </table>

    <script>
    function searchTable() {
        const input = document.getElementById('searchInput');
        const filter = input.value.toUpperCase();
        const table = document.getElementById('statusTable');
        const tr = table.getElementsByTagName('tr');
        
        for (let i = 1; i < tr.length; i++) {
            tr[i].style.display = '';
            let td = tr[i].getElementsByTagName('td');
            let found = false;
            for (let j = 0; j < td.length; j++) {
                if (td[j]) {
                    let txtValue = td[j].textContent || td[j].innerText;
                    if (txtValue.toUpperCase().indexOf(filter) > -1) {
                        found = true;
                        break;
                    }
                }
            }
            tr[i].style.display = found ? '' : 'none';
        }
    }
    </script>
</body>
</html>
"@

# Specify output HTML file path
$outputPath = "D:\output.html"

# Write the HTML to the output file
$html | Out-File -FilePath $outputPath -Encoding utf8

# Open the output file in the default web browser
Start-Process $outputPath