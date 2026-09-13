$ErrorActionPreference = 'Stop'
$root = 'C:/Users/LENOVO/Downloads/Report templates and guidelines 2024/Report templates and guidelines 2024'
$out = Join-Path $PSScriptRoot '../build/report-template'
New-Item -ItemType Directory -Force $out | Out-Null
$out = (Resolve-Path $out).Path
$word = New-Object -ComObject Word.Application
$word.Visible = $false
$word.DisplayAlerts = 0
try {
  $source = (Resolve-Path -LiteralPath "$root/Template/Template English.doc").Path
  $document = $word.Documents.Open($source, $false, $true)
  try {
    $document.SaveAs2((Join-Path $out 'reference.docx'), 16)
    $document.ExportAsFixedFormat((Join-Path $out 'reference.pdf'), 17)
    Write-Output $document.Content.Text
    foreach ($section in $document.Sections) {
      Write-Output ("Page pt: {0}x{1}; margins top/right/bottom/left: {2}/{3}/{4}/{5}" -f $section.PageSetup.PageWidth,$section.PageSetup.PageHeight,$section.PageSetup.TopMargin,$section.PageSetup.RightMargin,$section.PageSetup.BottomMargin,$section.PageSetup.LeftMargin)
    }
  } finally { $document.Close(0) }
} finally { $word.Quit() }
