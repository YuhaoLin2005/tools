# Desktop Organization Script
# Auto-categorizes desktop files into folders by type/pattern
# Usage: Right-click → Run with PowerShell, or: powershell -ExecutionPolicy Bypass -File organize_desktop.ps1

$desktop = [Environment]::GetFolderPath("Desktop")
$org = "$desktop\桌面整理"

# Create category folders
$folders = @(
    "$org\课程作业",
    "$org\课程实验",
    "$org\遥感实习相关",
    "$org\软件安装包",
    "$org\GIS地图数据",
    "$org\临时文件",
    "$org\文档资料",
    "$org\代码项目",
    "$org\图片",
    "$org\操作系统作业"
)
foreach ($f in $folders) {
    New-Item -ItemType Directory -Path $f -Force | Out-Null
}

Write-Host "=== Desktop Organization ==="
Write-Host "Moving files from: $desktop"
Write-Host "Target folder: $org"
Write-Host ""

# === 1. 课程作业 (customize student ID patterns below) ===
# Uncomment and edit to match your own student ID:
# Get-ChildItem $desktop -File | Where-Object { $_.Name -like "*<your_id>*" } | ForEach-Object {
#     Move-Item $_.FullName "$org\课程作业\" -Force -ErrorAction SilentlyContinue
# }

# === 2. 课程实验 ===
Get-ChildItem $desktop -File | Where-Object { $_.Name -like "*实验*" -or $_.Name -like "*实习*" -or $_.Name -like "*遥感*" } | ForEach-Object {
    Move-Item $_.FullName "$org\课程实验\" -Force -ErrorAction SilentlyContinue
}
Get-ChildItem $desktop -Directory | Where-Object { $_.Name -like "*实验*" -or $_.Name -like "*实习*" } | ForEach-Object {
    if ($_.Name -notlike "*2024级土管*") {
        Move-Item $_.FullName "$org\课程实验\" -Force -ErrorAction SilentlyContinue
    }
}

# === 3. 遥感实习相关 ===
Get-ChildItem $desktop -Directory | Where-Object { $_.Name -like "*2024级土管*" -or $_.Name -like "*遥感*" } | ForEach-Object {
    Move-Item $_.FullName "$org\遥感实习相关\" -Force -ErrorAction SilentlyContinue
}

# === 4. 软件安装包 ===
@("*.zip", "*.rar", "*.msi", "*.exe") | ForEach-Object {
    Get-ChildItem $desktop -File -Filter $_ | ForEach-Object {
        if ($_.Length -gt 100KB) {
            Move-Item $_.FullName "$org\软件安装包\" -Force -ErrorAction SilentlyContinue
        }
    }
}
Get-ChildItem $desktop -Directory | Where-Object { $_.Name -like "*ENVI*" } | ForEach-Object {
    Move-Item $_.FullName "$org\软件安装包\" -Force -ErrorAction SilentlyContinue
}

# === 5. GIS地图数据 ===
Get-ChildItem $desktop -File | Where-Object { $_.Name -like "*MapGIS*" -or $_.Name -like "*地图*" } | ForEach-Object {
    Move-Item $_.FullName "$org\GIS地图数据\" -Force -ErrorAction SilentlyContinue
}
Get-ChildItem $desktop -Directory | Where-Object { $_.Name -like "*MapGIS*" -or $_.Name -like "*地图*" -or $_.Name -like "*福建省*" -or $_.Name -like "*shiyan*" } | ForEach-Object {
    Move-Item $_.FullName "$org\GIS地图数据\" -Force -ErrorAction SilentlyContinue
}

# === 6. 操作系统作业 ===
Get-ChildItem $desktop -File | Where-Object { $_.Name -like "*Dining*" -or $_.Name -like "*Producer*" -or $_.Name -like "*Reader*" } | ForEach-Object {
    Move-Item $_.FullName "$org\操作系统作业\" -Force -ErrorAction SilentlyContinue
}

# === 7. 代码项目 ===
Get-ChildItem $desktop -Directory | Where-Object { $_.Name -like "*my-webgis*" -or $_.Name -like "*feature*" -or $_.Name -like "*info*" } | ForEach-Object {
    Move-Item $_.FullName "$org\代码项目\" -Force -ErrorAction SilentlyContinue
}
Get-ChildItem $desktop -File | Where-Object { $_.Name -like "*.html" -or $_.Name -like "*.py" } | ForEach-Object {
    Move-Item $_.FullName "$org\代码项目\" -Force -ErrorAction SilentlyContinue
}

# === 8. 图片 ===
Get-ChildItem $desktop -File | Where-Object { $_.Name -like "*.png" -or $_.Name -like "*.jpg" -or $_.Name -like "*.jpeg" -or $_.Name -like "*.gif" } | ForEach-Object {
    Move-Item $_.FullName "$org\图片\" -Force -ErrorAction SilentlyContinue
}
Get-ChildItem $desktop -Directory | Where-Object { $_.Name -like "*图*" } | ForEach-Object {
    Move-Item $_.FullName "$org\图片\" -Force -ErrorAction SilentlyContinue
}

# === 9. 文档资料 ===
Get-ChildItem $desktop -File | Where-Object { $_.Name -like "*.pdf" } | ForEach-Object {
    Move-Item $_.FullName "$org\文档资料\" -Force -ErrorAction SilentlyContinue
}
Get-ChildItem $desktop -File | Where-Object { $_.Name -like "*.txt" } | ForEach-Object {
    Move-Item $_.FullName "$org\临时文件\" -Force -ErrorAction SilentlyContinue
}

# === 10. 新建文件夹/临时文件 ===
Get-ChildItem $desktop -Directory | Where-Object { $_.Name -like "*新建*" } | ForEach-Object {
    Move-Item $_.FullName "$org\临时文件\" -Force -ErrorAction SilentlyContinue
}
Get-ChildItem $desktop -File | Where-Object { $_.Name -like "*新建*" } | ForEach-Object {
    Move-Item $_.FullName "$org\临时文件\" -Force -ErrorAction SilentlyContinue
}

# === 11. 快捷方式 (keep) ===
Write-Host "Shortcuts kept on desktop:"
Get-ChildItem $desktop -File -Filter "*.lnk" | ForEach-Object { Write-Host "  $($_.Name)" }

# === 12. Software folders ===
Get-ChildItem $desktop -Directory | Where-Object {
    $_.Name -like "*mysql*" -or $_.Name -like "*apache*" -or $_.Name -like "*tomcat*" -or
    $_.Name -like "*VMware*" -or $_.Name -like "*ubuntu*" -or $_.Name -like "*Desktop Runtime*"
} | ForEach-Object {
    Move-Item $_.FullName "$org\软件安装包\" -Force -ErrorAction SilentlyContinue
}

# === 13. Loose Office files ===
Get-ChildItem $desktop -File | Where-Object { $_.Name -like "*.docx" -or $_.Name -like "*.doc" -or $_.Name -like "*.pptx" -or $_.Name -like "*.xlsx" } | ForEach-Object {
    Move-Item $_.FullName "$org\文档资料\" -Force -ErrorAction SilentlyContinue
}

# === 14. .pkt files (Packet Tracer) ===
Get-ChildItem $desktop -File -Filter "*.pkt" | ForEach-Object {
    Move-Item $_.FullName "$org\课程实验\" -Force -ErrorAction SilentlyContinue
}

Write-Host ""
Write-Host "=== Organization Complete ==="
Write-Host "Remaining on desktop:"
Get-ChildItem $desktop | ForEach-Object { Write-Host "  $($_.Name)" }
