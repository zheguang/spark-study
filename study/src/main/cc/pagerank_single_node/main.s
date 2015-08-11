# mark_description "Intel(R) C++ Intel(R) 64 Compiler XE for applications running on Intel(R) 64, Version 14.0.3.174 Build 20140";
# mark_description "422";
# mark_description "-O3 -xHost -openmp -lrt -DUSE_OMP -S";
	.file "main.c"
	.text
..TXTST0:
# -- Begin  main
# mark_begin;
       .align    16,0x90
	.globl main
main:
# parameter 1: %edi
# parameter 2: %rsi
..B1.1:                         # Preds ..B1.0
..___tag_value_main.1:                                          #14.1
        pushq     %rbp                                          #14.1
..___tag_value_main.3:                                          #
        movq      %rsp, %rbp                                    #14.1
..___tag_value_main.4:                                          #
        andq      $-128, %rsp                                   #14.1
        pushq     %r12                                          #14.1
        pushq     %r13                                          #14.1
        pushq     %r14                                          #14.1
        pushq     %r15                                          #14.1
        pushq     %rbx                                          #14.1
        subq      $88, %rsp                                     #14.1
..___tag_value_main.6:                                          #
        movq      %rsi, %r15                                    #14.1
        movl      %edi, %r14d                                   #14.1
        movq      $0x0000197fe, %rsi                            #14.1
        movl      $3, %edi                                      #14.1
        call      __intel_new_feature_proc_init                 #14.1
                                # LOE r15 r14d
..B1.56:                        # Preds ..B1.1
        vstmxcsr  (%rsp)                                        #14.1
        movl      $.2.11_2_kmpc_loc_struct_pack.5, %edi         #14.1
        xorl      %esi, %esi                                    #14.1
        orl       $32832, (%rsp)                                #14.1
        xorl      %eax, %eax                                    #14.1
        vldmxcsr  (%rsp)                                        #14.1
..___tag_value_main.11:                                         #14.1
        call      __kmpc_begin                                  #14.1
..___tag_value_main.12:                                         #
                                # LOE r15 r14d
..B1.2:                         # Preds ..B1.56
        xorb      %r13b, %r13b                                  #16.10
        movl      %r14d, %edi                                   #23.14
        movq      %r15, %rsi                                    #23.14
        movl      $.L_2__STRING.1, %edx                         #23.14
        xorb      %bl, %bl                                      #17.10
        vxorpd    %xmm0, %xmm0, %xmm0                           #20.21
        vmovsd    %xmm0, 64(%rsp)                               #20.21
        call      getopt                                        #23.14
                                # LOE r12 r15 eax r14d bl r13b
..B1.3:                         # Preds ..B1.2
        cmpl      $-1, %eax                                     #23.48
        je        ..B1.20       # Prob 29%                      #23.48
                                # LOE r12 r15 eax r14d bl r13b
..B1.5:                         # Preds ..B1.3 ..B1.17
        addl      $-63, %eax                                    #24.3
        cmpl      $49, %eax                                     #24.3
        ja        ..B1.24       # Prob 20%                      #24.3
                                # LOE r12 r15 eax r14d bl r13b
..B1.6:                         # Preds ..B1.5
        movslq    %eax, %rax                                    #24.3
        jmp       *..1..TPKT.2_0.0.2(,%rax,8)                   #24.3
                                # LOE r12 r15 r14d bl r13b
..1.2_0.TAG.070.0.2:
..B1.8:                         # Preds ..B1.6
        movq      optarg(%rip), %rcx                            #36.19
        call      __intel_sse4_atol                             #36.19
                                # LOE rax r12 r15 r14d bl r13b
..B1.9:                         # Preds ..B1.8
        movl      %eax, num_threads(%rip)                       #36.5
        jmp       ..B1.16       # Prob 100%                     #36.5
                                # LOE r12 r15 r14d bl r13b
..1.2_0.TAG.066.0.2:
..B1.11:                        # Preds ..B1.6
        movq      optarg(%rip), %r12                            #33.12
        jmp       ..B1.16       # Prob 100%                     #33.12
                                # LOE r12 r15 r14d bl r13b
..1.2_0.TAG.063.0.2:
..B1.13:                        # Preds ..B1.6
        movb      $1, %bl                                       #30.5
        jmp       ..B1.16       # Prob 100%                     #30.5
                                # LOE r12 r15 r14d bl r13b
..1.2_0.TAG.061.0.2:
..B1.15:                        # Preds ..B1.6
        movb      $1, %r13b                                     #27.5
                                # LOE r12 r15 r14d bl r13b
