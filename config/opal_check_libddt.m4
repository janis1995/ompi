# -*- shell-script -*-
#
# Copyright (c) 2024      Esslingen University. All rights reserved.
# $COPYRIGHT$
#
# Additional copyrights may follow
#
# $HEADER$
#

# OPAL_CHECK_LIBDDTPACK
# --------------------------------------------------------
# Check for presence of the libddtpack-library for JIT-based datatype conversion
AC_DEFUN([OPAL_CHECK_LIBDDTPACK],[
    OPAL_VAR_SCOPE_PUSH([opal_check_libddtpack_happy opal_check_libddtpack_CPPFLAGS_save opal_check_libddtpack_LDFLAGS_save])

    AC_ARG_WITH([libddtpack],
                [AS_HELP_STRING([--with-libddtpack(=DIR)],
                                [Build with support for JIT datatype conversion, searching for headers and lib in DIR])])

    opal_check_libddtpack_CPPFLAGS_save="${CPPFLAGS}"
    opal_check_libddtpack_LDFLAGS_save="${LDFLAGS}"

    AS_IF([test -n "${with_libddtpack}" -a "${with_libddtpack}" != "yes" -a "${with_libddtpack}" != "no"],
          [
            opal_datatype_libddtpack_CPPFLAGS="-I${with_libddtpack}/include"
            opal_datatype_libddtpack_LDFLAGS="-L${with_libddtpack}/lib -lddtpack"
            CPPFLAGS="$CPPFLAGS ${opal_datatype_libddtpack_CPPFLAGS}"
            LDFLAGS="$LDFLAGS ${opal_datatype_libddtpack_LDFLAGS}"
          ])
   
    AC_CHECK_HEADER([ddtpack.h], [opal_check_libddtpack_happy="yes"], [opal_check_libddtpack_happy="no"])

    AS_IF([test "$opal_check_libddtpack_happy" = "yes"],
        [OPAL_CHECK_libddtpack_LIBRARY],
        [AC_MSG_ERROR([Was not able to find ddtpack.h.  Currently not optional.   Aborting])])
    
    # Instead of substituting our own new variables to be used in (quite many) Makefile.am, we keep CPPFLAGS set,
    # since several places slurp in opal_convertor.h and opal_datatype.h
    # AC_SUBST([opal_datatype_libddtpack_CPPFLAGS])
    # AC_SUBST([opal_datatype_libddtpack_LDFLAGS])
    # CPPFLAGS="${opal_check_libddtpack_CPPFLAGS_save}"
    # LDFLAGS="${opal_check_libddtpack_LDFLAGS_save}"

    OPAL_VAR_SCOPE_POP
])dnl

AC_DEFUN([OPAL_CHECK_libddtpack_LIBRARY],[
    AC_MSG_CHECKING([compile and run with libddtpack])
    AC_RUN_IFELSE([AC_LANG_PROGRAM([[
#include "ddtpack.h"
static int do_check (void) {
    ddtpack_datatype_s dt;
    ddtpack_dt_elem_desc_u elem[2];

    elem[0].elem.common.flags = DDTPACK_DATATYPE_FLAG_DATA;
    elem[0].elem.common.type = DDTPACK_DATATYPE_INT4;
    elem[0].elem.count = 1;
    elem[0].elem.blocklen = 1;
    elem[0].elem.extent = 4;
    elem[0].elem.disp = 0;

    elem[1].elem.common.flags = DDTPACK_DATATYPE_FLAG_DATA;
    elem[1].elem.common.type = DDTPACK_DATATYPE_FLOAT4;
    elem[1].elem.count = 1;
    elem[1].elem.blocklen = 1;
    elem[1].elem.extent = 4;
    elem[1].elem.disp = 4;

    dt.desc.used = 2;
    dt.desc.length = 2;
    dt.desc.desc = elem;

    return ddtpack_commit(&dt);
}
]],[[
    int rc = ddtpack_init();
    if (0 != rc)
        return rc;
    rc = do_check ();
    if (0 != rc)
        return rc;
    rc = ddtpack_finalize();
    return rc;
]])],
    [AC_MSG_RESULT([yes])
     opal_check_libddtpack_happy="yes"],
    [AC_MSG_RESULT([no])
     opal_check_libddtpack_happy="no"],
    [AC_MSG_RESULT([no (cross-compiling)])
     opal_check_libddtpack_happy="no"])

AS_IF([test "$opal_check_libddtpack_happy" = "yes"],
       [],
       [AC_MSG_ERROR([Was not able to compile against and run with libddtpack.  Currently not optional.   Aborting])])
])dnl
