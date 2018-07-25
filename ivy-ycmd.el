;;; ivy-ycmd.el --- Ivy interface to ycmd    -*- lexical-binding: t; -*-

;; Copyright (C) 2018 Austin Bingham

;; Author: Austin Bingham <austin.bingham@gmail.com>
;; Keywords: tools

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;;

;;; Code:

(require 'ivy)
(require 'ycmd)

(defgroup ivy-ycmd nil
  "Variables related to ivy-ycmd"
  :prefix "ivy-ycmd-"
  :group 'tools)

(defcustom ivy-ycmd-mininum-input-length 1
  "The minimum number of input characters before running a search."
  :type 'integer)

(defun ivy-ycmd--handle-selection (selection)
  "Jump to the file/line indicated by SELECTION."
  (with-ivy-window
    (save-match-data
      (let* ((loc-data (cdr selection))
             (filename (cdr (assq 'filepath loc-data)))
             (line-number (cdr (assq 'line_num loc-data))))
        (find-file filename)
        (widen)
        (goto-char (point-min))
        (forward-line (- line-number 1))))))

(defun ivy-ycmd--handle-response (response initial-input)
  (ivy-read "Goto: "
            (mapcar
             (lambda (f)
               (cons (make-symbol  (format "%s:%s\t%s"
                                           (cdr (assq 'filepath f))
                                           (cdr (assq 'line_num f))
                                           (cdr (assq 'description f))))
                     f))
             response)
            :initial-input initial-input
            :history #'ivy-ycmd-history
            :action #'ivy-ycmd--handle-selection
            :caller 'ivy-ycmd)
  )

;;;###autoload
(defun ivy-ycmd (&optional initial-input)
  "TODO"
  (interactive)
  (save-excursion
    (--when-let (bounds-of-thing-at-point 'symbol)
      (goto-char (car it)))
    (ycmd--run-completer-command "GoToReferences"
      (lambda (response)
        (ivy-ycmd--handle-response response initial-input)))))

(provide 'ivy-ycmd)
;;; ivy-ycmd.el ends here
