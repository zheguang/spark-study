# mark_description "Intel(R) C++ Intel(R) 64 Compiler XE for applications running on Intel(R) 64, Version 14.0.3.174 Build 20140";
# mark_description "422";
# mark_description "-O3 -xHost -openmp -lrt -DUSE_OMP -S";
	.file "adj.c"
	.text
..TXTST0:
# -- Begin  _Z14read_graph_adjP3ADJPc
# mark_begin;
       .align    16,0x90
	.globl _Z14read_graph_adjP3ADJPc
_Z14read_graph_adjP3ADJPc:
# parameter 1: %rdi
# parameter 2: %rsi
..B1.1:                         # Preds ..B1.0
..___tag_value__Z14read_graph_adjP3ADJPc.1:                     #3.46
        pushq     %rbp                                          #3.46
..___tag_value__Z14read_graph_adjP3ADJPc.3:                     #
        movq      %rsp, %rbp                                    #3.46
..___tag_value__Z14read_graph_adjP3ADJPc.4:                     #
        andq      $-32, %rsp                                    #3.46
        pushq     %r12                                          #3.46
        pushq     %r13                                          #3.46
        pushq     %r14                                          #3.46
        subq      $136, %rsp                                    #3.46
..___tag_value__Z14read_graph_adjP3ADJPc.6:                     #
        movq      %rdi, %r14                                    #3.46
        movq      %rsi, %rdi                                    #17.13
        movl      $.L_2__STRING.1, %esi                         #17.13
        xorl      %eax, %eax                                    #11.10
        movl      %eax, 108(%rsp)                               #11.10
        movl      %eax, 112(%rsp)                               #12.10
        movl      %eax, 116(%rsp)                               #13.14
        call      fopen                                         #17.13
                                # LOE rax rbx r12 r14 r15
..B1.35:                        # Preds ..B1.1
        movq      %rax, %r13                                    #17.13
                                # LOE rbx r12 r13 r14 r15
..B1.2:                         # Preds ..B1.35
        testq     %r13, %r13                                    #17.31
        je        ..B1.32       # Prob 3%                       #17.31
                                # LOE rbx r12 r13 r14 r15
..B1.3:                         # Preds ..B1.32 ..B1.2
        movq      %r13, %rdi                                    #19.9
        call      feof                                          #19.9
                                # LOE rbx r12 r13 r14 r15 eax
..B1.36:                        # Preds ..B1.3
        testl     %eax, %eax                                    #19.9
        jne       ..B1.10       # Prob 10%                      #19.9
                                # LOE rbx r12 r13 r14 r15
..B1.5:                         # Preds ..B1.36 ..B1.37
        movq      %r13, %rdi                                    #21.3
        movl      $.L_2__STRING.2, %esi                         #21.3
        xorl      %eax, %eax                                    #21.3
        lea       8(%rsp), %rdx                                 #21.3
        call      fscanf                                        #21.3
                                # LOE rbx r12 r13 r14 r15
..B1.6:                         # Preds ..B1.5
        movb      8(%rsp), %al                                  #22.6
        cmpb      $112, %al                                     #22.14
        je        ..B1.17       # Prob 16%                      #22.14
                                # LOE rbx r12 r13 r14 r15 al
..B1.7:                         # Preds ..B1.6
        cmpb      $97, %al                                      #28.19
        je        ..B1.13       # Prob 16%                      #28.19
                                # LOE rbx r12 r13 r14 r15
..B1.8:                         # Preds ..B1.29 ..B1.17 ..B1.27 ..B1.22 ..B1.20
                                #       ..B1.16 ..B1.15 ..B1.13 ..B1.7
        movq      %r13, %rdi                                    #19.9
        call      feof                                          #19.9
                                # LOE rbx r12 r13 r14 r15 eax
..B1.37:                        # Preds ..B1.8
        testl     %eax, %eax                                    #19.9
        je        ..B1.5        # Prob 82%                      #19.9
                                # LOE rbx r12 r13 r14 r15
..B1.10:                        # Preds ..B1.37 ..B1.36
        movq      %r12, %rdi                                    #39.2
        call      _mm_free                                      #39.2
                                # LOE rbx r13 r15
..B1.11:                        # Preds ..B1.10
        movq      %r13, %rdi                                    #40.2
        call      fclose                                        #40.2
                                # LOE rbx r15
..B1.12:                        # Preds ..B1.11
        addq      $136, %rsp                                    #41.1
..___tag_value__Z14read_graph_adjP3ADJPc.9:                     #41.1
        popq      %r14                                          #41.1
..___tag_value__Z14read_graph_adjP3ADJPc.10:                    #41.1
        popq      %r13                                          #41.1
..___tag_value__Z14read_graph_adjP3ADJPc.11:                    #41.1
        popq      %r12                                          #41.1
        movq      %rbp, %rsp                                    #41.1
        popq      %rbp                                          #41.1
..___tag_value__Z14read_graph_adjP3ADJPc.12:                    #
        ret                                                     #41.1
..___tag_value__Z14read_graph_adjP3ADJPc.14:                    #
                                # LOE
..B1.13:                        # Preds ..B1.7                  # Infreq
        cmpb      $0, 9(%rsp)                                   #28.34
        jne       ..B1.8        # Prob 78%                      #28.34
                                # LOE rbx r12 r13 r14 r15
..B1.14:                        # Preds ..B1.13                 # Infreq
        movq      %r13, %rdi                                    #29.4
        movl      $.L_2__STRING.4, %esi                         #29.4
        xorl      %eax, %eax                                    #29.4
        lea       108(%rsp), %rdx                               #29.4
        lea       112(%rsp), %rcx                               #29.4
        lea       116(%rsp), %r8                                #29.4
        call      fscanf                                        #29.4
                                # LOE rbx r12 r13 r14 r15
..B1.15:                        # Preds ..B1.14                 # Infreq
        movslq    108(%rsp), %r11                               #30.7
        testq     %r11, %r11                                    #30.13
        je        ..B1.8        # Prob 38%                      #30.13
                                # LOE rbx r11 r12 r13 r14 r15
..B1.16:                        # Preds ..B1.15                 # Infreq
        decq      %r11                                          #31.5
        movq      (%r14), %rax                                  #33.5
        movl      112(%rsp), %edx                               #32.5
        decl      %edx                                          #32.5
        movl      (%r12,%r11,4), %r10d                          #33.22
        movslq    %r10d, %r10                                   #33.5
        movq      (%rax,%r11,8), %rcx                           #33.5
        movl      116(%rsp), %r8d                               #34.47
        movl      %r11d, 108(%rsp)                              #31.5
        movl      %edx, (%rcx,%r10,4)                           #33.5
        movq      8(%r14), %rsi                                 #34.5
        movl      %edx, 112(%rsp)                               #32.5
        movq      (%rsi,%r11,8), %r9                            #34.5
        movl      %r8d, (%r9,%r10,4)                            #34.5
        incl      %r10d                                         #35.5
        movl      %r10d, (%r12,%r11,4)                          #35.5
        jmp       ..B1.8        # Prob 100%                     #35.5
                                # LOE rbx r12 r13 r14 r15
..B1.17:                        # Preds ..B1.6                  # Infreq
        cmpb      $0, 9(%rsp)                                   #22.29
        jne       ..B1.8        # Prob 78%                      #22.29
                                # LOE rbx r12 r13 r14 r15
