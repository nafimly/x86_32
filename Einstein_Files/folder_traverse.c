#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/syscall.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <errno.h>
#include <limits.h>  // <-- ADD THIS for PATH_MAX

// Structure that mirrors the kernel's dirent64 layout
struct linux_dirent64 {
    ino64_t        d_ino;    // 64-bit inode number (the "pointer")
    off64_t        d_off;    // 64-bit offset to next dirent
    unsigned short d_reclen; // Size of this dirent
    unsigned char  d_type;   // File type
    char           d_name[]; // Filename (null-terminated)
};

// File type constants (from linux/dirent.h)
#define DT_UNKNOWN  0
#define DT_FIFO     1
#define DT_CHR      2
#define DT_DIR      4
#define DT_BLK      6
#define DT_REG      8
#define DT_LNK      10
#define DT_SOCK     12

// Function to get file type string
const char* get_type_string(unsigned char type) {
    switch(type) {
        case DT_DIR:  return "DIRECTORY";
        case DT_REG:  return "FILE";
        case DT_LNK:  return "SYMLINK";
        case DT_CHR:  return "CHAR DEV";
        case DT_BLK:  return "BLOCK DEV";
        case DT_FIFO: return "FIFO";
        case DT_SOCK: return "SOCKET";
        default:      return "UNKNOWN";
    }
}

// Recursive raw directory traversal
void raw_traverse(const char* path, int depth) {
    int fd = open(path, O_RDONLY | O_DIRECTORY);
    if (fd < 0) {
        perror("open");
        return;
    }

    // Print indentation based on depth
    for (int i = 0; i < depth; i++) printf("  ");
    printf("[%s]\n", path);

    char buffer[4096];
    long nread;
    
    // Read raw directory entries using getdents64 syscall
    while ((nread = syscall(SYS_getdents64, fd, buffer, sizeof(buffer))) > 0) {
        struct linux_dirent64* d;
        
        // Iterate through the raw byte buffer
        for (long bpos = 0; bpos < nread; bpos += d->d_reclen) {
            d = (struct linux_dirent64*)(buffer + bpos);
            
            // Skip "." and ".." to avoid infinite recursion
            if (strcmp(d->d_name, ".") == 0 || strcmp(d->d_name, "..") == 0) {
                continue;
            }
            
            // Print the raw "pointer" (inode number) and details
            for (int i = 0; i < depth + 1; i++) printf("  ");
            printf("[inode=%lu] [type=%s] -> %s\n", 
                   (unsigned long)d->d_ino, 
                   get_type_string(d->d_type),
                   d->d_name);
            
            // Recursively traverse if it's a directory
            if (d->d_type == DT_DIR) {
                char new_path[PATH_MAX];
                snprintf(new_path, sizeof(new_path), "%s/%s", path, d->d_name);
                raw_traverse(new_path, depth + 1);
            }
        }
    }
    
    close(fd);
}

int main(int argc, char* argv[]) {
    const char* start_path = (argc > 1) ? argv[1] : ".";
    
    printf("=== RAW FOLDER TRAVERSAL ===\n");
    printf("This reads directory entries directly using getdents64 syscall\n");
    printf("No opendir/readdir/fopen used!\n\n");
    
    raw_traverse(start_path, 0);
    
    return 0;
}