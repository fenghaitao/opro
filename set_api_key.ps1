# PowerShell script to set OPENAI_API_KEY
# Usage: .\set_api_key.ps1

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "   OPRO - OpenAI API Key Setup" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Prompt for API key
$apiKey = Read-Host "Please enter your OpenAI API Key"

if ([string]::IsNullOrWhiteSpace($apiKey)) {
    Write-Host ""
    Write-Host "❌ ERROR: No API key entered!" -ForegroundColor Red
    exit 1
}

# Set environment variable for current session
$env:OPENAI_API_KEY = $apiKey
Write-Host ""
Write-Host "✅ API key set for current PowerShell session!" -ForegroundColor Green
Write-Host ""

# Ask if user wants to make it permanent
Write-Host "Do you want to make this permanent (save to user environment)? [Y/N]" -ForegroundColor Yellow
$response = Read-Host

if ($response -eq "Y" -or $response -eq "y") {
    try {
        [System.Environment]::SetEnvironmentVariable('OPENAI_API_KEY', $apiKey, 'User')
        Write-Host "✅ API key saved permanently!" -ForegroundColor Green
        Write-Host "   (You may need to restart PowerShell for it to take effect in new sessions)" -ForegroundColor Yellow
    } catch {
        Write-Host "❌ Failed to save permanently: $_" -ForegroundColor Red
    }
} else {
    Write-Host "⚠️  API key is only set for this session" -ForegroundColor Yellow
    Write-Host "   (It will be lost when you close this window)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "Now running test_setup.py to verify..." -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Run the test script
python test_setup.py
