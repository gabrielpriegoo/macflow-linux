# macflow

Dock com ampliacao e Spotlight para KDE Plasma (Wayland), em Quickshell/QML.
Visual inspirado no tema "Lord Flow" do LordOS (medidas observadas; codigo proprio).

## Instalar (CachyOS)
    sudo pacman -S quickshell wl-clipboard ttf-inter
    mkdir -p ~/.config/quickshell && cp -r . ~/.config/quickshell/macflow
    qs -c macflow            # testar

## Atalho do Spotlight
Configuracoes do Sistema > Atalhos > Adicionar comando:
    qs -c macflow ipc call spotlight toggle     (Meta+Espaco)

## Autostart
Configuracoes > Inicializacao e Desligamento > Adicionar: `qs -c macflow`
Para usar so a dock do macflow, remova ou oculte o painel do Plasma.

## Ajustes
Tudo em modules/Theme.qml: tamanho da dock, ampliacao, apps fixos, cores.
