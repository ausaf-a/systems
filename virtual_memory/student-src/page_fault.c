#include "paging.h"
#include "pagesim.h"
#include "swapops.h"
#include "stats.h"

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wunused-parameter"

/*  --------------------------------- PROBLEM 6 --------------------------------------
    Checkout PDF section 7 for this problem

    Page fault handler.

    When the CPU encounters an invalid address mapping in a page table,
    it invokes the OS via this handler.

    Your job is to put a mapping in place so that the translation can
    succeed. You can use free_frame() to make an available frame.
    Update the page table with the new frame, and don't forget
    to fill in the frame table.

    When you access a frame, you should update its referenced bit.

    Lastly, you must fill your newly-mapped page with data. If the page has
    never been mapped before, you must read an empty page from disk space and
    update the diskmap. Otherwise, the data will ahve been swapped to the disk
    when the page was evicted last. Call swap_read() to pull the back in from
    swap space.

    HINTS:
         - You will need to use the global variable current_process when
           setting the frame table entry.

    ----------------------------------------------------------------------------------
 */
void page_fault(vaddr_t address) {
   stats.page_faults++; 
    /* First, split the faulting address and locate the page table entry.
       Remember to keep a pointer to the entry so you can modify it later. */
   vpn_t vpn = vaddr_vpn(address); 
   
   pte_t *pte = (pte_t*)(mem + (PTBR*PAGE_SIZE)) + vpn; 
   
    /* It's a page fault, so the entry obviously won't be valid. Grab
       a frame to use by calling free_frame(). */
   pfn_t new_frame = free_frame(); 

    /* Update the page table entry. Make sure you set any relevant values. */
   pte->valid = 1; 
   pte->pfn = new_frame; 
   pte->dirty = 0; 
   
    /* Update the frame table. Make sure you set any relevant values. */
   frame_table[new_frame].process = current_process;
   frame_table[new_frame].vpn = vpn;
   frame_table[new_frame].mapped = 1; 
   frame_table[new_frame].protected = 0; 
    /* Update the timestamp of the appropriate frame table entry with the provided get_current_timestamp function. */
   frame_table[new_frame].referenced = 1; 

    /* Initialize the page's memory. On a page fault, it is not enough
     * just to allocate a new frame. We must load in the old data from
     * disk into the frame. If there was no old data on disk, then
     * we need to clear out the memory (why?).
     *
     * 1) Get a pointer to the new frame in memory.
     * 2) If the page has swap set, then we need to load in data from memory
     *    using swap_read().
     * 3) Else, read a zeroed-out page from disk space and update the diskmap
     *    for the corresponding page.
     */
   void* frame = mem + new_frame * PAGE_SIZE;
   if (swap_exists(pte)) {
      swap_read(pte, frame); 
   } else {
      diskmap_read(pte, frame);
      diskmap_update(vpn, pte->swap); 
   }


}

#pragma GCC diagnostic pop
