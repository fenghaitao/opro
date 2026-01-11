"""Quick test without environment variable check"""
import sys

try:
    import openai
    print("✓ openai module imported")
    
    import absl
    print("✓ absl-py installed")
    
    import google.generativeai
    print("✓ google-generativeai installed")
    
    import immutabledict
    print("✓ immutabledict installed")
    
    print("\n✅ All core dependencies are installed!")
    print("\nTo test OpenAI API connection, set your API key and run:")
    print('  $env:OPENAI_API_KEY = "your-key"; python test_setup.py')
    
except ImportError as e:
    print(f"❌ Missing dependency: {e}")
    sys.exit(1)
