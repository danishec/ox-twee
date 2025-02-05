;;; ox-twee.el --- Twee Backend for Org Export Engine

;; Copyright (C) 2025

;; Author: Danish Khatri <dk.ext@electroncloud.co>
;; Keywords: org, text, twee, Twine

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; GNU Emacs is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; This library implements a Twee backend for
;; Org exporter.  Twee is a text format for making the source
;; code of interactive, nonlinear Twine stories.  Twee files
;; can be imported into the Twine 2 (https://twinery.org/2) application

;;; Code:
(require 'ox)
(require 'cl-lib)

(defgroup org-export-twee nil
  "Options for exporting Org mode files to Twee."
  :tag "Org Export Twee"
  :group 'org-export)

;;; Utils
(defun org-twee-escape (s)
  "Return the string S with some caracters escaped.
`<', `>' and `&' are escaped.  From one.el."
  (replace-regexp-in-string
   "\\(<\\)\\|\\(>\\)\\|\\(&\\)\\|\\(\"\\)\\|\\('\\)"
   (lambda (m) (pcase m
                 ("<"  "&lt;")
                 (">"  "&gt;")
                 ("&"  "&amp;")
                 ("\"" "&quot;")
                 ("'"  "&apos;")))
   s))

;;; Define the Twee Backend
(org-export-define-backend 'twee
  '((keyword . org-twee-keyword)
    (headline . org-twee-headline)
    (section . org-twee-section)
    (paragraph . org-twee-paragraph)
    (plain-text . org-twee-plain-text)
    (link . org-twee-link))
  :options-alist   '((:twee-story-title-format nil nil org-twee-story-title-format)
		     (:twee-metadata-format nil nil org-twee-metadata-format)
		     (:twee-passage-format nil nil org-twee-passage-format)
		     (:twee-link-format nil nil org-twee-link-format)
		     (:twee-preserve-breaks nil "\\n" org-export-preserve-breaks))
  :filters-alist '((:filter-parse-tree . org-twee-filter-parse-tree))
  :menu-entry
  '(?t "Export to Twee"
       ((?T "As Twee file" org-twee-export-to-twee))))

;;; Customization Options
(defcustom org-twee-story-title-format
  ":: StoryTitle
%s


"
  "Format string for the Twine 2 StoryTitle section."
  :group 'org-export-twee
  :type 'string)

(defcustom org-twee-metadata-format
  ":: StoryData
{
  \"ifid\": \"%s\",
  \"format\": \"Twee\",
  \"format-version\": \"%s\",
  \"start\": \"%s\",
  \"zoom\": %s
}


"
  "Format string for the Twine 2 metadata section."
  :group 'org-export-twee
  :type 'string)

(defcustom org-twee-passage-format
  ":: %s %s
%s


"
  "Format string for Twine 2 passages."
  :group 'org-export-twee
  :type 'string)

(defcustom org-twee-link-format
  "[[%s%s]]"
  "Format string for Twine 2 links."
  :group 'org-export-twee
  :type 'string)

;;; Filter Functions
(defun org-twee-filter-parse-tree (tree backend info)
 "Filters for in-buffer settings before the parse TREE is created.
Adds the #+OPTIONS: tags:nil to prevent exporting the property drawer keywords.

BACKEND is the export back-end being used.
INFO is a plist holding contextual information about the export
process."
 (if (plist-member info :preserve-breaks)
     (plist-put info :preserve-breaks t)
   nil)
 tree)

;;; Transcoder Functions
(defun org-twee-keyword (keyword _contents info)
  "Transcode a KEYWORD element from Org to Twee.

_CONTENTS is nil because keyword isn't recursive.  INFO is a plist
holding contextual information."
  (let* ((key (org-element-property :key keyword))
	 (story-title (org-element-property :value keyword)))
    (format (plist-get info :twee-story-title-format)
		    story-title)))
  

(defun org-twee-headline (headline contents info)
  "Transcode a HEADLINE element from Org to Twee.

CONTENTS holds the contents of the headline.  INFO is a plist
holding contextual information."
  (let* ((level (org-element-property :level headline))
         (parsed-title (org-element-property :raw-value headline))
         (extra-metadata (and (equal level 1)
                              (org-twee-format-metadata headline info))))
    (if (string-equal parsed-title "Twine 2 Metadata")
        (if extra-metadata
            (concat "\n" extra-metadata "\n\n")
          "")
      (format (plist-get info :twee-passage-format)
		      parsed-title
		      (org-twee-format-properties headline)
		      (org-trim contents)))))

(defun org-twee-format-metadata (headline info)
  "Format the metadata section for Twine 2.

HEADLINE is the first, unique headline in the org file with
Twine metadata.  INFO is a plist holding contextual information."
  (let ((name (org-entry-get headline "name"))
        (ifid (org-entry-get headline "ifid"))
        (format-version (org-entry-get headline "format-version"))
        (start (org-entry-get headline "start"))
        (zoom (org-entry-get headline "zoom")))
    (format (plist-get info :twee-metadata-format)
            ifid format-version name zoom)))

(defun org-twee-format-properties (headline)
  "Format the properties for a Twine 2 passage.

HEADLINE is the headline containing the property drawer"
  (let ((name (org-entry-get headline "name"))
	(pid (org-entry-get headline "pid"))
	(position (org-entry-get headline "position"))
	(size (org-entry-get headline "size"))
	(tags (org-entry-get headline "tags")))
    (format " [%s] {\"position\":\"%s\",\"size\":\"%s\"}"
	    (or tags "")
            (or position "0,0")
            (or size "100,100"))))

(defun org-twee-section (section contents info)
  "Transcode a SECTION element from Org to Twee.

CONTENTS holds the contents of the section.  INFO is a plist holding
contextual information."
  (let ((first-child (org-element-contents section)))
    (if (and first-child
             (org-element-type-p first-child 'headline)
             (<= (org-element-property :level first-child) 2))
        contents
      (format "%s\n" contents))))

(defun org-twee-paragraph (paragraph contents info)
  "Transcode a PARAGRAPH element from Org to Twee.

CONTENTS is the contents of the paragraph, as a string.  INFO is
the plist used as a communication channel."
    (if (equal contents "")
      ""
    (concat contents "\n")))

(defun org-twee-link (link desc info)
  "Transcode a LINK object from Org to Twee.

DESC is the description part of the link, or the empty string.
desc is not being passed correctly for some reason, so this
transcoder gets desc from link INFO is a plist holding contextual
information."
  (let* ((type (org-element-property :type link))
         (path (org-element-property :path link))
         (name (org-entry-get link "name"))
         (arrow (if (not (equal name path)) "->" "")))
    (cond
     ((string= type "fuzzy")
      (format (plist-get info :twee-link-format)
              (if desc (concat desc " " arrow) "")
              path))
     (t ""))))

(defun org-twee-plain-text (text info)
  "Transcode plain text from Org to Twee.

TEXT is the string to transcode.  INFO is a plist holding
contextual information."
  text)

;;; User-Facing Functions
;;;###autoload
(defun org-twee-export-as-twee
    (&optional async subtreep visible-only body-only ext-plist)
  "Export current buffer to a Twee buffer.

If narrowing is active in the current buffer, only export its
narrowed part.

If a region is active, export that region.

A non-nil optional argument ASYNC means the process should happen
asynchronously.  The resulting file should be accessible through
the `org-export-stack` interface.

When optional argument SUBTREEP is non-nil, export the sub-tree
at point, extracting information from the headline properties
first.

When optional argument VISIBLE-ONLY is non-nil, don't export
contents of hidden elements.

When optional argument BODY-ONLY is non-nil, only write code
between \"<body>\" and \"</body>\" tags.

EXT-PLIST, when provided, is a property list with external
parameters overriding Org default settings, but still inferior to
file-local settings.

Return output file's name."
  (interactive)
  (org-export-to-buffer 'twee "*twee-buffer*"
    async subtreep visible-only body-only ext-plist))

;;;###autoload
(defun org-twee-export-to-twee
    (&optional async subtreep visible-only body-only ext-plist)
  "Export current buffer to a Twee file.

If narrowing is active in the current buffer, only export its
narrowed part.

If a region is active, export that region.

A non-nil optional argument ASYNC means the process should happen
asynchronously.  The resulting file should be accessible through
the `org-export-stack` interface.

When optional argument SUBTREEP is non-nil, export the sub-tree
at point, extracting information from the headline properties
first.

When optional argument VISIBLE-ONLY is non-nil, don't export
contents of hidden elements.

When optional argument BODY-ONLY is non-nil, only write code
between \"<body>\" and \"</body>\" tags.

EXT-PLIST, when provided, is a property list with external
parameters overriding Org default settings, but still inferior to
file-local settings.

Return output file's name."
  (interactive)
  (let ((outfile (org-export-output-file-name ".twee" subtreep)))
    (org-export-to-file 'twee outfile async subtreep visible-only)))

(provide 'ox-twee)
;;; ox-twee.el ends here
