;;; ol-notmuch.el --- Links to notmuch messages   -*- lexical-binding: t; -*-

;; Copyright (C) 2010-2011  Matthieu Lemerre
;; Copyright (C) 2010-2021  The Org Contributors

;; Author: Matthieu Lemerre <racin@free.fr>
;; Maintainer: Jonas Bernoulli <jonas@bernoul.li>
;; Keywords: hypermedia, mail
;; Homepage: https://git.sr.ht/~tarsius/ol-notmuch

;; Package-Requires: ((emacs "25.1") (notmuch "0.32") (org "9.4.5"))

;; SPDX-License-Identifier: GPL-3.0-or-later
;;
;; This file is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published
;; by the Free Software Foundation, either version 3 of the License,
;; or (at your option) any later version.
;;
;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this file.  If not, see <https://www.gnu.org/licenses/>.

;; This file is not part of GNU Emacs or Org mode.

;;; Commentary:

;; This file implements links to notmuch messages and "searches".  A
;; search is a query to be performed by notmuch; it is the equivalent
;; to folders in other mail clients.  Similarly, mails are referred to
;; by a query, so both a link can refer to several mails.

;; Links have one the following form
;; notmuch:<search terms>
;; notmuch-search:<search terms>.

;; The first form open the queries in notmuch-show mode, whereas the
;; second link open it in notmuch-search mode.  Note that queries are
;; performed at the time the link is opened, and the result may be
;; different from when the link was stored.

;;; Code:

(require 'notmuch)
(require 'ol)

;;; Message links

(defcustom org-notmuch-open-function 'org-notmuch-follow-link
  "Function used to follow notmuch links.
Should accept a notmuch search string as the sole argument."
  :group 'org-notmuch
  :type 'function)

(org-link-set-parameters "notmuch"
                         :follow #'org-notmuch-open
                         :store #'org-notmuch-store-link)

(defun org-notmuch-store-link ()
  "Store a link to a notmuch search or message."
  (when (memq major-mode '(notmuch-show-mode notmuch-tree-mode))
    (let* ((message-id (notmuch-show-get-message-id t))
           (subject (notmuch-show-get-subject))
           (to (notmuch-show-get-to))
           (from (notmuch-show-get-from))
           (date (org-trim (notmuch-show-get-date)))
           desc link)
      (org-link-store-props :type "notmuch" :from from :to to :date date
                            :subject subject :message-id message-id)
      (setq desc (org-link-email-description))
      (setq link (concat "notmuch:id:" message-id))
      (org-link-add-props :link link :description desc)
      link)))

(defun org-notmuch-open (path _)
  "Follow a notmuch message link specified by PATH."
  (funcall org-notmuch-open-function path))

(defun org-notmuch-follow-link (search)
  "Follow a notmuch link to SEARCH.
Can link to more than one message, if so all matching messages are shown."
  (notmuch-show search))

;;; Search links

(org-link-set-parameters "notmuch-search"
                         :follow #'org-notmuch-search-open
                         :store #'org-notmuch-search-store-link)

(defun org-notmuch-search-store-link ()
  "Store a link to a notmuch search or message."
  (when (eq major-mode 'notmuch-search-mode)
    (let ((link (concat "notmuch-search:" notmuch-search-query-string))
          (desc (concat "Notmuch search: " notmuch-search-query-string)))
      (org-link-store-props :type "notmuch-search"
                            :link link
                            :description desc)
      link)))

(defun org-notmuch-search-open (path _)
  "Follow a notmuch message link specified by PATH."
  (message "%s" path)
  (org-notmuch-search-follow-link path))

(defun org-notmuch-search-follow-link (search)
  "Follow a notmuch link by displaying SEARCH in Notmuch-Search mode."
  (notmuch-search search))

;;; Tree links

(org-link-set-parameters "notmuch-tree"
                         :follow #'org-notmuch-tree-open
                         :store #'org-notmuch-tree-store-link)

(defun org-notmuch-tree-store-link ()
  "Store a link to a notmuch search or message."
  (when (eq major-mode 'notmuch-tree-mode)
    (let ((link (concat "notmuch-tree:" (notmuch-tree-get-query)))
          (desc (concat "Notmuch tree: " (notmuch-tree-get-query))))
      (org-link-store-props :type "notmuch-tree"
                            :link link
                            :description desc)
      link)))

(defun org-notmuch-tree-open (path _)
  "Follow a notmuch message link specified by PATH."
  (message "%s" path)
  (org-notmuch-tree-follow-link path))

(defun org-notmuch-tree-follow-link (search)
  "Follow a notmuch link by displaying SEARCH in Notmuch-Tree mode."
  (notmuch-tree search))

;;; _
(provide 'ol-notmuch)
;; Local Variables:
;; indent-tabs-mode: nil
;; End:
;;; ol-notmuch.el ends here