..B1.16:                        # Preds ..B1.15 ..B1.13 ..B1.11 ..B1.9
        movl      %r14d, %edi                                   #23.14
        movq      %r15, %rsi                                    #23.14
        movl      $.L_2__STRING.1, %edx                         #23.14
        vzeroupper                                              #23.14
        call      getopt                                        #23.14
                                # LOE r12 r15 eax r14d bl r13b
..B1.17:                        # Preds ..B1.16
        cmpl      $-1, %eax                                     #23.48
        jne       ..B1.5        # Prob 82%                      #23.48
                                # LOE r12 r15 eax r14d bl r13b
..B1.18:                        # Preds ..B1.17
        cmpb      $1, %r13b                                     #46.10
        je        ..B1.43       # Prob 1%                       #46.10
                                # LOE r12 bl
..B1.19:                        # Preds ..B1.18
        cmpb      $1, %bl                                       #59.15
        je        ..B1.29       # Prob 5%                       #59.15
                                # LOE r12
..B1.20:                        # Preds ..B1.3 ..B1.52 ..B1.42 ..B1.19
        movl      $.L_2__STRING.6, %edi                         #78.2
        vmovsd    64(%rsp), %xmm0                               #78.2
        movl      $1, %eax                                      #78.2
..___tag_value_main.13:                                         #78.2
        call      printf                                        #78.2
..___tag_value_main.14:                                         #
                                # LOE
..B1.21:                        # Preds ..B1.20
        movl      $.2.11_2_kmpc_loc_struct_pack.24, %edi        #79.9
        xorl      %eax, %eax                                    #79.9
..___tag_value_main.15:                                         #79.9
        call      __kmpc_end                                    #79.9
..___tag_value_main.16:                                         #
                                # LOE
..B1.22:                        # Preds ..B1.21
        xorl      %eax, %eax                                    #79.9
        addq      $88, %rsp                                     #79.9
..___tag_value_main.17:                                         #79.9
        popq      %rbx                                          #79.9
..___tag_value_main.18:                                         #79.9
        popq      %r15                                          #79.9
..___tag_value_main.19:                                         #79.9
        popq      %r14                                          #79.9
..___tag_value_main.20:                                         #79.9
        popq      %r13                                          #79.9
..___tag_value_main.21:                                         #79.9
        popq      %r12                                          #79.9
        movq      %rbp, %rsp                                    #79.9
        popq      %rbp                                          #79.9
..___tag_value_main.22:                                         #
        ret                                                     #79.9
..___tag_value_main.24:                                         #
                                # LOE
..1.2_0.TAG.DEFAULT.0.2:
..B1.24:                        # Preds ..B1.5 ..B1.6
        call      abort                                         #44.5
                                # LOE
..1.2_0.TAG.03f.0.2:
..B1.26:                        # Preds ..B1.6
        movl      $.L_2__STRING.0, %esi                         #39.5
        xorl      %eax, %eax                                    #39.5
        movl      optopt(%rip), %edx                            #39.5
        movq      stderr(%rip), %rdi                            #39.5
        call      fprintf                                       #39.5
                                # LOE
..B1.27:                        # Preds ..B1.26
        movl      $.2.11_2_kmpc_loc_struct_pack.16, %edi        #42.12
        xorl      %eax, %eax                                    #42.12
..___tag_value_main.31:                                         #42.12
        call      __kmpc_end                                    #42.12
..___tag_value_main.32:                                         #
                                # LOE
..B1.28:                        # Preds ..B1.27
        movl      $1, %eax                                      #42.12
        addq      $88, %rsp                                     #42.12
..___tag_value_main.33:                                         #42.12
        popq      %rbx                                          #42.12
..___tag_value_main.34:                                         #42.12
        popq      %r15                                          #42.12
..___tag_value_main.35:                                         #42.12
        popq      %r14                                          #42.12
..___tag_value_main.36:                                         #42.12
        popq      %r13                                          #42.12
..___tag_value_main.37:                                         #42.12
        popq      %r12                                          #42.12
        movq      %rbp, %rsp                                    #42.12
        popq      %rbp                                          #42.12
..___tag_value_main.38:                                         #
        ret                                                     #42.12
..___tag_value_main.40:                                         #
                                # LOE
..B1.29:                        # Preds ..B1.19                 # Infreq
        movl      $104, %edi                                    #61.27
        call      malloc                                        #61.27
                                # LOE rax r12
