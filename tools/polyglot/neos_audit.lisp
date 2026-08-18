;;;; NeOS Profile Auditor in Common Lisp (SBCL / CLISP)

(defun file-exists-p (path)
  (probe-file path))

(defun read-packages (file-path)
  (with-open-file (stream file-path :direction :input :if-does-not-exist nil)
    (when stream
      (loop for line = (read-line stream nil nil)
            while line
            for trimmed = (string-trim '(#\Space #\Tab #\Newline #\Return) line)
            when (and (> (length trimmed) 0) (not (char= (char trimmed 0) #\#)))
            collect trimmed))))

(defun audit-profile (&optional (root-dir "."))
  (format t "~c[1;36m[Common-Lisp::Audit]~c[0m Auditing NeOS profile at: ~A~%" #\Esc #\Esc root-dir)
  (let ((required-files '("profile/profiledef.sh"
                          "profile/pacman.conf"
                          "profile/grub/grub.cfg"
                          "profile/syslinux/syslinux.cfg"
                          "profile/packages.x86_64"
                          "profile/airootfs/etc/pacman.d/neos-mirrorlist")))
    (dolist (file required-files)
      (let ((full-path (merge-pathnames file (pathname (concatenate 'string root-dir "/")))))
        (unless (file-exists-p full-path)
          (format *error-output* "❌ Missing required file: ~A~%" full-path)
          (sb-ext:exit :code 1)))))

  (let* ((pkg-path (merge-pathnames "profile/packages.x86_64" (pathname (concatenate 'string root-dir "/"))))
         (packages (read-packages pkg-path)))
    (unless packages
      (format *error-output* "❌ packages.x86_64 is empty or missing~%")
      (sb-ext:exit :code 1))
    (format t "~c[1;32m✓ Common Lisp Audit Passed! Verified ~D packages.~c[0m~%" #\Esc #\Esc (length packages))))

(audit-profile)
