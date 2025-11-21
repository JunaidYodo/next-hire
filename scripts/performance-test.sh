#!/bin/bash
set -e

echo "⚡ PERFORMANCE TESTS"
echo "==================="

ALB_DNS=$(aws elbv2 describe-load-balancers --names next-hire-alb --query 'LoadBalancers[0].DNSName' --output text)

# Load test the health endpoint
echo "Running performance test on: http://$ALB_DNS/health/"

# Install hey if not present
if ! command -v hey &> /dev/null; then
    echo "Installing hey load tester..."
    go install github.com/rakyll/hey@latest
fi

# Run load test
hey -n 100 -c 10 http://$ALB_DNS/health/

echo "✅ Performance tests completed"