..B1.60:                        # Preds ..B1.29                 # Infreq
        movq      %rax, %rbx                                    #61.27
                                # LOE rbx r12
..B1.30:                        # Preds ..B1.60                 # Infreq
        movq      %rbx, %rdi                                    #62.3
        movq      %r12, %rsi                                    #62.3
..___tag_value_main.47:                                         #62.3
        call      _Z12scan_csr_idxP3CSRPc                       #62.3
..___tag_value_main.48:                                         #
                                # LOE rbx r12
..B1.31:                        # Preds ..B1.30                 # Infreq
        movl      $il0_peep_printf_format_0, %edi               #63.3
        call      puts                                          #63.3
                                # LOE rbx r12
..B1.32:                        # Preds ..B1.31                 # Infreq
        movq      %rbx, %rdi                                    #64.3
        movq      %r12, %rsi                                    #64.3
..___tag_value_main.49:                                         #64.3
        call      _Z14read_graph_csrP3CSRPc                     #64.3
..___tag_value_main.50:                                         #
                                # LOE rbx
..B1.33:                        # Preds ..B1.32                 # Infreq
        movl      $il0_peep_printf_format_1, %edi               #65.3
        call      puts                                          #65.3
                                # LOE rbx
..B1.34:                        # Preds ..B1.33                 # Infreq
        xorl      %edi, %edi                                    #66.3
        lea       32(%rsp), %rsi                                #66.3
        call      clock_gettime                                 #66.3
                                # LOE rbx
..B1.35:                        # Preds ..B1.34                 # Infreq
        xorl      %edi, %edi                                    #66.3
        lea       32(%rsp), %rsi                                #66.3
        call      clock_gettime                                 #66.3
                                # LOE rbx
..B1.36:                        # Preds ..B1.35                 # Infreq
        vxorpd    %xmm0, %xmm0, %xmm0                           #66.3
        vxorpd    %xmm1, %xmm1, %xmm1                           #66.3
        vcvtsi2sdq 40(%rsp), %xmm0, %xmm0                       #66.3
        vcvtsi2sdq 32(%rsp), %xmm1, %xmm1                       #66.3
        vmulsd    .L_2il0floatpacket.33(%rip), %xmm0, %xmm2     #66.3
        movq      %rbx, %rdi                                    #67.3
        vaddsd    %xmm2, %xmm1, %xmm3                           #66.3
        vmovsd    %xmm3, last_tic(%rip)                         #66.3
..___tag_value_main.51:                                         #67.3
        call      _Z17init_pagerank_csrP3CSR                    #67.3
..___tag_value_main.52:                                         #
                                # LOE rbx
..B1.37:                        # Preds ..B1.36                 # Infreq
        movl      $il0_peep_printf_format_2, %edi               #68.3
        call      puts                                          #68.3
                                # LOE rbx
..B1.38:                        # Preds ..B1.37                 # Infreq
        movq      %rbx, %rdi                                    #70.3
..___tag_value_main.53:                                         #70.3
        call      _Z20compute_pagerank_csrP3CSR                 #70.3
..___tag_value_main.54:                                         #
                                # LOE
..B1.39:                        # Preds ..B1.38                 # Infreq
        movl      $il0_peep_printf_format_3, %edi               #71.3
        call      puts                                          #71.3
                                # LOE
..B1.40:                        # Preds ..B1.39                 # Infreq
        xorl      %edi, %edi                                    #74.9
        lea       48(%rsp), %rsi                                #74.9
        call      clock_gettime                                 #74.9
                                # LOE
..B1.41:                        # Preds ..B1.40                 # Infreq
        xorl      %edi, %edi                                    #74.9
        lea       48(%rsp), %rsi                                #74.9
        call      clock_gettime                                 #74.9
                                # LOE
..B1.42:                        # Preds ..B1.41                 # Infreq
        vxorpd    %xmm0, %xmm0, %xmm0                           #74.9
        vxorpd    %xmm1, %xmm1, %xmm1                           #74.9
        vcvtsi2sdq 56(%rsp), %xmm0, %xmm0                       #74.9
        vcvtsi2sdq 48(%rsp), %xmm1, %xmm1                       #74.9
        vmulsd    .L_2il0floatpacket.33(%rip), %xmm0, %xmm2     #74.9
        vaddsd    %xmm2, %xmm1, %xmm4                           #74.9
        vsubsd    last_tic(%rip), %xmm4, %xmm3                  #74.9
        vmovsd    %xmm3, 64(%rsp)                               #74.9
        vmovsd    %xmm4, last_tic(%rip)                         #74.9
        jmp       ..B1.20       # Prob 100%                     #74.9
                                # LOE
