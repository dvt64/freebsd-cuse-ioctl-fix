--- sys/fs/cuse/cuse.c.orig
+++ sys/fs/cuse/cuse.c
@@ -37,6 +37,7 @@
 #include <sys/mutex.h>
 #include <sys/condvar.h>
 #include <sys/sysctl.h>
+#include <sys/syscall.h>
 #include <sys/unistd.h>
 #include <sys/malloc.h>
 #include <sys/priv.h>
@@ -1858,8 +1859,24 @@
 		error = 0;
 	}
 
-	if (cmd & IOC_OUT)
+	/*
+	 * Refresh the kernel ioctl buffer from the server bounce buffer.
+	 * sys_ioctl() only copyout()s to userspace when IOC_OUT is set, so
+	 * for IOC_IN-only commands (Linux _IOW) that still update the
+	 * argument - notably EVIOCSFF returning ff_effect.id - copy to the
+	 * user pointer ourselves using the syscall argument saved in td_sa.
+	 */
+	if (len != 0 && (cmd & (IOC_IN | IOC_OUT)))
 		memcpy(data, pcc->ioctl_buffer, len);
+	if (error == 0 && len != 0 &&
+	    (cmd & IOC_IN) != 0 && (cmd & IOC_OUT) == 0 &&
+	    td->td_sa.code == SYS_ioctl) {
+		void *user_ptr;
+
+		user_ptr = (void *)(uintptr_t)td->td_sa.args[2];
+		if (user_ptr != NULL)
+			(void)copyout(pcc->ioctl_buffer, user_ptr, len);
+	}
 
 	cuse_cmd_unlock(pccmd);
 
