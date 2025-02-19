#include "kernel/spinlock.h" 
#include "kernel/types.h" 
#include "user/thread.h" 
#include "user/user.h" 
#define PGSIZE 4096

// Create a new thread using the given start_routine and argument.
int thread_create(void *(start_routine)(void*), void *arg) {
    // Allocate a stack pointer of PGSIZE bytes (4096).
    int ptr_size = PGSIZE * sizeof(void);
    void* st_ptr = (void*)malloc(ptr_size);
    int tid = clone(st_ptr);

    // For the child process, call the start_routine function with the argument.
    if (tid == 0) {
        (*start_routine)(arg);
        exit(0);
    }

    // Return 0 for the parent process.
    return 0;
}

// Initialize a lock.
void lock_init(struct lock_t* lock) {
    lock->locked = 0;
}

// Acquire the lock.
void lock_acquire(struct lock_t* lock) {
    // Spin until the lock is acquired.
    while (__sync_lock_test_and_set(&lock->locked, 1) != 0);
    // Ensure memory operations strictly follow the lock acquisition.
    __sync_synchronize();
}

// Release the lock.
void lock_release(struct lock_t* lock) {
    // Ensure all memory operations in the critical section are visible to other CPUs.
    __sync_synchronize();
    // Release the lock by setting it to 0.
    __sync_lock_release(&lock->locked, 0);
}