..B1.43:                        # Preds ..B1.18                 # Infreq
        movl      $72, %edi                                     #48.27
        call      malloc                                        #48.27
                                # LOE rax r12
..B1.61:                        # Preds ..B1.43                 # Infreq
        movq      %rax, %rbx                                    #48.27
                                # LOE rbx r12
..B1.44:                        # Preds ..B1.61                 # Infreq
        movq      %rbx, %rdi                                    #49.3
        movq      %r12, %rsi                                    #49.3
..___tag_value_main.55:                                         #49.3
        call      _Z13scan_adj_sizeP3ADJPc                      #49.3
..___tag_value_main.56:                                         #
                                # LOE rbx r12
..B1.45:                        # Preds ..B1.44                 # Infreq
        movq      %rbx, %rdi                                    #50.3
        movq      %r12, %rsi                                    #50.3
..___tag_value_main.57:                                         #50.3
        call      _Z14read_graph_adjP3ADJPc                     #50.3
..___tag_value_main.58:                                         #
                                # LOE rbx
..B1.46:                        # Preds ..B1.45                 # Infreq
        xorl      %edi, %edi                                    #51.3
        lea       (%rsp), %rsi                                  #51.3
        call      clock_gettime                                 #51.3
                                # LOE rbx
..B1.47:                        # Preds ..B1.46                 # Infreq
        xorl      %edi, %edi                                    #51.3
        lea       (%rsp), %rsi                                  #51.3
        call      clock_gettime                                 #51.3
                                # LOE rbx
..B1.48:                        # Preds ..B1.47                 # Infreq
        vxorpd    %xmm0, %xmm0, %xmm0                           #51.3
        vxorpd    %xmm1, %xmm1, %xmm1                           #51.3
        vcvtsi2sdq 8(%rsp), %xmm0, %xmm0                        #51.3
        vcvtsi2sdq (%rsp), %xmm1, %xmm1                         #51.3
        vmulsd    .L_2il0floatpacket.33(%rip), %xmm0, %xmm2     #51.3
        movq      %rbx, %rdi                                    #52.3
        vaddsd    %xmm2, %xmm1, %xmm3                           #51.3
        vmovsd    %xmm3, last_tic(%rip)                         #51.3
..___tag_value_main.59:                                         #52.3
        call      _Z17init_pagerank_adjP3ADJ                    #52.3
..___tag_value_main.60:                                         #
                                # LOE rbx
..B1.49:                        # Preds ..B1.48                 # Infreq
        movq      %rbx, %rdi                                    #54.3
..___tag_value_main.61:                                         #54.3
        call      _Z20compute_pagerank_adjP3ADJ                 #54.3
..___tag_value_main.62:                                         #
                                # LOE
..B1.50:                        # Preds ..B1.49                 # Infreq
        xorl      %edi, %edi                                    #57.9
        lea       16(%rsp), %rsi                                #57.9
        call      clock_gettime                                 #57.9
                                # LOE
..B1.51:                        # Preds ..B1.50                 # Infreq
        xorl      %edi, %edi                                    #57.9
        lea       16(%rsp), %rsi                                #57.9
        call      clock_gettime                                 #57.9
                                # LOE
..B1.52:                        # Preds ..B1.51                 # Infreq
        vxorpd    %xmm0, %xmm0, %xmm0                           #57.9
        vxorpd    %xmm1, %xmm1, %xmm1                           #57.9
        vcvtsi2sdq 24(%rsp), %xmm0, %xmm0                       #57.9
        vcvtsi2sdq 16(%rsp), %xmm1, %xmm1                       #57.9
        vmulsd    .L_2il0floatpacket.33(%rip), %xmm0, %xmm2     #57.9
        vaddsd    %xmm2, %xmm1, %xmm4                           #57.9
        vsubsd    last_tic(%rip), %xmm4, %xmm3                  #57.9
        vmovsd    %xmm3, 64(%rsp)                               #57.9
        vmovsd    %xmm4, last_tic(%rip)                         #57.9
        jmp       ..B1.20       # Prob 100%                     #57.9
        .align    16,0x90
..___tag_value_main.63:                                         #
                                # LOE
# mark_end;
	.type	main,@function
	.size	main,.-main
	.data
	.align 8
	.align 4
