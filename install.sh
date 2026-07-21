#!/bin/bash

################################################################################
#                                                                              #
#   INSTALADOR AUTOMÁTICO - ARCH LINUX + HYPRLAND + CAELESTIA SHELL          #
#   Versão: 3.0 (corrigida)                                                   #
#   Criado para: HP EliteBook 845 G7                                          #
#                                                                              #
################################################################################

VERDE='\033[0;32m'
AZUL='\033[0;34m'
AMARELO='\033[1;33m'
VERMELHO='\033[0;31m'
ROXO='\033[0;35m'
CIANO='\033[0;36m'
SEM_COR='\033[0m'
NEGRITO='\033[1m'
SUBLINHADO='\033[4m'

LOG_DIR="/tmp/arch-installer-logs"
INSTALL_LOG="$LOG_DIR/install.log"
CAELESTIA_LOG="$LOG_DIR/caelestia-build.log"
mkdir -p "$LOG_DIR"

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$INSTALL_LOG"; }

limpar() { clear; }

cabecalho() {
    limpar
    echo -e "${AZUL}${SUBLINHADO}════════════════════════════════════════════════════════════════${SEM_COR}"
    echo ""
    echo -e "  ${VERDE}${NEGRITO}🐧 INSTALADOR AUTOMÁTICO ARCH LINUX${SEM_COR}"
    echo -e "  ${ROXO}${NEGRITO}✨ HYPRLAND + CAELESTIA SHELL (v3.0)${SEM_COR}"
    echo ""
    echo -e "${AZUL}${SUBLINHADO}════════════════════════════════════════════════════════════════${SEM_COR}\n"
}

sucesso() { echo -e "${VERDE}${NEGRITO}✓ $1${SEM_COR}"; log "OK: $1"; }
erro()    { echo -e "${VERMELHO}${NEGRITO}✗ ERRO: $1${SEM_COR}"; log "ERRO: $1"; }
info()    { echo -e "${CIANO}${NEGRITO}ℹ $1${SEM_COR}"; log "INFO: $1"; }
aviso()   { echo -e "${AMARELO}${NEGRITO}⚠ $1${SEM_COR}"; log "AVISO: $1"; }

pausa() {
    echo ""
    echo -e "${AMARELO}Pressione [ENTER] para continuar...${SEM_COR}"
    read -r
}

verificar_root() {
    if [[ $EUID -ne 0 ]]; then
        erro "Este script precisa ser executado com sudo!"
        echo "Execute: sudo bash $0"
        exit 1
    fi
    if [[ -z "$SUDO_USER" ]]; then
        erro "Rode com 'sudo bash $0', não como root direto (preciso saber qual é seu usuário normal)."
        exit 1
    fi
}

verificar_internet() {
    if ! ping -c 1 8.8.8.8 &> /dev/null; then
        erro "Sem conexão com a internet!"
        echo "Conecte-se ao Wi-Fi e tente novamente."
        exit 1
    fi
    sucesso "Conexão com internet verificada!"
}

atualizar_sistema() {
    info "Sincronizando repositórios..."
    pacman -Sy --noconfirm
    sucesso "Repositórios sincronizados!"
    info "Atualizando sistema (pode levar alguns minutos)..."
    pacman -Syu --noconfirm
    sucesso "Sistema atualizado!"
}

instalar_pacote() {
    local pacote=$1
    local descricao=${2:-$pacote}
    if pacman -Qi "$pacote" &> /dev/null; then
        info "$descricao já está instalado"
        return 0
    else
        echo -e "${AMARELO}[...] Instalando $descricao (pacman)...${SEM_COR}"
        if pacman -S --needed --noconfirm "$pacote" >> "$INSTALL_LOG" 2>&1; then
            sucesso "$descricao instalado com sucesso!"
            return 0
        else
            erro "Falha ao instalar $descricao via pacman"
            return 1
        fi
    fi
}

instalar_multiplos() {
    local pacotes=("$@")
    for pacote in "${pacotes[@]}"; do
        instalar_pacote "$pacote"
    done
}

