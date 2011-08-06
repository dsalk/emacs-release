;; Copyright (C) 1998, 1999, 2000, 2001, 2002, 2003, 2004,2005, 2006,
;;   2007, 2008, 2009, 2010, 2011  Free Software Foundation, Inc.
;; GNU Emacs is free software: you can redistribute it and/or modify
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.
;; along with GNU Emacs.  If not, see <http://www.gnu.org/licenses/>.
;; - Improve `diff-add-change-log-entries-other-window',
;;   it is very simplistic now.
;;
  "Non-nil means `diff-goto-source' jumps to the old file.
  "Non-nil means hunk headers are kept up-to-date on-the-fly.
  "Non-nil means `diff-apply-hunk' will move to the next hunk after applying."
(defvar diff-vc-backend nil
  "The VC backend that created the current Diff buffer, if any.")

    ("\t" . diff-hunk-next)
    ([backtab] . diff-hunk-prev)
    ("g" . revert-buffer)
    ;; By analogy with the global C-x 4 a binding.
    ("\C-x4A" . diff-add-change-log-entries-other-window)
    ("\C-c\C-r" . diff-reverse-direction)
    ("\C-c\C-w" . diff-ignore-whitespace-hunk)
    ("\C-c\C-b" . diff-refine-hunk)  ;No reason for `b' :-(
    ["Jump to Source"		diff-goto-source
     :help "Jump to the corresponding source line"]
    ["Apply hunk"		diff-apply-hunk
     :help "Apply the current hunk to the source file and go to the next"]
    ["Test applying hunk"	diff-test-hunk
     :help "See whether it's possible to apply the current hunk"]
    ["Apply diff with Ediff"	diff-ediff-patch
     :help "Call `ediff-patch-file' on the current buffer"]
    ["Create Change Log entries" diff-add-change-log-entries-other-window
     :help "Create ChangeLog entries for the changes in the diff buffer"]
    "-----"
    ["Reverse direction"	diff-reverse-direction
     :help "Reverse the direction of the diffs"]
    ["Context -> Unified"	diff-context->unified
     :help "Convert context diffs to unified diffs"]
    ["Unified -> Context"	diff-unified->context
     :help "Convert unified diffs to context diffs"]
    ["Show trailing whitespace" whitespace-mode
     :style toggle :selected (bound-and-true-p whitespace-mode)
     :help "Show trailing whitespace in modified lines"]
    "-----"
    ["Split hunk"		diff-split-hunk
     :active (diff-splittable-p)
     :help "Split the current (unified diff) hunk at point into two hunks"]
    ["Ignore whitespace changes" diff-ignore-whitespace-hunk
     :help "Re-diff the current hunk, ignoring whitespace differences"]
    ["Highlight fine changes"	diff-refine-hunk
     :help "Highlight changes of hunk at point at a finer granularity"]
    ["Kill current hunk"	diff-hunk-kill
     :help "Kill current hunk"]
    ["Kill current file's hunks" diff-file-kill
     :help "Kill all current file's hunks"]
    "-----"
    ["Previous Hunk"		diff-hunk-prev
     :help "Go to the previous count'th hunk"]
    ["Next Hunk"		diff-hunk-next
     :help "Go to the next count'th hunk"]
    ["Previous File"		diff-file-prev
     :help "Go to the previous count'th file"]
    ["Next File"		diff-file-next
     :help "Go to the next count'th file"]
(define-minor-mode diff-auto-refine-mode
  "Automatically highlight changes in detail as the user visits hunks.
When transitioning from disabled to enabled,
try to refine the current hunk, as well."
  :group 'diff-mode :init-value t :lighter nil ;; " Auto-Refine"
  (when diff-auto-refine-mode
    (condition-case-no-debug nil (diff-refine-hunk) (error nil))))
     :background "grey80")