..B1.18:                        # Preds ..B1.17                 # Infreq
        movq      %r13, %rdi                                    #23.4
        movl      $.L_2__STRING.3, %esi                         #23.4
        xorl      %eax, %eax                                    #23.4
        lea       8(%rsp), %rdx                                 #23.4
        lea       (%rsp), %rcx                                  #23.4
        lea       4(%rsp), %r8                                  #23.4
        call      fscanf                                        #23.4
                                # LOE rbx r13 r14 r15
..B1.19:                        # Preds ..B1.18                 # Infreq
        movslq    (%rsp), %rdi                                  #24.22
        movl      $64, %esi                                     #24.22
        shlq      $2, %rdi                                      #24.22
        call      _mm_malloc                                    #24.22
                                # LOE rax rbx r13 r14 r15
..B1.38:                        # Preds ..B1.19                 # Infreq
        movq      %rax, %r12                                    #24.22
                                # LOE rbx r12 r13 r14 r15
..B1.20:                        # Preds ..B1.38                 # Infreq
        movslq    (%rsp), %rdx                                  #25.14
        testq     %rdx, %rdx                                    #25.14
        jle       ..B1.8        # Prob 10%                      #25.14
                                # LOE rdx rbx r12 r13 r14 r15
..B1.21:                        # Preds ..B1.20                 # Infreq
        cmpq      $24, %rdx                                     #25.4
        jle       ..B1.23       # Prob 0%                       #25.4
                                # LOE rdx rbx r12 r13 r14 r15
..B1.22:                        # Preds ..B1.21                 # Infreq
        shlq      $2, %rdx                                      #26.5
        movq      %r12, %rdi                                    #26.5
        xorl      %esi, %esi                                    #26.5
        call      _intel_fast_memset                            #26.5
        jmp       ..B1.8        # Prob 100%                     #26.5
                                # LOE rbx r12 r13 r14 r15
..B1.23:                        # Preds ..B1.21                 # Infreq
        cmpq      $4, %rdx                                      #25.4
        jl        ..B1.31       # Prob 10%                      #25.4
                                # LOE rdx rbx r12 r13 r14 r15
..B1.24:                        # Preds ..B1.23                 # Infreq
        movl      %edx, %eax                                    #25.4
        xorl      %ecx, %ecx                                    #25.4
        andl      $-4, %eax                                     #25.4
        movslq    %eax, %rax                                    #25.4
                                # LOE rax rdx rcx rbx r12 r13 r14 r15
..B1.25:                        # Preds ..B1.25 ..B1.24         # Infreq
        vpxor     %xmm0, %xmm0, %xmm0                           #26.5
        vmovdqu   %xmm0, (%r12,%rcx,4)                          #26.5
        addq      $4, %rcx                                      #25.4
        cmpq      %rax, %rcx                                    #25.4
        jb        ..B1.25       # Prob 82%                      #25.4
                                # LOE rax rdx rcx rbx r12 r13 r14 r15
..B1.27:                        # Preds ..B1.25 ..B1.31         # Infreq
        cmpq      %rdx, %rax                                    #25.4
        jae       ..B1.8        # Prob 0%                       #25.4
                                # LOE rax rdx rbx r12 r13 r14 r15
..B1.29:                        # Preds ..B1.27 ..B1.29         # Infreq
        movl      $0, (%r12,%rax,4)                             #26.5
        incq      %rax                                          #25.4
        cmpq      %rdx, %rax                                    #25.4
        jb        ..B1.29       # Prob 82%                      #25.4
        jmp       ..B1.8        # Prob 100%                     #25.4
                                # LOE rax rdx rbx r12 r13 r14 r15
..B1.31:                        # Preds ..B1.23                 # Infreq
        xorl      %eax, %eax                                    #25.4
        jmp       ..B1.27       # Prob 100%                     #25.4
                                # LOE rax rdx rbx r12 r13 r14 r15
..B1.32:                        # Preds ..B1.2                  # Infreq
        movl      $.L_2__STRING.0, %edi                         #18.3
        xorl      %eax, %eax                                    #18.3
..___tag_value__Z14read_graph_adjP3ADJPc.19:                    #18.3
        call      printf                                        #18.3
..___tag_value__Z14read_graph_adjP3ADJPc.20:                    #
        jmp       ..B1.3        # Prob 100%                     #18.3
        .align    16,0x90
..___tag_value__Z14read_graph_adjP3ADJPc.21:                    #
                                # LOE rbx r12 r13 r14 r15
# mark_end;
	.type	_Z14read_graph_adjP3ADJPc,@function
	.size	_Z14read_graph_adjP3ADJPc,.-_Z14read_graph_adjP3ADJPc
	.data
# -- End  _Z14read_graph_adjP3ADJPc
	.text
# -- Begin  _Z13scan_adj_sizeP3ADJPc
# mark_begin;
       .align    16,0x90
	.globl _Z13scan_adj_sizeP3ADJPc
_Z13scan_adj_sizeP3ADJPc:
# parameter 1: %rdi
# parameter 2: %rsi
..B2.1:                         # Preds ..B2.0
..___tag_value__Z13scan_adj_sizeP3ADJPc.22:                     #45.1
        pushq     %r12                                          #45.1
..___tag_value__Z13scan_adj_sizeP3ADJPc.24:                     #
        pushq     %r13                                          #45.1
..___tag_value__Z13scan_adj_sizeP3ADJPc.26:                     #
        subq      $136, %rsp                                    #45.1
..___tag_value__Z13scan_adj_sizeP3ADJPc.28:                     #
        movq      %rdi, %r13                                    #45.1
        movq      %rsi, %rdi                                    #57.13
        movl      $.L_2__STRING.1, %esi                         #57.13
        xorl      %eax, %eax                                    #51.10
        movl      %eax, 112(%rsp)                               #51.10
        movl      %eax, 116(%rsp)                               #52.10
        movl      %eax, 120(%rsp)                               #53.14
        call      fopen                                         #57.13
                                # LOE rax rbx rbp r13 r14 r15
..B2.38:                        # Preds ..B2.1
        movq      %rax, %r12                                    #57.13
                                # LOE rbx rbp r12 r13 r14 r15
..B2.2:                         # Preds ..B2.38
        testq     %r12, %r12                                    #57.31
        je        ..B2.35       # Prob 3%                       #57.31
                                # LOE rbx rbp r12 r13 r14 r15
..B2.3:                         # Preds ..B2.35 ..B2.2
        movq      %r12, %rdi                                    #59.9
        call      feof                                          #59.9
                                # LOE rbx rbp r12 r13 r14 r15 eax
..B2.39:                        # Preds ..B2.3
        testl     %eax, %eax                                    #59.9
        jne       ..B2.10       # Prob 10%                      #59.9
                                # LOE rbx rbp r12 r13 r14 r15
..B2.5:                         # Preds ..B2.39 ..B2.40
        movq      %r12, %rdi                                    #61.3
        movl      $.L_2__STRING.2, %esi                         #61.3
        xorl      %eax, %eax                                    #61.3
        lea       4(%rsp), %rdx                                 #61.3
        call      fscanf                                        #61.3
                                # LOE rbx rbp r12 r13 r14 r15
..B2.6:                         # Preds ..B2.5
        movb      4(%rsp), %al                                  #62.6
        cmpb      $112, %al                                     #62.14
        je        ..B2.30       # Prob 16%                      #62.14
                                # LOE rbx rbp r12 r13 r14 r15 al
