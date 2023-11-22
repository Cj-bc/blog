;;; insert-diary-knowledge.el --- Insert Knowledge element into today's diary post  -*- lexical-binding: t; -*-

;; Copyright (C) 2023 Cj-bc

;; Author:  Cj-bc a.k.a. 陽鞠莉桜
;; Keywords: internal, tools

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
(require 'org)
(require 'org-element)

(defvar diary/knowledge-heading "知ったこと"
  "Heading that contains all knowledge entries"
  )

(defun find-element-with-headline (headline-content)
    "Find org element with given HEADLINE-CONTENT"
    (let ((doc (org-element-parse-buffer 'headline)))
      (org-element-map doc 'headline
	#'(lambda (element)
	    (and (string= headline-content (org-element-property :raw-value element))
		 element)) nil t)))

(defun diary/today-file ()
  "Returns today's file path relative to repository root"
  (format-time-string "posts/%Y-%m-%d.org" nil "JST"))

(defun add-new-knowledge (title description &optional buffer)
  "Add new knowledge entry to diary file"
  (with-current-buffer (diary/today-file)
    (let* ((knowledge-hl (find-element-with-headline diary/knowledge-heading))
 	   (body (org-element-create 'paragraph '() description))
 	   (element
 	    (org-element-create 'headline
 				`(:title ,title :level ,(1+ (org-element-property :level knowledge-hl)))
 				body)))
      (unless knowledge-hl
	(setq element (org-element-create 'headline `(:level 2 :title ,diary/knowledge-heading) element)))
      (goto-char (org-element-property :end knowledge-hl))
      (insert (org-element-interpret-data element)))))


(provide 'insert-diary-knowledge)
;;; insert-diary-knowledge.el ends here
