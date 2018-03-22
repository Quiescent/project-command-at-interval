;;; project-command-at-interval --- Run one command per project at an interval and keep track of the command -*- lexical-binding: t; -*-

;;; Commentary:
;; This was originally created for the generation of tags but I
;; realised that it could also be useful for other regular tasks.
;;
;; An extension would be to do something with the output (perhaps warn
;; to commit?).
;;
;; Another extension would be to handle multiple commands per project.

;;; Code:

(require 'project)

(defvar project-command-at-interval-timer-alist '()
  "An alist of project roots to their commands.

  Only one command can be run per project.")

(defun project-command-at-interval-run (interval command)
  "Run COMMAND at the root of the current project.

  Command is repeated every INTERVAL seconds from now.

  Assume that there is one project root."
  (interactive "sinterval: \nscommand: ")
  (let* ((project-root    (car (project-roots (project-current))))
         (command-at-root (concat (expand-file-name project-root) command))
         (process-name    (format "*%s, %s every %s seconds*"
                                  project-root
                                  command
                                  interval)))
    (push (cons project-root (run-at-time t (string-to-number interval)
                                          (lambda ()
                                            (start-file-process-shell-command process-name
                                                                              (get-buffer-create process-name)
                                                                              command-at-root))))
          project-command-at-interval-timer-alist)))

(defun project-command-at-interval-stop-current ()
  "Cancel the command for the current project.

  Posts the command to the MESSAGES buffer."
  (interactive)
  (let ((project-root (car (project-roots (project-current)))))
    (pcase (assoc project-root project-command-at-interval-timer-alist)
      (`(,_ . ,timer)
       (cancel-timer timer)
       (message "Terminated: %s" timer))
      (_ (user-error (format "No project command for %s" project-root))))))

(provide 'project-command-at-interval)
;;; project-command-at-interval ends here