(define-obsolete-face-alias 'diff-header-face 'diff-header "22.1")
(define-obsolete-face-alias 'diff-file-header-face 'diff-file-header "22.1")
(define-obsolete-face-alias 'diff-index-face 'diff-index "22.1")
(define-obsolete-face-alias 'diff-hunk-header-face 'diff-hunk-header "22.1")
(define-obsolete-face-alias 'diff-removed-face 'diff-removed "22.1")
(define-obsolete-face-alias 'diff-added-face 'diff-added "22.1")
(define-obsolete-face-alias 'diff-changed-face 'diff-changed "22.1")
(define-obsolete-face-alias 'diff-function-face 'diff-function "22.1")
(define-obsolete-face-alias 'diff-context-face 'diff-context "22.1")
(define-obsolete-face-alias 'diff-nonexistent-face 'diff-nonexistent "22.1")
(defconst diff-hunk-header-re-unified
  "^@@ -\\([0-9]+\\)\\(?:,\\([0-9]+\\)\\)? \\+\\([0-9]+\\)\\(?:,\\([0-9]+\\)\\)? @@")
(defconst diff-context-mid-hunk-header-re
  "--- \\([0-9]+\\)\\(?:,\\([0-9]+\\)\\)? ----$")
  `((,(concat "\\(" diff-hunk-header-re-unified "\\)\\(.*\\)$")
     (1 diff-hunk-header-face) (6 diff-function-face))
    (,diff-context-mid-hunk-header-re . diff-hunk-header-face) ;context
    ;; For file headers, accept files with spaces, but be careful to rule
    ;; out false-positives when matching hunk headers.
    ("^\\(---\\|\\+\\+\\+\\|\\*\\*\\*\\) \\([^\t\n]+?\\)\\(?:\t.*\\| \\(\\*\\*\\*\\*\\|----\\)\\)?\n"
     (0 diff-header-face)
     (2 (if (not (match-end 3)) diff-file-header-face) prepend))
(defvar diff-valid-unified-empty-line t
  "If non-nil, empty lines are valid in unified diffs.
Some versions of diff replace all-blank context lines in unified format with
empty lines.  This makes the format less robust, but is tolerated.
See http://lists.gnu.org/archive/html/emacs-devel/2007-11/msg01990.html")

(defconst diff-hunk-header-re
  (concat "^\\(?:" diff-hunk-header-re-unified ".*\\|\\*\\{15\\}.*\n\\*\\*\\* .+ \\*\\*\\*\\*\\|[0-9]+\\(,[0-9]+\\)?[acd][0-9]+\\(,[0-9]+\\)?\\)$"))
(defconst diff-file-header-re (concat "^\\(--- .+\n\\+\\+\\+ \\|\\*\\*\\* .+\n--- \\|[^-+!<>0-9@* \n]\\).+\n" (substring diff-hunk-header-re 1)))
(defun diff-hunk-style (&optional style)
    (setq style (cdr (assq (char-after) '((?@ . unified) (?* . context)))))
  style)

(defun diff-end-of-hunk (&optional style donttrustheader)
  (let (end)
    (when (looking-at diff-hunk-header-re)
      ;; Especially important for unified (because headers are ambiguous).
      (setq style (diff-hunk-style style))
      (goto-char (match-end 0))
      (when (and (not donttrustheader) (match-end 2))
        (let* ((nold (string-to-number (or (match-string 2) "1")))
               (nnew (string-to-number (or (match-string 4) "1")))
               (endold
        (save-excursion
          (re-search-forward (if diff-valid-unified-empty-line
                                 "^[- \n]" "^[- ]")
                                     nil t nold)
                  (line-beginning-position 2)))
               (endnew
                ;; The hunk may end with a bunch of "+" lines, so the `end' is
                ;; then further than computed above.
                (save-excursion
                  (re-search-forward (if diff-valid-unified-empty-line
                                         "^[+ \n]" "^[+ ]")
                                     nil t nnew)
                  (line-beginning-position 2))))
          (setq end (max endold endnew)))))
    ;; We may have a first evaluation of `end' thanks to the hunk header.
    (unless end
      (setq end (and (re-search-forward
                      (case style
                        (unified (concat (if diff-valid-unified-empty-line
                                             "^[^-+# \\\n]\\|" "^[^-+# \\]\\|")
                                         ;; A `unified' header is ambiguous.
                                         diff-file-header-re))
                        (context "^[^-+#! \\]")
                        (normal "^[^<>#\\]")
                        (t "^[^-+#!<> \\]"))
                      nil t)
                     (match-beginning 0)))
      (when diff-valid-unified-empty-line
        ;; While empty lines may be valid inside hunks, they are also likely
        ;; to be unrelated to the hunk.
        (goto-char (or end (point-max)))
        (while (eq ?\n (char-before (1- (point))))
          (forward-char -1)
          (setq end (point)))))
