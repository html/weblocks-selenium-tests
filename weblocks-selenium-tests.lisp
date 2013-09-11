;;;; weblocks-selenium-tests.lisp

(in-package #:weblocks-selenium-tests)

(in-root-suite)

(defsuite* all-tests)

(defmacro def-test-suite (name-or-name-with-args &optional args &body body)
  "Defines test suite inside of all-tests suite"
  `(progn 
     (in-suite all-tests)
     (stefil:defsuite* ,name-or-name-with-args ,args ,@body)))

(deftest uploads-file ()
  (require-firefox
    (let ((old-files-list (cl-fad:list-directory (weblocks-selenium-tests-app::get-upload-directory)))
          (new-files-list))
      (with-new-or-existing-selenium-session
        (do-click-and-wait "link=File field form presentation")

        (do-screen-state-test "uploads-file")

        (do-attach-file "name=file" (format nil "~A/pub/test-data/test-file" (string-right-trim "/" *site-url*)))
        (do-click-and-wait "name=submit")
        (setf new-files-list (cl-fad:list-directory (weblocks-selenium-tests-app::get-upload-directory)))
        (is (= (length new-files-list)
               (1+ (length old-files-list))))
        (mapcar #'delete-file new-files-list)))))

(defun sample-dialog-assertions ()
  (is (string= "Dialog title" (do-get-text "css=h2.title-text")))
  (is (string= "Some dialog content" (do-get-text "css=div.dialog-body p")))
  (is (string= "Close dialog" (do-get-text "css=div.dialog-body a"))))

(deftest shows-dialog ()
  (with-new-or-existing-selenium-session 
    (do-click-and-wait "link=Dialog sample")

    (do-screen-state-test "dialog")

    (sample-dialog-assertions)
    (do-click-and-wait "link=Close dialog")))

(deftest shows-dialog-after-page-reloading ()
  (with-new-or-existing-selenium-session 
    (do-click-and-wait "link=Dialog sample")

    (do-screen-state-test "dialog")

    (sample-dialog-assertions)
    (do-refresh)
    (do-open-and-wait *site-url*)
    (sample-dialog-assertions)
    (do-click-and-wait "link=Close dialog")))

(deftest selects-child-navigation-properly ()
  (with-new-or-existing-selenium-session 
    (do-click-and-wait "link=Navigation sample")

    (do-screen-state-test "navigation-step-1")

    (do-click-and-wait "link=Fourth pane (second nested pane)")

    (do-screen-state-test "navigation-step-2")

    (do-click-and-wait "link=First pane")

    (do-screen-state-test "navigation-step-3")

    (do-click-and-wait "link=Fourth pane (second nested pane)") 

    (do-screen-state-test "navigation-step-4")

    (ensure-jquery-loaded-into-document)

    (is (string= 
          "true"
          (do-get-eval 
            (ps:ps 
              (ps:chain 
                (window.j-query "#second-level-nav-2 li:first")
                (has-class "selected-item"))))))))

(deftest gets-quickform-answer ()
  (with-new-or-existing-selenium-session 
    (do-click-and-wait "link=Quickform")
    (do-type "name=some-text" "Test text")
    (do-click-and-wait "name=submit")
    (is (not (null (ppcre:scan "Test text" (do-get-text "css=pre")))))))