..B2.7:                         # Preds ..B2.6
        cmpb      $97, %al                                      #69.19
        je        ..B2.26       # Prob 16%                      #69.19
                                # LOE rbx rbp r12 r13 r14 r15
..B2.8:                         # Preds ..B2.30 ..B2.28 ..B2.26 ..B2.7 ..B2.29
                                #       ..B2.34
        movq      %r12, %rdi                                    #59.9
        call      feof                                          #59.9
                                # LOE rbx rbp r12 r13 r14 r15 eax
..B2.40:                        # Preds ..B2.8
        testl     %eax, %eax                                    #59.9
        je        ..B2.5        # Prob 82%                      #59.9
                                # LOE rbx rbp r12 r13 r14 r15
..B2.10:                        # Preds ..B2.40 ..B2.39
        movslq    124(%rsp), %rdi                               #79.22
        movl      $64, %esi                                     #79.22
        shlq      $3, %rdi                                      #79.22
        call      _mm_malloc                                    #79.22
                                # LOE rax rbx rbp r12 r13 r14 r15
..B2.11:                        # Preds ..B2.10
        movslq    124(%rsp), %rdi                               #80.30
        movl      $64, %esi                                     #80.30
        shlq      $3, %rdi                                      #80.30
        movq      %rax, (%r13)                                  #79.2
        call      _mm_malloc                                    #80.30
                                # LOE rax rbx rbp r12 r13 r14 r15
..B2.12:                        # Preds ..B2.11
        movslq    124(%rsp), %rdi                               #81.31
        movl      $64, %esi                                     #81.31
        shlq      $3, %rdi                                      #81.31
        movq      %rax, 8(%r13)                                 #80.2
        call      _mm_malloc                                    #81.31
                                # LOE rax rbx rbp r12 r13 r14 r15
..B2.13:                        # Preds ..B2.12
        movslq    124(%rsp), %rdi                               #82.36
        movl      $64, %esi                                     #82.36
        shlq      $3, %rdi                                      #82.36
        movq      %rax, 40(%r13)                                #81.2
        call      _mm_malloc                                    #82.36
                                # LOE rax rbx rbp r12 r13 r14 r15
..B2.14:                        # Preds ..B2.13
        movq      %rax, 48(%r13)                                #82.2
        xorl      %edx, %edx                                    #84.6
        cmpl      $0, 124(%rsp)                                 #84.12
        jle       ..B2.20       # Prob 16%                      #84.12
                                # LOE rdx rbx rbp r12 r13 r14 r15
..B2.15:                        # Preds ..B2.14
        movq      %r14, 104(%rsp)                               #
..___tag_value__Z13scan_adj_sizeP3ADJPc.29:                     #
        movq      %rdx, %r14                                    #
                                # LOE rbx rbp r12 r13 r14 r15
..B2.16:                        # Preds ..B2.18 ..B2.15
        movq      56(%r13), %rax                                #85.25
        movl      $64, %esi                                     #85.25
        movslq    (%rax,%r14,4), %rdi                           #85.25
        shlq      $2, %rdi                                      #85.25
        call      _mm_malloc                                    #85.25
                                # LOE rax rbx rbp r12 r13 r14 r15
..B2.45:                        # Preds ..B2.16
        movq      %rax, %rcx                                    #85.25
                                # LOE rcx rbx rbp r12 r13 r14 r15
..B2.17:                        # Preds ..B2.45
        movq      (%r13), %rax                                  #85.3
        movl      $64, %esi                                     #86.33
        movq      %rcx, (%rax,%r14,8)                           #85.3
        movq      56(%r13), %rcx                                #86.33
        movslq    (%rcx,%r14,4), %rdi                           #86.33
        shlq      $2, %rdi                                      #86.33
        call      _mm_malloc                                    #86.33
                                # LOE rax rbx rbp r12 r13 r14 r15
..B2.46:                        # Preds ..B2.17
        movq      %rax, %rcx                                    #86.33
                                # LOE rcx rbx rbp r12 r13 r14 r15
..B2.18:                        # Preds ..B2.46
        movq      8(%r13), %rax                                 #86.3
        movq      %rcx, (%rax,%r14,8)                           #86.3
        incq      %r14                                          #84.18
        movslq    124(%rsp), %rcx                               #84.12
        cmpq      %rcx, %r14                                    #84.12
        jl        ..B2.16       # Prob 82%                      #84.12
                                # LOE rbx rbp r12 r13 r14 r15
..B2.19:                        # Preds ..B2.18
        movq      104(%rsp), %r14                               #
..___tag_value__Z13scan_adj_sizeP3ADJPc.30:                     #
                                # LOE rbx rbp r12 r13 r14 r15
..B2.20:                        # Preds ..B2.19 ..B2.14
        xorl      %eax, %eax                                    #88.6
        cmpl      $0, 64(%r13)                                  #88.12
        jle       ..B2.24       # Prob 10%                      #88.12
                                # LOE rax rbx rbp r12 r13 r14 r15
..B2.21:                        # Preds ..B2.20
        vmovsd    .L_2il0floatpacket.4(%rip), %xmm0             #90.32
                                # LOE rax rbx rbp r12 r13 r14 r15 xmm0
..B2.22:                        # Preds ..B2.22 ..B2.21
        movq      56(%r13), %rdx                                #90.44
        vxorpd    %xmm1, %xmm1, %xmm1                           #90.44
        movq      32(%r13), %rcx                                #90.3
        vcvtsi2sd (%rdx,%rax,4), %xmm1, %xmm1                   #90.44
        vdivsd    %xmm1, %xmm0, %xmm2                           #90.44
        vmovsd    %xmm2, (%rcx,%rax,8)                          #90.3
        incq      %rax                                          #88.26
        movslq    64(%r13), %rsi                                #88.12
        cmpq      %rsi, %rax                                    #88.12
        jl        ..B2.22       # Prob 82%                      #88.12
                                # LOE rax rbx rbp r12 r13 r14 r15 xmm0
..B2.24:                        # Preds ..B2.22 ..B2.20
        movq      %r12, %rdi                                    #92.2
        call      fclose                                        #92.2
                                # LOE rbx rbp r14 r15
..B2.25:                        # Preds ..B2.24
        addq      $136, %rsp                                    #93.1
..___tag_value__Z13scan_adj_sizeP3ADJPc.31:                     #
        popq      %r13                                          #93.1
..___tag_value__Z13scan_adj_sizeP3ADJPc.33:                     #
        popq      %r12                                          #93.1
..___tag_value__Z13scan_adj_sizeP3ADJPc.35:                     #
        ret                                                     #93.1
..___tag_value__Z13scan_adj_sizeP3ADJPc.36:                     #
                                # LOE
..B2.26:                        # Preds ..B2.7                  # Infreq
        cmpb      $0, 5(%rsp)                                   #69.34
        jne       ..B2.8        # Prob 78%                      #69.34
                                # LOE rbx rbp r12 r13 r14 r15
..B2.27:                        # Preds ..B2.26                 # Infreq
        movq      %r12, %rdi                                    #70.4
        movl      $.L_2__STRING.4, %esi                         #70.4
        xorl      %eax, %eax                                    #70.4
        lea       112(%rsp), %rdx                               #70.4
        lea       116(%rsp), %rcx                               #70.4
        lea       120(%rsp), %r8                                #70.4
        call      fscanf                                        #70.4
                                # LOE rbx rbp r12 r13 r14 r15
