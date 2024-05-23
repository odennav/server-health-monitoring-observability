<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Trivy Scan Report</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 20px;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 20px;
        }
        th, td {
            border: 1px solid #dddddd;
            text-align: left;
            padding: 8px;
        }
        th {
            background-color: #f2f2f2;
        }
        h1, h2 {
            color: #333;
        }
    </style>
</head>
<body>
    <h1>Trivy Scan Report</h1>
    <p><strong>Image:</strong> {{ .ArtifactName }}</p>
    <p><strong>Generated at:</strong> {{ .GeneratedAt }}</p>

    {{ range .Results }}
    <h2>{{ .Target }}</h2>
    {{ if .Vulnerabilities }}
    <table>
        <thead>
            <tr>
                <th>ID</th>
                <th>Package</th>
                <th>Severity</th>
                <th>Title</th>
                <th>Description</th>
                <th>Fixed Version</th>
                <th>References</th>
            </tr>
        </thead>
        <tbody>
            {{ range .Vulnerabilities }}
            <tr>
                <td>{{ .VulnerabilityID }}</td>
                <td>{{ .PkgName }}</td>
                <td>{{ .Severity }}</td>
                <td>{{ .Title }}</td>
                <td>{{ .Description }}</td>
                <td>{{ .FixedVersion }}</td>
                <td>{{ range .References }}<a href="{{ . }}" target="_blank">{{ . }}</a><br>{{ end }}</td>
            </tr>
            {{ end }}
        </tbody>
    </table>
    {{ else }}
    <p>No vulnerabilities found.</p>
    {{ end }}

    {{ if .Misconfigurations }}
    <h2>Misconfigurations</h2>
    <table>
        <thead>
            <tr>
                <th>ID</th>
                <th>Title</th>
                <th>Description</th>
                <th>Severity</th>
                <th>References</th>
            </tr>
        </thead>
        <tbody>
            {{ range .Misconfigurations }}
            <tr>
                <td>{{ .ID }}</td>
                <td>{{ .Title }}</td>
                <td>{{ .Description }}</td>
                <td>{{ .Severity }}</td>
                <td>{{ range .References }}<a href="{{ . }}" target="_blank">{{ . }}</a><br>{{ end }}</td>
            </tr>
            {{ end }}
        </tbody>
    </table>
    {{ end }}

    {{ if .Secrets }}
    <h2>Secrets</h2>
    <table>
        <thead>
            <tr>
                <th>ID</th>
                <th>Rule ID</th>
                <th>Category</th>
                <th>Severity</th>
                <th>Title</th>
                <th>Description</th>
                <th>Match</th>
            </tr>
        </thead>
        <tbody>
            {{ range .Secrets }}
            <tr>
                <td>{{ .ID }}</td>
                <td>{{ .RuleID }}</td>
                <td>{{ .Category }}</td>
                <td>{{ .Severity }}</td>
                <td>{{ .Title }}</td>
                <td>{{ .Description }}</td>
                <td>{{ .Match }}</td>
            </tr>
            {{ end }}
        </tbody>
    </table>
    {{ end }}

    {{ end }}
</body>
</html>

