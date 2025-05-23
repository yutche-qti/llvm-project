; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-- -mcpu=x86-64    | FileCheck %s --check-prefixes=SSE
; RUN: llc < %s -mtriple=x86_64-- -mcpu=x86-64-v2 | FileCheck %s --check-prefixes=SSE
; RUN: llc < %s -mtriple=x86_64-- -mcpu=x86-64-v3 | FileCheck %s --check-prefixes=AVX
; RUN: llc < %s -mtriple=x86_64-- -mcpu=x86-64-v4 | FileCheck %s --check-prefixes=AVX

; Check for failure to recognise undef elements in constant foldable splats
define <4 x i32> @PR78109() {
; SSE-LABEL: PR78109:
; SSE:       # %bb.0:
; SSE-NEXT:    movaps {{.*#+}} xmm0 = [0,1,0,1]
; SSE-NEXT:    retq
  %shuffle.1 = shufflevector <4 x i32> <i32 7, i32 7, i32 0, i32 7>, <4 x i32> zeroinitializer, <4 x i32> <i32 2, i32 2, i32 1, i32 1> ; <0, 0, 7, 7>
  %shift = lshr <4 x i32> %shuffle.1, <i32 0, i32 0, i32 1, i32 0> ; <0, 0, 3, 7>
  %shuffle.2 = shufflevector <4 x i32> %shift, <4 x i32> zeroinitializer, <4 x i32> <i32 2, i32 2, i32 0, i32 0> ; <3, 3, 0, 0>
  %shuffle.3 = shufflevector <4 x i32> %shuffle.2, <4 x i32> <i32 1, i32 1, i32 1, i32 1>, <4 x i32> <i32 2, i32 6, i32 3, i32 7> ; <0, 1, 0, 1>
  ret <4 x i32> %shuffle.3
}
;; NOTE: These prefixes are unused and the list is autogenerated. Do not add tests below this line:
; AVX: {{.*}}
