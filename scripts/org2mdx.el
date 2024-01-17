;;; org2mdx.el --- COnverter script to convert my org file to mdx file -*- lexical-binding: t; -*-

;; Copyright (C) 2023  Cj-bc

;; Author:  Cj-bc a.k.a. 陽鞠莉桜
;; Keywords: 

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
;; This is only for my blog posts, not generalized org-to-mdx converter.

;;; Code:
(require 'ox-zenn)

(defun org2mdx/--toplevel-keyword-p (elem)
  "Returns t if ELEM is a valid toplevel keyword.
ELEM should be a valid org-element. More about org-element can be found at "
  (let ((parent-elem (org-element-property :parent elem)))
    (and (eq (car parent-elem) 'section)
   	 (eq (org-element-property :begin parent-elem) 1))))

(defun org2mdx/keywords (&optional data)
  "Get alist of keywords in parse tree DATA.
DATA should have the same structure as the one retunred by
`org-element-parse-buffer'

keywords are

#+KEY: VALUE
"
  (unless data (setq data (org-element-parse-buffer)))
  (org-element-map data 'keyword
    #'(lambda (keyword)
	(when (let ((parent-elem (org-element-property :parent keyword)))
		(and (eq (car parent-elem) 'section)
		     (eq (org-element-property :begin parent-elem) 1)))
	  (cons (org-element-property :key keyword) (org-element-property :value keyword))))))

(defun org2mdx/--copy-toplevel-props-to-toplevel-keywords ()
  ""
  ;; Go to first headline
  (goto-char 0)
  (when (eq (car (org-element-at-point)) 'headline)
    (org-next-visible-heading 1))

  ;; 
  (let ((predefined-keywords (org2mdx/keywords)))
    (dolist (e (org-entry-properties))
      (goto-char 0)
      (insert
       (pcase e
	 ;; If the same keyword is alerady defined, ignore current property
	 ((pred (lambda (v) (assoc (car v) predefined-keywords))) "")
	 ;; (`("ITEM" . ,v) (format "#+TITLE: %s\n" v))
	 (`(,k . ,v) (format "#+%s: %s\n" k v))))))
  (org-next-visible-heading 1)
  (insert "\n"))

;; TODO
(defun org-myBlog-template (contents info)
  (let ((keywords)) (concat "---\n"
	  "---\n"
	  contents)))

(setq org2mdx/backend (org-export-create-backend
		       :parent 'zennmd
		       :transcoders '((template . org-myBlog-template))))

;;; org2mdx.el ends here
