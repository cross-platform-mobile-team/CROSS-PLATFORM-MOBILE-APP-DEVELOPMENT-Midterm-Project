param([string]$Document = 'output/pdf/taskflow-report.docx')
$ErrorActionPreference = 'Stop'
$path = (Resolve-Path -LiteralPath $Document).Path
$pdf = Join-Path ([System.IO.Path]::GetDirectoryName($path)) 'taskflow-report-word.pdf'
$word = New-Object -ComObject Word.Application
$word.Visible = $false
$word.DisplayAlerts = 0
try {
  $doc = $word.Documents.Open($path, $false, $false)
  try {
    $doc.Fields.Update() | Out-Null
    foreach ($toc in $doc.TablesOfContents) { $toc.Update() }
    $doc.Repaginate()
    foreach ($toc in $doc.TablesOfContents) { $toc.UpdatePageNumbers() }
    $doc.Save()
    $doc.ExportAsFixedFormat($pdf, 17)
    Write-Output ("Pages: {0}; PDF: {1}" -f $doc.ComputeStatistics(2), $pdf)
  } finally { $doc.Close(0) }
} finally { $word.Quit() }
