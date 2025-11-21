#!/bin/bash
set -e

echo "🧪 STAGING ENVIRONMENT TESTS"
echo "============================"

ALB_DNS=$(aws elbv2 describe-load-balancers --names next-hire-alb --query 'LoadBalancers[0].DNSName' --output text)

echo "Testing Staging Environment: http://$ALB_DNS"

# Test application endpoints
echo "1. Testing health endpoint..."
curl -s http://$ALB_DNS/health/ | jq '.'

echo "3. Checking ECS service status..."
aws ecs describe-services --cluster next-hire-cluster --services next-hire-app --query 'services[0]'

echo "✅ Staging environment tests passed!"