..B2.28:                        # Preds ..B2.27                 # Infreq
        movslq    112(%rsp), %rdx                               #71.7
        testq     %rdx, %rdx                                    #71.13
        je        ..B2.8        # Prob 38%                      #71.13
                                # LOE rdx rbx rbp r12 r13 r14 r15
..B2.29:                        # Preds ..B2.28                 # Infreq
        decq      %rdx                                          #72.5
        movq      56(%r13), %rax                                #74.5
        movl      %edx, 112(%rsp)                               #72.5
        decl      116(%rsp)                                     #73.5
        incl      (%rax,%rdx,4)                                 #74.5
        incl      68(%r13)                                      #75.5
        jmp       ..B2.8        # Prob 100%                     #75.5
                                # LOE rbx rbp r12 r13 r14 r15
..B2.30:                        # Preds ..B2.6                  # Infreq
        cmpb      $0, 5(%rsp)                                   #62.29
        jne       ..B2.8        # Prob 78%                      #62.29
                                # LOE rbx rbp r12 r13 r14 r15
..B2.31:                        # Preds ..B2.30                 # Infreq
        movq      %r12, %rdi                                    #63.4
        movl      $.L_2__STRING.3, %esi                         #63.4
        xorl      %eax, %eax                                    #63.4
        lea       4(%rsp), %rdx                                 #63.4
        lea       124(%rsp), %rcx                               #63.4
        lea       (%rsp), %r8                                   #63.4
        call      fscanf                                        #63.4
                                # LOE rbx rbp r12 r13 r14 r15
..B2.32:                        # Preds ..B2.31                 # Infreq
        movslq    124(%rsp), %rdi                               #64.20
        movl      $64, %esi                                     #66.27
        movl      %edi, 64(%r13)                                #64.4
        shlq      $2, %rdi                                      #66.27
        movl      $0, 68(%r13)                                  #65.4
        call      _mm_malloc                                    #66.27
                                # LOE rax rbx rbp r12 r13 r14 r15
..B2.33:                        # Preds ..B2.32                 # Infreq
        movslq    124(%rsp), %rdi                               #67.41
        movl      $64, %esi                                     #67.41
        shlq      $3, %rdi                                      #67.41
        movq      %rax, 56(%r13)                                #66.4
        call      _mm_malloc                                    #67.41
                                # LOE rax rbx rbp r12 r13 r14 r15
..B2.34:                        # Preds ..B2.33                 # Infreq
        movq      %rax, 32(%r13)                                #67.4
        jmp       ..B2.8        # Prob 100%                     #67.4
                                # LOE rbx rbp r12 r13 r14 r15
..B2.35:                        # Preds ..B2.2                  # Infreq
        movl      $.L_2__STRING.0, %edi                         #58.3
        xorl      %eax, %eax                                    #58.3
..___tag_value__Z13scan_adj_sizeP3ADJPc.39:                     #58.3
        call      printf                                        #58.3
..___tag_value__Z13scan_adj_sizeP3ADJPc.40:                     #
        jmp       ..B2.3        # Prob 100%                     #58.3
        .align    16,0x90
..___tag_value__Z13scan_adj_sizeP3ADJPc.41:                     #
                                # LOE rbx rbp r12 r13 r14 r15
# mark_end;
	.type	_Z13scan_adj_sizeP3ADJPc,@function
	.size	_Z13scan_adj_sizeP3ADJPc,.-_Z13scan_adj_sizeP3ADJPc
	.data
# -- End  _Z13scan_adj_sizeP3ADJPc
	.text
# -- Begin  _Z20compute_pagerank_adjP3ADJ
# mark_begin;
       .align    16,0x90
	.globl _Z20compute_pagerank_adjP3ADJ
_Z20compute_pagerank_adjP3ADJ:
# parameter 1: %rdi
..B3.1:                         # Preds ..B3.0
..___tag_value__Z20compute_pagerank_adjP3ADJ.42:                #111.40
        movq      %rdi, %r9                                     #111.40
        vxorpd    %xmm1, %xmm1, %xmm1                           #114.37
        xorl      %esi, %esi                                    #116.16
        vmovsd    .L_2il0floatpacket.6(%rip), %xmm0             #114.21
        xorl      %edi, %edi                                    #121.30
        movl      64(%r9), %r11d                                #114.37
        vcvtsi2sd %r11d, %xmm1, %xmm1                           #114.37
        vdivsd    %xmm1, %xmm0, %xmm2                           #114.37
        vmovsd    .L_2il0floatpacket.7(%rip), %xmm1             #115.22
        vmovsd    .L_2il0floatpacket.8(%rip), %xmm0             #127.60
                                # LOE rbx rbp rdi r9 r12 r13 r14 r15 esi r11d xmm0 xmm1 xmm2
..B3.2:                         # Preds ..B3.14 ..B3.1
        incl      %esi                                          #118.3
        movl      $1, %r8d                                      #119.3
        movq      %rdi, %rcx                                    #120.7
        testl     %r11d, %r11d                                  #120.13
        jle       ..B3.16       # Prob 16%                      #120.13
                                # LOE rcx rbx rbp rdi r9 r12 r13 r14 r15 esi r8d xmm0 xmm1 xmm2
..B3.3:                         # Preds ..B3.2
        movq      48(%r9), %rdx                                 #121.4
                                # LOE rdx rcx rbx rbp rdi r9 r12 r13 r14 r15 esi r8d xmm0 xmm1 xmm2
..B3.4:                         # Preds ..B3.10 ..B3.3
        movq      %rdi, (%rdx,%rcx,8)                           #121.4
        movq      %rdi, %rdx                                    #122.8
        movq      56(%r9), %r10                                 #122.15
        movslq    (%r10,%rcx,4), %r11                           #122.15
        testq     %r11, %r11                                    #122.15
        jle       ..B3.10       # Prob 10%                      #122.15
                                # LOE rdx rcx rbx rbp rdi r9 r10 r11 r12 r13 r14 r15 esi r8d xmm0 xmm1 xmm2
..B3.6:                         # Preds ..B3.4 ..B3.8
        movq      (%r9), %rax                                   #123.23
        movq      (%rax,%rcx,8), %rax                           #123.23
        movslq    (%rax,%rdx,4), %rax                           #123.23
        cmpl      $0, (%r10,%rax,4)                             #123.41
        jle       ..B3.8        # Prob 16%                      #123.41
                                # LOE rax rdx rcx rbx rbp rdi r9 r10 r11 r12 r13 r14 r15 esi r8d xmm0 xmm1 xmm2
..B3.7:                         # Preds ..B3.6
        movq      40(%r9), %r11                                 #124.32
        movq      48(%r9), %r10                                 #124.5
        vmovsd    (%r11,%rax,8), %xmm3                          #124.32
        movq      32(%r9), %r11                                 #124.68
        vmulsd    (%r11,%rax,8), %xmm3, %xmm4                   #124.68
        vaddsd    (%r10,%rcx,8), %xmm4, %xmm5                   #124.5
        vmovsd    %xmm5, (%r10,%rcx,8)                          #124.5
        movq      56(%r9), %r10                                 #122.15
        movslq    (%r10,%rcx,4), %r11                           #122.15
                                # LOE rdx rcx rbx rbp rdi r9 r10 r11 r12 r13 r14 r15 esi r8d xmm0 xmm1 xmm2
