# Linux 清理脚本

## 简介
这是一个轻量级的自动化系统清理脚本，旨在定期释放服务器磁盘空间，防止因日志堆积和冗余文件导致磁盘爆满。保持健康充足的存储空间，可以确保服务器上的 Docker 容器能够长期、稳定地运行。

## 文件结构
- `auto_clean.sh`：核心清理脚本，无输出静默运行设计。
- `README.md`：本说明文档。

## 常用的磁盘排查命令
当系统发出空间不足的预警，或者你想手动检查当前的存储状态时，可以使用以下命令进行排查：

### 1. 查看系统整体磁盘使用率
```bash
df -h

```

> **重点关注**：`/`（根目录）或 `/dev/vda1` 等主分区的 `Use%` (使用百分比) 和 `Avail` (剩余可用空间)。如果使用率超过 80%，建议立即进行清理。

### 2. 查看 Docker 占用的详细空间

```bash
docker system df

```

> **说明**：这会清晰地列出镜像 (Images)、容器 (Containers)、本地数据卷 (Local Volumes) 和构建缓存 (Build Cache) 各自占用了多少总空间，以及有多少是可以安全回收的 (RECLAIMABLE)。

### 3. 揪出占用空间最大的目录

如果根目录空间紧张，但不确定是哪个文件夹吃掉了硬盘，可以在根目录下运行此命令：

```bash
du -sh /* 2>/dev/null | sort -rh | head -n 10

```

> **说明**：这会遍历根目录，并按从大到小的顺序，列出占用空间排名前 10 的文件或文件夹，帮助你精准定位“空间杀手”（例如异常庞大的 `/var` 或 `/root` 目录）。

## 自动清理功能说明

脚本执行时将依次完成以下深度清理任务：

1. **APT 缓存清理** (`apt-get clean` & `autoremove -y`)
2. **系统日志瘦身** (`journalctl --vacuum-time=3d`)
3. **Docker 冗余数据回收** (`docker system prune -f`)
4. **Docker 容器日志截断** (`truncate -s 0 /var/lib/docker/containers/*/*-json.log`)

## 部署与使用指南

### 1. 赋予执行权限

```bash
chmod +x /sh/linux-clean/auto_clean.sh

```

### 2. 配置定时任务

通过执行 `crontab -e` 编辑定时任务表，添加以下规则实现每周一凌晨 3:00 静默清理：

```cron
0 3 * * 1 /sh/linux-clean/auto_clean.sh >/dev/null 2>&1

```

## 注意事项

* 脚本中的日志截断操作会清空当前运行容器的控制台历史输出，若需长期保留业务日志，请配置外部日志收集系统。

