;;; manual-tagging.el ---

;; Copyright (C) 2012 Grégoire Jadi

;; Author: Grégoire Jadi <gregoire.jadi@gmail.com>

;; This program is free software: you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation, either version 3 of
;; the License, or (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;;; Code:

(defgroup manual-tagging nil
  "Manual Tagging"
  :group 'faces)

(defcustom mt-separator "/"
  "*The separator used between a token and its tag."
  :type 'string
  :group 'manual-tagging)

(defvar mt-overlay nil)
(make-local-variable 'mt-overlay)

(make-face 'mt-face)
(defcustom mt-face
  nil
  "*The face used to highlight the current word."
  :group 'manual-tagging)

(defcustom mt-pos-tagging
  '(("ADJ" "adjective" "new, good, high, special, big, local")
    ("ADV" "adverb" "really, already, still, early, now")
    ("CNJ" "conjunction" "and, or, but, if, while, although")
    ("DET" "determiner" "the, a, some, most, every, no")
    ("EX" "existential" "there, there's")
    ("FW" "foreign word" "dolce, ersatz, esprit, quo, maitre")
    ("MOD" "modal verb" "will, can, would, may, must, should")
    ("N" "noun" "year, home, costs, time, education")
    ("NP" "proper noun" "Alison, Africa, April, Washington")
    ("NUM" "number" "twenty-four, fourth, 1991, 14:24")
    ("PRO" "pronoun" "he, their, her, its, my, I, us")
    ("P" "preposition" "on, of, at, with, by, into, under")
    ("TO" "the word to" "to")
    ("UH" "interjection" "ah, bang, ha, whee, hmpf, oops")
    ("V" "verb" "is, has, get, do, make, see, run")
    ("VD" "past tense" "said, took, told, made, asked")
    ("VG" "present participle" "making, going, playing, working")
    ("VN" "past participle" "given, taken, begun, sung")
    ("WH" "wh determiner" "who, which, when, what, where, how"))
  "*http://nltk.googlecode.com/svn/trunk/doc/book/ch05.html#tab-simplified-tagset"
  :type '(repeat
          (list (string :tag "Tag name")
                (string :tag "Short description")
                (string :tag "Examples")))
  :group 'manual-tagging)

(defun mt-insert-tag (tag)
  (save-excursion
    (goto-char (1- (search-forward " ")))
    (insert mt-separator
            tag)))

(defun mt-next-token ()
  (search-forward " " nil t))

(defun mt-prev-token ()
  (let ((pos (search-backward " " nil t 2)))
    (if (null pos)                      ; beginning of file
        (goto-char (point-min))
      (goto-char (1+ pos)               ; skip white space
                 ))))

(defun mt-ask-tag (tag)
  (interactive
   (list
    (let   ((completion-extra-properties
             '(:annotation-function mt-annotation-function))
            (completion-ignore-case t))
      (completing-read "Tag? "
                       mt-pos-tagging
                       nil
                       t))))
  tag)

(defun mt-find-tag-help (tag)
  (assoc tag mt-pos-tagging))

(defun mt-format-tag-help (tag-help)
  (format "\t\t%s\t%s"
          (second tag-help)
          (third tag-help)))

(defun mt-annotation-function (tag)
  (let ((tag-help (mt-find-tag-help tag)))
    (when tag-help
      (mt-format-tag-help tag-help))))

(defun mt-start ()
  (interactive)
  (unwind-protect
      (progn
        (mt-create-overlay)
        (goto-char (point-min))
        (loop do (mt-show-token)
              for tag = (call-interactively #'mt-ask-tag)
              do (mt-insert-tag tag)

              while (mt-next-token)))
    (mt-delete-overlay)))

(defun mt-create-overlay ()
  (let ((attribute (face-attr-construct 'mt-face)))
    (set (make-local-variable 'mt-overlay) (make-overlay 0 0))
    (overlay-put mt-overlay 'face attribute)))

(defun mt-delete-overlay ()
  (when mt-overlay
    (delete-overlay mt-overlay))
  (setq mt-overlay nil))

(defun mt-show-token ()
  (move-overlay mt-overlay
                (point)
                (save-excursion (1- (search-forward " ")))))

(provide 'manual-tagging)

;;; manual-tagging.el ends here
