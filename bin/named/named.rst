.. Copyright (C) Internet Systems Consortium, Inc. ("ISC")
..
.. SPDX-License-Identifier: MPL-2.0
..
.. This Source Code Form is subject to the terms of the Mozilla Public
.. License, v. 2.0.  If a copy of the MPL was not distributed with this
.. file, you can obtain one at https://mozilla.org/MPL/2.0/.
..
.. See the COPYRIGHT file distributed with this work for additional
.. information regarding copyright ownership.

.. highlight: console

.. _man_named:

named - Internet domain name server
-----------------------------------

Synopsis
~~~~~~~~

:program:`named` [ [**-4**] | [**-6**] ] [**-c** config-file] [**-d** debug-level] [**-D** string] [**-E** engine-name] [**-f**] [**-g**] [**-L** logfile] [**-M** option] [**-m** flag] [**-n** #cpus] [**-p** port] [**-s**] [**-t** directory] [**-U** #listeners] [**-u** user] [**-v**] [**-V**] [**-X** lock-file]

Description
~~~~~~~~~~~

``named`` is a Domain Name System (DNS) server, part of the BIND 9
distribution from ISC. For more information on the DNS, see :rfc:`1033`,
:rfc:`1034`, and :rfc:`1035`.

When invoked without arguments, ``named`` reads the default
configuration file |named_conf|, reads any initial data, and
listens for queries.

Options
~~~~~~~

``-4``
   This option tells ``named`` to use only IPv4, even if the host machine is capable of IPv6. ``-4`` and
   ``-6`` are mutually exclusive.

``-6``
   This option tells ``named`` to use only IPv6, even if the host machine is capable of IPv4. ``-4`` and
   ``-6`` are mutually exclusive.

``-c config-file``
   This option tells ``named`` to use ``config-file`` as its configuration file instead of the default,
   |named_conf|. To ensure that the configuration file
   can be reloaded after the server has changed its working directory
   due to to a possible ``directory`` option in the configuration file,
   ``config-file`` should be an absolute pathname.

``-d debug-level``
   This option sets the daemon's debug level to ``debug-level``. Debugging traces from
   ``named`` become more verbose as the debug level increases.

``-D string``
   This option specifies a string that is used to identify a instance of ``named``
   in a process listing. The contents of ``string`` are not examined.

``-E engine-name``
   When applicable, this option specifies the hardware to use for cryptographic
   operations, such as a secure key store used for signing.

   When BIND 9 is built with OpenSSL, this needs to be set to the OpenSSL
   engine identifier that drives the cryptographic accelerator or
   hardware service module (usually ``pkcs11``).

``-f``
   This option runs the server in the foreground (i.e., do not daemonize).

``-g``
   This option runs the server in the foreground and forces all logging to ``stderr``.

``-L logfile``
   This option sets the log to the file ``logfile`` by default, instead of the system log.

``-M option``
   This option sets the default memory context options. If set to ``external``,
   the internal memory manager is bypassed in favor of
   system-provided memory allocation functions. If set to ``fill``, blocks
   of memory are filled with tag values when allocated or freed, to
   assist debugging of memory problems. ``nofill`` disables this behavior,
   and is the default unless ``named`` has been compiled with developer
   options.

``-m flag``
   This option turns on memory usage debugging flags. Possible flags are ``usage``,
   ``trace``, ``record``, ``size``, and ``mctx``. These correspond to the
   ``ISC_MEM_DEBUGXXXX`` flags described in ``<isc/mem.h>``.

``-n #cpus``
   This option creates ``#cpus`` worker threads to take advantage of multiple CPUs. If
   not specified, ``named`` tries to determine the number of CPUs
   present and creates one thread per CPU. If it is unable to determine
   the number of CPUs, a single worker thread is created.

``-p value``
   This option specifies the port(s) on which the server will listen
   for queries. If ``value`` is of the form ``<portnum>`` or
   ``dns=<portnum>``, the server will listen for DNS queries on
   ``portnum``; if not not specified, the default is port 53. If
   ``value`` is of the form ``tls=<portnum>``, the server will
   listen for TLS queries on ``portnum``; the default is 853.
   If ``value`` is of the form ``https=<portnum>``, the server will
   listen for HTTPS queries on ``portnum``; the default is 443.
   If ``value`` is of the form ``http=<portnum>``, the server will
   listen for HTTP queries on ``portnum``; the default is 80.
   
``-s``
   This option writes memory usage statistics to ``stdout`` on exit.

.. note::

      This option is mainly of interest to BIND 9 developers and may be
      removed or changed in a future release.

``-S #max-socks``
   This option is deprecated and no longer has any function.

.. warning::

      This option should be unnecessary for the vast majority of users.
      The use of this option could even be harmful, because the specified
      value may exceed the limitation of the underlying system API. It
      is therefore set only when the default configuration causes
      exhaustion of file descriptors and the operational environment is
      known to support the specified number of sockets. Note also that
      the actual maximum number is normally slightly fewer than the
      specified value, because ``named`` reserves some file descriptors
      for its internal use.

``-t directory``
   This option tells ``named`` to chroot to ``directory`` after processing the command-line arguments, but
   before reading the configuration file.

.. warning::

      This option should be used in conjunction with the ``-u`` option,
      as chrooting a process running as root doesn't enhance security on
      most systems; the way ``chroot`` is defined allows a process
      with root privileges to escape a chroot jail.

``-U #listeners``
   This option tells ``named`` the number of ``#listeners`` worker threads to listen on, for incoming UDP packets on
   each address. If not specified, ``named`` calculates a default
   value based on the number of detected CPUs: 1 for 1 CPU, and the
   number of detected CPUs minus one for machines with more than 1 CPU.
   This cannot be increased to a value higher than the number of CPUs.
   If ``-n`` has been set to a higher value than the number of detected
   CPUs, then ``-U`` may be increased as high as that value, but no
   higher.

``-u user``
   This option sets the setuid to ``user`` after completing privileged operations, such as
   creating sockets that listen on privileged ports.

.. note::

      On Linux, ``named`` uses the kernel's capability mechanism to drop
      all root privileges except the ability to ``bind`` to a
      privileged port and set process resource limits. Unfortunately,
      this means that the ``-u`` option only works when ``named`` is run
      on kernel 2.2.18 or later, or kernel 2.3.99-pre3 or later, since
      previous kernels did not allow privileges to be retained after
      ``setuid``.

``-v``
   This option reports the version number and exits.

``-V``
   This option reports the version number and build options, and exits.

``-X lock-file``
   This option acquires a lock on the specified file at runtime; this helps to
   prevent duplicate ``named`` instances from running simultaneously.
   Use of this option overrides the ``lock-file`` option in
   ``named.conf``. If set to ``none``, the lock file check is disabled.

Signals
~~~~~~~

In routine operation, signals should not be used to control the
nameserver; ``rndc`` should be used instead.

SIGHUP
   This signal forces a reload of the server.

SIGINT, SIGTERM
   These signals shut down the server.

The result of sending any other signals to the server is undefined.

Configuration
~~~~~~~~~~~~~

The ``named`` configuration file is too complex to describe in detail
here. A complete description is provided in the BIND 9 Administrator
Reference Manual.

``named`` inherits the ``umask`` (file creation mode mask) from the
parent process. If files created by ``named``, such as journal files,
need to have custom permissions, the ``umask`` should be set explicitly
in the script used to start the ``named`` process.

Files
~~~~~

|named_conf|
   The default configuration file.

|named_pid|
   The default process-id file.

See Also
~~~~~~~~

:rfc:`1033`, :rfc:`1034`, :rfc:`1035`, :manpage:`named-checkconf(8)`, :manpage:`named-checkzone(8)`, :manpage:`rndc(8)`, :manpage:`named.conf(5)`, BIND 9 Administrator Reference Manual.
