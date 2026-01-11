# PowerShell script to run the TSP (Traveling Salesman Problem) optimization example

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "   OPRO - TSP Optimization" -ForegroundColor Cyan
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
    Write-Host '  $env:OPENAI_API_KEY = "your-key"; .\run_tsp_example.ps1' -ForegroundColor Yellow
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
Write-Host "  • Solve a Traveling Salesman Problem with 100 cities" -ForegroundColor White
Write-Host "  • Use GPT-3.5-turbo to find optimal route" -ForegroundColor White
Write-Host "  • Run up to 500 optimization steps" -ForegroundColor White
Write-Host "  • Start with 'farthest_insertion' algorithm" -ForegroundColor White
Write-Host "  • Make multiple API calls (will cost more than linear regression)" -ForegroundColor White
Write-Host ""
Write-Host "⚠️  This will take 10-20 minutes and make many API calls!" -ForegroundColor Yellow
Write-Host ""

$response = Read-Host "Continue? [Y/N]"
if ($response -ne "Y" -and $response -ne "y") {
    Write-Host "Cancelled." -ForegroundColor Yellow
    exit 0
}

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "Starting TSP optimization..." -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Run the optimization
python opro/optimization/optimize_tsp.py `
  --optimizer="gpt-3.5-turbo" `
  --starting_algorithm="farthest_insertion" `
  --openai_api_key="$env:OPENAI_API_KEY"

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "================================================" -ForegroundColor Green
    Write-Host "✅ Optimization completed successfully!" -ForegroundColor Green
    Write-Host "================================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Results have been saved to:" -ForegroundColor Cyan
    Write-Host "  outputs/optimization-results/tsp-o-gpt-3.5-turbo-*/" -ForegroundColor White
} else {
    Write-Host ""
    Write-Host "❌ Optimization failed!" -ForegroundColor Red
}