..B3.8:                         # Preds ..B3.7 ..B3.6
        incq      %rdx                                          #122.34
        cmpq      %r11, %rdx                                    #122.15
        jl        ..B3.6        # Prob 82%                      #122.15
                                # LOE rdx rcx rbx rbp rdi r9 r10 r11 r12 r13 r14 r15 esi r8d xmm0 xmm1 xmm2
..B3.10:                        # Preds ..B3.8 ..B3.4
        movq      48(%r9), %rdx                                 #126.57
        vmulsd    (%rdx,%rcx,8), %xmm1, %xmm3                   #126.57
        vaddsd    %xmm3, %xmm2, %xmm4                           #126.57
        vmovsd    %xmm4, (%rdx,%rcx,8)                          #126.4
        movq      48(%r9), %rdx                                 #127.12
        movq      40(%r9), %r10                                 #127.38
        movl      64(%r9), %r11d                                #120.13
        vmovsd    (%rdx,%rcx,8), %xmm5                          #127.12
        movslq    %r11d, %r11                                   #120.3
        vsubsd    (%r10,%rcx,8), %xmm5, %xmm6                   #127.38
        vandpd    .L_2il0floatpacket.9(%rip), %xmm6, %xmm7      #127.7
        incq      %rcx                                          #120.27
        vcmpngtsd %xmm0, %xmm7, %xmm8                           #128.5
        vmovd     %xmm8, %eax                                   #128.5
        andl      %eax, %r8d                                    #128.5
        cmpq      %r11, %rcx                                    #120.13
        jl        ..B3.4        # Prob 82%                      #120.13
                                # LOE rdx rcx rbx rbp rdi r9 r10 r12 r13 r14 r15 esi r8d r11d xmm0 xmm1 xmm2
..B3.11:                        # Preds ..B3.10
        testl     %r11d, %r11d                                  #130.13
        jle       ..B3.14       # Prob 10%                      #130.13
                                # LOE rdx rbx rbp rdi r9 r10 r12 r13 r14 r15 esi r8d r11d xmm0 xmm1 xmm2
..B3.12:                        # Preds ..B3.11
        movq      %rdi, %rax                                    #
                                # LOE rax rdx rbx rbp rdi r9 r10 r12 r13 r14 r15 esi r8d xmm0 xmm1 xmm2
..B3.13:                        # Preds ..B3.23 ..B3.12
        movq      (%rdx,%rax,8), %rdx                           #131.25
        movq      %rdx, (%r10,%rax,8)                           #131.4
        incq      %rax                                          #130.27
        movl      64(%r9), %r11d                                #130.13
        movslq    %r11d, %r11                                   #130.3
        cmpq      %r11, %rax                                    #130.13
        jge       ..B3.14       # Prob 18%                      #130.13
                                # LOE rax rbx rbp rdi r9 r12 r13 r14 r15 esi r8d r11d xmm0 xmm1 xmm2
..B3.23:                        # Preds ..B3.13
        .byte     144                                           #121.4
        movq      48(%r9), %rdx                                 #121.4
        movq      40(%r9), %r10                                 #121.4
        jmp       ..B3.13       # Prob 100%                     #121.4
                                # LOE rax rdx rbx rbp rdi r9 r10 r12 r13 r14 r15 esi r8d xmm0 xmm1 xmm2
..B3.14:                        # Preds ..B3.11 ..B3.13
        testl     %r8d, %r8d                                    #117.22
        je        ..B3.2        # Prob 82%                      #117.22
                                # LOE rbx rbp rdi r9 r12 r13 r14 r15 esi r11d xmm0 xmm1 xmm2
..B3.16:                        # Preds ..B3.2 ..B3.14          # Infreq
        movl      $.L_2__STRING.5, %edi                         #134.2
        xorl      %eax, %eax                                    #134.2
        jmp       printf                                        #134.2
        .align    16,0x90
..___tag_value__Z20compute_pagerank_adjP3ADJ.44:                #
                                # LOE
# mark_end;
	.type	_Z20compute_pagerank_adjP3ADJ,@function
	.size	_Z20compute_pagerank_adjP3ADJ,.-_Z20compute_pagerank_adjP3ADJ
	.data
# -- End  _Z20compute_pagerank_adjP3ADJ
	.text
# -- Begin  _Z12print_pr_adjP3ADJ
# mark_begin;
       .align    16,0x90
	.globl _Z12print_pr_adjP3ADJ
_Z12print_pr_adjP3ADJ:
# parameter 1: %rdi
..B4.1:                         # Preds ..B4.0
..___tag_value__Z12print_pr_adjP3ADJ.45:                        #137.32
        subq      $24, %rsp                                     #137.32
..___tag_value__Z12print_pr_adjP3ADJ.47:                        #
        xorl      %edx, %edx                                    #139.6
        cmpl      $0, 64(%rdi)                                  #139.12
        jle       ..B4.6        # Prob 10%                      #139.12
                                # LOE rdx rbx rbp rdi r12 r13 r14 r15
..B4.2:                         # Preds ..B4.1
        movq      %r12, 8(%rsp)                                 #
..___tag_value__Z12print_pr_adjP3ADJ.48:                        #
        movq      %rdx, %r12                                    #
        movq      %r13, (%rsp)                                  #
..___tag_value__Z12print_pr_adjP3ADJ.49:                        #
        movq      %rdi, %r13                                    #
                                # LOE rbx rbp r12 r13 r14 r15
..B4.3:                         # Preds ..B4.4 ..B4.2
        movq      40(%r13), %rcx                                #140.3
        movl      $.L_2__STRING.6, %edi                         #140.3
        movl      $1, %eax                                      #140.3
        vmovsd    (%rcx,%r12,8), %xmm0                          #140.3
..___tag_value__Z12print_pr_adjP3ADJ.50:                        #140.3
        call      printf                                        #140.3
..___tag_value__Z12print_pr_adjP3ADJ.51:                        #
                                # LOE rbx rbp r12 r13 r14 r15
..B4.4:                         # Preds ..B4.3
        incq      %r12                                          #139.26
        movslq    64(%r13), %rax                                #139.12
        cmpq      %rax, %r12                                    #139.12
        jl        ..B4.3        # Prob 82%                      #139.12
                                # LOE rbx rbp r12 r13 r14 r15
..B4.5:                         # Preds ..B4.4
        movq      8(%rsp), %r12                                 #
..___tag_value__Z12print_pr_adjP3ADJ.52:                        #
        movq      (%rsp), %r13                                  #
..___tag_value__Z12print_pr_adjP3ADJ.53:                        #
                                # LOE rbx rbp r12 r13 r14 r15
..B4.6:                         # Preds ..B4.5 ..B4.1
        movl      $10, %edi                                     #141.2
        addq      $24, %rsp                                     #141.2
..___tag_value__Z12print_pr_adjP3ADJ.54:                        #
        jmp       putchar                                       #141.2
        .align    16,0x90
..___tag_value__Z12print_pr_adjP3ADJ.55:                        #
                                # LOE
# mark_end;
	.type	_Z12print_pr_adjP3ADJ,@function
	.size	_Z12print_pr_adjP3ADJ,.-_Z12print_pr_adjP3ADJ
	.data
# -- End  _Z12print_pr_adjP3ADJ
	.text
# -- Begin  _Z13vis_graph_adjP3ADJ
# mark_begin;
       .align    16,0x90
	.globl _Z13vis_graph_adjP3ADJ