.2.11_2_kmpc_loc_struct_pack.5:
	.long	0
	.long	2
	.long	0
	.long	0
	.quad	.2.11_2__kmpc_loc_pack.4
	.align 4
.2.11_2__kmpc_loc_pack.4:
	.byte	59
	.byte	117
	.byte	110
	.byte	107
	.byte	110
	.byte	111
	.byte	119
	.byte	110
	.byte	59
	.byte	109
	.byte	97
	.byte	105
	.byte	110
	.byte	59
	.byte	49
	.byte	52
	.byte	59
	.byte	49
	.byte	52
	.byte	59
	.byte	59
	.space 3, 0x00 	# pad
	.align 4
.2.11_2_kmpc_loc_struct_pack.16:
	.long	0
	.long	2
	.long	0
	.long	0
	.quad	.2.11_2__kmpc_loc_pack.15
	.align 4
.2.11_2__kmpc_loc_pack.15:
	.byte	59
	.byte	117
	.byte	110
	.byte	107
	.byte	110
	.byte	111
	.byte	119
	.byte	110
	.byte	59
	.byte	109
	.byte	97
	.byte	105
	.byte	110
	.byte	59
	.byte	52
	.byte	50
	.byte	59
	.byte	52
	.byte	50
	.byte	59
	.byte	59
	.space 3, 0x00 	# pad
	.align 4
.2.11_2_kmpc_loc_struct_pack.24:
	.long	0
	.long	2
	.long	0
	.long	0
	.quad	.2.11_2__kmpc_loc_pack.23
	.align 4
.2.11_2__kmpc_loc_pack.23:
	.byte	59
	.byte	117
	.byte	110
	.byte	107
	.byte	110
	.byte	111
	.byte	119
	.byte	110
	.byte	59
	.byte	109
	.byte	97
	.byte	105
	.byte	110
	.byte	59
	.byte	55
	.byte	57
	.byte	59
	.byte	55
	.byte	57
	.byte	59
	.byte	59
	.section .rodata, "a"
	.align 32
	.align 32
..1..TPKT.2_0.0.2:
	.quad	..1.2_0.TAG.03f.0.2
	.quad	..1.2_0.TAG.DEFAULT.0.2
	.quad	..1.2_0.TAG.DEFAULT.0.2
	.quad	..1.2_0.TAG.DEFAULT.0.2
	.quad	..1.2_0.TAG.DEFAULT.0.2
	.quad	..1.2_0.TAG.DEFAULT.0.2
	.quad	..1.2_0.TAG.DEFAULT.0.2
	.quad	..1.2_0.TAG.DEFAULT.0.2
	.quad	..1.2_0.TAG.DEFAULT.0.2
	.quad	..1.2_0.TAG.DEFAULT.0.2
	.quad	..1.2_0.TAG.DEFAULT.0.2
	.quad	..1.2_0.TAG.DEFAULT.0.2
	.quad	..1.2_0.TAG.DEFAULT.0.2
	.quad	..1.2_0.TAG.DEFAULT.0.2
	.quad	..1.2_0.TAG.DEFAULT.0.2
	.quad	..1.2_0.TAG.DEFAULT.0.2
	.quad	..1.2_0.TAG.DEFAULT.0.2
	.quad	..1.2_0.TAG.DEFAULT.0.2
	.quad	..1.2_0.TAG.DEFAULT.0.2
	.quad	..1.2_0.TAG.DEFAULT.0.2
	.quad	..1.2_0.TAG.DEFAULT.0.2
	.quad	..1.2_0.TAG.DEFAULT.0.2
	.quad	..1.2_0.TAG.DEFAULT.0.2
	.quad	..1.2_0.TAG.DEFAULT.0.2
	.quad	..1.2_0.TAG.DEFAULT.0.2
	.quad	..1.2_0.TAG.DEFAULT.0.2
	.quad	..1.2_0.TAG.DEFAULT.0.2
	.quad	..1.2_0.TAG.DEFAULT.0.2
	.quad	..1.2_0.TAG.DEFAULT.0.2
	.quad	..1.2_0.TAG.DEFAULT.0.2
	.quad	..1.2_0.TAG.DEFAULT.0.2
	.quad	..1.2_0.TAG.DEFAULT.0.2
	.quad	..1.2_0.TAG.DEFAULT.0.2
	.quad	..1.2_0.TAG.DEFAULT.0.2
	.quad	..1.2_0.TAG.061.0.2
	.quad	..1.2_0.TAG.DEFAULT.0.2
	.quad	..1.2_0.TAG.063.0.2
	.quad	..1.2_0.TAG.DEFAULT.0.2
	.quad	..1.2_0.TAG.DEFAULT.0.2
	.quad	..1.2_0.TAG.066.0.2
	.quad	..1.2_0.TAG.DEFAULT.0.2
	.quad	..1.2_0.TAG.DEFAULT.0.2
	.quad	..1.2_0.TAG.DEFAULT.0.2
	.quad	..1.2_0.TAG.DEFAULT.0.2
	.quad	..1.2_0.TAG.DEFAULT.0.2
	.quad	..1.2_0.TAG.DEFAULT.0.2
	.quad	..1.2_0.TAG.DEFAULT.0.2
	.quad	..1.2_0.TAG.DEFAULT.0.2
	.quad	..1.2_0.TAG.DEFAULT.0.2
	.quad	..1.2_0.TAG.070.0.2
	.section .rodata.str1.4, "aMS",@progbits,1
	.align 4
	.align 4
