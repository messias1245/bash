#!/bin/bash

# Configurações
BRIDGE=natbr2
BRIDGE_IP=192.168.100.1
SUBNET=192.168.100.0/24
INTERFACE_PUBLICA=$(ip route | grep default | awk '{print $5}')

echo "🔧 Criando bridge $BRIDGE com IP $BRIDGE_IP..."

# Instala ferramentas necessárias (para Debian/Ubuntu)
apt update -y && apt install -y bridge-utils iptables-persistent

# Cria a bridge
brctl addbr $BRIDGE
ip addr add $BRIDGE_IP/24 dev $BRIDGE
ip link set dev $BRIDGE up

echo "✅ Bridge $BRIDGE criada!"

# Ativa roteamento
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
sysctl -p

# Regras de iptables para NAT
echo "⚙️ Configurando iptables..."

iptables -t nat -A POSTROUTING -s $SUBNET -o $INTERFACE_PUBLICA -j MASQUERADE
iptables -A FORWARD -i $BRIDGE -j ACCEPT
iptables -A FORWARD -o $BRIDGE -j ACCEPT

# Salva as regras
netfilter-persistent save

echo "✅ NAT com $BRIDGE configurado com sucesso!"
echo ""
echo "➡️ Agora vá no painel do Virtualizor e crie um IP Pool com os seguintes dados:"
echo "   - Tipo: NAT"
echo "   - Interface: $BRIDGE"
echo "   - IP Range: 192.168.100.2 - 192.168.100.254"
echo "   - Gateway: $BRIDGE_IP"
echo "   - NAT IP: (o IP público do seu servidor)"