# Tenta pacman, e se o pacote não existir no repo oficial, cai pro AUR (yay)
instalar_pacote_universal() {
    local pacote=$1
    local descricao=${2:-$pacote}

    if pacman -Qi "$pacote" &> /dev/null; then
        info "$descricao já está instalado"
        return 0
    fi

    if pacman -Si "$pacote" &> /dev/null; then
        instalar_pacote "$pacote" "$descricao"
        return $?
    fi

    if ! command -v yay &> /dev/null; then
        aviso "$descricao só existe no AUR e o 'yay' não está instalado."
        FALTANTES_AUR+=("$pacote")
        return 1
    fi

    echo -e "${AMARELO}[...] Instalando $descricao via AUR (yay)...${SEM_COR}"
    if sudo -u "$SUDO_USER" yay -S --needed --noconfirm "$pacote" >> "$INSTALL_LOG" 2>&1; then
        sucesso "$descricao instalado com sucesso via AUR!"
        return 0
    else
        erro "Falha ao instalar $descricao via AUR"
        return 1
    fi
}

detectar_gpu_instalar_drivers() {
    info "Detectando GPU..."
    local gpu_info
    gpu_info=$(lspci 2>/dev/null | grep -iE 'vga|3d|display')
    echo -e "${CIANO}$gpu_info${SEM_COR}"

    local pacotes=("mesa" "lib32-mesa")

    if echo "$gpu_info" | grep -qi amd; then
        sucesso "GPU AMD detectada"
        pacotes+=("vulkan-radeon" "lib32-vulkan-radeon" "amd-ucode" "libva-mesa-driver" "lib32-libva-mesa-driver")
    elif echo "$gpu_info" | grep -qi nvidia; then
        sucesso "GPU NVIDIA detectada"
        pacotes+=("nvidia" "nvidia-utils" "lib32-nvidia-utils")
    elif echo "$gpu_info" | grep -qi intel; then
        sucesso "GPU Intel detectada"
        pacotes+=("vulkan-intel" "lib32-vulkan-intel" "intel-media-driver")
    else
        aviso "GPU não identificada automaticamente. Instalando apenas mesa (genérico)."
    fi

    instalar_multiplos "${pacotes[@]}"
}

setup_inicial() {
    cabecalho
    echo -e "${VERDE}${NEGRITO}[1] SETUP INICIAL${SEM_COR}\n"
    info "Verificando requisitos..."
    pausa
    verificar_internet
    echo ""

    local usuario_home
    usuario_home=$(eval echo ~"${SUDO_USER}")

    info "Criando diretórios necessários..."
    sudo -u "$SUDO_USER" mkdir -p "$usuario_home/.config/hypr"
    sudo -u "$SUDO_USER" mkdir -p "$usuario_home/.config/foot"
    sudo -u "$SUDO_USER" mkdir -p "$usuario_home/.config/quickshell"
    sudo -u "$SUDO_USER" mkdir -p "$usuario_home/.local/share/applications"
    sudo -u "$SUDO_USER" mkdir -p "$usuario_home/.local/bin"
    sucesso "Diretórios criados!"
    echo ""

    info "Atualizando banco de dados de pacotes..."
    atualizar_sistema
    echo ""
    sucesso "Setup inicial concluído!"
    pausa
}

instalar_dependencias_basicas() {
    cabecalho
    echo -e "${VERDE}${NEGRITO}[2] INSTALANDO DEPENDÊNCIAS BÁSICAS${SEM_COR}\n"
    local deps_basicas=("base-devel" "git" "cmake" "ninja" "pkgconf" "vim" "nano" "wget" "curl" "htop" "neofetch")
    instalar_multiplos "${deps_basicas[@]}"
    sucesso "Dependências básicas instaladas!"
    pausa
}

instalar_hyprland() {
    cabecalho
    echo -e "${VERDE}${NEGRITO}[3] INSTALANDO HYPRLAND${SEM_COR}\n"
    local hyprland_deps=("hyprland" "hyprland-protocols" "xdg-desktop-portal-hyprland" "wayland" "wayland-protocols" "egl-wayland" "polkit" "seatd")
    instalar_multiplos "${hyprland_deps[@]}"
    systemctl enable --now seatd 2>/dev/null || true
    sucesso "Hyprland instalado com sucesso!"
    pausa
}

instalar_drivers() {
    cabecalho
    echo -e "${VERDE}${NEGRITO}[4] INSTALANDO DRIVERS GRÁFICOS${SEM_COR}\n"
    detectar_gpu_instalar_drivers
    sucesso "Drivers gráficos instalados!"
    pausa
}

