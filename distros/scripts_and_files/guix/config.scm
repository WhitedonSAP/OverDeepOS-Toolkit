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
             (gnu services sddm)
             (gnu services xorg)
             (guix channels)
             (guix gexp)
             (nongnu packages linux)
             (nongnu packages nvidia)
             (nongnu system linux-initrd)
             (nonguix transformations))

(use-service-modules desktop networking sddm ssh xorg)

(define %my-os
  (operating-system
    (host-name "gnuguix")
    (locale "pt_BR.utf8")
    (keyboard-layout (keyboard-layout "br"))
    (timezone "America/Sao_Paulo")
    (kernel linux)
    (initrd microcode-initrd)
    (firmware (cons* amd-microcode
                     linux-firmware
                     nvidia-firmware
                %base-firmware))

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
     (cons* (service sddm-service-type
             (sddm-configuration
               (display-server "x11")
               (theme "breeze")))
            (service plasma-desktop-service-type)
            (service bluetooth-service-type)
            (modify-services %desktop-services
              (delete gdm-service-type)
              (guix-service-type config => (guix-configuration
               (inherit config)
               (substitute-urls
                (cons* "https://substitutes.nonguix.org"
                   %default-substitute-urls))
               (authorized-keys
                (cons* (plain-file "non-guix.pub"
                                   "(public-key (ecc
                                                 (curve Ed25519)
                                                 (q #C1FD53E5D4CE971933EC50C9F307AE2171A2D3B52C804642A7A35F84F3A4EA98#)))")
                                      %default-authorized-guix-keys)))))))

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

((nonguix-transformation-nvidia #:driver nvda-595
                                #:open-source-kernel-module? #f
                                #:kernel-mode-setting? #t
                                #:configure-xorg? sddm-service-type
                                #:remove-nvenc-restriction? #f)
 %my-os)
