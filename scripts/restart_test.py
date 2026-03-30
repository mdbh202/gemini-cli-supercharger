import pexpect
import sys
import os

WRAPPER_PATH = os.path.expanduser("~/gemini-cli-supercharger/scripts/gemini-wrapper.sh")

print(f"Launching Level 4 Sandbox Stress Test...")

try:
    child = pexpect.spawn(f"{WRAPPER_PATH} --sandbox", timeout=45, encoding='utf-8')
    child.logfile = sys.stdout
    
    for i in range(1, 6):
        print(f"\nCycle {i}: Waiting for prompt...")
        child.expect('>')
        print(f"\nCycle {i}: Prompt reached. Sending /restart...")
        child.sendline("/restart")
        
    print("\nFinal Cycle: Waiting for prompt after 5 restarts...")
    child.expect('>')
    print("\nFinal Cycle: Prompt reached. CLI is stable.")
    
    child.sendline("exit")
    child.close()
    print("\nSTRESS TEST PASSED: Level 4 Atomic Initialization is stable.")
    sys.exit(0)

except Exception as e:
    print(f"\nERROR during stress test: {str(e)}")
    sys.exit(1)
