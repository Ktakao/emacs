;;; Startup settings
;; Load cl-lib package
(require 'cl-lib)
;; Laod generic mode
(require 'generic-x)
;; Answer question from emacs with y/n
(fset 'yes-or-no-p 'y-or-n-p)
;; Hide startup message
(setq inhibit-startup-screen t)
;; Make sure to check at the end
(setq confirm-kill-emacs 'yes-or-no-p)

;;; Make directory for Elisp
;; Define function to add load-path
(defun add-to-load-path (&rest paths)
  (let (path)
    (dolist (path paths paths)
      (let ((default-directory
              (expand-file-name (concat user-emacs-directory path))))
        (add-to-list 'load-path default-directory)
        (if (fboundp 'normal-top-level-add-subdirs-to-load-path)
            (normal-top-level-add-subdirs-to-load-path))))))
;; Add sub-directory to load-path
(add-to-load-path "elisp" "conf" "public_repos")
;; Define function to add spec
(defun my-lisp-load (filename)
  "Load lisp from FILENAME"
  (let ((fullname (expand-file-name (concat "pref/" filename) user-emacs-directory))
        lisp)
    (when (file-readable-p fullname)
      (with-temp-buffer
        (progn
          (insert-file-contents fullname)
          (setq lisp
                (condition-case nil
                    (read (current-buffer))
                  (error ()))))))
    lisp))
;;; Add other ELPA repository
(require 'package)
(add-to-list
 'package-archives
 '("melpa" . "http://melpa.milkbox.net/packages/"))
(add-to-list
 'package-archives
 '("marmalade" . "http://marmalade-repo.org/packages/"))
(package-initialize)
;; Load latest package list
(when (not package-archive-contents)
  (package-refresh-contents))

;;; Branch CUI and GUI
;; Setting for GUI
(when window-system
  ;; Hide tool-bar
  (tool-bar-mode 0)
  ;; Hide scroll-bar
    (scroll-bar-mode 0))
;; Hide menu bar except for CocoaEmacs
(unless (eq window-system 'ns)
  ;; Hide menu-bar
  (menu-bar-mode 0))

;;; Replace C-h with backspace
;; Replace incoming key sequence
(keyboard-translate ?\C-h ?\C-?)

;;; Assign newline-and-indent to C-m
(global-set-key (kbd "C-m") 'newline-and-indent)
;; Wrap toggle command
(define-key global-map (kbd "C-c l") 'toggle-truncate-lines)
;; Switch window with C-t
(define-key global-map (kbd "C-t") 'other-window)

;;; Setting path
(add-to-list 'exec-path "/opt/local/bin")
(add-to-list 'exec-path "/usr/local/bin")
(add-to-list 'exec-path "~/bin")

;;; Settings related to the mode line
;; Display culumn number
(column-number-mode t)
;; Display file size
(size-indication-mode t)
;; Display date
(setq display-time-24hr-format t) ; 24hours
(display-time-mode t)
;; Display battery level
(display-battery-mode t)
;; Display the number of lines and characters in the region on the mode line
(defun count-lines-and-chars ()
  (if mark-active
      (format "%d lines,%d chars "
              (count-lines (region-beginning) (region-end))
              (- (region-end) (region-beginning)))
    ""))
;; Removed default-* from emacs26*, so set value
(if (string-match "26" emacs-version)
    (setq default-mode-line-format (default-value 'mode-line-format)))
(add-to-list 'default-mode-line-format
             '(:eval (count-lines-and-chars)))
;; Display full-file-path in title bar
(setq frame-title-format "%f")
;; Display line number
(global-linum-mode t)

;;; Settings indent
;; Tab characters display. default 8
(setq-default tab-width 4)
;; Don't use tab characters for indent
(setq-default indent-tabs-mode nil)
;; Indent
(add-hook 'c-mode-common-hook
          '(lambda ()
             (c-set-style "cc-mode")))

;;; Highlight current line
(defface my-hl-line-face
  ;; If the background is dark, set the background color to dark blue
  '((((class color) (background dark))
     (:background "NavyBlue" t))
    ;; If the background is light, set the background color to green
    (((class color) (background light))
     (:background "LightGoldenrodYellow" t))
    (t (:bold t)))
  "hl-line's my face")
(setq hl-line-face 'my-hl-line-face)
(global-hl-line-mode t)

;;; : Parentheses correspondence highlights
;; paren-mode
(setq show-paren-delay 0)
(show-paren-mode t)
;; paren-mode style
(setq show-paren-style 'expression)
;; Change face
(set-face-attribute 'show-paren-match nil
      :background 'unspecified)
(set-face-background 'show-paren-match nil)
(set-face-underline-p 'show-paren-match "yellow")

;;; Settings backups and autosave
(setq make-backup-files t)
;; Collect backup and autosave files to ~/.emacs.d/backups
(add-to-list 'backup-directory-alist
             (cons "." "~/.emacs.d/backups/"))
(setq auto-save-file-name-transforms
      `((".*" ,(expand-file-name "~/.emacs.d/backups/") t)))
;; Second interval until auto save file is created
(setq auto-save-timeout 15)
;; Type interval until auto save file creation
(setq auto-save-interval 60)
;;; Automatic file updates
(global-auto-revert-mode t)

;;; hook
;; If the file starts with #!, save it with +x
(add-hook 'after-save-hook
          'executable-make-buffer-file-executable-if-script-p)
;; Define function for emacs-lisp-mode-hook
(defun elisp-mode-hooks ()
  "lisp-mode-hooks"
  (when (require 'eldoc nil t)
    (setq eldoc-idle-delay 0.2)
    (setq eldoc-echo-area-use-multiline-p t)
    (turn-on-eldoc-mode)))
;; Set hook for emacs-lisp-mode
(add-hook 'emacs-lisp-mode-hook 'elisp-mode-hooks)

;;; Use custom theme
(package-install 'atom-one-dark-theme)
(load-theme 'atom-one-dark t)

;;; popwin
(package-install 'popwin)
(require 'popwin)
(popwin-mode 1)
(setq pop-up-windows nil)
(setq anything-samewindow nil)

;;; Helm
(package-install 'helm)
;; Helm
(require 'helm-config)

;;; helm-show-kill-ring
;; Assign helm-show-kill-ring to M-y
(define-key global-map (kbd "M-y") 'helm-show-kill-ring)

;;; helm-c-moccur
(package-install 'helm-c-moccur)
(when (require 'helm-c-moccur nil t)
  (setq
   helm-idle-delay 0.1
   ;; for helm-c-moccur `helm-idle-delay'
   helm-c-moccur-helm-idle-delay 0.1
   ;; Highlight buffer information
   helm-c-moccur-higligt-info-line-flag t
   ;; Display the position of the currently selected candidate in another window
   helm-c-moccur-enable-auto-look-flag t
   ;; Set the word at point to the initial pattern at startup
   helm-c-moccur-enable-initial-pattern t)
  ;; Assign helm-c-moccur-occur-by-moccur to C-M-o
  (global-set-key (kbd "C-M-o") 'helm-c-moccur-occur-by-moccur))

;;; Auto Complete Mode
(package-install 'auto-complete)
;;; enable auto-complete-mode
(when (require 'auto-complete-config nil t)
  (define-key ac-mode-map (kbd "M-TAB") 'auto-complete)
  (ac-config-default)
  (setq ac-use-menu-map t)
  (setq ac-ignore-case nil))

;;; color-moccur
(when (require 'color-moccur nil t)
  ;; Assign occur-by-moccur to M-o
  (define-key global-map (kbd "M-o") 'occur-by-moccur)
  ;; AND search with space delimiter
  (setq moccur-split-word t)
  ;; Files excluded during directory search
  (add-to-list 'dmoccur-exclusion-mask "\\.DS_Store")
  (add-to-list 'dmoccur-exclusion-mask "^#.+#$"))

;;; moccur-edit
(package-install 'moccur-edit)
(require 'moccur-edit nil t)
;; Save file at the same time as moccur-edit-finish-edit
(defadvice moccur-edit-change-file
  (after save-after-moccur-edit-buffer activate)
  (save-buffer))

;;; wgrep
(require 'wgrep nil t)

;;; undohist
(package-install 'undohist)
(when (require 'undohist nil t)
  (undohist-initialize))

;;; undo-tree
(package-install 'undo-tree)
(when (require 'undo-tree nil t)
  (define-key global-map (kbd "C-'") 'undo-tree-redo)
  (global-undo-tree-mode))

;;; ElScreen
(package-install 'elscreen)
(when (require 'elscreen nil t)
  (elscreen-start)
  (if window-system
      (define-key elscreen-map (kbd "C-z") 'iconify-or-deiconify-frame)
    (define-key elscreen-map (kbd "C-z") 'suspend-emacs)))

;;; howm
(package-install 'howm)
;; howm note location
(setq howm-directory (concat user-emacs-directory "howm"))
;; howm-menu language changed to Japanese
(setq howm-menu-lang 'ja)
;; Howm memos are saved one file per day
(setq howm-file-name-format "%Y/%m/%Y-%m-%d.howm")
;; Load howm-mode
(when (require 'howm-mode nil t)
  ;; Start howm-menu with C-c ,,
  (define-key global-map (kbd "C-c ,,") 'howm-menu))
;; close howm note when saving
(defun howm-save-buffer-and-kill ()
  "Close howm note as soon as you save it."
  (interactive)
  (when (and (buffer-file-name)
             (howm-buffer-p))
    (save-buffer)
,    (kill-buffer nil)))
;; Close buffer with saving notes with C-c C-c
(define-key howm-mode-map (kbd "C-c C-c") 'howm-save-buffer-and-kill)

;;; cua-mode
(cua-mode t)
;; Disable CUA keybinds
(setq cua-enable-cua-keys nil)

;;; web-mode
(package-install 'web-mode)
(when (require 'web-mode nil t)
  ;; Add extensions that you want to start web-mode automatically
  (add-to-list 'auto-mode-alist '("\\.html\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.css\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.js\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.jsx\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.tpl\\.php\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.ctp\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.jsp\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.as[cp]x\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.erb\\'" . web-mode))
)
;;; Edit HTML5 in nxml-mode
(package-install 'html5-schema)

;;; nxml-mode
;; Enter & lt; / to automatically close the tag
(setq nxml-slash-auto-complete-flag t)
;; Complement tags with M-TAB
(setq nxml-bind-meta-tab-to-complete-flag t)
;; Use auto-complete-mode with nxml-mode
(add-to-list 'ac-modes 'nxml-mode)

;; Set the indent width of child elements. Initial value is 2
(setq nxml-child-indent 0)
;; Set the indent width of attribute value. Initial value is 4
(setq nxml-attribute-indent 0)

;;; less-css-mode
(package-install 'less-css-mode)

;;; sass-mode
(package-install 'sass-mode)

;;; js-mode
(defun js-indent-hook ()
  ;; Set the indent width 4
  (setq js-indent-level 2
        js-expr-indent-offset 2
        indent-tabs-mode nil)
  (defun my-js-indent-line () ←(d1)
    (interactive)
    (let* ((parse-status (save-excursion (syntax-ppss (point-at-bol))))
           (offset (- (current-column) (current-indentation)))
           (indentation (js--proper-indentation parse-status)))
      (back-to-indentation)
      (if (looking-at "case\\s-")
          (indent-line-to (+ indentation 2))
        (js-indent-line))
      (when (> offset 0) (forward-char offset))))
  (set (make-local-variable 'indent-line-function) 'my-js-indent-line))
;; Add hook when starting js-mode
(add-hook 'js-mode-hook 'js-indent-hook)

;;; js2-mode
(package-install 'js2-mode)
;; (add-to-list 'auto-mode-alist '("\\.js\\'" . js2-mode))
(add-to-list 'auto-mode-alist '("\\.jsx?\\'" . js2-jsx-mode))

;;; php-mode
(when (require 'php-mode nil t)
  (add-to-list 'auto-mode-alist '("\\.ctp\\'" . php-mode))
  (setq php-search-url "http://jp.php.net/ja/")
  (setq php-manual-url "http://jp.php.net/manual/ja/"))
;; Setting php-mode indent
(defun php-indent-hook ()
  (setq indent-tabs-mode nil)
  (setq c-basic-offset 4)
  (c-set-offset 'arglist-intro '+)
  (c-set-offset 'arglist-close 0))

(add-hook 'php-mode-hook 'php-indent-hook)

;; cperl-mode
;; make perl-mode an alias for cperl-mode
(defalias 'perl-mode 'cperl-mode)
;; Setting cperl-mode indent
(setq cperl-indent-level 4
      cperl-continued-statement-offset 4
      cperl-brace-offset -4
      cperl-label-offset -4
      cperl-indent-parens-as-block t
      cperl-close-paren-offset -4
      cperl-tab-always-indent t
      cperl-highlight-variables-indiscriminately t)

;;; Make dtw an alias for delete-trailing-whitespace
(defalias 'dtw 'delete-trailing-whitespace)

;;; yaml-mode
(package-install 'yaml-mode)

;;; ruby-mode
;; Setting ruby-mode indent
(setq ruby-indent-level 3
      ruby-deep-indent-paren-style nil
      ruby-indent-tabs-mode t)

;;; Use convenient minor mode for Ruby editing
(package-install 'ruby-electric)
(package-install 'inf-ruby)
;; ruby-electric-mode added to ruby-mode-hook
(add-hook 'ruby-mode-hook #'ruby-electric-mode)

;;; python-mode
(setq python-check-command "flake8")

;;; Flycheck
(package-install 'flycheck)
;; Perform a grammar check
(add-hook 'after-init-hook #'global-flycheck-mode)
;; Add function
(package-install 'flycheck-pos-tip)
(with-eval-after-load 'flycheck
  (flycheck-pos-tip-mode))

;;; Cooperation between gtags and Emacs
(setq gtags-suggested-key-mapping t)
(setq gtags-auto-update t)

;;; Cooperation between gtags and Helm
(package-install 'helm-gtags)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(fci-rule-color "#3E4451")
 '(helm-gtags-auto-update t)
 '(helm-gtags-suggested-key-mapping t)
 '(package-selected-packages
   (quote
    (popwin codic google-translate projectile flycheck inf-ruby less-css-mode helm yaml-mode web-mode undohist undo-tree sass-mode ruby-electric projectile-rails multi-term moccur-edit magit js2-mode html5-schema howm helm-projectile helm-gtags helm-c-moccur flycheck-pos-tip elscreen color-theme-monokai auto-complete atom-one-dark-theme)))
 '(size-indication-mode t)
 '(tetris-x-colors
   [[229 192 123]
    [97 175 239]
    [209 154 102]
    [224 108 117]
    [152 195 121]
    [198 120 221]
    [86 182 194]]))

;;; projectile
(package-install 'projectile)
(when (require 'projectile nil t)
  ;; Start project management automatically
  (projectile-mode)
  ;; Add directories to be excluded from project management
  (add-to-list
    'projectile-globally-ignored-directories
    "node_modules")
  ;; Cache project info
  (setq projectile-enable-caching t))
;; Change projectile prefix key to s-p
(define-key projectile-mode-map
  (kbd "s-p") 'projectile-command-map)

;;; Helm for projectile
(package-install 'helm-projectile)
(when (require 'helm-projectile nil t)
  (setq projectile-completion-system 'helm))

;;; Switch files to edit using Rails support
(package-install 'projectile-rails)
(when (require 'projectile-rails nil t)
  (projectile-rails-global-mode))

;;; Don't put ediff control panel in separate frame
(setq ediff-window-setup-function 'ediff-setup-windows-plain)

;;; Magit (git frontend)
(package-install 'magit)

;;; multi-term
(package-install 'multi-term)
(when (require 'multi-term nil t)
  (setq multi-term-program "/usr/bin/bash"))
(defun term-send-forward-char ()
  (interactive)
  (term-send-raw-string "\C-f"))
(defun term-send-backward-char ()
  (interactive)
  (term-send-raw-string "\C-b"))
(defun term-send-previous-line ()
  (interactive)
  (term-send-raw-string "\C-p"))
(defun term-send-next-line ()
  (interactive)
  (term-send-raw-string "\C-n"))
(defun term-send-reverse-search-history ()
  (interactive)
  (term-send-raw-string "\C-r"))
(add-hook 'term-mode-hook
          '(lambda ()
             (let* ((key-and-func
                     `(("\C-p"           term-send-previous-line)
                       ("\C-n"           term-send-next-line)
                       ("\C-b"           term-send-backward-char)
                       ("\C-f"           term-send-forward-char)
                       ("\C-r"           term-send-reverse-search-history)
                       (,(kbd "C-h")     term-send-backspace)
                       (,(kbd "C-y")     term-paste)
                       (,(kbd "ESC ESC") term-send-raw)
                       (,(kbd "C-S-p")   multi-term-prev)
                       (,(kbd "C-S-n")   multi-term-next))))
               (loop for (keybind function) in key-and-func do
                     (define-key term-raw-map keybind function)))))

;;; tramp
;; Do not create backup files with TRAMP
(add-to-list 'backup-directory-alist
             (cons tramp-file-name-regexp nil))

;;; WoMan
;; Make cache
(setq woman-cache-filename "~/.emacs.d/.wmncach.el")
;; Set man path
(setq woman-manpath '("/usr/share/man"
                      "/usr/local/share/man"
                      "/usr/local/share/man/ja"))
;;; Man by Helm
;; Load source file
(require 'helm-elisp)
(require 'helm-man)
;; Define based source
(setq helm-for-document-sources
      '(helm-source-info-elisp
        helm-source-info-cl
        helm-source-info-pages
        helm-source-man-pages))
;; Define helm-for-document command
(defun helm-for-document ()
  "Preconfigured `helm' for helm-for-document."
  (interactive)
  (let ((default (thing-at-point 'symbol)))
    (helm :sources
          (nconc
           (mapcar (lambda (func)
                     (funcall func default))
                   helm-apropos-function-list)
           helm-for-document-sources)
          :buffer "*helm for docuemont*")))

;; Assign helm-for-document to s-d
(define-key global-map (kbd "s-d") 'helm-for-document)

;;; : Do not follow symlink
(setq-default find-file-visit-truename t)

;;; Add PARH to exec-path
(cl-loop for x in (reverse
                (split-string (substring (shell-command-to-string "echo $PATH") 0 -1) ":"))
      do (add-to-list 'exec-path x))

;;; Increase history of recentf and save automatically
(when (require 'recentf nil 'noerror)
  (setq recentf-max-saved-items 100000)
  (setq recentf-exclude '("recentf"))
  (setq recentf-auto-save-timer
        (run-with-idle-timer 30 t 'recentf-save-list))
  (recentf-mode 1))

;;; Visualize double-byte spaces, line breaks, etc.
(setq whitespace-display-mappings
      '(
        (space-mark ?\x3000 [?\□]) ; zenkaku space
        (newline-mark 10 [182 10]) ; ¶
        (tab-mark 9 [187 9] [92 9]) ; tab » 187
        ))
(setq whitespace-style
      '(
        spaces
        trailing
        newline
        space-mark
        tab-mark
        newline-mark))

;;; display zenkaku space
(setq whitespace-space-regexp "\\(\u3000+\\)")

(global-whitespace-mode t)
(define-key global-map (kbd "<f5>") 'global-whitespace-mode)
(set-face-foreground 'whitespace-newline "Gray")

;;; Remove trailing blanks when saving
(add-hook 'before-save-hook 'delete-trailing-whitespace)
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

;;; Jpananse ime settings
(require 'mozc)
(set-language-environment "Japanese")
(prefer-coding-system 'utf-8)
(setq default-input-method "japanese-mozc")
;;; google translate
(package-install 'google-translate)
(require 'google-translate)
(require 'google-translate-default-ui)
(defun google-translate-json-suggestion (json)
  "Retrieve from JSON (which returns by the
`google-translate-request' function) suggestion. This function
does matter when translating misspelled word. So instead of
translation it is possible to get suggestion."
  (let ((info (aref json 7)))
    (if (and info (> (length info) 0))
        (aref info 1)
      nil)))
(global-set-key "\C-ct" 'google-translate-auto)
(defun google-translate-auto ()
  "Automatically recognize and translate Japanese and English."
  (interactive)
  (if (use-region-p)
      (let ((string (buffer-substring-no-properties (region-beginning) (region-end))))
        (deactivate-mark)
        (if (string-match (format "\\`[%s]+\\'" "[:ascii:]")
                          string)
            (google-translate-translate
             "en" "ja"
             string)
          (google-translate-translate
           "ja" "en"
           string)))
    (let ((string (read-string "Google Translate: ")))
      (if (string-match
           (format "\\`[%s]+\\'" "[:ascii:]")
           string)
          (google-translate-translate
           "en" "ja"
           string)
        (google-translate-translate
         "ja" "en"
         string)))))

;;; emacs-codic
(package-install 'codic)
(setq codic-api-token (my-lisp-load "codic-token"))
