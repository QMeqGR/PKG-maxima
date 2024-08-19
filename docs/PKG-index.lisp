(in-package :cl-info)
(let (
(deffn-defvr-pairs '(
; CONTENT: (<INDEX TOPIC> . (<FILENAME> <BYTE OFFSET> <LENGTH IN CHARACTERS> <NODE NAME>))
("myfunc" . ("PKG.info" 1045 485 "Functions and Variables for PKG"))
("myfunc2" . ("PKG.info" 1280 258 "Functions and Variables for PKG"))
("myvar" . ("PKG.info" 991 49 "Functions and Variables for PKG"))
))
(section-pairs '(
; CONTENT: (<NODE NAME> . (<FILENAME> <BYTE OFFSET> <LENGTH IN CHARACTERS>))
("Functions and Variables for PKG" . ("PKG.info" 919 726))
("Introduction to package PKG" . ("PKG.info" 715 96))
)))
(load-info-hashtables (maxima::maxima-load-pathname-directory) deffn-defvr-pairs section-pairs))
