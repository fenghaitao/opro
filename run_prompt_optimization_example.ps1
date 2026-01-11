# PowerShell script to run Prompt Optimization on GSM8K dataset

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "   OPRO - Prompt Optimization (GSM8K)" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Check if API key is set
if (-not $env:OPENAI_API_KEY) {
    Write-Host "❌ ERROR: OPENAI_API_KEY is not set!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please set it first:" -ForegroundColor Yellow
    Write-Host '  $env:OPENAI_API_KEY = "your-api-key-here"' -ForegroundColor Yellow
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
Write-Host "  • Optimize prompts for GSM8K math reasoning task" -ForegroundColor White
Write-Host "  • Use GPT-3.5-turbo as both optimizer AND scorer" -ForegroundColor White
Write-Host "  • Start from: 'Let's solve the problem.'" -ForegroundColor White
Write-Host "  • Run up to 200 optimization steps" -ForegroundColor White
Write-Host "  • Try to evolve better prompts like:" -ForegroundColor White
Write-Host "    'Let's think step by step.'" -ForegroundColor DarkGray
Write-Host "    'Break down the problem carefully.'" -ForegroundColor DarkGray
Write-Host ""
Write-Host "⚠️  WARNING: This is VERY expensive!" -ForegroundColor Red
Write-Host "  • Will take 30-60+ minutes" -ForegroundColor Yellow
Write-Host "  • Makes 1000s of API calls" -ForegroundColor Yellow
Write-Host "  • Could cost $5-$20 depending on iterations" -ForegroundColor Yellow
Write-Host ""

$response = Read-Host "Are you SURE you want to continue? [Y/N]"
if ($response -ne "Y" -and $response -ne "y") {
    Write-Host "Cancelled. Good choice - this is expensive!" -ForegroundColor Yellow
    exit 0
}

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "Starting prompt optimization..." -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Run the optimization with both optimizer and scorer as GPT-3.5
python opro/optimization/optimize_instructions.py `
  --optimizer="gpt-3.5-turbo" `
  --scorer="gpt-3.5-turbo" `
  --instruction_pos="Q_begin" `
  --dataset="gsm8k" `
  --task="train" `
  --openai_api_key="$env:OPENAI_API_KEY"

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "================================================" -ForegroundColor Green
    Write-Host "✅ Optimization completed successfully!" -ForegroundColor Green
    Write-Host "================================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Results have been saved to:" -ForegroundColor Cyan
    Write-Host "  outputs/optimization-results/GSM8K-train-s-gpt-3.5-turbo-o-gpt-3.5-turbo-*/" -ForegroundColor White
    Write-Host ""
    Write-Host "Check the optimized prompts in the output folder!" -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "❌ Optimization failed!" -ForegroundColor Red
}