_Z13vis_graph_adjP3ADJ:
# parameter 1: %rdi
..B5.1:                         # Preds ..B5.0
..___tag_value__Z13vis_graph_adjP3ADJ.56:                       #145.1
        pushq     %r12                                          #145.1
..___tag_value__Z13vis_graph_adjP3ADJ.58:                       #
        pushq     %r13                                          #145.1
..___tag_value__Z13vis_graph_adjP3ADJ.60:                       #
        subq      $24, %rsp                                     #145.1
..___tag_value__Z13vis_graph_adjP3ADJ.62:                       #
        movq      %rdi, %r13                                    #145.1
        movl      $.L_2__STRING.8, %edi                         #149.8
        movl      $.L_2__STRING.9, %esi                         #149.8
        call      fopen                                         #149.8
                                # LOE rax rbx rbp r13 r14 r15
..B5.19:                        # Preds ..B5.1
        movq      %rax, %r12                                    #149.8
                                # LOE rbx rbp r12 r13 r14 r15
..B5.2:                         # Preds ..B5.19
        testq     %r12, %r12                                    #149.38
        je        ..B5.16       # Prob 3%                       #149.38
                                # LOE rbx rbp r12 r13 r14 r15
..B5.3:                         # Preds ..B5.16 ..B5.2
        movl      $il0_peep_printf_format_0, %edi               #151.2
        movq      %r12, %rsi                                    #151.2
        call      fputs                                         #151.2
                                # LOE rbx rbp r12 r13 r14 r15
..B5.4:                         # Preds ..B5.3
        movslq    64(%r13), %rdx                                #152.17
        xorl      %r8d, %r8d                                    #152.6
        testq     %rdx, %rdx                                    #152.17
        jle       ..B5.13       # Prob 10%                      #152.17
                                # LOE rdx rbx rbp r8 r12 r13 r14 r15
..B5.5:                         # Preds ..B5.4
        movq      56(%r13), %rax                                #153.18
        movq      %r14, 16(%rsp)                                #153.18
..___tag_value__Z13vis_graph_adjP3ADJ.63:                       #
        movq      %r13, %r14                                    #153.18
        movq      %r15, 8(%rsp)                                 #153.18
..___tag_value__Z13vis_graph_adjP3ADJ.64:                       #
        movq      %r8, %r13                                     #153.18
        movq      %rbx, (%rsp)                                  #153.18
..___tag_value__Z13vis_graph_adjP3ADJ.65:                       #
                                # LOE rax rdx rbp r12 r13 r14
..B5.6:                         # Preds ..B5.11 ..B5.5
        xorl      %ebx, %ebx                                    #153.7
        cmpl      $0, (%rax,%r13,4)                             #153.18
        jle       ..B5.11       # Prob 10%                      #153.18
                                # LOE rax rdx rbx rbp r12 r13 r14
..B5.7:                         # Preds ..B5.6
        movl      %r13d, %r15d                                  #154.4
                                # LOE rbx rbp r12 r13 r14 r15d
..B5.8:                         # Preds ..B5.9 ..B5.7
        movq      (%r14), %r9                                   #154.4
        movq      %r12, %rdi                                    #154.4
        movl      $.L_2__STRING.11, %esi                        #154.4
        movl      %r15d, %edx                                   #154.4
        xorl      %eax, %eax                                    #154.4
        movq      (%r9,%r13,8), %r10                            #154.4
        movl      (%r10,%rbx,4), %ecx                           #154.4
        call      fprintf                                       #154.4
                                # LOE rbx rbp r12 r13 r14 r15d
..B5.9:                         # Preds ..B5.8
        movq      56(%r14), %rax                                #153.18
        incq      %rbx                                          #153.39
        movslq    (%rax,%r13,4), %rcx                           #153.18
        cmpq      %rcx, %rbx                                    #153.18
        jl        ..B5.8        # Prob 82%                      #153.18
                                # LOE rax rbx rbp r12 r13 r14 r15d
..B5.10:                        # Preds ..B5.9
        movslq    64(%r14), %rdx                                #152.17
                                # LOE rax rdx rbp r12 r13 r14
..B5.11:                        # Preds ..B5.10 ..B5.6
        incq      %r13                                          #152.32
        cmpq      %rdx, %r13                                    #152.17
        jl        ..B5.6        # Prob 82%                      #152.17
                                # LOE rax rdx rbp r12 r13 r14
..B5.12:                        # Preds ..B5.11
        movq      16(%rsp), %r14                                #
..___tag_value__Z13vis_graph_adjP3ADJ.66:                       #
        movq      8(%rsp), %r15                                 #
..___tag_value__Z13vis_graph_adjP3ADJ.67:                       #
        movq      (%rsp), %rbx                                  #
..___tag_value__Z13vis_graph_adjP3ADJ.68:                       #
                                # LOE rbx rbp r12 r14 r15
..B5.13:                        # Preds ..B5.12 ..B5.4
        movl      $il0_peep_printf_format_1, %edi               #157.2
        movq      %r12, %rsi                                    #157.2
        call      fputs                                         #157.2
                                # LOE rbx rbp r12 r14 r15
..B5.14:                        # Preds ..B5.13
        movq      %r12, %rdi                                    #158.2
        addq      $24, %rsp                                     #158.2
..___tag_value__Z13vis_graph_adjP3ADJ.69:                       #
        popq      %r13                                          #158.2
..___tag_value__Z13vis_graph_adjP3ADJ.71:                       #
        popq      %r12                                          #158.2
..___tag_value__Z13vis_graph_adjP3ADJ.73:                       #
        jmp       fclose                                        #158.2
..___tag_value__Z13vis_graph_adjP3ADJ.74:                       #
                                # LOE
..B5.16:                        # Preds ..B5.2                  # Infreq
        movl      $.L_2__STRING.0, %edi                         #150.3
        xorl      %eax, %eax                                    #150.3
..___tag_value__Z13vis_graph_adjP3ADJ.77:                       #150.3
        call      printf                                        #150.3
..___tag_value__Z13vis_graph_adjP3ADJ.78:                       #
        jmp       ..B5.3        # Prob 100%                     #150.3
        .align    16,0x90
..___tag_value__Z13vis_graph_adjP3ADJ.79:                       #
                                # LOE rbx rbp r12 r13 r14 r15
# mark_end;
	.type	_Z13vis_graph_adjP3ADJ,@function
	.size	_Z13vis_graph_adjP3ADJ,.-_Z13vis_graph_adjP3ADJ
	.section .rodata.str1.4, "aMS",@progbits,1
	.align 4
	.align 4
il0_peep_printf_format_0:
	.long	1919379812
	.long	543715425
	.long	175841351
	.byte	0
	.space 3, 0x00 	# pad
	.align 4
il0_peep_printf_format_1:
	.word	2685
	.byte	0
	.data
# -- End  _Z13vis_graph_adjP3ADJ
	.text
# -- Begin  _Z17init_pagerank_adjP3ADJ
# mark_begin;
       .align    16,0x90
	.globl _Z17init_pagerank_adjP3ADJ
_Z17init_pagerank_adjP3ADJ:
# parameter 1: %rdi
..B6.1:                         # Preds ..B6.0
..___tag_value__Z17init_pagerank_adjP3ADJ.80:                   #95.37
        xorl      %edx, %edx                                    #98.6
        cmpl      $0, 64(%rdi)                                  #98.13
        jle       ..B6.5        # Prob 10%                      #98.13
                                # LOE rdx rbx rbp rdi r12 r13 r14 r15
