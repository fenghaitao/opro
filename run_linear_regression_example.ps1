# PowerShell script to run the Linear Regression optimization example
# This is the simplest OPRO example

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "   OPRO - Linear Regression Optimization" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Check if API key is set
if (-not $env:OPENAI_API_KEY) {
    Write-Host "❌ ERROR: OPENAI_API_KEY is not set!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please set it first:" -ForegroundColor Yellow
    Write-Host '  $env:OPENAI_API_KEY = "your-api-key-here"' -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Or run this script with the key:" -ForegroundColor Yellow
    Write-Host '  $env:OPENAI_API_KEY = "your-key"; .\run_linear_regression_example.ps1' -ForegroundColor Yellow
    exit 1
}

Write-Host "✓ API key is set" -ForegroundColor Green
Write-Host ""

# Set proxy for OpenAI API access
$env:HTTP_PROXY = "http://localhost:7890"
$env:HTTPS_PROXY = "http://localhost:7890"
Write-Host "✓ Proxy configured: localhost:7890" -ForegroundColor Green
Write-Host ""
Write-Host "This example will:" -ForegroundColor Cyan
Write-Host "  • Use GPT-3.5-turbo to optimize a linear regression problem" -ForegroundColor White
Write-Host "  • Try to find y = w*x + b where w=15 and b=14" -ForegroundColor White
Write-Host "  • Run 5 repetitions with up to 500 steps each" -ForegroundColor White
Write-Host "  • Make several API calls (will cost a few cents)" -ForegroundColor White
Write-Host ""
Write-Host "⚠️  This will take a few minutes and make API calls!" -ForegroundColor Yellow
Write-Host ""

$response = Read-Host "Continue? [Y/N]"
if ($response -ne "Y" -and $response -ne "y") {
    Write-Host "Cancelled." -ForegroundColor Yellow
    exit 0
}

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "Starting optimization..." -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Run the optimization
python opro/optimization/optimize_linear_regression.py `
  --optimizer="gpt-3.5-turbo" `
  --openai_api_key="$env:OPENAI_API_KEY"

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "================================================" -ForegroundColor Green
    Write-Host "✅ Optimization completed successfully!" -ForegroundColor Green
    Write-Host "================================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Results have been saved to:" -ForegroundColor Cyan
    Write-Host "  outputs/optimization-results/linear_regression-o-gpt-3.5-turbo-*/" -ForegroundColor White
} else {
    Write-Host ""
    Write-Host "❌ Optimization failed!" -ForegroundColor Red
}
