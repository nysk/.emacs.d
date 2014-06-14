;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Emacs実践入門より
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; おまじない
(require 'cl)
;; Emacsからの質問をy/nで回答する
(fset 'yes-or-no-p 'y-or-n-p)
;; スタートアップメッセージを非表示
(setq inhibit-startup-screen t)

;; ~/.emacs.d/elispディレクトリをロードパスに追加する
;; ただし、add-to-load-path関数を作成した場合は不要
(add-to-list 'load-path "~/.emacs.d/elisp")

;; エラー
;; load-pathを追加する関数を定義
;(defun add-to-load-path (&rest paths)
;  (len (path)
;       (dolist (path paths paths)
;	 (len ((default-directory
;		 (expand-file-name (concat user-emacs-directory path))))
;	      (add-to-list 'load-path default-directory)
;	      (if (fboundp 'normal-top-level-add-subdirs-to-load-path)
;		  (normal-top-level-add-subdirs-to-load-path))))))

;; 引数のディレクトリとそのサブディレクトリをload-pathに追加
;(add-to-load-path "elisp" "conf" "public_repos")

;;
;; auto-install
;;
(when (require 'auto-install nil t)
  ;; インストールディレクトリを設定する、初期値は~/.emacs.d/auto-install/
  (setq auto-install-directory "~/.emacs.d/elisp/")
  ;; EmacsWikiに登録されているelispの名前を取得する
  (auto-install-update-emacswiki-package-name t)
  ;; 必要であればプロキシの設定を行う
  ;; (setq url-proxy-services '(("http" . "localhost:8339")))
  ;; install-elisp の関数を利用可能にする
  (auto-install-compatibility-setup))

;;
;; anything
;;
;; (auto-install-batch "anything")
(when (require 'anything nil t)
  (setq
   ;; 候補を表示するまでの時間。デフォルトは0.5
   anything-idle-delay 0.3
   ;; タイプして再描写するまでの時間。デフォルトは0.1
   anything-input-idle-delay 0.2
   ;; 候補の最大表示数。デフォルトは50
   anything-candidate-number-limit 100
   ;; 候補が多いときに体感速度を早くする
   anything-quick-update t
   ;; 候補選択ショートカットをアルファベットに
   anything-enable-shortcuts 'alphabet)

  (when (require 'anything-config nil t)
    ;; root権限でアクションを実行するときのコマンド
    ;; デフォルトは"su"
    (setq anything-su-or-sudo "sudo"))

  (require 'anything-match-plugin nil t)

  (when (and (executable-find "cmigemo")
             (require 'migemo nil t))
    (require 'anything-migemo nil t))

  (when (require 'anything-complete nil t)
    ;; lispシンボルの補完候補の再検索時間
    (anything-lisp-complete-symbol-set-timer 150))

  (require 'anything-show-completion nil t)

  (when (require 'auto-install nil t)
    (require 'anything-auto-install nil t))

  (when (require 'descbinds-anything nil t)
    ;; describe-bindingsをAnythingに置き換える
    (descbinds-anything-install)))

;;
;; auto-complete
;;
(when (require 'auto-complete-config nil t)
  (add-to-list 'ac-dictionary-directories "~/.emacs.d/elisp/ac-dict")
  (define-key ac-mode-map (kbd "M-TAB") 'auto-complete)
  (ac-config-default))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; my settings
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;
;; flymake
;;
(require 'flymake)
;(add-hook 'find-file-hook 'flymake-find-file-hook)
(add-hook 'python-mode-hook 'flymake-find-file-hook)
(when (load "flymake" t)
  (defun flymake-pychecker-init ()
    (let* ((temp-file (flymake-init-create-temp-buffer-copy 'flymake-create-temp-inplace))
	   (local-file (file-relative-name temp-file (file-name-directory buffer-file-name))))
      (list "/usr/local/bin/pyflakes" (list local-file))))
  (add-to-list 'flymake-allowed-file-name-masks '("\\.py\\'" flymake-pychecker-init)))

(set-face-background 'flymake-errline "#992222")

;; エラーを無視する場合
(defadvice flymake-post-syntax-check (before flymake-force-check-was-interrupted)
  (setq flymake-check-was-interrupted t))
(ad-activate 'flymake-post-syntax-check)

;;
;; elpa
;;
;; elpaの内容を増やす設定（Emacs24）
(require 'package)
(add-to-list 'package-archives '("melpa" . "http://melpa.milkbox.net/packages/") t)
(add-to-list 'package-archives '("marmalade" . "http://marmalade-repo.org/packages/"))
(package-initialize)

(require 'flymake-cursor)

;;
;; git-gutter
;; git-gutter-fringe
;; fringe-helper
;;
(global-git-gutter-mode t)
;(add-hook 'ruby-mode-hook 'git-gutter-mode)
;(add-hook 'python-mode-hook 'git-gutter-mode)

(require 'git-gutter-fringe)
;(set-face-foreground 'git-gutter-fr:modified "yellow")
;(set-face-foreground 'git-gutter-fr:added    "blue")
;(set-face-foreground 'git-gutter-fr:deleted  "white")

;; Please adjust fringe width if your own sign is too big.
(setq-default left-fringe-width  20)
(setq-default right-fringe-width 20)
(fringe-helper-define 'git-gutter-fr:added nil
  ".XXXXXX."
  "XX....XX"
  "X......X"
  "X......X"
  "XXXXXXXX"
  "XXXXXXXX"
  "X......X"
  "X......X")
(fringe-helper-define 'git-gutter-fr:deleted nil
  "XXXXXX.."
  "XX....X."
  "XX.....X"
  "XX.....X"
  "XX.....X"
  "XX.....X"
  "XX....X."
  "XXXXXX..")
(fringe-helper-define 'git-gutter-fr:modified nil
  "XXXXXXXX"
  "X..XX..X"
  "X..XX..X"
  "X..XX..X"
  "X..XX..X"
  "X..XX..X"
  "X..XX..X"
  "X..XX..X")

;;
;; color-theme
;;
(require 'color-theme nil t)
(color-theme-initialize)
;(color-theme-blue-sea) ; default
(color-theme-dark-laptop)
;(color-theme-hober)
;(color-theme-taylor)
;(color-theme-calm-forest)

;;
;; タイトルバー
;;
;; タイトルバーにフルパス表示
(setq frame-title-format "%f")

;;
;; モードライン
;;
;; モードラインに時刻を表示
(display-time)

;; モードラインに行番号桁番号を表示
(line-number-mode 1)
(column-number-mode 1)

;; モードラインの文字色
;(set-face-foreground 'modeline "Black")

;; モードラインの背景色を設定します
;(set-face-background 'modeline "MediumPurple2")
;(set-face-background 'modeline "DeepSkyBlue")
;(set-face-background 'modeline "firebrick1")

;;
;; サイドバー
;;
;; 左に行番号表示
;(require 'linum)
;(global-linum-mode t)

;;
;; その他設定
;;
;; キーバインド
(global-set-key (kbd "M-r") 'recentf-open-files)

;; 現在行をハイライト
(global-hl-line-mode t)
(defface my-hl-line-face
  '((((class color) (background dark)) ; カラーかつ, 背景が dark ならば,
;     (:background "DarkSlateBlue" t)) ; 背景を黒に
     (:background "grey30" t))
    (((class color) (background light)) ; カラーかつ, 背景が light ならば,
     (:background "ForestGreen" t)) ; 背景を ForestGreen に
    (t (:bold t)))
  "hl-line's my face")
(setq hl-line-face 'my-hl-line-face)

;; 色
;(set-face-background 'hl-line "darkolivegreeen")

;; 履歴を次回Emacs起動時にも保存する
(savehist-mode 1)

;; ファイル内のカーソル位置を保存する
(setq-default save-place t)

;; 対応する括弧を表示させる
(show-paren-mode 1)

;; シェルに合わせるため、C-hは後退に割り当てる
(global-set-key (kbd "C-h") 'delete-backward-char)

;; リージョンに色をつける
(transient-mark-mode 1)

;; ツールバーとスクロールバーを消す
(tool-bar-mode -1)
(scroll-bar-mode -1)

;; スクロールを1行ずつにする
(setq scroll-conservatively 35
  scroll-margin 0
  scroll-step 1)

;; 日本語
(set-language-environment 'Japanese)

;; UTF-8
(prefer-coding-system 'utf-8)

;; commandをmetaとして利用する
;(setq mac-command-key-is-meta t)
(setq ns-command-modifier (quote meta))
(setq ns-alternate-modifier (quote super))

;; global-font-lock-mode(色の設定等）を有効にする
(global-font-lock-mode t)
;; そしてそれらのオプションとも言うべき設定をおこなっていきます。
(setq font-lock-maximum-decoration t)
(setq fast-lock nil)
(setq lazy-lock nil)
(setq jit-lock t)

;; 透明度を設定する（アクティブ時ノンアクティブ時）
;(setq default-frame-alist (append (list '(alpha . (85 60))) default-frame-alist))

;; ウィンドウの大きさを設定
(if window-system (progn
  (setq initial-frame-alist '((width . 170)(height . 45)(top . 0)(left . 0)))
;; 背景色設定
;  (set-background-color "Black")
;; 文字色設定
;  (set-foreground-color "White")
;; カーソル色設定
;;  (set-cursor-color "DeepSkyBlue")
;  (set-cursor-color "firebrick1")
))

;; 画像ファイルを表示
(auto-image-file-mode t)

;; M-fで別窓でファイルを開く
(global-set-key "\M-f" 'find-file-other-frame)

;; ウィンドウをだす
(global-set-key "\M-2" 'make-frame)

;; ウィンドウを閉じる
(global-set-key "\M-0" 'delete-frame)

;; 選択中のリージョンの色を設定します
;(set-face-background 'region "LightSteelBlue1")
(set-face-background 'region "grey50")

;; タブや全角スペース、改行直前の半角スペースに色をつける設定
;(defface my-face-r-1 '((t (:background "gray15"))) nil)
(defface my-face-b-1 '((t (:background "gray"))) nil)
(defface my-face-b-2 '((t (:background "gray26"))) nil)
(defface my-face-u-1 '((t (:foreground "SteelBlue" :underline t))) nil)
;(defvar my-face-r-1 'my-face-r-1)
(defvar my-face-b-1 'my-face-b-1)
(defvar my-face-b-2 'my-face-b-2)
(defvar my-face-u-1 'my-face-u-1)
(defadvice font-lock-mode (before my-font-lock-mode ())
  (font-lock-add-keywords
   major-mode
   '(("\t" 0 my-face-b-2 append)
     ("　" 0 my-face-b-1 append)
     ("[ \t]+$" 0 my-face-u-1 append)
;     ("[\r]*\n" 0 my-face-r-1 append)
     )))
(ad-enable-advice 'font-lock-mode 'before 'my-font-lock-mode)
(ad-activate 'font-lock-mode)

;; スクロールバーの色
;(set-face-foreground 'scroll-bar "Blue") ; 前景色
;(set-face-background 'scroll-bar "DeepSkyBlue") ; 背景色

;; 入力支援
(add-hook 'python-mode-hook
	  (lambda ()
;	    (define-key python-mode-map "\"" 'electric-pair)
	    (define-key python-mode-map "\'" 'electric-pair)
	    (define-key python-mode-map "(" 'electric-pair)
	    (define-key python-mode-map "[" 'electric-pair)
	    (define-key python-mode-map "{" 'electric-pair)))
(defun electric-pair ()
  "Insert character pair without sournding spaces"
  (interactive)
  (let (parens-require-spaces)
    (insert-pair)))

;; とりあえず半角カナの文字化けを修正するため
(when (and (>= emacs-major-version 24)
           (eq window-system 'ns))
  ;; フォントセットを作る
  (let* ((fontset-name "myfonts") ; フォントセットの名前
;         (size 14) ; ASCIIフォントのサイズ [9/10/12/14/15/17/19/20/...]
         (size 12) ; ASCIIフォントのサイズ [9/10/12/14/15/17/19/20/...]
         (asciifont "Menlo") ; ASCIIフォント
         (jpfont "Hiragino Maru Gothic ProN") ; 日本語フォント
         (font (format "%s-%d:weight=normal:slant=normal" asciifont size))
         (fontspec (font-spec :family asciifont))
         (jp-fontspec (font-spec :family jpfont)) 
         (fsn (create-fontset-from-ascii-font font nil fontset-name)))
    (set-fontset-font fsn 'japanese-jisx0213.2004-1 jp-fontspec)
    (set-fontset-font fsn 'japanese-jisx0213-2 jp-fontspec)
    (set-fontset-font fsn 'katakana-jisx0201 jp-fontspec) ; 半角カナ
    (set-fontset-font fsn '(#x0080 . #x024F) fontspec)    ; 分音符付きラテン
    (set-fontset-font fsn '(#x0370 . #x03FF) fontspec)    ; ギリシャ文字
    )
  ;; デフォルトのフレームパラメータでフォントセットを指定
  (add-to-list 'default-frame-alist '(font . "fontset-myfonts"))
  ;; フォントサイズの比を設定
  (dolist (elt '(("^-apple-hiragino.*"               . 1.2)
		 (".*osaka-bold.*"                   . 1.2)
		 (".*osaka-medium.*"                 . 1.2)
		 (".*courier-bold-.*-mac-roman"      . 1.0)
		 (".*monaco cy-bold-.*-mac-cyrillic" . 0.9)
		 (".*monaco-bold-.*-mac-roman"       . 0.9)))
    (add-to-list 'face-font-rescale-alist elt))
  ;; デフォルトフェイスにフォントセットを設定
  ;; # これは起動時に default-frame-alist に従ったフレームが
  ;; # 作成されない現象への対処
  (set-face-font 'default "fontset-myfonts"))

;; wdired.el diredモードでrを押すとファイル名編集などができるように
(define-key dired-mode-map "r" 'wdired-change-to-wdired-mode)

;; 種類ごとの色
(add-hook 'font-lock-mode-hook
  '(lambda ()
;    ;(set-face-foreground 'font-lock-comment-face "chocolate1")
;    (set-face-foreground 'font-lock-comment-face "#f69933")  ; 微調整
;    (set-face-foreground 'font-lock-string-face "LightSalmon")
;    ;(set-face-foreground 'font-lock-keyword-face "Cyan1")
;    (set-face-foreground 'font-lock-keyword-face "#66e6e6")  ; 微調整
;    (set-face-foreground 'font-lock-builtin-face "LightSteelBlue")
;    (set-face-foreground 'font-lock-function-name-face "LightSkyBlue")
;    (set-face-foreground 'font-lock-variable-name-face "LightGoldenrod")
;    (set-face-foreground 'font-lock-type-face "PaleGreen")
;    (set-face-foreground 'font-lock-constant-face "Aquamarine")
;    (set-face-foreground 'font-lock-warning-face "Pink")
  )
)

;; 80文字チェック
;; http://emacs-fu.blogspot.com/2008/12/highlighting-lines-that-are-too-long.html
(add-hook 'python-mode-hook
  (lambda ()
    (font-lock-add-keywords nil
;      '(("^[^\n]\\{80\\}\\(.*\\)$" 1 font-lock-warning-face t)))))
      '(("^[^\n]\\{80\\}\\(.*\\)$" 1 font-lock-comment-face t)))))