il0_peep_printf_format_0:
	.long	1768843622
	.long	1684367475
	.long	1633907488
	.word	110
	.space 2, 0x00 	# pad
	.align 4
il0_peep_printf_format_1:
	.long	1768843622
	.long	1684367475
	.long	1634038304
	.word	100
	.space 2, 0x00 	# pad
	.align 4
il0_peep_printf_format_2:
	.long	1768843622
	.long	1684367475
	.long	1768843552
	.word	116
	.space 2, 0x00 	# pad
	.align 4
il0_peep_printf_format_3:
	.long	1768843622
	.long	1684367475
	.long	1836016416
	.long	1702131056
	.byte	0
	.data
# -- End  main
	.text
# -- Begin  _Z5timerv
# mark_begin;
       .align    16,0x90
	.globl _Z5timerv
_Z5timerv:
..B2.1:                         # Preds ..B2.0
..___tag_value__Z5timerv.64:                                    #85.1
        subq      $24, %rsp                                     #85.1
..___tag_value__Z5timerv.66:                                    #
        xorl      %edi, %edi                                    #87.3
        lea       (%rsp), %rsi                                  #87.3
        call      clock_gettime                                 #87.3
                                # LOE rbx rbp r12 r13 r14 r15
..B2.2:                         # Preds ..B2.1
        xorl      %edi, %edi                                    #88.3
        lea       (%rsp), %rsi                                  #88.3
        call      clock_gettime                                 #88.3
                                # LOE rbx rbp r12 r13 r14 r15
..B2.3:                         # Preds ..B2.2
        vcvtsi2sdq 8(%rsp), %xmm0, %xmm0                        #89.49
        vcvtsi2sdq (%rsp), %xmm1, %xmm1                         #89.19
        vmulsd    .L_2il0floatpacket.33(%rip), %xmm0, %xmm2     #89.49
        vaddsd    %xmm2, %xmm1, %xmm0                           #89.49
        addq      $24, %rsp                                     #89.49
..___tag_value__Z5timerv.67:                                    #
        ret                                                     #89.49
        .align    16,0x90
..___tag_value__Z5timerv.68:                                    #
                                # LOE
# mark_end;
	.type	_Z5timerv,@function
	.size	_Z5timerv,.-_Z5timerv
	.data
# -- End  _Z5timerv
	.text
# -- Begin  _Z3ticv
# mark_begin;
       .align    16,0x90
	.globl _Z3ticv
_Z3ticv:
..B3.1:                         # Preds ..B3.0
..___tag_value__Z3ticv.69:                                      #95.1
        subq      $24, %rsp                                     #95.1
..___tag_value__Z3ticv.71:                                      #
        xorl      %edi, %edi                                    #96.14
        lea       (%rsp), %rsi                                  #96.14
        call      clock_gettime                                 #96.14
                                # LOE rbx rbp r12 r13 r14 r15
..B3.2:                         # Preds ..B3.1
        xorl      %edi, %edi                                    #96.14
        lea       (%rsp), %rsi                                  #96.14
        call      clock_gettime                                 #96.14
                                # LOE rbx rbp r12 r13 r14 r15
..B3.3:                         # Preds ..B3.2
        vcvtsi2sdq 8(%rsp), %xmm0, %xmm0                        #96.14
        vcvtsi2sdq (%rsp), %xmm1, %xmm1                         #96.14
        vmulsd    .L_2il0floatpacket.33(%rip), %xmm0, %xmm2     #96.14
        vaddsd    %xmm2, %xmm1, %xmm3                           #96.14
        vmovsd    %xmm3, last_tic(%rip)                         #96.3
        addq      $24, %rsp                                     #97.1
