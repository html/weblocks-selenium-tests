
(in-package :weblocks-selenium-tests-app)

;; Define callback function to initialize new sessions
(defun init-user-session (root)
  (setf (widget-children root)
	(list (lambda (&rest args)
		(with-html
		  (:strong "Happy Hacking!"))))))

