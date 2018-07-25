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

;; Description:
;;
;; This adds an ivy-based interface to some of the features of ycmd. For
;; instance, it lets you access references to a name through ivy.

;;; Code:

(require 'ivy)
(require 'ycmd)

(defun ivy-ycmd--handle-selection (selection)
  "Jump to the file/line indicated by `selection'."
  (with-ivy-window
    (save-match-data
      (let* ((loc-data (cdr selection))
             (filename (cdr (assq 'filepath loc-data)))
             (line-number (cdr (assq 'line_num loc-data))))
        (find-file filename)
        (widen)
        (goto-char (point-min))
        (forward-line (- line-number 1))))))

(defun ivy-ycmd--make-selection-entry (location)
  "Create an ivy selection entry from `location'.

The entry will be a cons-sell with a display-string as the car
and `location' as the cdr."
  (cons (make-symbol
         (format "%s:%s\t%s"
                 (cdr (assq 'filepath location))
                 (cdr (assq 'line_num location))
                 (cdr (assq 'description location))))
        location))

(defun ivy-ycmd--handle-response (response)
  "List the file locations in `response' with ivy."
  (ivy-read "Goto: "
            (mapcar #'ivy-ycmd--make-selection-entry response)
            :action #'ivy-ycmd--handle-selection
            :caller 'ivy-ycmd))

;;;###autoload
(defun ivy-ycmd-goto-references ()
  "Jump to a reference to the symbol at the current point.

This finds all references to the symbol at point, lists them with
ivy, and jumps to the one selected by the user."
  (interactive)
  (save-excursion
    (--when-let (bounds-of-thing-at-point 'symbol)
      (goto-char (car it)))
    (ycmd--run-completer-command "GoToReferences"
      (lambda (response)
        (ivy-ycmd--handle-response response)))))

(provide 'ivy-ycmd)
;;; ivy-ycmd.el ends here
