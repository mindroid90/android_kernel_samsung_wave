/* linux/arch/arm/plat-s5p/sleep.S
 *
 * Copyright (c) 2010 Samsung Electronics Co., Ltd.
 *		http://www.samsung.com
 *
 * S5PV210 power Manager (Suspend-To-RAM) support
 * Based on S3C2410 sleep code by:
 * 	Ben Dooks, (c) 2004 Simtec Electronics
 *
 * Based on PXA/SA1100 sleep code by:
 *	Nicolas Pitre, (c) 2002 Monta Vista Software Inc
 *	Cliff Brake, (c) 2001
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*/

#include <linux/linkage.h>
#include <asm/assembler.h>
#include <asm/memory.h>

	.text

	/* s3c_cpu_save
	 *
	 * entry:
	 *	r1 = v:p offset
	*/

ENTRY(s3c_cpu_save)

	stmfd	sp!, { r3 - r12, lr }
	ldr	r3, =resume_with_mmu
	bl	cpu_suspend

	ldr	r0, =pm_cpu_sleep
	ldr	r0, [ r0 ]
	mov	pc, r0

resume_with_mmu:
	/* Invalidate TLB after mucking with MMU table. */
	mov	r0, #0
	mcr	p15, 0, r0, c8, c7, 0		@ Invalidate I & D TLB

	ldmfd	sp!, { r3 - r12, pc }

	.ltorg

	/* sleep magic, to allow the bootloader to check for an valid
	 * image to resume to. Must be the first word before the
	 * s3c_cpu_resume entry.
	*/

	.word	0x2bedf00d

	/* s3c_cpu_resume
	 *
	 * resume code entry for bootloader to call
	 *
	 * we must put this code here in the data segment as we have no
	 * other way of restoring the stack pointer after sleep, and we
	 * must not write to the code segment (code is read-only)
	*/

ENTRY(s3c_cpu_resume)
	b	cpu_resume