instalar_audio() {
    cabecalho
    echo -e "${VERDE}${NEGRITO}[5] INSTALANDO PIPEWIRE${SEM_COR}\n"
    local audio_packages=("pipewire" "pipewire-pulse" "pipewire-alsa" "pipewire-jack" "wireplumber" "pavucontrol")
    instalar_multiplos "${audio_packages[@]}"
    sudo -u "$SUDO_USER" XDG_RUNTIME_DIR="/run/user/$(id -u "$SUDO_USER")" \
        systemctl --user enable --now pipewire pipewire-pulse wireplumber 2>/dev/null || \
        aviso "Não foi possível ativar o PipeWire agora (normal sem sessão gráfica ativa)."
    sucesso "PipeWire instalado!"
    pausa
}

instalar_terminais() {
    cabecalho
    echo -e "${VERDE}${NEGRITO}[6] INSTALANDO TERMINAIS${SEM_COR}\n"
    instalar_multiplos "foot" "alacritty" "kitty"
    sucesso "Terminais instalados!"
    pausa
}

instalar_ferramentas_sistema() {
    cabecalho
    echo -e "${VERDE}${NEGRITO}[7] INSTALANDO FERRAMENTAS DE SISTEMA${SEM_COR}\n"
    local ferramentas=("networkmanager" "network-manager-applet" "bluez" "bluez-utils" "brightnessctl" "alsa-utils" "dunst" "rofi" "feh" "flameshot" "thunar" "jq")
    instalar_multiplos "${ferramentas[@]}"
    systemctl enable --now NetworkManager 2>/dev/null || true
    systemctl enable --now bluetooth 2>/dev/null || true
    sucesso "Ferramentas de sistema instaladas!"
    pausa
}

instalar_yay() {
    if command -v yay &> /dev/null; then
        info "yay já está instalado"
        return 0
    fi
    info "Instalando 'yay' (necessário para pacotes do AUR como o quickshell)..."
    local tmp_dir
    tmp_dir=$(mktemp -d)
    chown "$SUDO_USER":"$SUDO_USER" "$tmp_dir"
    if sudo -u "$SUDO_USER" git clone https://aur.archlinux.org/yay.git "$tmp_dir/yay" >> "$INSTALL_LOG" 2>&1 && \
       (cd "$tmp_dir/yay" && sudo -u "$SUDO_USER" makepkg -si --noconfirm >> "$INSTALL_LOG" 2>&1); then
        sucesso "yay instalado com sucesso!"
        rm -rf "$tmp_dir"
        return 0
    else
        erro "Falha ao instalar o yay. Veja o log: $INSTALL_LOG"
        rm -rf "$tmp_dir"
        return 1
    fi
}

