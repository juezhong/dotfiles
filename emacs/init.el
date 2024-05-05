;; (setq inhibit-startup-screen t) ;; close the startup screen
;; (scroll-bar-mode -1) ;; disable visible scrollbar
;; (tool-bar-mode -1)   ;; disable the toolbar
;; (tooltip-mode -1)    ;; disable tooltips
;; (set-fringe-mode 10) ;; give some breathing room
;; (menu-bar-mode -1)   ;; disable the menu bar
;; (setq visible-bell t) ;; set the visible bell
;; (load-theme 'tango-dark)

;; (global-set-key (kbd "<f12>") (kbd "C-x C-e"))
;; (global-set-key (kbd "<f11>") (kbd "C-u C-x C-e"))
;; (defun liyunfeng/open-my-config ()
;; 	"Open my init.el file"
;; 	(interactive)
;; 	(find-file "~/.emacs.d/init.el")
;; 	)
;; (global-set-key (kbd "<f10>") 'liyunfeng/open-my-config)
;; (global-set-key (kbd "<f10>") (lambda () (interactive) (find-file "~/.emacs.d/init.el")))

;; ;; 单引号的意思是按字面意思理解——将其视为某物的名称。如果您删除 emacs-lisp-mode-hook 中的引号，Emacs 将查找该变量中的值并将其用作实际设置的变量名称，您可能会收到错误。
;; ;;(setq myname "liyunfeng");; equal below expression
;; ;;(set 'myname "liyunfeng");; set myname="liyunfeng"
;; ;;(message myname);; use myname value, not myname string
;; ;; setq 代表“设置引用”。这实际上与 (set 'delete-old-versions -1) 或 (set (quote delete-old-versions) -1) 相同的代码，但 setq 更短，因此更常见。
;; ;;(setq visible-bell nil)
;; (setq column-number-mode t)
;; (setq-default tab-width 2)
;; (setq-default indicate-empty-lines t)
;; (setq-default show-trailing-whitespace t)
;; ;; (setq debug-on-error t)

;; ;; website: https://emacslife.com/how-to-read-emacs-lisp.html
;; ;; 钩子是函数列表，通过Emacs Lisp调用以修改某些功能的行为。例如，不同的模式有它们自己的钩子，这样您就可以在初始化该模式时添加要运行的函数。您之前在模块中看到了这个例子。
;; (add-hook 'emacs-lisp-mode-hook 'turn-on-eldoc-mode)
;; ;; (remove-hook 'emacs-lisp-mode-hook 'turn-on-eldoc-mode)





;; (custom-set-variables
;;  ;; custom-set-variables was added by Custom.
;;  ;; If you edit it by hand, you could mess it up, so be careful.
;;  ;; Your init file should contain only one such instance.
;;  ;; If there is more than one, they won't work right.
;;  '(tramp-default-method "sftp"))
;; (custom-set-faces
;;  ;; custom-set-faces was added by Custom.
;;  ;; If you edit it by hand, you could mess it up, so be careful.
;;  ;; Your init file should contain only one such instance.
;;  ;; If there is more than one, they won't work right.
;;  )
;; ================ self configuration
;; ================ Youtuber System Crafters configuration
(global-set-key (kbd "<f12>") (kbd "C-x C-e"))
(global-set-key (kbd "<f11>") (kbd "C-u C-x C-e"))
(defun liyunfeng/open-my-config ()
	"Open my init.el file"
	(interactive)
	(find-file "~/.emacs.d/init.el")
	)
(global-set-key (kbd "<f10>") 'liyunfeng/open-my-config)
(global-set-key (kbd "<f10>") (lambda () (interactive) (find-file "~/.emacs.d/init.el")))
(global-set-key (kbd "<f9>") 'set-variable)
(defun liyunfeng/check-pointer (info)
  (message ">>> [INFO] CHECK %s" info))




(setq inhibit-startup-message t)

; Disable visible scrollbar
(scroll-bar-mode -1)
; Disable the toolbar
(tool-bar-mode 1)
; Disable tooltips
(tooltip-mode -1)
; Give some breathing room
(set-fringe-mode 10)

; Disable the menu bar
(menu-bar-mode 1)


;; Set up the visible bell
(setq visible-bell t)


;; font set size
;;(set-face-attribute 'default nil :height 105)
(set-face-attribute 'default nil :font "MesloLGM Nerd Font Mono" :height 113)
;; (set-face-attribute 'default nil :font "Fira Code Retina" :height 280)


;;(load-theme 'tango-dark)

;; set column number
;; status line will show 81:28, not L81
(column-number-mode)
;; show line number
(global-display-line-numbers-mode t)
;; disable line numbers for some modes
(dolist (mode '(org-mode-hook
		shell-mode-hook
		term-mode-hook
		shell-mode-hook))
        (add-hook mode (lambda () (display-line-numbers-mode 0))))

;; test add hook
;; 添加在初始化该模式时运行的函数。应该是在进入该模式之前被调用。
;; Hook run when entering Lisp Interaction mode.
;;(add-hook 'lisp-interaction-mode-hook (lambda () (message "set elisp mode hook in init.el file.")))
;; (defun add-to-lisp-interaction-mode-hook-func ()
;;   (interactive)
;;   (message "set lisp interaction mode hook func"))
;; (add-hook 'lisp-interaction-mode-hook 'add-to-lisp-interaction-mode-hook-func)

;; set proxy
(setq url-proxy-services
      '(("http"  . "192.168.123.1:10809")
	("https" . "192.168.123.1:10809")))




;; Make ESC quit prompts
(global-set-key (kbd "<escape>") 'keyboard-escape-quit)

;; Initialize package sources
(require 'package)

(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("org" . "https://orgmode.org/elpa/")
                         ("elpa" . "https://elpa.gnu.org/packages/")))

(package-initialize)
(unless package-archive-contents
 (package-refresh-contents))

;; Initialize use-package on non-Linux platforms
(unless (package-installed-p 'use-package)
   (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

;; minibuffer extension
(use-package ivy
  :diminish
;;  :bind (("C-s" . swiper)
         ;; :map ivy-minibuffer-map
         ;; ("TAB" . ivy-alt-done)	
         ;; ("C-l" . ivy-alt-done)
         ;; ("C-j" . ivy-next-line)
         ;; ("C-k" . ivy-previous-line)
         ;; :map ivy-switch-buffer-map
         ;; ("C-k" . ivy-previous-line)
         ;; ("C-l" . ivy-done)
         ;; ("C-d" . ivy-switch-buffer-kill)
         ;; :map ivy-reverse-i-search-map
         ;; ("C-k" . ivy-previous-line)
         ;; ("C-d" . ivy-reverse-i-search-kill))
  :config
  (ivy-mode 1))

;; ivy-rich show more(extra) information, like function, variable describe
;; seems need counsel package
(use-package counsel
  :bind (("M-x" . counsel-M-x)
	 ("C-x b" . counsel-ibuffer)
	 ("C-x C-f" . counsel-find-file)
	 :map minibuffer-local-map
	 ("C-r" . 'counsel-minibuffer-history)
	 ))
(use-package ivy-rich
  :init
  (ivy-rich-mode 1))

;; ;; set global key about counsel command
;; (global-set-key (kbd "C-M-b") 'counsel-switch-buffer)
;; ;; remap C-x b to counsel switch buffer, for preview buffer content
;; ;;(global-set-key (kbd "C-x b") 'counsel-switch-buffer)
;; ;; The above method is not universal, look here!!
;; ;; set key maps that use in specific mode(some majar, minor mode)
;; ;; define-key is for setting a key in a specific keymap,
;; ;;    Documentation
;; ;;    In KEYMAP, define key sequence KEY as DEF.
;; ;;    !!! define-key is a legacy function; see keymap-set for the recommended function to use instead.
;; ;; (define-key global-map (kbd "C-x b") 'counsel-switch-buffer)
;; ;;    Signature
;; ;;    (keymap-set KEYMAP KEY DEFINITION)
;; ;;    Documentation
;; ;;    Set KEY to DEFINITION in KEYMAP.
;; (keymap-set emacs-lisp-mode-map "C-c C-t" 'counsel-load-theme)
;; ;; the code above is the same as:
;; ;; (define-key emacs-lisp-mode-map (kbd "C-c C-t") 'counsel-load-theme)
;; ;;(keymap-set global-map "C-x b" 'counsel-switch-buffer)
(keymap-set global-map "C-M-b" 'counsel-switch-buffer)
;; !!! The above content is usually replaced by the functions of the general package. !!!
;; see General Package





;; icons for doom modeline
;; if the first time install, need to run the following command
;; interactively so that mode line icons display correctly:
;; M-x all-the-icons-install-fonts
(use-package all-the-icons)
(use-package doom-modeline
  :ensure t
  :init (doom-modeline-mode 1)
  :custom ((doom-modeline-height 15)))


;; custom modeline size
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(mode-line ((t (:family "MesloLGM Nerd Font Mono" :height 1.0))))
 '(mode-line-active ((t (:family "MesloLGM Nerd Font Mono" :height 1.0))))
 '(mode-line-inactive ((t (:family "MesloLGM Nerd Font Mono" :height 1.0)))))
;; set modeline icon size
(setq nerd-icons-scale-factor 1.5)




(use-package doom-themes
  :init
  (load-theme 'doom-horizon t))
;; doom-horizon
;; doom-vibrant
;; doom-material
;; doom-material-dark
;;(load-theme 'doom-horizon 1)

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

;;(use-package atom-one-dark-theme)

;;(load-theme 'atom-one-dark 1)

;; which-key
(use-package which-key
  :init (which-key-mode)
  :diminish which-key-mode
  :config
  (setq which-key-idle-delay 0.3))

;; enhance help page
(use-package helpful
  :custom
  (counsel-describe-function-function #'helpful-callable)
  (counsel-describe-variable-function #'helpful-variable)
  :bind
  ([remap describe-function] . counsel-describe-function)
  ([remap describe-command] . helpful-command)
  ([remap describe-variable] . counsel-describe-variable)
  ([remap describe-key] . helpful-key))


;; general define keymaps
(use-package general
  :config
  (general-evil-setup t)
  ;; Easier way, use General Package to define key bindings
  ;; (general-define-key "C-M-b" 'counsel-switch-buffer)
  ;; another way that define key with prefix key, more commonly used than above method.
  (general-create-definer liyunfeng/leader-keys
    :keymaps '(normal insert visual emacs)
    ;; :prefix my-leader-key
    ;; need set my-leader-key variable
    ;; (setq my-leader-key "SPC")
    ;; or without a variable
    ;; :prefix "SPC"
    ;; :global-prefix "C-SPC")
    :prefix ","
    :global-prefix "C-,")
  ;; ** Global Keybindings
;;;; Don't repeat definitions.
  ;; (liyunfeng/leader-keys
  ;;   "t" 'counsel-load-theme)
  ;; (liyunfeng/leader-keys
  ;;   "a" 'org-agenda
  ;;   "b" 'counsel-bookmark
  ;;   "c" 'org-capture)

  ;; ** Mode Keybindings
;;;; Don't repeat definitions.
  (liyunfeng/leader-keys
    :keymap global-map
    ;;"t" 'counsel-load-theme
    "t"  '(:ignore t :which-key "toggles")
    "tt" '(counsel-load-theme :which-key "choose theme"))
  ;; (my-leader-def
  ;;   :keymaps 'clojure-mode-map
  ;;   ;; bind "C-c C-l"
  ;;   "C-l" 'cider-load-file
  ;;   "C-z" 'cider-switch-to-repl-buffer)
  ;; general-create-definer creates wrappers around general-def, so
  ;; define-key-like syntax is also supported
;;;; Don't repeat definitions.
  ;; (liyunfeng/leader-keys global-map
  ;;   "t" 'counsel-load-theme)
  ;; (my-leader-def clojure-mode-map
  ;;   "C-l" 'cider-load-file
  ;;   "C-z" 'cider-switch-to-repl-buffer)
  )
;; Youtuber Evil mode example, already same as above, delete it.
;; hydra 定义一组即时（临时）的按键绑定，快速重复相同的动作，不必多次按下重复前缀键
;; 对于要多次重复/循环执行的命令更有效
(use-package hydra)

(defhydra hydra-text-scale (:timeout 3)
	  "scale text"
	  ("i" text-scale-increase "inc")
	  ("d" text-scale-decrease "dec")
	  ("f" nil "finished" :exit t))
;; add bindings to general-definer
(liyunfeng/leader-keys
  "ts" '(hydra-text-scale/body :which-key "scale text"))



;; 任何时候都自动在 emacs 状态下启动，而不是 evil 的 normal 模式。
;; the evil-emacs-state-modes list is 应在 Emacs 状态下出现的模式。
;; can press C-z switch state
(defun liyunfeng/evil-hook ()
  (dolist (mode '(custom-mode
		  eshell-mode
		  ;;help-mode
		  helpful-mode))
    (add-to-list 'evil-emacs-state-modes mode)
    ;; (liyunfeng/check-pointer "in evil-hook func")
    ))
;; (setq start-with-emacs-mode '(custom-mode
;; 			      eshell-mode
;; 			      help-mode))
;; 找出了 BUG 是要添加的 mode 要存在才能被找到
;; 基础的问题，也就是说想用某种 mode 需要先 require 对应的 package，因为 package 里面才提供(provide)了 xxxx-mode
;; (defun liyunfeng/evil-hook (mode-lists)
;;   (dolist (mode mode-lists)
;;     (add-to-list 'evil-emacs-state-modes mode)
;;     ;; (liyunfeng/check-pointer "in evil-hook func")
;;     ))
;;(liyunfeng/evil-hook start-with-emacs-mode)



;; so this is why i prefer to use vim key bindings for editing inside of buffers
;; and then use emacs keybindings for other things
(use-package evil
  :init
  (setq evil-want-integation t)
  (setq evil-want-keybinding nil)
  (setq evil-want-C-u-scroll t)
  (setq evil-want-C-i-jump nil)
  (liyunfeng/check-pointer "in evil init")
  ;; in :init manual add hook
  ;;(add-hook 'evil-mode-hook 'liyunfeng/evil-hook) ;; has evil-collection package, don't need again
  :config
  (liyunfeng/check-pointer "in evil config")
  (evil-mode 1)
  ;; quit to normal state
  (keymap-set evil-insert-state-map "C-g" 'evil-normal-state)
  ;; (define-key evil-insert-state-map (kbd "C-g") 'evil-normal-state)
  ;; set C-h bind Backspace key
  ;;(keymap-set evil-insert-state-map "C-h" 'evil-delete-backward-char-and-join)

  ;; Use visual line motions even outeside of visual-line-mode buffers
  (evil-global-set-key 'motion "j" 'evil-next-visual-line)
  (evil-global-set-key 'motion "k" 'evil-previous-visual-line)

  ;; set initial state for different mode
  (evil-set-initial-state 'message-buffer-mode 'normal)
  (evil-set-initial-state 'dashboard-mode 'normal)
;;  :hook (evil-mode . liyunfeng/evil-hook)
;;  :hook (evil-mode . (lambda () message "in evil hook lambda"))
  )

;; 用于默认情况下 Evil 未正确覆盖的 Emacs 部分，例如 help-mode 、 M-x calendar 、 Eshell 等。
;; 解决了不能按 q 退出的问题，不需要添加 hook 的预设了。
(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))












(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(hydra evil-collection which-key rainbow-delimiters ivy-rich helpful general evil doom-themes doom-modeline counsel atom-one-dark-theme all-the-icons)))
