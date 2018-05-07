;; undo-tree がない
;; view-mode がない

;; C-l : recenter-top-bottom

;; 対応する括弧を強調

;; 行頭 kill-line で行全体をカット

;; C-w や M-c を範囲が指定されていない場合無効にする

;; 検索、置換(occur等を除く)時に常に大文字、小文字の区別をする

;; deleteで空白を一括削除、タブ幅
(add-hook 'c-mode-hook (lambda ()(interactive) (c-toggle-hungry-state t) (setq tab-width 4)))

;; 他のエディタでファイルが変更されたら自動で更新
(global-auto-revert-mode t)

;; スクロール時にカーソルの位置をなるべく変えない
(setq scroll-preserve-screen-position 'always)


;;===================================================== 色関連 ================================================================


;; 標準色
(set-foreground-color "snow")
(set-background-color "#323232")
(set-cursor-color "yellow")
(set-face-background 'region "#462fe8")


;; 各Face (http://www.geocities.co.jp/SiliconValley-Bay/9285/ELISP-JA/elisp_359.html)
(set-face-foreground 'font-lock-comment-face "#6c91d2")
(set-face-foreground 'font-lock-string-face  "grey50")
(set-face-foreground 'font-lock-keyword-face "#d26ca5")
(set-face-foreground 'font-lock-builtin-face "#b0c4de")
(set-face-foreground 'font-lock-function-name-face "#6bffb4")
(set-face-foreground 'font-lock-variable-name-face "#e59975")
(set-face-foreground 'font-lock-type-face "#c5f7eb")
(set-face-foreground 'font-lock-constant-face "#89c6ec")
(set-face-foreground 'font-lock-warning-face "snow")


;; フレーム左右の余白部分、行番号との境界
(custom-set-faces '(fringe ((t (:background "#4f4f4f")))))



;;===================================================== キャッシュ関連 ========================================================

;; 前回閉じた時のカーソル位置を復元させる



;;===================================================== 標準キーバインド ======================================================


;; 基本キーバインド
;; (global-set-key "\C-z" 'toggle-truncate-lines) ;; 行の折り返し
(global-set-key "\C-t" 'yank-pop)	;; yank の後に打てばkill ring を遡る
(global-set-key "\C-c\C-k" 'append-next-kill) ;; killコマンドの前に打つことで最新のkill-ringに追加する



;; 忘れがちだけど便利なデフォルトキーバインド
;; C-M-h : 関数選択
;; M-f (M-b) : next word (previous word)
;; C-x C-x : exchange-point-and-mark


;; C-/ でバックスラッシュ
(define-key key-translation-map (kbd "C-/") "\\")

;; C-' でアンダーバー
(define-key key-translation-map (kbd "C-'") "_")

;; ミスタイプ防止のキーバインド
;; ANSI配列
(define-key key-translation-map (kbd "C-9") "(")
(define-key key-translation-map (kbd "C--") "_")
(define-key key-translation-map (kbd "C-=") "+")



;;************************************************************************



;; 10行スクロール
(global-set-key "\C-v" (lambda ()(interactive) (scroll-up 10)))
(global-set-key "\C-q" (lambda ()(interactive) (scroll-down 10)))

;; 段落スクロール
(global-set-key (kbd "C-M-n") (lambda ()(interactive) (forward-paragraph)(recenter)))
(global-set-key (kbd "C-M-p") (lambda ()(interactive) (backward-paragraph)(recenter)))

;; 1画面スクロール
(global-set-key (kbd "C-M-v") 'scroll-up)
;; (define-minor-mode scroll-down-minor-mode "undo-treeと競合したため" t "" `((,(kbd "C-M-q") . scroll-down)))
(define-minor-mode scroll-down-minor-mode "undo-treeと競合したため" t "" `((,(kbd "C-M-w") . scroll-down)))

;; コメントアウトされている行をスライド
(global-set-key (kbd "M-,") (lambda ()(interactive) (replace-comment)(beginning-of-line 0)))
(global-set-key (kbd "M-.") (lambda ()(interactive) (beginning-of-line 2)(replace-comment)))


;; 段落選択
(define-minor-mode mark-paragraph-minor-mode
  "I-searchと競合したため"		;説明文字列
  t                                     ;デフォルトで有効にする
  ""                                    ;モードラインに表示しない
  `((,(kbd "C-s") . mark-paragraph)))






;; カーソル位置のブックマーク



;; スペルチェックispellの辞書をaspellに変更

;; インストール
;; $ brew install aspell --with-lang-en
;; チェック言語を英語に指定(ホームにファイルが生成される)
;; $ echo "lang en_US" > ~/.aspell.conf



;; 動的なスペルチェック

;; Skim の自動更新をデフォルトにする
;; $ defaults write -app Skim SKAutoReloadFileUpdate -boolean true


;;===================================================== helm ==================================================================
;; 補完・リストアップ・絞り込みのためのインターフェイス


(require 'helm-config)
(helm-mode t)

;; 非表示ファイルの設定
(advice-add 'helm-ff-filter-candidate-one-by-one
	    :around (lambda (fcn file)
		      (unless (string-match "\\(?:DS_Store\\|\\.Trash\\|\\.dropbox\\|CFUserTextEncoding\\|\\.dSYM\\|\\.git\\'\\|Icon\\|\\(?:/\\|\\`\\)\\.\\'\\)" file)
			(funcall fcn file))))

;; M-x を helm-M-x に変換
(define-key global-map (kbd "M-x") 'helm-M-x)

;; C-hで1文字削除
(define-key helm-map (kbd "C-h") 'delete-backward-char)
(define-key helm-find-files-map (kbd "C-h") 'delete-backward-char)

;; TABで補完
(define-key helm-find-files-map (kbd "TAB") 'helm-execute-persistent-action)
(define-key helm-read-file-map (kbd "TAB") 'helm-execute-persistent-action)

;; キーバインド
(define-key global-map (kbd "C-M-k")   'helm-show-kill-ring)
(define-key global-map (kbd "C-x C-b") 'helm-for-files)
(define-key global-map (kbd "C-x C-f") 'helm-find-files)
(define-key global-map (kbd "C-x f") 'helm-find-files) ; tmux用
(define-key global-map (kbd "C-x C-m") 'helm-recentf)

(define-key global-map (kbd "C-u C-i") 'helm-imenu)
(define-key global-map (kbd "C-u C-o") 'helm-occur)
(define-key global-map (kbd "C-u C-p") 'helm-resume)


;; あいまい検索
(setq helm-M-x-fuzzy-match t)
;; (setq helm-imenu-fuzzy-match t)

;; C-q をhelmで使えるように
(define-key helm-map (kbd "C-q") 'helm-previous-page)

;; C-o : 先頭行に移動
;; C-c d : delete file






;;===================================================== YaTeX =================================================================
;; Texの拡張モード



;; *.tex は自動的にYaTeXモード
(setq auto-mode-alist (append '(("\\.tex$" . yatex-mode)) auto-mode-alist))
(autoload 'yatex-mode "yatex" "Yet Another LaTeX mode" t)


(with-eval-after-load 'yatex

  ;; コマンドのPATH設定
  (setenv "PATH" "/usr/local/bin:/Library/TeX/texbin/:/Users/yy/Dropbox/Personal/Command/:$PATH" t)
  (setq exec-path (append '("/usr/local/bin" "/Library/TeX/texbin" "/Users/yy/Dropbox/Personal/Command") exec-path))

  ;; パッケージ"amsmath"がうまく動作しないときのための設定
  (setq YaTeX-use-LaTeX2e t)
  (setq YaTeX-use-AMS-LaTeX t)

  ;; コマンドの指定("~"は使えない)
  (setq tex-command "/Users/yy/Dropbox/Personal/Command/pdfplatex.sh")
  (setq bibtex-command "/Users/yy/Dropbox/Personal/Command/bibplatex.sh")
  (setq makeindex-command "mendex")

  ;; pdfplatex.sh と bibplatex.sh をホームディレクトリに作成し実行権限を与える。自分の好きなディレクトリに移動して良い(上のパスに加えることを忘れずに)。
  ;; $ echo '#!/bin/shplatex -synctex=1 $1dvipdfmx ${1%tex}dvi' > ~/pdfplatex.shchmod +x ~/pdfplatex.sh
  ;; $ echo '#!/bin/shpbibtex $1platex -synctex=1 $1' > ~/bibplatex.shchmod +x ~/bibplatex.sh

  ;; キーバインド
  (define-key YaTeX-mode-map (kbd "C-c C-i") 'reftex-citation)
  (define-key YaTeX-mode-map (kbd "C-c C-b") 'YaTeX-make-begin-end)

  ;; ************************ BibTeX等のPATH設定 ******************************

  (let ((MYPATH ":~/Dropbox/Personal/BibTeX/:"))

    ;; *.bst
    (setenv "BSTINPUTS" (concat ".:" (getenv "HOME")
				MYPATH (getenv "BSTINPUTS")))
    ;; *.bib
    (setenv "BIBINPUTS" (concat ".:" (getenv "HOME")
				MYPATH (getenv "BIBINPUTS")))
    ;; *.cls
    (setenv "TEXINPUTS" (concat ".:" (getenv "HOME")
				MYPATH (getenv "TEXINPUTS")))
    )
  ;; "~/.bashrc"に以下を加える
  ;; export BSTINPUTS=$BSTINPUTS:~/Dropbox/Personal/BibTeX/
  ;; export BIBINPUTS=$BIBINPUTS:~/Dropbox/Personal/BibTeX/
  ;; export TEXINPUTS=$TEXINPUTS:~/Dropbox/Personal/BibTeX/

  ;; **************************************************************************


  )


;; RefTeX を有効にする
(add-hook 'yatex-mode-hook 'reftex-mode)




;;===================================================== yasnippet =============================================================
;; Tabでテンプレート挿入






;;===================================================== rainbow-delimiters ====================================================
;; 対応する括弧の色付け(モード指定)


;; 色変更
#7fffd4,#FAAC58,#72c572,#f78181,#F2F5A9,#66cdaa,#d26ca5,#6DB3D4,#ffa0a0






;;===================================================== sequential-command ====================================================
;; 連続打鍵時の動作変更

;; C-a : 行の先頭 => バッファの先頭 => 元の位置 => 行の先頭 => ...
;; C-e : 行の末尾 => バッファの末尾 => 元の位置 => 行の末尾 => ...



;;===================================================== volatile-highlights ===================================================
;; 挿入文のハイライト

;; 色変更
(set-face-attribute 'vhl/default-face nil
		    :foreground "#000"
		    :background "#86c18d"
		    )


;; undo-treeで使えるようにする
(vhl/define-extension 'undo-tree 'undo-tree-yank 'undo-tree-move)
(vhl/install-extension 'undo-tree)





;;===================================================== key-combo =============================================================
;; 自動スペース挿入

;; "="などの入力時に自動で前後にスペースを入れる
;; 直後にundoでスペースを削除できる


(with-eval-after-load 'cc-mode

  (require 'key-combo)
  (global-key-combo-mode t)

  (define-key c-mode-map "\M-3" 'key-combo-mode)

  (key-combo-define c-mode-map (kbd ",") '(", " ","))
  (key-combo-define c-mode-map (kbd "=") '(" = " " == "))
  (key-combo-define c-mode-map (kbd ">") " > ")
  (key-combo-define c-mode-map (kbd ">=") " >= ")
  (key-combo-define c-mode-map (kbd "<") " < ")
  (key-combo-define c-mode-map (kbd "<=") " <= ")
  (key-combo-define c-mode-map (kbd "+") '(" + " "++"))
  (key-combo-define c-mode-map (kbd "+=") " += ")
  (key-combo-define c-mode-map (kbd "-") '(" - " "--"))
  (key-combo-define c-mode-map (kbd "-=") " -= ")
  (key-combo-define c-mode-map (kbd "*") '(" * " "*" "**" "***"))
  (key-combo-define c-mode-map (kbd "*=") " *= ")
  (key-combo-define c-mode-map (kbd "/") '(" / " "// " "/"))
  (key-combo-define c-mode-map (kbd "/=") " /= ")
  (key-combo-define c-mode-map (kbd "%") " % ")
  (key-combo-define c-mode-map (kbd "%=") " %= ")
  (key-combo-define c-mode-map (kbd "!=") " != ")
  (key-combo-define c-mode-map (kbd "&&") " && ")
  (key-combo-define c-mode-map (kbd "||") " || ")
  (key-combo-define c-mode-map (kbd "^") " ^ ")
  ;; (key-combo-define c-mode-map (kbd "^=") " ^= ")
  )







;;===================================================== migemo ================================================================
;; ローマ字や英語で日本語検索

;; インストール
;; $ brew install cmigemo --HEAD


(require 'migemo)

;; PATH設定
(setq migemo-command "/usr/local/bin/cmigemo")
(setq migemo-dictionary "/usr/local/share/migemo/utf-8/migemo-dict")

(setq migemo-options '("-q" "--emacs"))
(setq migemo-user-dictionary nil)
(setq migemo-regex-dictionary nil)
(setq migemo-coding-system 'utf-8-unix)
(load-library "migemo")
(migemo-init)

;; helmでmigemoを有効にする
(helm-migemo-mode t)




;;===================================================== iedit =================================================================
;; インタラクティブな置換

;; http://tam5917.hatenablog.com/entry/2014/10/23/105352


(require 'iedit)

;; 起動/終了
(global-set-key (kbd "C-c C-i") 'iedit-mode)

;; 領域を制限
(define-key iedit-mode-keymap (kbd "M-i") 'iedit-restrict-current-line) ; 一行
(define-key iedit-mode-keymap (kbd "M-h") 'iedit-restrict-function)     ; 関数

;; 領域を上下に増やす
(define-key iedit-mode-keymap (kbd "M-p") 'iedit-expand-up-a-line)
(define-key iedit-mode-keymap (kbd "M-n") 'iedit-expand-down-a-line)

;; 起動後に範囲指定し、もう一度起動すればその範囲に限定できる

(define-key iedit-mode-keymap (kbd "M-u") 'iedit-show/hide-unmatched-lines) ;; マッチした行だけ抽出
(define-key iedit-mode-keymap (kbd "C-k") 'iedit-delete-occurrences) ;; マッチした箇所を全削除
(define-key iedit-mode-keymap (kbd "C-m") 'iedit-toggle-selection) ;; セット/解除

;; M-U / M-L : マッチした箇所を大文字/小文字に

;; セット箇所を巡回
;; (define-key iedit-mode-keymap (kbd "TAB") 'iedit-next-occurrence) ; デフォルト
(define-key iedit-mode-keymap (kbd "S-TAB") 'iedit-prev-occurrence)

;; マッチした最初/最後の箇所に移動
(define-key iedit-mode-keymap (kbd "M-a") 'iedit-goto-first-occurrence)
(define-key iedit-mode-keymap (kbd "M-e") 'iedit-goto-last-occurrence)

;; auto-complete
(define-key iedit-mode-keymap (kbd "C-o") 'ac-trigger-key-command)

;; 大文字小文字の区別をする
(setq iedit-case-sensitive-default nil)

;; 色変更
(set-face-background 'iedit-occurrence "#8e0027")

;; Debug Me
;; (add-hook 'iedit-mode (lambda ()
;; 			(global-key-combo-mode nil)
;; 			(key-combo-mode nil)))

;; iedit中に key-combo を使うとバグる
;; 日本語も時々バグる




;;===================================================== helm-swoop ============================================================
;; helm-occur より重いが高機能


(require 'helm-swoop)

(global-set-key (kbd "C-u C-t") 'helm-swoop)

;; 候補表示画面で改行しないように
(setq helm-truncate-lines t)























;;===================================================== 自作キーバインド ======================================================



;; 一行全体コピー
(defun copy-whole-line ()
  "連続で打てばまとめてkill ringに入れる"
  "範囲選択時も対応"
  (interactive)
  (if (region-active-p)
      (kill-ring-save (region-beginning) (region-end))
    (let ((beg (line-beginning-position 1))
	  (end (line-beginning-position 2)))
      (if (eq last-command 'copy-whole-line)
	  (kill-append (buffer-substring beg end) (< end beg))
	(kill-new (buffer-substring beg end))))
    (beginning-of-line 2)))
(global-set-key "\C-o" 'copy-whole-line)



;; 1文字進んでkill ringに入れる
(defun copy-forward-char ()
  (interactive)
  (let ((beg (point))
	(end (1+ (point))))
    (if (eq last-command 'copy-forward-char)
	(kill-append (buffer-substring beg end) (< end beg))
      (kill-new (buffer-substring beg end))))
  (forward-char))
(global-set-key (kbd "M-o") 'copy-forward-char)




;; backspaceしてkill ringに入れる
(defun delete-backward-char-to-kill-ring ()
  (interactive)
  (let ((beg (point))
	(end (1- (point))))
    (if (eq last-command 'delete-backward-char-to-kill-ring)
 	(kill-append (buffer-substring beg end) (< end beg))
      (kill-new (buffer-substring beg end))))
  (delete-backward-char 1))
(global-set-key (kbd "M-h") 'delete-backward-char-to-kill-ring)



;; deleteしてkill ringに入れる
(defun delete-forward-char-to-kill-ring ()
  (interactive)
  (let ((beg (point))
	(end (1+ (point))))
    (if (eq last-command 'delete-forward-char-to-kill-ring)
 	(kill-append (buffer-substring beg end) (< end beg))
      (kill-new (buffer-substring beg end))))
  (delete-forward-char 1))
(global-set-key (kbd "M-d") 'delete-forward-char-to-kill-ring)



;; カーソルから行末までコピー
(defun copy-line-forward ()
  "改行記号は入れない"
  (interactive)
  (kill-new (buffer-substring (point) (line-end-position))))
(define-minor-mode copy-line-forward-minor-mode "" t "" `((,(kbd "C-c C-o") . copy-line-forward)))



;; 前後にスペース挿入
(defun insert-space ()
  "範囲選択時も対応"
  (interactive)
  (if (region-active-p)
      (progn (save-excursion
               (let ((beg (region-beginning))
                     (end (region-end)))
                 (deactivate-mark)
                 (goto-char beg)
                 (insert " ")
                 (goto-char (1+ end))
                 (insert " "))))
    (insert "  ")
    (backward-char)))
(global-set-key (kbd "C-M-c") 'insert-space)
(global-set-key (kbd "C-M-SPC") 'insert-space)



;; 連続コメントアウト
(defun comet-comment ()
  "範囲選択時も対応"
  "コメント関数は重いのでc-modeでは長押し非推奨"
  (interactive)
  (unless (eobp)
    (if (region-active-p)
        (comment-or-uncomment-region (region-beginning) (region-end))
      (let ((zeroflag t)
            (lastflag (eq last-command 'comet-comment)))
        (unless lastflag
          (setq comet-comment-beg (line-beginning-position)))
        (while (string-blank-p (buffer-substring (line-beginning-position) (line-end-position)))
          (beginning-of-line 2)
          (setf zeroflag nil))
        (when zeroflag
          (when lastflag
            (comment-or-uncomment-region comet-comment-beg (line-beginning-position)))
          (comment-or-uncomment-region comet-comment-beg (line-beginning-position 2))
          (beginning-of-line 2))))))
(global-set-key "\C-r" 'comet-comment)



;; 連続コメントアウト用のundo
(defun undo-comet-comment ()
  (interactive)
  (if (and comet-comment-beg (or (eq last-command 'comet-comment) (eq last-command 'undo-tree-undo)))
      (progn (comment-or-uncomment-region comet-comment-beg (line-beginning-position))
      	     (goto-char comet-comment-beg))
    (message "Not Valid")))
(global-set-key "\C-c\C-j" 'undo-comet-comment)



;; 複製コメントアウト
(defun replica-comment ()
  "範囲選択時も対応"
  "copy-whole-lineの後ならその範囲"
  (interactive)
  (volatile-highlights-mode nil)
  (if (eq last-command 'copy-whole-line)
      (progn (save-excursion
               (set-mark (point))
               (yank)
               (goto-char (- (point) (* (- (region-end) (region-beginning)) 2)))
               (comment-or-uncomment-region (region-beginning) (region-end)))
             (indent-for-tab-command))
    (if (region-active-p)
        (progn (let ((beg (region-beginning))
                     (end (region-end)))
                 (kill-new (buffer-substring beg end))
                 (goto-char beg)
                 (yank)
                 (goto-char end)
                 (comment-or-uncomment-region beg end)
                 (if (eq last-command 'mark-paragraph)
                     (beginning-of-line 2))
                 (if (or (eq last-command 'c-mark-function) (eq last-command 'mark-defun))
                     (newline))
                 (back-to-indentation)
                 ))
      (indent-for-tab-command)
      (save-excursion
        ;; (back-to-indentation)
        (copy-whole-line)
        (beginning-of-line 0)
        (yank)
        (beginning-of-line 0)
        (comment-or-uncomment-region (line-beginning-position) (line-end-position)))
      (if (bolp)
	  (beginning-of-line 2))
      ))
  (volatile-highlights-mode t))
(global-set-key "\C-u\C-r" 'replica-comment)



;; コメント/非コメントを二行入れ替える
(defun replace-comment()
  "カーソル行とその上の行をそれぞれコメントアウト"
  (interactive)
  (save-excursion
    (comment-or-uncomment-region (line-beginning-position) (line-end-position))
    (beginning-of-line 0)
    (comment-or-uncomment-region (line-beginning-position) (line-end-position))))
(global-set-key (kbd "C-.") 'replace-comment)
(with-eval-after-load 'cc-mode (define-key c-mode-map (kbd "C-c C-n") 'replace-comment))
(with-eval-after-load 'cc-mode (define-key c-mode-map (kbd "C-.") 'replace-comment))



;; 段落スクロールアップ
(defun paragraph-scroll-up (n)
  "n行以上離れた次の段落に飛ぶ"
  (while (and (string-blank-p (buffer-substring (line-beginning-position) (line-end-position))) (not (bobp)))
    (beginning-of-line 0))
  (let ((cnt 0))
    (while (and (< cnt n) (not (eobp)))
      (beginning-of-line 2)
      (if (string-blank-p (buffer-substring (line-beginning-position) (line-end-position)))
	  (incf cnt)
	(setf cnt 0))))
  (beginning-of-line 2)
  (while (and (string-blank-p (buffer-substring (line-beginning-position) (line-end-position))) (not (eobp)))
    (beginning-of-line 2))
  (recenter))
(global-set-key (kbd "M-n") (lambda ()(interactive) (paragraph-scroll-up 4)))



;; 段落スクロールダウン
(defun paragraph-scroll-down (n)
  "n行以上離れた前の段落に飛ぶ"
  (beginning-of-line 0)
  (while (and (string-blank-p (buffer-substring (line-beginning-position) (line-end-position))) (not (bobp)))
    (beginning-of-line 0))
  (let ((cnt 0))
    (while (and (< cnt n) (not (bobp)))
      (beginning-of-line 0)
      (if (string-blank-p (buffer-substring (line-beginning-position) (line-end-position)))
	  (incf cnt)
	(setf cnt 0))))
  (unless (bobp)
    (beginning-of-line (1+ n)))
  (recenter))
(global-set-key (kbd "M-p") (lambda ()(interactive) (paragraph-scroll-down 4)))



;; 一行 or 範囲コメントアウト
(defun comment-or-uncomment-dwim ()
  "範囲選択されていなければ一行"
  "範囲選択されていればその範囲"
  (interactive)
  (if (region-active-p)
      (comment-or-uncomment-region (region-beginning) (region-end))
    (comment-or-uncomment-region (line-beginning-position) (line-end-position))))
(define-minor-mode comment-or-uncomment-minor-mode "" t "" `((,(kbd "C-c C-c") . comment-or-uncomment-dwim)))



;; カーソル行の関数のプロトタイプ宣言表示
(defun echo-declaration ()
  "最大5秒表示"
  (interactive)
  (let ((flag nil)
	(funcName nil))
    (save-excursion
      (beginning-of-line)
      (while (not (or (eq (preceding-char) ?\() (eolp)))
	(forward-char))
      (let ((end (point))
	    (main nil))
	(while (not (or (eq (preceding-char) ?\s) (eq (preceding-char) ?\t) (bolp)))
	  (backward-char))
	(setf funcName (buffer-substring (point) end))
	(goto-char (point-min))
	(setf main (search-forward "int main("))
	(goto-char (point-min))
	(when (search-forward funcName main t)
	  (beginning-of-line)
	  (while (not (or (eq (following-char) ?\;) (eolp)))
	    (forward-char))
	  (setf funcName (buffer-substring (line-beginning-position) (point)))
	  (unless (eolp)
	    (setf flag t)))))
    (if flag
	(message funcName)
      (message "Not Found"))
    (dotimes (k 500)
      (sit-for 0.01))))
(eval-after-load 'cc-mode '(define-key c-mode-map (kbd "C-u C-e") 'echo-declaration))



;; 自動ファイルクローズ
(defun auto-fclose ()
  "閉じていないファイルポインタを閉じる"
  "カーソルと行頭文字の位置関係で挿入位置を分岐"
  (interactive)
  (let ((beg)
	(end)
	(ofile nil)
	(cfile nil))
    (save-excursion
      (c-mark-function)
      (setf beg (region-beginning))
      (setf end (region-end))
      (deactivate-mark)
      (goto-char beg)
      (while (search-forward "fclose(" end t)
	(unless (comment-only-p (line-beginning-position) (line-end-position))
	  (while (and (eq (following-char) ?\s) (not (eolp)))
	    (forward-char))
          (push (thing-at-point 'symbol) cfile))))
    (save-excursion
      (end-of-line)
      (while (re-search-backward ".=\s[a-z]+open" beg t)
	(unless (comment-only-p (line-beginning-position) (line-end-position))
          (let ((fname (thing-at-point 'symbol)))
            (unless (member fname cfile)
              (push fname ofile))))))
    (if (null ofile)
	(message "No Need to Close File Pointer at all")
      (if (string-blank-p (buffer-substring (line-beginning-position) (line-end-position)))
	  (indent-for-tab-command)
	(let ((cur (point)))
	  (back-to-indentation)
	  (if (<= cur (point))
	      (open-line-next-indent)
	    (end-of-line)
	    (newline-and-indent))))
      (while (not (null ofile))
	(insert (concat "fclose( " (pop ofile) " );"))
	(newline-and-indent))
      (hungry-delete)
      (message nil))))
(eval-after-load 'cc-mode '(define-key c-mode-map (kbd "C-c C-s") 'auto-fclose))



;; 自動メモリ解放
(defun auto-free ()
  "解放していないメモリを解放する"
  "mallocとcallocに対応"
  (interactive)
  (let ((funbeg)
	(funend)
	(sfree nil)
        (mptr nil)
	(fptr nil))
    (save-excursion
      (c-mark-function)
      (setf funbeg (region-beginning))
      (setf funend (region-end))
      (deactivate-mark)
      ;; free
      (goto-char funbeg)
      (while (search-forward "free(" funend t)
	(unless (comment-only-p (line-beginning-position) (line-end-position))
	  (while (and (eq (following-char) ?\s) (not (eolp)))
	    (forward-char))
          (let ((fbeg (point)))
            (end-of-line)
            (search-backward ");" (line-beginning-position) t)
            (while (and (eq (preceding-char) ?\s) (not (bolp)))
              (backward-char))
            (push (buffer-substring fbeg (point)) fptr)))))
    ;; malloc
    (save-excursion
      (end-of-line)
      (while (re-search-backward "=\s*[mc]alloc" funbeg t)
	(unless (comment-only-p (line-beginning-position) (line-end-position))
	  (while (and (eq (preceding-char) ?\s) (not (bolp)))
	    (backward-char))
          (let ((pend (point))
                (pname)
                (single t))
            (while (not (or (eq (preceding-char) ?*) (bolp)))
              (backward-char))
            (if (bolp)
                (back-to-indentation))
            (setf pname (buffer-substring (point) pend))
            (push pname mptr) ;; malloc pointer
            (while (< (point) pend)
              (if (eq (following-char) ?\[)
                  (setf single nil))
              (forward-char))
            ;; free文 作成
            (unless (member pname fptr)
              (if single
                  (push (concat "free( " pname " );\n") sfree)
                (while (not (or (and (equal (buffer-substring (point) (+ (point) 3)) "for")
                                     (not (comment-only-p (point) (+ (point) 3)))
                                     (equal (buffer-substring (- (line-end-position) 2) (line-end-position)) "){"))
                                (bobp)))
                  (beginning-of-line 0)
                  (back-to-indentation))
                (push (concat (thing-at-point 'line) "free( " pname " );\n}\n") sfree)
                (goto-char pend)))))))
    (if (null sfree)
	(message "No Need to Free up Memory at all in this Function")
      (end-of-line)
      (newline)
      (let ((insertbeg (point))
            (insertend (point))
            (tmptr)
            (tsfree)
            (posi))
        (while (not (null sfree))
          (setf tmptr (pop mptr))
          (setf tsfree (pop sfree))
          (if (setf posi (string-match "\\[[^\\[]+\\]$" tmptr))
              (progn
                (setf tmptr (substring tmptr 0 posi))
                (search-backward tmptr insertbeg t) ;; 挿入箇所
                (beginning-of-line)
                (insert tsfree)
                (incf insertend (length tsfree)))
            (insert tsfree)
            (setf insertend (point)))
          (goto-char insertend))
        (indent-region insertbeg (point)))
      (hungry-delete)
      (message nil))))
(eval-after-load 'cc-mode '(define-key c-mode-map (kbd "C-c C-a") 'auto-free))



;; 解放忘れのポインタの検索
(defun confirm-unfree ()
  "解放忘れのポインタがある関数を表示(自動解放はしない)"
  (interactive)
  (save-excursion
    (goto-char (point-min))
    (search-forward "int main(")
    (c-end-of-defun)
    (let ((unfun nil)
          (sfun)
          (funbeg)
          (funend)
          (mptr)
          (fptr))
      ;; 関数ループ
      (while (c-end-of-defun)
        (setf funend (point))
        (c-beginning-of-defun)
        (setf funbeg (point))
        (setf mptr nil)
        (setf fptr nil)
        ;; 関数名
        (while (not (or (eq (following-char) ?\s) (eolp)))
          (forward-char))
        (forward-char)
        (let ((fnbeg (point)))
          (while (not (or (eq (following-char) ?\() (eolp)))
            (forward-char))
          (setf sfun (buffer-substring fnbeg (point))))
       ;; free
        (while (search-forward "free(" funend t)
          (unless (comment-only-p (line-beginning-position) (line-end-position))
            (while (and (eq (following-char) ?\s) (not (eolp)))
              (forward-char))
            (let ((frbeg (point)))
              (end-of-line)
              (search-backward ");" (line-beginning-position) t)
              (while (and (eq (preceding-char) ?\s) (not (bolp)))
                (backward-char))
              (push (buffer-substring frbeg (point)) fptr))))
        ;; malloc
        (goto-char funend)
        (while (re-search-backward "=\s*[mc]alloc" funbeg t)
          (unless (comment-only-p (line-beginning-position) (line-end-position))
            (while (and (eq (preceding-char) ?\s) (not (bolp)))
              (backward-char))
            (let ((pend (point))
                  (pname)
                  (single t))
              (while (not (or (eq (preceding-char) ?*) (bolp)))
                (backward-char))
              (if (bolp)
                  (back-to-indentation))
              (setf pname (buffer-substring (point) pend))
              (unless (member pname fptr)
                (push pname mptr)))))
        (unless (null mptr)
          (push sfun unfun))
        (c-beginning-of-defun)
        (c-end-of-defun))
      (if (null unfun)
          (message "No Need to Free up Memory at all in this Buffer")
        (let ((unfuns nil))
          (while (not (null unfun))
            (setf unfuns (concat (pop unfun) ", " unfuns)))
          (message (concat "Unfreed Memorys Exists in following Funncions : " (substring unfuns 0 -2))))))))
(eval-after-load 'cc-mode '(define-key c-mode-map (kbd "C-c C-z") 'confirm-unfree))




;; hungry-delete
(defun hungry-delete ()
  "*.c 以外用"
  (interactive)
  (while (or (eq (preceding-char) ?\s) (eq (preceding-char) ?\n) (eq (preceding-char) ?\t))
    (delete-backward-char 1)))
(global-set-key (kbd "C-x DEL") 'hungry-delete)



;; save-buffer のカスタム
(defun custom-save-buffer ()
  (interactive)
  (shell-command "open -a iTerm")
  (save-buffer)
  (message nil))
(defun first-compile-execute ()
  "cde, cx が使えること前提"
  (interactive)
  (shell-command "open -a iTerm")
  (save-buffer)
  (kill-new (concat "cde
cx " (substring (buffer-name) 0 -2) "
"))
  (message nil))
;; iTerm => Keys => Key Mapping から新規で、
;; "C-,"に Send Hex Code "0x10 0x0d" を
;; "C-y"に Select Menu Item "Paste"  を割り当てる
(with-eval-after-load 'cc-mode
  (define-key c-mode-map (kbd "C-,") 'custom-save-buffer)
  (define-key c-mode-map (kbd "C-c C-y") 'first-compile-execute))



;; 適応スペース
(defun adaptive-space ()
  (interactive)
  (if (region-active-p)
      (insert-space)
    (if (or (and (eq (preceding-char) ?\() (eq (following-char) ?\)))
	    ;; (eq last-command 'c-electric-paren)
            (and (eq (preceding-char) ?\[) (eq (following-char) ?\])))
        (progn (insert "  ")
               (backward-char))
      (insert " "))))
(eval-after-load 'cc-mode '(define-key c-mode-map (kbd "SPC") 'adaptive-space))



;; 適応スペース(YaTeX用)
(defun adaptive-space-for-yatex ()
  (interactive)
  (if (region-active-p)
      (insert-space)
    (if (or (and (eq (preceding-char) ?\() (eq (following-char) ?\)))
            (and (eq (preceding-char) ?\() (eq (following-char) ?\\))
            (and (eq (preceding-char) ?\[) (eq (following-char) ?\]))
            (and (eq (preceding-char) ?\[) (eq (following-char) ?\\))
            (and (eq (preceding-char) ?\{) (eq (following-char) ?\}))
            (and (eq (preceding-char) ?\{) (eq (following-char) ?\\))
            (and (eq (preceding-char) ?\$) (eq (following-char) ?\$)))
        (progn (insert "  ")
               (backward-char))
      (insert " "))))
(eval-after-load 'yatex '(define-key YaTeX-mode-map (kbd "SPC") 'adaptive-space-for-yatex))
