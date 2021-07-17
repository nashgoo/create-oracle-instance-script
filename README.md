# 说明
建议脚本在墙外机器运行，并且运行机器上必须配置好oci环境。

---
依赖jq

https://github.com/stedolan/jq


安装jq
```bash
wget http://stedolan.github.io/jq/download/linux64/jq -O /usr/local/bin/jq
chmod +x /usr/local/bin/jq
```

---

# 使用方法

下载脚本

```
wget https://raw.githubusercontent.com/angelsky11/create-oracle-instance-script/main/create_oracle_instance.sh
```

运行

```bash
chmod +x create_oracle_instance.sh
./create_oracle_instance.sh
```

可添加定时任务每1分钟检测一次


运行`crontab -e`后添加下面一行：
```
*/1 * * * * /YOUR_PATH/create_oracle_instance.sh >> /dev/null 2>&1
```
如果不想1分钟一次请自行搜索crontab用法


如果oci环境配置了多个config，可根据指定config运行脚本
```bash
./create_oracle_instance.sh -c /PATH/OF/YOUR/CONFIG_FIEL
```

# 消息推送

---

server酱推送

https://sc.ftqq.com


修改以下两个参数
```bash
NOTIFICATION=1
#server酱api
SERVERCHAN_KEY='YOUR_SERVERCHAN_API'
```

---

telegram推送

修改以下三个参数
```bash
NOTIFICATION=2
BOT_TOKEN='YOUR_SERVERCHAN_API'
USERID='YOUR_USERID'
```
---

如有使用问题请先搜索后发信息 https://t.me/angelsky11
