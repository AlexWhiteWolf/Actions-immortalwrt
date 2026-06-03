#!/bin/bash

echo "======================================="
echo "[*] 开始安装 5G 模块支持..."
echo "======================================="

# 1. 添加 QModem 源
echo >> feeds.conf.default
echo 'src-git qmodem https://github.com/FUjr/QModem.git;main' >> feeds.conf.default
./scripts/feeds update qmodem
./scripts/feeds install -a -f -p qmodem

# 2. 删除旧版 Modem-Support
if [ -d "package/Modem-Support" ]; then
     echo "⚠️ 目录 package/Modem-Support 已存在，删除旧版本..."
     rm -rf package/Modem-Support
fi

# 3. 克隆最新 5G 模组支持
git clone --depth=1 https://github.com/Siriling/5G-Modem-Support package/Modem-Support
if [ $? -ne 0 ]; then
     echo "❌ Git 克隆失败！请检查网络连接或仓库地址"
     exit 1
fi

# 删除无用文件
rm -rf package/Modem-Support/rooter/0optionalapps/bwallocate
rm -rf package/Modem-Support/rooter/0optionalapps/ext-rspeedtest
rm -rf package/Modem-Support/rooter/0optionalapps/ext-speedtest

# 4. 修复目录名称错误（关键！！！）
# 仓库里是 quectel-CM-5G，不是 quectel_cm_5G
mkdir -p package/network/utils/quectel-CM-5G
mkdir -p package/network/utils/sms-tool

# 正确移动
if [ -d "package/Modem-Support/quectel-CM-5G" ]; then
    mv -f package/Modem-Support/quectel-CM-5G/* package/network/utils/quectel-CM-5G/
else
    echo "❌ 错误：quectel-CM-5G 目录不存在"
    exit 1
fi

if [ -d "package/Modem-Support/sms-tool" ]; then
    mv -f package/Modem-Support/sms-tool/* package/network/utils/sms-tool/
fi

# 5. 刷新软件包
./scripts/feeds clean
./scripts/feeds update -a
./scripts/feeds install -a

echo "======================================="
echo "✅ 5G 模块支持安装完成！"
echo "======================================="
exit 0
