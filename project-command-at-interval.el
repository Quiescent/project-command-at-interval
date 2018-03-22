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

(defvar project-command-at-interval-timers (make-hash-table :test #'equal)
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
    (if (gethash project-root project-command-at-interval-timers)
        (user-error "A command is already runnig for this project")
      (puthash project-root (run-at-time t (string-to-number interval)
                                         (lambda ()
                                           (start-file-process-shell-command process-name
                                                                             (get-buffer-create process-name)
                                                                             command-at-root)))
               project-command-at-interval-timers))))

(defun project-command-at-interval-stop-current ()
  "Cancel the command for the current project.

  Posts the command to the MESSAGES buffer."
  (interactive)
  (let* ((project-root          (car (project-roots (project-current))))
         (project-command-timer (gethash project-root project-command-at-interval-timers)))
    (if project-command-timer
        (progn
          (cancel-timer project-command-timer)
          (remhash project-root project-command-at-interval-timers)
          (message "Terminated: %s" project-command-timer))
      (user-error (format "No command running in %s" project-root)))))

(provide 'project-command-at-interval)
;;; project-command-at-interval ends here