instalar_caelestia() {
    cabecalho
    echo -e "${VERDE}${NEGRITO}[8] INSTALANDO CAELESTIA SHELL${SEM_COR}\n"

    local usuario_home
    usuario_home=$(eval echo ~"${SUDO_USER}")
    # Local CORRETO exigido pelo Quickshell
    local caelestia_dir="$usuario_home/.config/quickshell/caelestia"
    FALTANTES_AUR=()

    aviso "A doc oficial recomenda instalar via AUR (pacote 'caelestia-shell'), que resolve build e deps sozinho."
    echo ""
    echo -ne "${AMARELO}Instalar via AUR/yay (recomendado) [R] ou manualmente com git+cmake [M]? ${SEM_COR}"
    read -r modo

    instalar_yay || { aviso "Sem yay não dá pra instalar quickshell/caelestia-cli (só existem no AUR)."; pausa; return 1; }

    if [[ "$modo" =~ ^[Rr]$ ]] || [[ -z "$modo" ]]; then
        info "Instalando caelestia-shell via AUR..."
        if sudo -u "$SUDO_USER" yay -S --needed --noconfirm caelestia-shell >> "$INSTALL_LOG" 2>&1; then
            sucesso "Caelestia Shell instalado via AUR com sucesso!"
        else
            erro "Falha ao instalar via AUR. Veja o log: $INSTALL_LOG"
            aviso "Tentando instalação manual como alternativa..."
            modo="M"
        fi
    fi

    if [[ "$modo" =~ ^[Mm]$ ]]; then
        info "Instalando dependências oficiais..."
        local deps_oficiais=("qt6-base" "qt6-declarative" "glibc" "gcc-libs" "bash" "libqalculate" "networkmanager" "lm_sensors" "fish" "aubio" "libpipewire" "ddcutil" "brightnessctl" "swappy")
        instalar_multiplos "${deps_oficiais[@]}"

        info "Instalando dependências do AUR (quickshell-git, caelestia-cli, fontes)..."
        instalar_pacote_universal "quickshell-git" "Quickshell (versão git, obrigatória)"
        instalar_pacote_universal "caelestia-cli" "Caelestia CLI"
        instalar_pacote_universal "libcava" "libcava"
        instalar_pacote_universal "ttf-material-symbols-variable-git" "Material Symbols"
        instalar_pacote_universal "ttf-caskaydia-cove-nerd" "Caskaydia Cove Nerd Font"

        if [ ${#FALTANTES_AUR[@]} -gt 0 ]; then
            erro "Não instalados: ${FALTANTES_AUR[*]}"
            aviso "Instale manualmente com: yay -S ${FALTANTES_AUR[*]}"
            pausa
        fi

        info "Clonando repositório em $caelestia_dir ..."
        if [ -d "$caelestia_dir" ]; then
            aviso "Diretório já existe. Removendo para reinstalar..."
            rm -rf "$caelestia_dir"
        fi
        sudo -u "$SUDO_USER" mkdir -p "$usuario_home/.config/quickshell"

        if sudo -u "$SUDO_USER" git clone https://github.com/caelestia-dots/shell.git "$caelestia_dir" >> "$INSTALL_LOG" 2>&1; then
            sucesso "Repositório clonado com sucesso!"
        else
            erro "Falha ao clonar repositório! Veja: $INSTALL_LOG"
            pausa
            return 1
        fi

        info "Compilando (log completo em $CAELESTIA_LOG)..."
        (
            cd "$caelestia_dir" || exit 1
            rm -rf build
            sudo -u "$SUDO_USER" cmake -B build -G Ninja \
                -DCMAKE_BUILD_TYPE=Release \
                -DCMAKE_INSTALL_PREFIX=/ \
                -DINSTALL_QSCONFDIR="$caelestia_dir" \
                > "$CAELESTIA_LOG" 2>&1 && \
            sudo -u "$SUDO_USER" cmake --build build >> "$CAELESTIA_LOG" 2>&1 && \
            cmake --install build >> "$CAELESTIA_LOG" 2>&1
        )

        if [ $? -eq 0 ]; then
            sucesso "Caelestia Shell compilado e instalado!"
            chown -R "$SUDO_USER":"$SUDO_USER" "$caelestia_dir"
        else
            erro "Falha ao compilar! Verifique o log:"
            echo -e "${VERMELHO}$CAELESTIA_LOG${SEM_COR}"
            echo -e "${AMARELO}Últimas linhas:${SEM_COR}"
            tail -n 20 "$CAELESTIA_LOG"
            pausa
            return 1
        fi
    fi

    chown -R "$SUDO_USER":"$SUDO_USER" "$usuario_home/.config/quickshell" 2>/dev/null || true
    sucesso "Etapa do Caelestia Shell concluída!"
    pausa
}

configurar_hyprland() {
    cabecalho
    echo -e "${VERDE}${NEGRITO}[9] CONFIGURANDO HYPRLAND${SEM_COR}\n"

    local usuario_home
    usuario_home=$(eval echo ~"${SUDO_USER}")
    local config_dir="$usuario_home/.config/hypr"

    if [ -f "$config_dir/hyprland.conf" ]; then
        aviso "Arquivo já existe. Criando backup..."
        cp "$config_dir/hyprland.conf" "$config_dir/hyprland.conf.bak"
    fi

    cat > "$config_dir/hyprland.conf" << 'EOF'
monitor=,preferred,auto,1

env = XCURSOR_SIZE,24
env = XCURSOR_THEME,default
env = QT_QPA_PLATFORM_PLUGIN_PATH,/usr/lib/qt6/plugins

input {
    kb_layout = br
    kb_variant = abnt2
    follow_mouse = 1
    touchpad {
        natural_scroll = true
    }
    sensitivity = 0
}

general {
    gaps_in = 5
    gaps_out = 20
    border_size = 2
    col.active_border = rgba(33ccffee)
    col.inactive_border = rgba(595959aa)
    layout = dwindle
    resize_on_border = true
}

decoration {
    rounding = 10
    blur = true
    blur_size = 4
    blur_passes = 2
    active_opacity = 1.0
    inactive_opacity = 0.95
    drop_shadow = true
    shadow_range = 15
    shadow_render_power = 3
}

animations {
    enabled = true
    bezier = myBezier, 0.05, 0.9, 0.1, 1.05
    animation = windows, 1, 10, myBezier
    animation = windowsOut, 1, 10, default, popin 80%
    animation = border, 1, 10, default
    animation = fade, 1, 10, default
    animation = workspaces, 1, 6, default
}

dwindle {
    pseudotile = true
    preserve_split = true
}

master {
    new_is_master = true
}

exec-once = dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP HYPRLAND_INSTANCE_SIGNATURE
exec-once = qs -c caelestia

bind = SUPER, Return, exec, foot
bind = SUPER, Q, killactive,
bind = SUPER, M, exit,
bind = SUPER, E, exec, thunar
bind = SUPER, Space, togglefloating,
bind = SUPER, F, fullscreen,
bind = SUPER, P, pseudo,
bind = SUPER, J, togglesplit,

bind = SUPER, left, movefocus, l
bind = SUPER, right, movefocus, r
bind = SUPER, up, movefocus, u
bind = SUPER, down, movefocus, d

bind = SUPER SHIFT, left, movewindow, l
bind = SUPER SHIFT, right, movewindow, r
bind = SUPER SHIFT, up, movewindow, u
bind = SUPER SHIFT, down, movewindow, d

bind = SUPER, 1, workspace, 1
bind = SUPER, 2, workspace, 2
bind = SUPER, 3, workspace, 3
bind = SUPER, 4, workspace, 4
bind = SUPER, 5, workspace, 5
bind = SUPER, 6, workspace, 6
bind = SUPER, 7, workspace, 7
bind = SUPER, 8, workspace, 8
bind = SUPER, 9, workspace, 9
bind = SUPER, 0, workspace, 10

bind = SUPER SHIFT, 1, movetoworkspace, 1
bind = SUPER SHIFT, 2, movetoworkspace, 2
bind = SUPER SHIFT, 3, movetoworkspace, 3
bind = SUPER SHIFT, 4, movetoworkspace, 4
bind = SUPER SHIFT, 5, movetoworkspace, 5
bind = SUPER SHIFT, 6, movetoworkspace, 6
bind = SUPER SHIFT, 7, movetoworkspace, 7
bind = SUPER SHIFT, 8, movetoworkspace, 8
bind = SUPER SHIFT, 9, movetoworkspace, 9
bind = SUPER SHIFT, 0, movetoworkspace, 10

bind = SUPER, mouse_down, workspace, e+1
bind = SUPER, mouse_up, workspace, e-1

bindm = SUPER, mouse:272, movewindow
bindm = SUPER, mouse:273, resizewindow
EOF

    chown "$SUDO_USER":"$SUDO_USER" "$config_dir/hyprland.conf"
    sucesso "Hyprland configurado!"

    sudo -u "$SUDO_USER" mkdir -p "$usuario_home/.config/foot"
    cat > "$usuario_home/.config/foot/foot.ini" << 'EOF'
[main]
term=xterm-256color
pad=10x10
font=Monospace:size=12
dpi-aware=yes

[colors]
background=1e1e2e
foreground=cdd6f4
EOF
    chown "$SUDO_USER":"$SUDO_USER" "$usuario_home/.config/foot/foot.ini"
    sucesso "Foot configurado!"
    pausa
}

fix_terminal() {
    cabecalho
    echo -e "${VERDE}${NEGRITO}[10] CORRIGINDO PROBLEMAS DO TERMINAL${SEM_COR}\n"
    local usuario_home
    usuario_home=$(eval echo ~"${SUDO_USER}")
    instalar_pacote "foot" "Emulador de Terminal Foot"

    if [ -f "$usuario_home/.config/hypr/hyprland.conf" ]; then
        sed -i 's/exec, kitty/exec, foot/g' "$usuario_home/.config/hypr/hyprland.conf"
        sed -i 's/exec, alacritty/exec, foot/g' "$usuario_home/.config/hypr/hyprland.conf"
        sucesso "Configurações corrigidas!"
    fi

    chown -R "$SUDO_USER":"$SUDO_USER" "$usuario_home/.config/hypr"
    sucesso "Problemas de terminal corrigidos!"
    pausa
}

setup_caelestia() {
    cabecalho
    echo -e "${VERDE}${NEGRITO}[11] INICIANDO CAELESTIA SHELL${SEM_COR}\n"
    info "Verificando se o Quickshell (qs) está instalado..."

    if command -v qs &> /dev/null; then
        sucesso "Quickshell detectado!"
        aviso "Para aplicar o tema, rode (como usuário normal): qs -c caelestia"
        aviso "Ou reinicie o Hyprland: Super + Shift + R"
    else
        erro "Quickshell (qs) não foi detectado!"
        aviso "Rode a opção [8] para instalar, ou [15] para diagnóstico."
    fi
    pausa
}

criar_script_atalho() {
    cabecalho
    echo -e "${VERDE}${NEGRITO}[12] CRIANDO SCRIPT DE ATALHO${SEM_COR}\n"
    local usuario_home
    usuario_home=$(eval echo ~"${SUDO_USER}")
    sudo -u "$SUDO_USER" mkdir -p "$usuario_home/.local/bin"

    cat > "$usuario_home/.local/bin/iniciar-caelestia.sh" << 'EOF'
#!/bin/bash
echo "🚀 Iniciando Caelestia Shell..."
qs -c caelestia
if [ $? -eq 0 ]; then
    echo "✓ Caelestia ativado com sucesso!"
else
    echo "✗ Erro ao iniciar Caelestia"
    echo "Rode 'sudo bash install.sh' e escolha a opção [15] Diagnóstico Completo."
fi
EOF
    chmod +x "$usuario_home/.local/bin/iniciar-caelestia.sh"
    chown "$SUDO_USER":"$SUDO_USER" "$usuario_home/.local/bin/iniciar-caelestia.sh"
    sucesso "Script criado em ~/.local/bin/iniciar-caelestia.sh"
    pausa
}

verificacao_final() {
    cabecalho
    echo -e "${VERDE}${NEGRITO}[13] VERIFICAÇÃO FINAL${SEM_COR}\n"
    local pacotes=("hyprland" "foot" "alacritty" "rofi" "dunst" "networkmanager")
    local todos_ok=true
    for pacote in "${pacotes[@]}"; do
        if pacman -Qi "$pacote" &> /dev/null; then
            sucesso "$pacote instalado"
        else
            erro "$pacote NÃO encontrado"
            todos_ok=false
        fi
    done
    [ "$todos_ok" = true ] && echo -e "${VERDE}${NEGRITO}✓ TUDO PRONTO!${SEM_COR}" || aviso "Alguns pacotes faltam."
    pausa
}

resumo_final() {
    cabecalho
    echo -e "${VERDE}${NEGRITO}🎉 INSTALAÇÃO CONCLUÍDA!${SEM_COR}\n"
    echo -e "  ${VERDE}✓${SEM_COR} Hyprland, drivers, PipeWire, terminais, ferramentas, Caelestia Shell"
    echo ""
    echo -e "  ${AMARELO}1.${SEM_COR} Reinicie sua sessão: ${ROXO}Super + Shift + R${SEM_COR}"
    echo -e "  ${AMARELO}2.${SEM_COR} Ative o Caelestia: ${ROXO}qs -c caelestia${SEM_COR}"
    echo -e "  ${AMARELO}3.${SEM_COR} Logs em: ${ROXO}$LOG_DIR${SEM_COR}"
    pausa
}

diagnostico_completo() {
    cabecalho
    echo -e "${VERDE}${NEGRITO}[15] DIAGNÓSTICO COMPLETO${SEM_COR}\n"
    local usuario_home
    usuario_home=$(eval echo ~"${SUDO_USER}")

    declare -A checks
    checks["Hyprland"]="pacman -Qi hyprland"
    checks["Wayland"]="pacman -Qi wayland"
    checks["Qt6 base"]="pacman -Qi qt6-base"
    checks["Qt6 declarative"]="pacman -Qi qt6-declarative"
    checks["Mesa/Vulkan"]="pacman -Qi mesa"
    checks["PipeWire"]="pacman -Qi pipewire"
    checks["Quickshell (qs)"]="command -v qs"
    checks["Caelestia CLI"]="command -v caelestia"
    checks["Fish"]="pacman -Qi fish"
    checks["Rofi"]="pacman -Qi rofi"
    checks["Foot"]="pacman -Qi foot"
    checks["Dunst"]="pacman -Qi dunst"
    checks["Polkit"]="pacman -Qi polkit"
    checks["seatd"]="pacman -Qi seatd"
    checks["NetworkManager"]="pacman -Qi networkmanager"
    checks["yay"]="command -v yay"

    local faltando=()
    echo -e "${CIANO}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${SEM_COR}"
    for nome in "${!checks[@]}"; do
        if eval "${checks[$nome]}" &> /dev/null; then
            printf "  %-22s ${VERDE}✓${SEM_COR}\n" "$nome"
        else
            printf "  %-22s ${VERMELHO}✗${SEM_COR}\n" "$nome"
            faltando+=("$nome")
        fi
    done
    echo -e "${CIANO}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${SEM_COR}"

    if [ -d "$usuario_home/.config/quickshell/caelestia" ]; then
        sucesso "Diretório do Caelestia encontrado em ~/.config/quickshell/caelestia"
    else
        erro "Diretório do Caelestia NÃO encontrado"
        faltando+=("Diretório caelestia")
    fi

    if [ ${#faltando[@]} -eq 0 ]; then
        echo -e "${VERDE}${NEGRITO}Tudo certo!${SEM_COR}"
    else
        aviso "Itens faltando: ${faltando[*]}"
        info "Logs: $INSTALL_LOG / $CAELESTIA_LOG"
    fi
    pausa
}

menu_principal() {
    while true; do
        cabecalho
        echo -e "${CIANO}${NEGRITO}Escolha uma opção:${SEM_COR}\n"
        echo -e "  ${VERDE}[1]${SEM_COR}  Setup Inicial"
        echo -e "  ${VERDE}[2]${SEM_COR}  Instalar Dependências Básicas"
        echo -e "  ${VERDE}[3]${SEM_COR}  Instalar Hyprland"
        echo -e "  ${VERDE}[4]${SEM_COR}  Instalar Drivers Gráficos (auto-detecção)"
        echo -e "  ${VERDE}[5]${SEM_COR}  Instalar PipeWire"
        echo -e "  ${VERDE}[6]${SEM_COR}  Instalar Terminais"
        echo -e "  ${VERDE}[7]${SEM_COR}  Instalar Ferramentas de Sistema"
        echo -e "  ${VERDE}[8]${SEM_COR}  Instalar Caelestia Shell (corrigido)"
        echo -e "  ${VERDE}[9]${SEM_COR}  Configurar Hyprland"
        echo -e "  ${VERDE}[10]${SEM_COR} Fix Terminal"
        echo -e "  ${VERDE}[11]${SEM_COR} Setup Caelestia Shell"
        echo -e "  ${VERDE}[12]${SEM_COR} Criar Script de Atalho"
        echo -e "  ${VERDE}[13]${SEM_COR} Verificação Final"
        echo -e "  ${VERDE}[14]${SEM_COR} Resumo e Próximos Passos"
        echo -e "  ${VERDE}[15]${SEM_COR} Diagnóstico Completo"
        echo -e "  ${VERDE}[99]${SEM_COR} Executar Tudo (Recomendado)"
        echo -e "  ${VERDE}[0]${SEM_COR}  Sair"
        echo ""
        echo -ne "${AMARELO}Digite a opção: ${SEM_COR}"
        read -r opcao

        case $opcao in
            1)  setup_inicial ;;
            2)  instalar_dependencias_basicas ;;
            3)  instalar_hyprland ;;
            4)  instalar_drivers ;;
            5)  instalar_audio ;;
            6)  instalar_terminais ;;
            7)  instalar_ferramentas_sistema ;;
            8)  instalar_caelestia ;;
            9)  configurar_hyprland ;;
            10) fix_terminal ;;
            11) setup_caelestia ;;
            12) criar_script_atalho ;;
            13) verificacao_final ;;
            14) resumo_final ;;
            15) diagnostico_completo ;;
            99)
                setup_inicial; instalar_dependencias_basicas; instalar_hyprland
                instalar_drivers; instalar_audio; instalar_terminais
                instalar_ferramentas_sistema; instalar_caelestia; configurar_hyprland
                criar_script_atalho; verificacao_final; diagnostico_completo; resumo_final
                ;;
            0)
                cabecalho
                echo -e "${VERDE}${NEGRITO}Saindo...${SEM_COR}"
                exit 0
                ;;
            *)
                erro "Opção inválida!"
                sleep 1.5
                ;;
        esac
    done
}

main() {
    verificar_root
    menu_principal
}

main "$@"