..B6.2:                         # Preds ..B6.1
        movq      $0x3ff0000000000000, %rax                     #103.24
                                # LOE rax rdx rbx rbp rdi r12 r13 r14 r15
..B6.3:                         # Preds ..B6.3 ..B6.2
        movq      40(%rdi), %rcx                                #103.3
        movq      %rax, (%rcx,%rdx,8)                           #103.3
        incq      %rdx                                          #98.28
        movslq    64(%rdi), %rsi                                #98.13
        cmpq      %rsi, %rdx                                    #98.13
        jl        ..B6.3        # Prob 82%                      #98.13
                                # LOE rax rdx rbx rbp rdi r12 r13 r14 r15
..B6.5:                         # Preds ..B6.3 ..B6.1
        ret                                                     #109.1
        .align    16,0x90
..___tag_value__Z17init_pagerank_adjP3ADJ.82:                   #
                                # LOE
# mark_end;
	.type	_Z17init_pagerank_adjP3ADJ,@function
	.size	_Z17init_pagerank_adjP3ADJ,.-_Z17init_pagerank_adjP3ADJ
	.data
# -- End  _Z17init_pagerank_adjP3ADJ
	.section .rodata, "a"
	.align 16
	.align 16
.L_2il0floatpacket.9:
	.long	0xffffffff,0x7fffffff,0x00000000,0x00000000
	.type	.L_2il0floatpacket.9,@object
	.size	.L_2il0floatpacket.9,16
	.align 8
.L_2il0floatpacket.4:
	.long	0x00000000,0x3ff00000
	.type	.L_2il0floatpacket.4,@object
	.size	.L_2il0floatpacket.4,8
	.align 8
.L_2il0floatpacket.6:
	.long	0x33333333,0x3fd33333
	.type	.L_2il0floatpacket.6,@object
	.size	.L_2il0floatpacket.6,8
	.align 8
.L_2il0floatpacket.7:
	.long	0x66666666,0x3fe66666
	.type	.L_2il0floatpacket.7,@object
	.size	.L_2il0floatpacket.7,8
	.align 8
.L_2il0floatpacket.8:
	.long	0xa0b5ed8d,0x3eb0c6f7
	.type	.L_2il0floatpacket.8,@object
	.size	.L_2il0floatpacket.8,8
	.section .rodata.str1.4, "aMS",@progbits,1
	.space 1, 0x00 	# pad
	.align 4
.L_2__STRING.1:
	.word	114
	.type	.L_2__STRING.1,@object
	.size	.L_2__STRING.1,2
	.space 2, 0x00 	# pad
	.align 4
.L_2__STRING.0:
	.long	543516788
	.long	1701603686
	.long	1970239776
	.long	1886284064
	.long	1679848565
	.long	544433519
	.long	544501614
	.long	1936291941
	.word	8564
	.byte	0
	.type	.L_2__STRING.0,@object
	.size	.L_2__STRING.0,35
	.space 1, 0x00 	# pad
	.align 4
.L_2__STRING.2:
	.word	29477
	.byte	0
	.type	.L_2__STRING.2,@object
	.size	.L_2__STRING.2,3
	.space 1, 0x00 	# pad
	.align 4
.L_2__STRING.3:
	.long	622883621
	.long	1680154724
	.byte	0
	.type	.L_2__STRING.3,@object
	.size	.L_2__STRING.3,9
	.space 3, 0x00 	# pad
	.align 4
.L_2__STRING.4:
	.long	622879781
	.long	1680154724
	.byte	0
	.type	.L_2__STRING.4,@object
	.size	.L_2__STRING.4,9
	.space 3, 0x00 	# pad
	.align 4
.L_2__STRING.5:
	.long	544044398
	.long	1919251561
	.long	174335264
	.byte	0
	.type	.L_2__STRING.5,@object
	.size	.L_2__STRING.5,13
	.space 3, 0x00 	# pad
	.align 4
.L_2__STRING.6:
	.long	2123301
	.type	.L_2__STRING.6,@object
	.size	.L_2__STRING.6,4
	.align 4
.L_2__STRING.9:
	.word	119
	.type	.L_2__STRING.9,@object
	.size	.L_2__STRING.9,2
	.space 2, 0x00 	# pad
	.align 4
.L_2__STRING.8:
	.long	1769353006
	.long	1684090739
	.long	1769352810
	.word	115
	.type	.L_2__STRING.8,@object
	.size	.L_2__STRING.8,14
	.space 2, 0x00 	# pad
	.align 4
.L_2__STRING.11:
	.long	757097509
	.long	1680154686
	.word	2619
	.byte	0
	.type	.L_2__STRING.11,@object
	.size	.L_2__STRING.11,11
	.data
	.section .note.GNU-stack, ""
// -- Begin DWARF2 SEGMENT .eh_frame
	.section .eh_frame,"a",@progbits
