; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -passes=instcombine -S | FileCheck %s
;
; Make sure the llvm.access.group meta-data is preserved
; when a memcpy is replaced with a load+store by instcombine
;
; #include <string.h>
; void test(char* out, long size)
; {
;     #pragma clang loop vectorize(assume_safety)
;     for (long i = 0; i < size; i+=2) {
;         memcpy(&(out[i]), &(out[i+size]), 2);
;     }
; }

define void @_Z4testPcl(ptr %out, i64 %size) {
; CHECK-LABEL: @_Z4testPcl(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[FOR_COND:%.*]]
; CHECK:       for.cond:
; CHECK-NEXT:    [[I_0:%.*]] = phi i64 [ 0, [[ENTRY:%.*]] ], [ [[ADD2:%.*]], [[FOR_INC:%.*]] ]
; CHECK-NEXT:    [[CMP:%.*]] = icmp slt i64 [[I_0]], [[SIZE:%.*]]
; CHECK-NEXT:    br i1 [[CMP]], label [[FOR_BODY:%.*]], label [[FOR_END:%.*]]
; CHECK:       for.body:
; CHECK-NEXT:    [[ARRAYIDX:%.*]] = getelementptr inbounds nuw i8, ptr [[OUT:%.*]], i64 [[I_0]]
; CHECK-NEXT:    [[TMP0:%.*]] = getelementptr i8, ptr [[OUT]], i64 [[I_0]]
; CHECK-NEXT:    [[ARRAYIDX1:%.*]] = getelementptr i8, ptr [[TMP0]], i64 [[SIZE]]
; CHECK-NEXT:    [[TMP1:%.*]] = load i16, ptr [[ARRAYIDX1]], align 1, !llvm.access.group [[ACC_GRP0:![0-9]+]]
; CHECK-NEXT:    store i16 [[TMP1]], ptr [[ARRAYIDX]], align 1, !llvm.access.group [[ACC_GRP0]]
; CHECK-NEXT:    br label [[FOR_INC]]
; CHECK:       for.inc:
; CHECK-NEXT:    [[ADD2]] = add nuw nsw i64 [[I_0]], 2
; CHECK-NEXT:    br label [[FOR_COND]], !llvm.loop [[LOOP1:![0-9]+]]
; CHECK:       for.end:
; CHECK-NEXT:    ret void
;
entry:
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %entry
  %i.0 = phi i64 [ 0, %entry ], [ %add2, %for.inc ]
  %cmp = icmp slt i64 %i.0, %size
  br i1 %cmp, label %for.body, label %for.end

for.body:                                         ; preds = %for.cond
  %arrayidx = getelementptr inbounds i8, ptr %out, i64 %i.0
  %add = add nsw i64 %i.0, %size
  %arrayidx1 = getelementptr inbounds i8, ptr %out, i64 %add
  call void @llvm.memcpy.p0.p0.i64(ptr %arrayidx, ptr %arrayidx1, i64 2, i1 false), !llvm.access.group !4
  br label %for.inc

for.inc:                                          ; preds = %for.body
  %add2 = add nsw i64 %i.0, 2
  br label %for.cond, !llvm.loop !2

for.end:                                          ; preds = %for.cond
  ret void
}

declare void @llvm.memcpy.p0.p0.i64(ptr nocapture writeonly, ptr nocapture readonly, i64, i1)

!1 = distinct !{!1, !2, !3, !{!"llvm.loop.parallel_accesses", !4}}
!2 = distinct !{!2, !3}
!3 = !{!"llvm.loop.vectorize.enable", i1 true}
!4 = distinct !{} ; access group