(defun diff-beginning-of-hunk (&optional try-harder)
  "Move back to beginning of hunk.
If TRY-HARDER is non-nil, try to cater to the case where we're not in a hunk
but in the file header instead, in which case move forward to the first hunk."
      (error
       (if (not try-harder)
           (error "Can't find the beginning of the hunk")
         (diff-beginning-of-file-and-junk)
         (diff-hunk-next))))))

(defun diff-unified-hunk-p ()
  (save-excursion
    (ignore-errors
      (diff-beginning-of-hunk)
      (looking-at "^@@"))))
    (let ((start (point))
          res)
      ;; diff-file-header-re may need to match up to 4 lines, so in case
      ;; we're inside the header, we need to move up to 3 lines forward.
      (forward-line 3)
      (if (and (setq res (re-search-backward diff-file-header-re nil t))
               ;; Maybe the 3 lines forward were too much and we matched
               ;; a file header after our starting point :-(
               (or (<= (point) start)
                   (setq res (re-search-backward diff-file-header-re nil t))))
          res
        (goto-char start)
        (error "Can't find the beginning of the file")))))

 diff-hunk diff-hunk-header-re "hunk" diff-end-of-hunk diff-restrict-view
 (if diff-auto-refine-mode
     (condition-case-no-debug nil (diff-refine-hunk) (error nil))))

    (if arg (diff-beginning-of-file) (diff-beginning-of-hunk 'try-harder))
         ;; Search the second match, since we're looking at the first.
	 (nexthunk (when (re-search-forward diff-hunk-header-re nil t 2)
;; "index ", "old mode", "new mode", "new file mode" and
;; "deleted file mode" are output by git-diff.
(defconst diff-file-junk-re
  "diff \\|index \\|\\(?:deleted file\\|new\\(?: file\\)?\\|old\\) mode")

(defun diff-beginning-of-file-and-junk ()
  "Go to the beginning of file-related diff-info.
This is like `diff-beginning-of-file' except it tries to skip back over leading
data such as \"Index: ...\" and such."
  (let* ((orig (point))
         ;; Skip forward over what might be "leading junk" so as to get
         ;; closer to the actual diff.
         (_ (progn (beginning-of-line)
                   (while (looking-at diff-file-junk-re)
                     (forward-line 1))))
         (start (point))
         (prevfile (condition-case err
                       (save-excursion (diff-beginning-of-file) (point))
                     (error err)))
         (err (if (consp prevfile) prevfile))
         (nextfile (ignore-errors
                     (save-excursion
                       (goto-char start) (diff-file-next) (point))))
         ;; prevhunk is one of the limits.
         (prevhunk (save-excursion
                     (ignore-errors
                       (if (numberp prevfile) (goto-char prevfile))
                       (diff-hunk-prev) (point))))
         (previndex (save-excursion
                      (forward-line 1)  ;In case we're looking at "Index:".
                      (re-search-backward "^Index: " prevhunk t))))
    ;; If we're in the junk, we should use nextfile instead of prevfile.
    (if (and (numberp nextfile)
             (or (not (numberp prevfile))
                 (and previndex (> previndex prevfile))))
        (setq prevfile nextfile))
    (if (and previndex (numberp prevfile) (< previndex prevfile))
        (setq prevfile previndex))
    (if (and (numberp prevfile) (<= prevfile start))
          (progn
            (goto-char prevfile)
            ;; Now skip backward over the leading junk we may have before the
            ;; diff itself.
            (while (save-excursion
                     (and (zerop (forward-line -1))
                          (looking-at diff-file-junk-re)))
              (forward-line -1)))
      ;; File starts *after* the starting point: we really weren't in
      ;; a file diff but elsewhere.
      (goto-char orig)
      (signal (car err) (cdr err)))))

  (let ((orig (point))
        (start (progn (diff-beginning-of-file-and-junk) (point)))
    (if (> orig (point)) (error "Not inside a file diff"))
(defun diff-splittable-p ()
  (save-excursion
    (beginning-of-line)
    (and (looking-at "^[-+ ]")
         (progn (forward-line -1) (looking-at "^[-+ ]"))
         (diff-unified-hunk-p))))

    (unless (looking-at diff-hunk-header-re-unified)
	   (start2 (string-to-number (match-string 3)))
(defvar diff-remembered-defdir nil)
			       nil (diff-find-file-name old 'noprompt) t))))
(defun diff-find-file-name (&optional old noprompt prefix)
Non-nil NOPROMPT means to prefer returning nil than to prompt the user.
  (unless (equal diff-remembered-defdir default-directory)
    ;; Flush diff-remembered-files-alist if the default-directory is changed.
    (set (make-local-variable 'diff-remembered-defdir) default-directory)
    (set (make-local-variable 'diff-remembered-files-alist) nil))
			       ;; Use file-regular-p to avoid
			       ;; /dev/null, directories, etc.
			       ((or (null file) (file-regular-p file))
	    (diff-find-file-name old noprompt (match-string 1)))
       (unless noprompt
         (let ((file (read-file-name (format "Use file %s: "
                                             (or (first fs) ""))
                                     nil (first fs) t (first fs))))
           (set (make-local-variable 'diff-remembered-files-alist)
                (cons (cons fs file) diff-remembered-files-alist))
           file))))))
else cover the whole buffer."
      (while (and (re-search-forward
                   (concat "^\\(\\(---\\) .+\n\\(\\+\\+\\+\\) .+\\|"
                           diff-hunk-header-re-unified ".*\\)$")
                   nil t)
		  (lines1 (or (match-string 5) "1"))
		  (lines2 (or (match-string 7) "1"))
		  ;; Variables to use the special undo function.
		  (old-undo buffer-undo-list)
		  (old-end (marker-position end))
		  (start (match-beginning 0))
		  (reversible t))
					    -1))
		       " ****"))
		(narrow-to-region (line-beginning-position 2)
                                  ;; Call diff-end-of-hunk from just before
                                  ;; the hunk header so it can use the hunk
                                  ;; header info.
                          ;; diff-valid-unified-empty-line.
                          (?\n (insert "  ") (setq modif nil) (backward-char 2))
						 -1))
                            " ----\n" hunk))
		      (if (save-excursion (re-search-forward "^\\+.*\n-" nil t))
                          ;; Normally, lines in a substitution come with
                          ;; first the removals and then the additions, and
                          ;; the context->unified function follows this
                          ;; convention, of course.  Yet, other alternatives
                          ;; are valid as well, but they preclude the use of
                          ;; context->unified as an undo command.
			  (setq reversible nil))
                          ;; diff-valid-unified-empty-line.
                          (?\n (insert "  ") (setq modif nil) (backward-char 2)
                               (setq reversible nil))
			    (setq delete nil)))))))
		(unless (or (not reversible) (eq buffer-undo-list t))
                  ;; Drop the many undo entries and replace them with
                  ;; a single entry that uses diff-context->unified to do
                  ;; the work.
		  (setq buffer-undo-list
			(cons (list 'apply (- old-end end) start (point-max)
				    'diff-context->unified start (point-max))
			      old-undo)))))))))))
          (inhibit-read-only t))
        (goto-char start)
        (while (and (re-search-forward "^\\(\\(\\*\\*\\*\\) .+\n\\(---\\) .+\\|\\*\\{15\\}.*\n\\*\\*\\* \\([0-9]+\\),\\(-?[0-9]+\\) \\*\\*\\*\\*\\)$" nil t)
                    (< (point) end))
          (combine-after-change-calls
            (if (match-beginning 2)
                ;; we matched a file header
                (progn
                  ;; use reverse order to make sure the indices are kept valid
                  (replace-match "+++" t t nil 3)
                  (replace-match "---" t t nil 2))
              ;; we matched a hunk header
              (let ((line1s (match-string 4))
                    (line1e (match-string 5))
                    (pt1 (match-beginning 0))
                    ;; Variables to use the special undo function.
                    (old-undo buffer-undo-list)
                    (old-end (marker-position end))
                    (reversible t))
                (replace-match "")
                (unless (re-search-forward
                         diff-context-mid-hunk-header-re nil t)
                  (error "Can't find matching `--- n1,n2 ----' line"))
                (let ((line2s (match-string 1))
                      (line2e (match-string 2))
                      (pt2 (progn
                             (delete-region (progn (beginning-of-line) (point))
                                            (progn (forward-line 1) (point)))
                             (point-marker))))
                  (goto-char pt1)
                  (forward-line 1)
                  (while (< (point) pt2)
                    (case (char-after)
                      (?! (delete-char 2) (insert "-") (forward-line 1))
                      (?- (forward-char 1) (delete-char 1) (forward-line 1))
                      (?\s           ;merge with the other half of the chunk
                       (let* ((endline2
                               (save-excursion
                                 (goto-char pt2) (forward-line 1) (point))))
                         (case (char-after pt2)
                           ((?! ?+)
                            (insert "+"
                                    (prog1 (buffer-substring (+ pt2 2) endline2)
                                      (delete-region pt2 endline2))))
                           (?\s
                            (unless (= (- endline2 pt2)
                                       (- (line-beginning-position 2) (point)))
                              ;; If the two lines we're merging don't have the
                              ;; same length (can happen with "diff -b"), then
                              ;; diff-unified->context will not properly undo
                              ;; this operation.
                              (setq reversible nil))
                            (delete-region pt2 endline2)
                            (delete-char 1)
                            (forward-line 1))
                           (?\\ (forward-line 1))
                           (t (setq reversible nil)
                              (delete-char 1) (forward-line 1)))))
                      (t (setq reversible nil) (forward-line 1))))
                  (while (looking-at "[+! ] ")
                    (if (/= (char-after) ?!) (forward-char 1)
                      (delete-char 1) (insert "+"))
                    (delete-char 1) (forward-line 1))
                  (save-excursion
                    (goto-char pt1)
                    (insert "@@ -" line1s ","
                            (number-to-string (- (string-to-number line1e)
                                                 (string-to-number line1s)
                                                 -1))
                            " +" line2s ","
                            (number-to-string (- (string-to-number line2e)
                                                 (string-to-number line2s)
                                                 -1)) " @@"))
                  (set-marker pt2 nil)
                  ;; The whole procedure succeeded, let's replace the myriad
                  ;; of undo elements with just a single special one.
                  (unless (or (not reversible) (eq buffer-undo-list t))
                    (setq buffer-undo-list
                          (cons (list 'apply (- old-end end) pt1 (point)
                                      'diff-unified->context pt1 (point))
                                old-undo)))
                  )))))))))
