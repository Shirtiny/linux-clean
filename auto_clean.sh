#!/bin/bash

# 1. 清理 APT 包管理器缓存
apt-get clean
apt-get autoremove -y

# 2. 清理系统日志 (仅保留最近 3 天)
journalctl --vacuum-time=3d

# 3. 清理 Docker 冗余数据 (强制清理，不需要手动确认)
docker system prune -f

# 4. 清空 Docker 容器的运行日志文件
truncate -s 0 /var/lib/docker/containers/*/*-json.log 2>/dev/null
