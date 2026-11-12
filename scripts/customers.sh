#!/usr/bin/env bash
# Simulates customers ordering coffee every second, and counts failed orders.
# Run it during a deployment to prove zero downtime. Ctrl + C to stop.
ITEMS=(espresso cappuccino matcha iced croissant chocolate)
ok=0; fail=0
trap 'echo; echo "📊 Orders: ✅ $ok succeeded · ❌ $fail failed"; exit 0' INT
echo "🧑‍🤝‍🧑 Customers are ordering... (Ctrl + C to stop)"
while true; do
  item=${ITEMS[$((RANDOM % ${#ITEMS[@]}))]}
  resp=$(curl -s -m 3 -X POST http://localhost:8090/api/orders \
         -H 'Content-Type: application/json' -d "{\"item\":\"$item\"}")
  if echo "$resp" | grep -q '"id"'; then
    ok=$((ok+1))
    ver=$(curl -s -m 3 http://localhost:8090/api/orders | sed -n 's/.*"version":"\([^"]*\)".*/\1/p')
    printf "✅ #%-4s %-11s served by v%s\n" "$(echo "$resp" | sed -n 's/.*"id":\([0-9]*\).*/\1/p')" "$item" "$ver"
  else
    fail=$((fail+1)); echo "❌ order failed"
  fi
  sleep 1
done