else cover the whole buffer."
		  (unless (looking-at diff-context-mid-hunk-header-re)
		  (let* ((str1end (or (match-end 2) (match-end 1)))
                         (str1 (buffer-substring (match-beginning 1) str1end)))
                    (goto-char str1end)
                    (insert lines1)
                    (delete-region (match-beginning 1) str1end)
			  (memq c (if diff-valid-unified-empty-line
                                      '(?\s ?\n) '(?\s)))))
else cover the whole buffer."
      (goto-char end) (diff-end-of-hunk nil 'donttrustheader)
		    (concat diff-hunk-header-re-unified
	     ((looking-at diff-hunk-header-re-unified)
	      (let* ((old1 (match-string 2))
		     (old2 (match-string 4))
                (if old2
                    (unless (string= new2 old2) (replace-match new2 t t nil 4))
                  (goto-char (match-end 4)) (insert "," new2))
                (if old1
                    (unless (string= new1 old1) (replace-match new1 t t nil 2))
                  (goto-char (match-end 2)) (insert "," new1))))
	     ((looking-at diff-context-mid-hunk-header-re)
	;; We used to fixup modifs on all the changes, but it turns out that
	;; it's safer not to do it on big changes, e.g. when yanking a big
	;; diff, or when the user edits the header, since we might then
	;; screw up perfectly correct values.  --Stef
        (let* ((style (if (looking-at "\\*\\*\\*") 'context))
               (start (line-beginning-position (if (eq style 'context) 3 2)))
               (mid (if (eq style 'context)
                        (save-excursion
                          (re-search-forward diff-context-mid-hunk-header-re
                                             nil t)))))
          (when (and ;; Don't try to fixup changes in the hunk header.
                 (> (car diff-unhandled-changes) start)
                 ;; Don't try to fixup changes in the mid-hunk header either.
                 (or (not mid)
                     (< (cdr diff-unhandled-changes) (match-beginning 0))
                     (> (car diff-unhandled-changes) (match-end 0)))
                 (save-excursion
		(diff-end-of-hunk nil 'donttrustheader)
                   ;; Don't try to fixup changes past the end of the hunk.
                   (>= (point) (cdr diff-unhandled-changes))))
      (setq diff-unhandled-changes nil))))
(defvar whitespace-style)
(defvar whitespace-trailing-regexp)

  (set (make-local-variable 'beginning-of-defun-function)
       'diff-beginning-of-file-and-junk)
  (set (make-local-variable 'end-of-defun-function)
       'diff-end-of-file)

  ;; Set up `whitespace-mode' so that turning it on will show trailing
  ;; whitespace problems on the modified lines of the diff.
  (set (make-local-variable 'whitespace-style) '(trailing))
  (set (make-local-variable 'whitespace-trailing-regexp)
       "^[-\+!<>].*?\\([\t ]+\\)$")

       (lambda () (diff-find-file-name nil 'noprompt))))
      (and (re-search-forward diff-hunk-header-re-unified nil t)
	   (equal (match-string 2) (match-string 4)))))
        (if (not (looking-at "\\*\\{15\\}\\(?: .*\\)?\n\\*\\*\\* \\([0-9]+\\)\\(?:,\\([0-9]+\\)\\)? \\*\\*\\*\\*"))
	   (if (match-end 2)
	       (1+ (- (string-to-number (match-string 2))
		      (string-to-number (match-string 1))))
	     1))
          (if (not (looking-at diff-context-mid-hunk-header-re))
	     (if (match-end 2)
		 (1+ (- (string-to-number (match-string 2))
			(string-to-number (match-string 1))))
	       1)))))
        (if (not (looking-at diff-hunk-header-re-unified))
          (let ((before (string-to-number (or (match-string 2) "1")))
                (after (string-to-number (or (match-string 4) "1"))))
                  (?-
                   (if (and (looking-at diff-file-header-re)
                            (zerop before) (zerop after))
                       ;; No need to query: this is a case where two patches
                       ;; are concatenated and only counting the lines will
                       ;; give the right result.  Let's just add an empty
                       ;; line so that our code which doesn't count lines
                       ;; will not get confused.
                       (progn (save-excursion (insert "\n")) nil)
                     (decf before) t))
                    ((and diff-valid-unified-empty-line
                          ;; Not just (eolp) so we don't infloop at eob.
                          (eq (char-after) ?\n)
                          (> before 0) (> after 0))
                     (decf before) (decf after) t)
                    ((not (y-or-n-p (concat "Try to auto-fix " (if (eolp) "whitespace loss" "word-wrap damage") "? ")))
	     (re-search-forward diff-context-mid-hunk-header-re nil t)
(defsubst diff-xor (a b) (if a (if (not b) a) b))
(defun diff-find-source-location (&optional other-file reverse noprompt)
SWITCHED is non-nil if the patch is already applied.
NOPROMPT, if non-nil, means not to prompt the user."
	   (char-offset (- (point) (progn (diff-beginning-of-hunk 'try-harder)
                                          (point))))
	   ;;
	   ;; Suppress check when NOPROMPT is non-nil (Bug#3033).
           (_ (unless noprompt (diff-sanity-check-hunk)))
	   (hunk (buffer-substring
                  (point) (save-excursion (diff-end-of-hunk) (point))))
		       (unless (re-search-forward
                                diff-context-mid-hunk-header-re nil t)
	   (file (or (diff-find-file-name other noprompt)
                     (error "Can't find the file")))
        (goto-char (point-min)) (forward-line (1- (string-to-number line)))
      ;; Sometimes we'd like to have the following behavior: if REVERSE go
      ;; to the new file, otherwise go to the old.  But that means that by
      ;; default we use the old file, which is the opposite of the default
      ;; for diff-goto-source, and is thus confusing.  Also when you don't
      ;; know about it it's pretty surprising.
      ;; TODO: make it possible to ask explicitly for this behavior.
      ;;
      ;; This is duplicated in diff-test-hunk.
      (diff-find-source-location nil reverse)
      (diff-find-source-location nil reverse)
  ;; Kill change-log-default-name so it gets recomputed each time, since
  ;; each hunk may belong to another file which may belong to another
  ;; directory and hence have a different ChangeLog file.
  (kill-local-variable 'change-log-default-name)
    (destructuring-bind (&optional buf line-offset pos src dst switched)
        ;; Use `noprompt' since this is used in which-func-mode and such.
	(ignore-errors                ;Signals errors in place of prompting.
          (diff-find-source-location nil nil 'noprompt))
      (when buf
        (beginning-of-line)
        (or (when (memq (char-after) '(?< ?-))
              ;; Cursor is pointing at removed text.  This could be a removed
              ;; function, in which case, going to the source buffer will
              ;; not help since the function is now removed.  Instead,
              ;; try to figure out the function name just from the
              ;; code-fragment.
              (let ((old (if switched dst src)))
                (with-temp-buffer
                  (insert (car old))
                  (funcall (buffer-local-value 'major-mode buf))
                  (goto-char (+ (point-min) (cdr old)))
                  (add-log-current-defun))))
            (with-current-buffer buf
              (goto-char (+ (car pos) (cdr src)))
              (add-log-current-defun)))))))

(defun diff-ignore-whitespace-hunk ()
  "Re-diff the current hunk, ignoring whitespace differences."
  (let* ((char-offset (- (point) (progn (diff-beginning-of-hunk 'try-harder)
                                        (point))))
	 (inhibit-read-only t)
;;; Fine change highlighting.

(defface diff-refine-change
  '((((class color) (min-colors 88) (background light))
     :background "grey85")
    (((class color) (min-colors 88) (background dark))
     :background "grey60")
    (((class color) (background light))
     :background "yellow")
    (((class color) (background dark))
     :background "green")
    (t :weight bold))
  "Face used for char-based changes shown by `diff-refine-hunk'."
  :group 'diff-mode)

(defun diff-refine-preproc ()
  (while (re-search-forward "^[+>]" nil t)
    ;; Remove spurious changes due to the fact that one side of the hunk is
    ;; marked with leading + or > and the other with leading - or <.
    ;; We used to replace all the prefix chars with " " but this only worked
    ;; when we did char-based refinement (or when using
    ;; smerge-refine-weight-hack) since otherwise, the `forward' motion done
    ;; in chopup do not necessarily do the same as the ones in highlight
    ;; since the "_" is not treated the same as " ".
    (replace-match (cdr (assq (char-before) '((?+ . "-") (?> . "<"))))))
  )

(defun diff-refine-hunk ()
  "Highlight changes of hunk at point at a finer granularity."
  (interactive)
  (eval-and-compile (require 'smerge-mode))
  (save-excursion
    (diff-beginning-of-hunk 'try-harder)
    (let* ((start (point))
           (style (diff-hunk-style))    ;Skips the hunk header as well.
           (beg (point))
           (props '((diff-mode . fine) (face diff-refine-change)))
           ;; Be careful to go back to `start' so diff-end-of-hunk gets
           ;; to read the hunk header's line info.
           (end (progn (goto-char start) (diff-end-of-hunk) (point))))

      (remove-overlays beg end 'diff-mode 'fine)

      (goto-char beg)
      (case style
        (unified
         (while (re-search-forward "^\\(?:-.*\n\\)+\\(\\)\\(?:\\+.*\n\\)+"
                                   end t)
           (smerge-refine-subst (match-beginning 0) (match-end 1)
                                (match-end 1) (match-end 0)
                                props 'diff-refine-preproc)))
        (context
         (let* ((middle (save-excursion (re-search-forward "^---")))
                (other middle))
           (while (re-search-forward "^\\(?:!.*\n\\)+" middle t)
             (smerge-refine-subst (match-beginning 0) (match-end 0)
                                  (save-excursion
                                    (goto-char other)
                                    (re-search-forward "^\\(?:!.*\n\\)+" end)
                                    (setq other (match-end 0))
                                    (match-beginning 0))
                                  other
                                  props 'diff-refine-preproc))))
        (t ;; Normal diffs.
         (let ((beg1 (1+ (point))))
           (when (re-search-forward "^---.*\n" end t)
             ;; It's a combined add&remove, so there's something to do.
             (smerge-refine-subst beg1 (match-beginning 0)
                                  (match-end 0) end
                                  props 'diff-refine-preproc))))))))


(defun diff-add-change-log-entries-other-window ()
  "Iterate through the current diff and create ChangeLog entries.
I.e. like `add-change-log-entry-other-window' but applied to all hunks."
  (interactive)
  ;; XXX: Currently add-change-log-entry-other-window is only called
  ;; once per hunk.  Some hunks have multiple changes, it would be
  ;; good to call it for each change.
  (save-excursion
    (goto-char (point-min))
    (let ((orig-buffer (current-buffer)))
      (condition-case nil
	  ;; Call add-change-log-entry-other-window for each hunk in
	  ;; the diff buffer.
	  (while (progn
                   (diff-hunk-next)
                   ;; Move to where the changes are,
                   ;; `add-change-log-entry-other-window' works better in
                   ;; that case.
                   (re-search-forward
                    (concat "\n[!+-<>]"
                            ;; If the hunk is a context hunk with an empty first
                            ;; half, recognize the "--- NNN,MMM ----" line
                            "\\(-- [0-9]+\\(,[0-9]+\\)? ----\n"
                            ;; and skip to the next non-context line.
                            "\\( .*\n\\)*[+]\\)?")
                    nil t))
            (save-excursion
              ;; FIXME: this pops up windows of all the buffers.
              (add-change-log-entry nil nil t nil t)))
        ;; When there's no more hunks, diff-hunk-next signals an error.
	(error nil)))))