..___tag_value__Z3ticv.72:                                      #
        ret                                                     #97.1
        .align    16,0x90
..___tag_value__Z3ticv.73:                                      #
                                # LOE
# mark_end;
	.type	_Z3ticv,@function
	.size	_Z3ticv,.-_Z3ticv
	.data
# -- End  _Z3ticv
	.text
# -- Begin  _Z3tocv
# mark_begin;
       .align    16,0x90
	.globl _Z3tocv
_Z3tocv:
..B4.1:                         # Preds ..B4.0
..___tag_value__Z3tocv.74:                                      #101.1
        subq      $24, %rsp                                     #101.1
..___tag_value__Z3tocv.76:                                      #
        xorl      %edi, %edi                                    #102.20
        lea       (%rsp), %rsi                                  #102.20
        call      clock_gettime                                 #102.20
                                # LOE rbx rbp r12 r13 r14 r15
..B4.2:                         # Preds ..B4.1
        xorl      %edi, %edi                                    #102.20
        lea       (%rsp), %rsi                                  #102.20
        call      clock_gettime                                 #102.20
                                # LOE rbx rbp r12 r13 r14 r15
..B4.3:                         # Preds ..B4.2
        vcvtsi2sdq 8(%rsp), %xmm0, %xmm0                        #102.20
        vcvtsi2sdq (%rsp), %xmm1, %xmm1                         #102.20
        vmulsd    .L_2il0floatpacket.33(%rip), %xmm0, %xmm2     #102.20
        vaddsd    %xmm2, %xmm1, %xmm3                           #102.20
        vsubsd    last_tic(%rip), %xmm3, %xmm0                  #103.26
        vmovsd    %xmm3, last_tic(%rip)                         #104.3
        addq      $24, %rsp                                     #105.10
..___tag_value__Z3tocv.77:                                      #
        ret                                                     #105.10
        .align    16,0x90
..___tag_value__Z3tocv.78:                                      #
                                # LOE
# mark_end;
	.type	_Z3tocv,@function
	.size	_Z3tocv,.-_Z3tocv
	.data
# -- End  _Z3tocv
	.data
	.space 3, 0x00 	# pad
	.align 8
last_tic:
	.long	0x00000000,0xbff00000
	.type	last_tic,@object
	.size	last_tic,8
	.align 4
	.globl num_threads
num_threads:
	.long	1
	.type	num_threads,@object
	.size	num_threads,4
	.section .rodata, "a"
	.align 8
.L_2il0floatpacket.33:
	.long	0xe826d695,0x3e112e0b
	.type	.L_2il0floatpacket.33,@object
	.size	.L_2il0floatpacket.33,8
	.section .rodata.str1.4, "aMS",@progbits,1
	.space 3, 0x00 	# pad
	.align 4
.L_2__STRING.1:
	.long	980444001
	.word	14950
	.byte	0
	.type	.L_2__STRING.1,@object
	.size	.L_2__STRING.1,7
	.space 1, 0x00 	# pad
	.align 4
.L_2__STRING.0:
	.long	1852534357
	.long	544110447
	.long	1769238639
	.long	1663069807
	.long	1634885992
	.long	1919251555
	.long	2019319840
	.long	774338597
	.word	10
	.type	.L_2__STRING.0,@object
	.size	.L_2__STRING.0,34
	.space 2, 0x00 	# pad
	.align 4
