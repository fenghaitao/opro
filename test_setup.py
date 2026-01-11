"""
Simple test script to verify OPRO setup is working correctly.
Tests the OpenAI API connection using GPT-3.5-turbo.
"""

import os
import sys
import openai

# Check if OPENAI_API_KEY is set
openai_api_key = os.environ.get("OPENAI_API_KEY", "")

if not openai_api_key:
    print("❌ ERROR: OPENAI_API_KEY environment variable is not set!")
    print("\nPlease set it by running:")
    print('  PowerShell: $env:OPENAI_API_KEY = "your-api-key-here"')
    print('  CMD: set OPENAI_API_KEY=your-api-key-here')
    sys.exit(1)

print("✓ OPENAI_API_KEY is set")
print(f"  Key starts with: {openai_api_key[:20]}...")

# Test OpenAI API connection
print("\n🔄 Testing OpenAI API connection...")
try:
    openai.api_key = openai_api_key
    
    # Make a simple test call
    response = openai.ChatCompletion.create(
        model="gpt-3.5-turbo",
        messages=[
            {"role": "user", "content": "Does the sun rise from the north? Just answer yes or no."}
        ],
        max_tokens=10,
        temperature=0.0
    )
    
    test_output = response.choices[0].message.content.strip()
    print(f"✓ OpenAI API connection successful!")
    print(f"  Test response: {test_output}")
    
except Exception as e:
    print(f"❌ Error connecting to OpenAI API: {str(e)}")
    sys.exit(1)

# Check if required dependencies are installed
print("\n🔄 Checking dependencies...")
dependencies = [
    ("absl-py", "absl"),
    ("immutabledict", "immutabledict"),
    ("openai", "openai"),
    ("numpy", "numpy"),
    ("pandas", "pandas"),
]

all_ok = True
for package_name, import_name in dependencies:
    try:
        __import__(import_name)
        print(f"  ✓ {package_name}")
    except ImportError:
        print(f"  ❌ {package_name} - not installed")
        all_ok = False

# Check google-generativeai separately (has Python 3.14 compatibility issues)
try:
    import google.generativeai
    print(f"  ✓ google-generativeai")
except Exception as e:
    print(f"  ⚠️  google-generativeai - installed but has compatibility issues")
    print(f"      (This is OK if you're only using OpenAI models)")

if not all_ok:
    print("\n⚠️  Some dependencies are missing. Install them with:")
    print("  python -m pip install numpy pandas")
else:
    print("\n✅ All required dependencies are installed!")

print("\n" + "="*60)
print("🎉 Setup verification complete!")
print("="*60)
print("\nYou can now run OPRO examples:")
print("\n1. Prompt Optimization (GSM8K dataset with GPT-3.5-turbo):")
print('   python opro/optimization/optimize_instructions.py \\')
print('     --optimizer="gpt-3.5-turbo" \\')
print('     --scorer="gpt-3.5-turbo" \\')
print('     --instruction_pos="Q_begin" \\')
print('     --dataset="gsm8k" \\')
print('     --task="train" \\')
print('     --openai_api_key="%OPENAI_API_KEY%"')
print("\n2. Prompt Evaluation:")
print('   python opro/evaluation/evaluate_instructions.py \\')
print('     --scorer="gpt-3.5-turbo" \\')
print('     --dataset="gsm8k" \\')
print('     --task="test" \\')
print('     --instruction_pos="Q_begin" \\')
print('     --openai_api_key="%OPENAI_API_KEY%"')
print("\n3. Linear Regression Example:")
print('   python opro/optimization/optimize_linear_regression.py \\')
print('     --optimizer="gpt-3.5-turbo" \\')
print('     --openai_api_key="%OPENAI_API_KEY%"')
print("\n⚠️  Note: API calls may incur costs. Start with small tests!")
