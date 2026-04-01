;; Esta é uma configuração do sistema operacional
;; gerada pelo instalador gráfico.
;;
;; Quando a instalação estiver completa, você pode
;; ler e modificar esse arquivo para ajustar a configuração
;; do sistema, e usar o comando 'guix system reconfigure'
;; para aplicar suas mudanças.


;; Indica quais módulos importar para acessar as variáveis
;; usadas nessa configuração.
(use-modules (gnu)
             (nongnu packages linux)
             (nongnu system linux-initrd)
             (nonguix transformations))
(use-service-modules cups desktop networking ssh xorg)

(define %my-os
  (operating-system
    (kernel linux)
    (initrd microcode-initrd)
    (firmware (list linux-firmware))
    (locale "pt_BR.utf8")
    (timezone "America/Sao_Paulo")
    (keyboard-layout (keyboard-layout "br"))
    (host-name "gnuguix")

    ;; A lista de contas de usuário ('root' está implícito).
    (users (cons* (user-account
                    (name "whitedon")
                    (comment "Whitedon")
                    (group "users")
                    (home-directory "/home/whitedon")
                    (supplementary-groups '("wheel" "netdev" "audio" "video")))
                  %base-user-accounts))

    ;; Abaixo está a lista de serviços do sistema. Para procurar por serviços
    ;; disponíveis, execute 'guix system search PALAVRA-CHAVE' em um terminal.
    (services
     (append (list (service gnome-desktop-service-type)
                   (set-xorg-configuration
                    (xorg-configuration (keyboard-layout keyboard-layout))))

             ;; Essa é a lista padrão de serviços na
             ;; qual estamos adicionando.
             %desktop-services))
    (bootloader (bootloader-configuration
                  (bootloader grub-efi-bootloader)
                  (targets (list "/boot/efi"))
                  (keyboard-layout keyboard-layout)))

    ;; A lista de sistemas de arquivos que são "montados". Os identificadores
    ;; únicos de sistema de arquivos ("UUIDs") podem ser obtidos
    ;; executando o comando 'blkid' em um terminal.
    (file-systems (cons* (file-system
                           (mount-point "/")
                           (device (uuid
                                    "4fd13976-cfef-460c-82d9-4ab5c193622a"
                                    'ext4))
                           (type "ext4"))
                         (file-system
                           (mount-point "/boot/efi")
                           (device (uuid "2F3C-1AF9"
                                         'fat32))
                           (type "vfat")) %base-file-systems))))
((compose (nonguix-transformation-nvidia))
  %my-os)
