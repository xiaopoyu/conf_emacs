;;; package -- 面板配置
;;; Commentary:
;;; Code:

;; 使用C-c <left> 和C-c <right>来对窗口配置进行redo或者undo。这样在窗口乱了后可以恢复到原来不乱的状态
(when (fboundp 'winner-mode)
  (winner-mode 1))

;; 超过两个窗口，可以使用"C-x o"进行切换
(require-package 'switch-window)
(require 'switch-window)
(setq-default switch-window-shortcut-style 'alphabet)
(setq-default switch-window-timeout nil)
(global-set-key (kbd "C-x o") 'switch-window)

(defun my/window/split-window-func-with-other-buffer (split-function)
  "分屏并且把焦点放在新的window上, SPLIT-FUNCTION为分屏函数."
  (lexical-let ((s-f split-function))
    (lambda (&optional arg)
      "Split this window and switch to the new window unless ARG is provided."
      (interactive "P")
      (funcall s-f)
      (let ((target-window (next-window)))
        (set-window-buffer target-window (other-buffer))
        (unless arg
          (select-window target-window))))))

(global-set-key "\C-x2" (my/window/split-window-func-with-other-buffer 'split-window-vertically))
(global-set-key "\C-x3" (my/window/split-window-func-with-other-buffer 'split-window-horizontally))

;; 触发删除其它窗口
(defun my/window/toggle-delete-other-windows ()
  "Delete other windows in frame if any, or restore previous window config."
  (interactive)
  (if (and winner-mode
           (equal (selected-window) (next-window)))
      (winner-undo)
    (delete-other-windows)))
(global-set-key "\C-x1" 'my/window/toggle-delete-other-windows)

;; 设置分屏, C-x |和C-x _分别表示竖分和横分。使用这个操作的时候只会一直只有两个window
(defun my/window/split-window-horizontally-instead ()
  "横向分割."
  (interactive)
  (save-excursion
    (delete-other-windows)
    (funcall (my/window/split-window-func-with-other-buffer 'split-window-horizontally))))
(defun my/window/split-window-vertically-instead ()
  "纵向分割."
  (interactive)
  (save-excursion
    (delete-other-windows)
    (funcall (my/window/split-window-func-with-other-buffer 'split-window-vertically))))
(global-set-key "\C-x|" 'my/window/split-window-horizontally-instead)
(global-set-key "\C-x_" 'my/window/split-window-vertically-instead)

;; 使用F7键会分屏显示最后打开的buffer，如果再按一下则关闭分屏。很实用的功能
;; Borrowed from http://postmomentum.ch/blog/201304/blog-on-emacs
(defun my/window/split-window()
  "Split the window to see the most recent buffer in the other window.
Call a second time to restore the original window configuration."
  (interactive)
  (if (eq last-command 'my/window/split-window)
      (progn
        (jump-to-register :my/window/split-window)
        (setq this-command 'my/window/unsplit-window))
    (window-configuration-to-register :my/window/split-window)
    (switch-to-buffer-other-window nil)))
(global-set-key (kbd "<f7>") 'my/window/split-window)

;; 显示当前窗口关联了那个buffer
(defun my/window/toggle-current-window-dedication ()
  "Toggle whether the current window is dedicated to its current buffer."
  (interactive)
  (let* ((window (selected-window))
         (was-dedicated (window-dedicated-p window)))
    (set-window-dedicated-p window (not was-dedicated))
    (message "Window %sdedicated to %s"
             (if was-dedicated "no longer " "")
             (buffer-name))))
(global-set-key (kbd "C-c <down>") 'my/window/toggle-current-window-dedication)

(provide 'init-window)
;;;  init-window.el ends here
