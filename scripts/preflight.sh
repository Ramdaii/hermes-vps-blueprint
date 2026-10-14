
#!/usr/bin/env bash
set -u

echo "=== Hermes VPS Blueprint: Preflight ==="
echo

echo "=== Operating System ==="
if [ -r /etc/os-release ]; then
  . /etc/os-release
  printf 'OS: %s\n' "${PRETTY_NAME:-unknown}"
else
  echo "OS information unavailable"
fi

echo
echo "=== CPU ==="
if command -v nproc >/dev/null 2>&1; then
  printf 'CPU cores: '
  nproc
else
  echo "nproc unavailable"
fi

echo
echo "=== Memory ==="
if command -v free >/dev/null 2>&1; then
  free -h
else
  echo "free unavailable"
fi

echo
echo "=== Disk ==="
df -h /

echo
echo "=== Required Commands ==="
for cmd in bash curl git python3; do
  if command -v "$cmd" >/dev/null 2>&1; then
    printf '[OK] %s\n' "$cmd"
  else
    printf '[MISSING] %s\n' "$cmd"
  fi
done

echo
echo "=== Docker ==="
if command -v docker >/dev/null 2>&1; then
  docker --version
  if docker compose version >/dev/null 2>&1; then
    docker compose version
  else
    echo "[MISSING] Docker Compose plugin"
  fi
else
  echo "[MISSING] Docker"
fi

echo
echo "=== Local Port 20128 ==="
if command -v ss >/dev/null 2>&1; then
  if ss -lnt | grep -q ':20128[[:space:]]'; then
    echo "[IN USE] Port 20128"
  else
    echo "[AVAILABLE] No listener detected on port 20128"
  fi
else
  echo "Cannot check port: ss unavailable"
fi

echo
echo "Preflight complete. No system changes were made."