.eh_frame_seg:
	.align 8
	.4byte 0x0000001c
	.8byte 0x00507a0100000000
	.4byte 0x09107801
	.byte 0x00
	.8byte __gxx_personality_v0
	.4byte 0x9008070c
	.2byte 0x0001
	.byte 0x00
	.4byte 0x000000bc
	.4byte 0x00000024
	.8byte ..___tag_value__Z14read_graph_adjP3ADJPc.1
	.8byte ..___tag_value__Z14read_graph_adjP3ADJPc.21-..___tag_value__Z14read_graph_adjP3ADJPc.1
	.2byte 0x0400
	.4byte ..___tag_value__Z14read_graph_adjP3ADJPc.3-..___tag_value__Z14read_graph_adjP3ADJPc.1
	.2byte 0x100e
	.byte 0x04
	.4byte ..___tag_value__Z14read_graph_adjP3ADJPc.4-..___tag_value__Z14read_graph_adjP3ADJPc.3
	.4byte 0x8610060c
	.2byte 0x0402
	.4byte ..___tag_value__Z14read_graph_adjP3ADJPc.6-..___tag_value__Z14read_graph_adjP3ADJPc.4
	.8byte 0xffe00d1c380e0c10
	.8byte 0xfffffff80d1affff
	.8byte 0xe00d1c380e0d1022
	.8byte 0xfffff00d1affffff
	.8byte 0x0d1c380e0e1022ff
	.8byte 0xffe80d1affffffe0
	.4byte 0x0422ffff
	.4byte ..___tag_value__Z14read_graph_adjP3ADJPc.9-..___tag_value__Z14read_graph_adjP3ADJPc.6
	.2byte 0x04ce
	.4byte ..___tag_value__Z14read_graph_adjP3ADJPc.10-..___tag_value__Z14read_graph_adjP3ADJPc.9
	.2byte 0x04cd
	.4byte ..___tag_value__Z14read_graph_adjP3ADJPc.11-..___tag_value__Z14read_graph_adjP3ADJPc.10
	.2byte 0x04cc
	.4byte ..___tag_value__Z14read_graph_adjP3ADJPc.12-..___tag_value__Z14read_graph_adjP3ADJPc.11
	.4byte 0xc608070c
	.byte 0x04
	.4byte ..___tag_value__Z14read_graph_adjP3ADJPc.14-..___tag_value__Z14read_graph_adjP3ADJPc.12
	.8byte 0x0e0c10028610060c
	.8byte 0x1affffffe00d1c38
	.8byte 0x0d1022fffffff80d
	.8byte 0xffffffe00d1c380e
	.8byte 0x1022fffffff00d1a
	.8byte 0xffffe00d1c380e0e
	.8byte 0x22ffffffe80d1aff
	.4byte 0x00000000
	.2byte 0x0000
	.4byte 0x00000064
	.4byte 0x000000e4
	.8byte ..___tag_value__Z13scan_adj_sizeP3ADJPc.22
	.8byte ..___tag_value__Z13scan_adj_sizeP3ADJPc.41-..___tag_value__Z13scan_adj_sizeP3ADJPc.22
	.2byte 0x0400
	.4byte ..___tag_value__Z13scan_adj_sizeP3ADJPc.24-..___tag_value__Z13scan_adj_sizeP3ADJPc.22
	.4byte 0x028c100e
	.byte 0x04
	.4byte ..___tag_value__Z13scan_adj_sizeP3ADJPc.26-..___tag_value__Z13scan_adj_sizeP3ADJPc.24
	.4byte 0x038d180e
	.byte 0x04
	.4byte ..___tag_value__Z13scan_adj_sizeP3ADJPc.28-..___tag_value__Z13scan_adj_sizeP3ADJPc.26
	.4byte 0x0401a00e
	.4byte ..___tag_value__Z13scan_adj_sizeP3ADJPc.29-..___tag_value__Z13scan_adj_sizeP3ADJPc.28
	.2byte 0x078e
	.byte 0x04
	.4byte ..___tag_value__Z13scan_adj_sizeP3ADJPc.30-..___tag_value__Z13scan_adj_sizeP3ADJPc.29
	.2byte 0x04ce
	.4byte ..___tag_value__Z13scan_adj_sizeP3ADJPc.31-..___tag_value__Z13scan_adj_sizeP3ADJPc.30
	.4byte 0x04cd180e
	.4byte ..___tag_value__Z13scan_adj_sizeP3ADJPc.33-..___tag_value__Z13scan_adj_sizeP3ADJPc.31
	.4byte 0x04cc100e
	.4byte ..___tag_value__Z13scan_adj_sizeP3ADJPc.35-..___tag_value__Z13scan_adj_sizeP3ADJPc.33
	.2byte 0x080e
	.byte 0x04
	.4byte ..___tag_value__Z13scan_adj_sizeP3ADJPc.36-..___tag_value__Z13scan_adj_sizeP3ADJPc.35
	.8byte 0x00038d028c01a00e
	.4byte 0x00000000
	.4byte 0x0000001c
	.4byte 0x0000014c
	.8byte ..___tag_value__Z20compute_pagerank_adjP3ADJ.42
	.8byte ..___tag_value__Z20compute_pagerank_adjP3ADJ.44-..___tag_value__Z20compute_pagerank_adjP3ADJ.42
	.8byte 0x0000000000000000
	.4byte 0x00000044
	.4byte 0x0000016c
	.8byte ..___tag_value__Z12print_pr_adjP3ADJ.45
	.8byte ..___tag_value__Z12print_pr_adjP3ADJ.55-..___tag_value__Z12print_pr_adjP3ADJ.45
	.2byte 0x0400
	.4byte ..___tag_value__Z12print_pr_adjP3ADJ.47-..___tag_value__Z12print_pr_adjP3ADJ.45
	.2byte 0x200e
	.byte 0x04
	.4byte ..___tag_value__Z12print_pr_adjP3ADJ.48-..___tag_value__Z12print_pr_adjP3ADJ.47
	.2byte 0x038c
	.byte 0x04
	.4byte ..___tag_value__Z12print_pr_adjP3ADJ.49-..___tag_value__Z12print_pr_adjP3ADJ.48
	.2byte 0x048d
	.byte 0x04
	.4byte ..___tag_value__Z12print_pr_adjP3ADJ.52-..___tag_value__Z12print_pr_adjP3ADJ.49
	.2byte 0x04cc
	.4byte ..___tag_value__Z12print_pr_adjP3ADJ.53-..___tag_value__Z12print_pr_adjP3ADJ.52
	.2byte 0x04cd
	.4byte ..___tag_value__Z12print_pr_adjP3ADJ.54-..___tag_value__Z12print_pr_adjP3ADJ.53
	.8byte 0x000000000000080e
	.byte 0x00
	.4byte 0x0000007c
	.4byte 0x000001b4
	.8byte ..___tag_value__Z13vis_graph_adjP3ADJ.56
	.8byte ..___tag_value__Z13vis_graph_adjP3ADJ.79-..___tag_value__Z13vis_graph_adjP3ADJ.56
	.2byte 0x0400
	.4byte ..___tag_value__Z13vis_graph_adjP3ADJ.58-..___tag_value__Z13vis_graph_adjP3ADJ.56
	.4byte 0x028c100e
	.byte 0x04
	.4byte ..___tag_value__Z13vis_graph_adjP3ADJ.60-..___tag_value__Z13vis_graph_adjP3ADJ.58
	.4byte 0x038d180e
	.byte 0x04
	.4byte ..___tag_value__Z13vis_graph_adjP3ADJ.62-..___tag_value__Z13vis_graph_adjP3ADJ.60
	.2byte 0x300e
	.byte 0x04
	.4byte ..___tag_value__Z13vis_graph_adjP3ADJ.63-..___tag_value__Z13vis_graph_adjP3ADJ.62
	.2byte 0x048e
	.byte 0x04
	.4byte ..___tag_value__Z13vis_graph_adjP3ADJ.64-..___tag_value__Z13vis_graph_adjP3ADJ.63
	.2byte 0x058f
	.byte 0x04
	.4byte ..___tag_value__Z13vis_graph_adjP3ADJ.65-..___tag_value__Z13vis_graph_adjP3ADJ.64
	.2byte 0x0683
	.byte 0x04
	.4byte ..___tag_value__Z13vis_graph_adjP3ADJ.66-..___tag_value__Z13vis_graph_adjP3ADJ.65
	.2byte 0x04ce
	.4byte ..___tag_value__Z13vis_graph_adjP3ADJ.67-..___tag_value__Z13vis_graph_adjP3ADJ.66
	.2byte 0x04cf
	.4byte ..___tag_value__Z13vis_graph_adjP3ADJ.68-..___tag_value__Z13vis_graph_adjP3ADJ.67
	.2byte 0x04c3
	.4byte ..___tag_value__Z13vis_graph_adjP3ADJ.69-..___tag_value__Z13vis_graph_adjP3ADJ.68
	.4byte 0x04cd180e
	.4byte ..___tag_value__Z13vis_graph_adjP3ADJ.71-..___tag_value__Z13vis_graph_adjP3ADJ.69
	.4byte 0x04cc100e
	.4byte ..___tag_value__Z13vis_graph_adjP3ADJ.73-..___tag_value__Z13vis_graph_adjP3ADJ.71
	.2byte 0x080e
	.byte 0x04
	.4byte ..___tag_value__Z13vis_graph_adjP3ADJ.74-..___tag_value__Z13vis_graph_adjP3ADJ.73
	.8byte 0x0000038d028c300e
	.2byte 0x0000
	.byte 0x00
	.4byte 0x0000001c
	.4byte 0x00000234
	.8byte ..___tag_value__Z17init_pagerank_adjP3ADJ.80
	.8byte ..___tag_value__Z17init_pagerank_adjP3ADJ.82-..___tag_value__Z17init_pagerank_adjP3ADJ.80
	.8byte 0x0000000000000000
# End