.L_2__STRING.6:
	.long	1701273968
	.long	1851879968
	.long	1769218155
	.long	1763730797
	.long	1713709171
	.long	1667592992
	.long	1935961711
	.word	2606
	.byte	0
	.type	.L_2__STRING.6,@object
	.size	.L_2__STRING.6,31
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
	.4byte 0x0000018c
	.4byte 0x00000024
	.8byte ..___tag_value_main.1
	.8byte ..___tag_value_main.63-..___tag_value_main.1
	.2byte 0x0400
	.4byte ..___tag_value_main.3-..___tag_value_main.1
	.2byte 0x100e
	.byte 0x04
	.4byte ..___tag_value_main.4-..___tag_value_main.3
	.4byte 0x8610060c
	.2byte 0x0402
	.4byte ..___tag_value_main.6-..___tag_value_main.4
	.8byte 0xff800d1c380e0310
	.8byte 0xffffffd80d1affff
	.8byte 0x800d1c380e0c1022
	.8byte 0xfffff80d1affffff
	.8byte 0x0d1c380e0d1022ff
	.8byte 0xfff00d1affffff80
	.8byte 0x1c380e0e1022ffff
	.8byte 0xe80d1affffff800d
	.8byte 0x380e0f1022ffffff
	.8byte 0x0d1affffff800d1c
	.4byte 0xffffffe0
	.2byte 0x0422
	.4byte ..___tag_value_main.17-..___tag_value_main.6
	.2byte 0x04c3
	.4byte ..___tag_value_main.18-..___tag_value_main.17
	.2byte 0x04cf
	.4byte ..___tag_value_main.19-..___tag_value_main.18
	.2byte 0x04ce
	.4byte ..___tag_value_main.20-..___tag_value_main.19
	.2byte 0x04cd
	.4byte ..___tag_value_main.21-..___tag_value_main.20
	.2byte 0x04cc
	.4byte ..___tag_value_main.22-..___tag_value_main.21
	.4byte 0xc608070c
	.byte 0x04
	.4byte ..___tag_value_main.24-..___tag_value_main.22
	.8byte 0x1c380e031010060c
	.8byte 0xd80d1affffff800d
	.8byte 0x0c10028622ffffff
	.8byte 0xffffff800d1c380e
	.8byte 0x1022fffffff80d1a
	.8byte 0xffff800d1c380e0d
	.8byte 0x22fffffff00d1aff
	.8byte 0xff800d1c380e0e10
	.8byte 0xffffffe80d1affff
	.8byte 0x800d1c380e0f1022
	.8byte 0xffffe00d1affffff
	.2byte 0x22ff
	.byte 0x04
	.4byte ..___tag_value_main.33-..___tag_value_main.24
	.2byte 0x04c3
	.4byte ..___tag_value_main.34-..___tag_value_main.33
	.2byte 0x04cf
	.4byte ..___tag_value_main.35-..___tag_value_main.34
	.2byte 0x04ce
	.4byte ..___tag_value_main.36-..___tag_value_main.35
	.2byte 0x04cd
	.4byte ..___tag_value_main.37-..___tag_value_main.36
	.2byte 0x04cc
	.4byte ..___tag_value_main.38-..___tag_value_main.37
	.4byte 0xc608070c
	.byte 0x04
	.4byte ..___tag_value_main.40-..___tag_value_main.38
	.8byte 0x1c380e031010060c
	.8byte 0xd80d1affffff800d
	.8byte 0x0c10028622ffffff
	.8byte 0xffffff800d1c380e
	.8byte 0x1022fffffff80d1a
	.8byte 0xffff800d1c380e0d
	.8byte 0x22fffffff00d1aff
	.8byte 0xff800d1c380e0e10
	.8byte 0xffffffe80d1affff
	.8byte 0x800d1c380e0f1022
	.8byte 0xffffe00d1affffff
	.2byte 0x22ff
	.4byte 0x00000024
	.4byte 0x000001b4
	.8byte ..___tag_value__Z5timerv.64
	.8byte ..___tag_value__Z5timerv.68-..___tag_value__Z5timerv.64
	.2byte 0x0400
	.4byte ..___tag_value__Z5timerv.66-..___tag_value__Z5timerv.64
	.2byte 0x200e
	.byte 0x04
	.4byte ..___tag_value__Z5timerv.67-..___tag_value__Z5timerv.66
	.2byte 0x080e
	.byte 0x00
	.4byte 0x00000024
	.4byte 0x000001dc
	.8byte ..___tag_value__Z3ticv.69
	.8byte ..___tag_value__Z3ticv.73-..___tag_value__Z3ticv.69
	.2byte 0x0400
	.4byte ..___tag_value__Z3ticv.71-..___tag_value__Z3ticv.69
	.2byte 0x200e
	.byte 0x04
	.4byte ..___tag_value__Z3ticv.72-..___tag_value__Z3ticv.71
	.2byte 0x080e
	.byte 0x00
	.4byte 0x00000024
	.4byte 0x00000204
	.8byte ..___tag_value__Z3tocv.74
	.8byte ..___tag_value__Z3tocv.78-..___tag_value__Z3tocv.74
	.2byte 0x0400
	.4byte ..___tag_value__Z3tocv.76-..___tag_value__Z3tocv.74
	.2byte 0x200e
	.byte 0x04
	.4byte ..___tag_value__Z3tocv.77-..___tag_value__Z3tocv.76
	.2byte 0x080e
	.byte 0x00
# End
