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

(defun org2mdx/--copy-toplevel-props-to-toplevel-keywords (&optional whitelist substitute)
  "Copy toplevel properties to toplevel keyword.
If WHITELIST, which should be list of strings, is supplied, only keywords in WHITELIST will be copied.
TRANSFORMER is a function that takes one string argument, and returns string to replace.

If current buffer is:
```
* My task
  :PROPERTIES:
  :TAGS: :emacs:
  :END:
```

It will convert it to:
```
#+TAGS: :emacs:
* My task
  :PROPERTIES:
  :TAGS: :emacs:
  :END:
```

If same keyword is given, it won't be copied.
\(fn (&optional whitelist (fn ())))"
  ;; Go to first headline
  (goto-char 0)
  (unless (eq (car (org-element-at-point)) 'headline)
    (org-next-visible-heading 1))

  (let* ((range (org-get-property-block))
	(beg (car range))
	(end (cdr range)))
    (evil-ex-substitute beg end '(":TAGS:") ":BLOG_POST_TAGS:"))

  (let ((predefined-keywords (org2mdx/keywords))
	(_sub (or substitute '())))

    (dolist (e (org-entry-properties))
      (goto-char 0)
      (let* ((original-key (upcase (car e)))
	     (value (cdr e))
	     (converted-key (upcase (cdr (or (assoc-string original-key _sub) `(t . ,original-key)))))
	     )
	(insert
	 (pcase e
	   ;; If the same keyword is alerady defined, ignore current property
	   ((pred (lambda (v) (assoc (car v) predefined-keywords))) "")
	   ((guard (or (null whitelist) (member converted-key (map 'list #'upcase whitelist))))
	    (format "#+%s: %s\n" converted-key value))
	   (_ "")))
	(org-next-visible-heading 1)
	(org-entry-delete (point) original-key))
      ))
  (org-next-visible-heading 1)
  (insert "\n"))

(defun migration ()
  (let ((git-tracked-post-buffers
	 (with-temp-buffer
	   (setq default-directory (magit-toplevel))
	   (call-process "git" nil (current-buffer) nil "ls-files")
	   (seq-map #'find-file-noselect
		    (seq-filter #'(lambda (l) (string-match-p "^posts/.*\.org$" l)) (string-lines (buffer-string)))))))
    (dolist (buf git-tracked-post-buffers)
      (with-current-buffer buf
	(org2mdx/--copy-toplevel-props-to-toplevel-keywords
	 '("DATE" "TAGS" "KIND" "PROGRESS" "STATUS" "title" "description" "author" "image")
	 '(("BLOG_POST_KIND" . "KIND") ("BLOG_POST_PROGRESS" . "PROGRESS" ) ("BLOG_POST_STATUS"  . "STATUS")
	   ("ITEM" . "TITLE") ("BLOG_POST_TAGS" . "TAGS")))))))

;; TODO

;;; org2mdx.el ends here
