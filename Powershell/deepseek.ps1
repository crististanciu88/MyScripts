# 1. Import CSV Data
$services = Import-Csv -Path "D:\servers.csv"
# 2. Get the current date and time in the desired format

$lastRefreshTime = (Get-Date).ToString("dd MMM HH:mm UTCzzz")



# 3. Create HTML Structure with Search Feature and Last Refresh Time

$html = @"

<!DOCTYPE html>

<html>

<head>

    <title>Server Services Report</title>

    <style>

        body { font-family: Arial, sans-serif; margin: 20px; }

        table { border-collapse: collapse; width: 100%; }

        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }

        th { background-color: #f2f2f2; }

        tr:hover { background-color: #f5f5f5; }

        /* Custom CSS for search bar and last refresh time */

        .dataTables_filter {

            float: left !important; /* Move search bar to the left */

            margin-bottom: 10px; /* Add some spacing */

        }

        .dataTables_filter input {

            padding: 5px;

            width: 300px;

        }

        .last-refresh {

            float: right; /* Move last refresh time to the right */

            margin-top: 5px;

            font-size: 14px;

            color: #555;

        }

    </style>

    <!-- Add DataTables for enhanced search and sorting -->

    <link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/1.11.5/css/jquery.dataTables.css">

    <script type="text/javascript" charset="utf8" src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

    <script type="text/javascript" charset="utf8" src="https://cdn.datatables.net/1.11.5/js/jquery.dataTables.js"></script>

</head>

<body>

    <div class="last-refresh">Last Refresh: $lastRefreshTime</div>

    <table id="servicesTable">

        <thead>

            <tr>

                <th>Server Name</th>

                <th>Service Name</th>

                <th>Status</th>

                <th>Startup Type</th>

            </tr>

        </thead>

        <tbody>

"@



# 4. Add Table Rows from CSV

foreach ($service in $services) {

    $html += @"

            <tr>

                <td>$($service.ServerName)</td>

                <td>$($service.ServiceName)</td>

                <td>$($service.Status)</td>

                <td>$($service.StartupType)</td>

            </tr>

"@

}



# 5. Close HTML and Add JavaScript

$html += @"

        </tbody>

    </table>

    <script>

        `$(document).ready(function() {

            `$('#servicesTable').DataTable({

                "paging": false,

                "info": false,

                "dom": '<"top"f>rt<"bottom"lp><"clear">' // Custom placement of search bar

            });

        });

    </script>

</body>

</html>

"@


# 5. Save to File
$html | Out-File -FilePath "D:\output2.html"