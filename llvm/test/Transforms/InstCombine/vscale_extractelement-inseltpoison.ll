; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -instcombine -S | FileCheck %s

define i32 @extractelement_in_range(<vscale x 4 x i32> %a) {
; CHECK-LABEL: @extractelement_in_range(
; CHECK-NEXT:    [[R:%.*]] = extractelement <vscale x 4 x i32> [[A:%.*]], i64 1
; CHECK-NEXT:    ret i32 [[R]]
;
  %r = extractelement <vscale x 4 x i32> %a, i64 1
  ret i32 %r
}

define i32 @extractelement_maybe_out_of_range(<vscale x 4 x i32> %a) {
; CHECK-LABEL: @extractelement_maybe_out_of_range(
; CHECK-NEXT:    [[R:%.*]] = extractelement <vscale x 4 x i32> [[A:%.*]], i64 4
; CHECK-NEXT:    ret i32 [[R]]
;
  %r = extractelement <vscale x 4 x i32> %a, i64 4
  ret i32 %r
}

define i32 @extractelement_bitcast(float %f) {
; CHECK-LABEL: @extractelement_bitcast(
; CHECK-NEXT:    [[R:%.*]] = bitcast float [[F:%.*]] to i32
; CHECK-NEXT:    ret i32 [[R]]
;
  %vec_float = insertelement <vscale x 4 x float> poison, float %f, i32 0
  %vec_int = bitcast <vscale x 4 x float> %vec_float to <vscale x 4 x i32>
  %r = extractelement <vscale x 4 x i32> %vec_int, i32 0
  ret i32 %r
}

define i8 @extractelement_bitcast_to_trunc(<vscale x 2 x i32> %a, i32 %x) {
; CHECK-LABEL: @extractelement_bitcast_to_trunc(
; CHECK-NEXT:    [[R:%.*]] = trunc i32 [[X:%.*]] to i8
; CHECK-NEXT:    ret i8 [[R]]
;
  %vec = insertelement <vscale x 2 x i32> %a, i32 %x, i32 1
  %vec_cast = bitcast <vscale x 2 x i32> %vec to <vscale x 8 x i8>
  %r = extractelement <vscale x 8 x i8> %vec_cast, i32 4
  ret i8 %r
}

; TODO: Instcombine could remove the insert.
define i8 @extractelement_bitcast_wrong_insert(<vscale x 2 x i32> %a, i32 %x) {
; CHECK-LABEL: @extractelement_bitcast_wrong_insert(
; CHECK-NEXT:    [[VEC:%.*]] = insertelement <vscale x 2 x i32> [[A:%.*]], i32 [[X:%.*]], i32 1
; CHECK-NEXT:    [[VEC_CAST:%.*]] = bitcast <vscale x 2 x i32> [[VEC]] to <vscale x 8 x i8>
; CHECK-NEXT:    [[R:%.*]] = extractelement <vscale x 8 x i8> [[VEC_CAST]], i32 2
; CHECK-NEXT:    ret i8 [[R]]
;
  %vec = insertelement <vscale x 2 x i32> %a, i32 %x, i32 1 ; <- This insert could be removed.
  %vec_cast = bitcast <vscale x 2 x i32> %vec to <vscale x 8 x i8>
  %r = extractelement <vscale x 8 x i8> %vec_cast, i32 2
  ret i8 %r
}

; TODO: Instcombine could optimize to return %v.
define i32 @extractelement_shuffle_in_range(i32 %v) {
; CHECK-LABEL: @extractelement_shuffle_in_range(
; CHECK-NEXT:    [[IN:%.*]] = insertelement <vscale x 4 x i32> poison, i32 [[V:%.*]], i32 0
; CHECK-NEXT:    [[SPLAT:%.*]] = shufflevector <vscale x 4 x i32> [[IN]], <vscale x 4 x i32> undef, <vscale x 4 x i32> zeroinitializer
; CHECK-NEXT:    [[R:%.*]] = extractelement <vscale x 4 x i32> [[SPLAT]], i32 1
; CHECK-NEXT:    ret i32 [[R]]
;
  %in = insertelement <vscale x 4 x i32> poison, i32 %v, i32 0
  %splat = shufflevector <vscale x 4 x i32> %in, <vscale x 4 x i32> undef, <vscale x 4 x i32> zeroinitializer
  %r = extractelement <vscale x 4 x i32> %splat, i32 1
  ret i32 %r
}

define i32 @extractelement_shuffle_maybe_out_of_range(i32 %v) {
; CHECK-LABEL: @extractelement_shuffle_maybe_out_of_range(
; CHECK-NEXT:    [[IN:%.*]] = insertelement <vscale x 4 x i32> poison, i32 [[V:%.*]], i32 0
; CHECK-NEXT:    [[SPLAT:%.*]] = shufflevector <vscale x 4 x i32> [[IN]], <vscale x 4 x i32> undef, <vscale x 4 x i32> zeroinitializer
; CHECK-NEXT:    [[R:%.*]] = extractelement <vscale x 4 x i32> [[SPLAT]], i32 4
; CHECK-NEXT:    ret i32 [[R]]
;
  %in = insertelement <vscale x 4 x i32> poison, i32 %v, i32 0
  %splat = shufflevector <vscale x 4 x i32> %in, <vscale x 4 x i32> undef, <vscale x 4 x i32> zeroinitializer
  %r = extractelement <vscale x 4 x i32> %splat, i32 4
  ret i32 %r
}

define i32 @extractelement_shuffle_invalid_index(i32 %v) {
; CHECK-LABEL: @extractelement_shuffle_invalid_index(
; CHECK-NEXT:    [[IN:%.*]] = insertelement <vscale x 4 x i32> poison, i32 [[V:%.*]], i32 0
; CHECK-NEXT:    [[SPLAT:%.*]] = shufflevector <vscale x 4 x i32> [[IN]], <vscale x 4 x i32> undef, <vscale x 4 x i32> zeroinitializer
; CHECK-NEXT:    [[R:%.*]] = extractelement <vscale x 4 x i32> [[SPLAT]], i32 -1
; CHECK-NEXT:    ret i32 [[R]]
;
  %in = insertelement <vscale x 4 x i32> poison, i32 %v, i32 0
  %splat = shufflevector <vscale x 4 x i32> %in, <vscale x 4 x i32> undef, <vscale x 4 x i32> zeroinitializer
  %r = extractelement <vscale x 4 x i32> %splat, i32 -1
  ret i32 %r
}


define i32 @extractelement_shuffle_symbolic_index(i32 %v, i32 %idx) {
; CHECK-LABEL: @extractelement_shuffle_symbolic_index(
; CHECK-NEXT:    [[IN:%.*]] = insertelement <vscale x 4 x i32> poison, i32 [[V:%.*]], i32 0
; CHECK-NEXT:    [[SPLAT:%.*]] = shufflevector <vscale x 4 x i32> [[IN]], <vscale x 4 x i32> undef, <vscale x 4 x i32> zeroinitializer
; CHECK-NEXT:    [[R:%.*]] = extractelement <vscale x 4 x i32> [[SPLAT]], i32 [[IDX:%.*]]
; CHECK-NEXT:    ret i32 [[R]]
;
  %in = insertelement <vscale x 4 x i32> poison, i32 %v, i32 0
  %splat = shufflevector <vscale x 4 x i32> %in, <vscale x 4 x i32> undef, <vscale x 4 x i32> zeroinitializer
  %r = extractelement <vscale x 4 x i32> %splat, i32 %idx
  ret i32 %r
}

define <vscale x 4 x i32> @extractelement_insertelement_same_positions(<vscale x 4 x i32> %vec) {
; CHECK-LABEL: @extractelement_insertelement_same_positions(
; CHECK-NEXT:    ret <vscale x 4 x i32> [[VEC:%.*]]
;
  %vec.e0 = extractelement <vscale x 4 x i32> %vec, i32 0
  %vec.e1 = extractelement <vscale x 4 x i32> %vec, i32 1
  %vec.e2 = extractelement <vscale x 4 x i32> %vec, i32 2
  %vec.e3 = extractelement <vscale x 4 x i32> %vec, i32 3
  %1 = insertelement <vscale x 4 x i32> %vec, i32 %vec.e0, i32 0
  %2 = insertelement <vscale x 4 x i32> %1, i32 %vec.e1, i32 1
  %3 = insertelement <vscale x 4 x i32> %2, i32 %vec.e2, i32 2
  %4 = insertelement <vscale x 4 x i32> %3, i32 %vec.e3, i32 3
  ret <vscale x 4 x i32> %4
}

define <vscale x 4 x i32> @extractelement_insertelement_diff_positions(<vscale x 4 x i32> %vec) {
; CHECK-LABEL: @extractelement_insertelement_diff_positions(
; CHECK-NEXT:    [[VEC_E0:%.*]] = extractelement <vscale x 4 x i32> [[VEC:%.*]], i32 4
; CHECK-NEXT:    [[VEC_E1:%.*]] = extractelement <vscale x 4 x i32> [[VEC]], i32 5
; CHECK-NEXT:    [[VEC_E2:%.*]] = extractelement <vscale x 4 x i32> [[VEC]], i32 6
; CHECK-NEXT:    [[VEC_E3:%.*]] = extractelement <vscale x 4 x i32> [[VEC]], i32 7
; CHECK-NEXT:    [[TMP1:%.*]] = insertelement <vscale x 4 x i32> [[VEC]], i32 [[VEC_E0]], i32 0
; CHECK-NEXT:    [[TMP2:%.*]] = insertelement <vscale x 4 x i32> [[TMP1]], i32 [[VEC_E1]], i32 1
; CHECK-NEXT:    [[TMP3:%.*]] = insertelement <vscale x 4 x i32> [[TMP2]], i32 [[VEC_E2]], i32 2
; CHECK-NEXT:    [[TMP4:%.*]] = insertelement <vscale x 4 x i32> [[TMP3]], i32 [[VEC_E3]], i32 3
; CHECK-NEXT:    ret <vscale x 4 x i32> [[TMP4]]
;
  %vec.e0 = extractelement <vscale x 4 x i32> %vec, i32 4
  %vec.e1 = extractelement <vscale x 4 x i32> %vec, i32 5
  %vec.e2 = extractelement <vscale x 4 x i32> %vec, i32 6
  %vec.e3 = extractelement <vscale x 4 x i32> %vec, i32 7
  %1 = insertelement <vscale x 4 x i32> %vec, i32 %vec.e0, i32 0
  %2 = insertelement <vscale x 4 x i32> %1, i32 %vec.e1, i32 1
  %3 = insertelement <vscale x 4 x i32> %2, i32 %vec.e2, i32 2
  %4 = insertelement <vscale x 4 x i32> %3, i32 %vec.e3, i32 3
  ret <vscale x 4 x i32> %4
}

define i32 @bitcast_of_extractelement( <vscale x 2 x float> %d) {
; CHECK-LABEL: @bitcast_of_extractelement(
; CHECK-NEXT:    [[BC:%.*]] = bitcast <vscale x 2 x float> [[D:%.*]] to <vscale x 2 x i32>
; CHECK-NEXT:    [[CAST:%.*]] = extractelement <vscale x 2 x i32> [[BC]], i32 0
; CHECK-NEXT:    ret i32 [[CAST]]
;
  %ext = extractelement <vscale x 2 x float> %d, i32 0
  %cast = bitcast float %ext to i32
  ret i32 %cast
}

define i1 @extractelement_is_zero(<vscale x 2 x i32> %d, i1 %b, i32 %z) {
; CHECK-LABEL: @extractelement_is_zero(
; CHECK-NEXT:    [[EXT:%.*]] = extractelement <vscale x 2 x i32> [[D:%.*]], i32 0
; CHECK-NEXT:    [[BB:%.*]] = icmp eq i32 [[EXT]], 0
; CHECK-NEXT:    ret i1 [[BB]]
;
  %ext = extractelement <vscale x 2 x i32> %d, i32 0
  %bb = icmp eq i32 %ext, 0
  ret i1 %bb
}

; OSS-Fuzz #25272
; https://bugs.chromium.org/p/oss-fuzz/issues/detail?id=25272
define i32 @ossfuzz_25272(float %f) {
; CHECK-LABEL: @ossfuzz_25272(
; CHECK-NEXT:    [[VEC_FLOAT:%.*]] = insertelement <vscale x 4 x float> poison, float [[F:%.*]], i32 0
; CHECK-NEXT:    [[VEC_INT:%.*]] = bitcast <vscale x 4 x float> [[VEC_FLOAT]] to <vscale x 4 x i32>
; CHECK-NEXT:    [[E:%.*]] = extractelement <vscale x 4 x i32> [[VEC_INT]], i32 2147483647
; CHECK-NEXT:    ret i32 [[E]]
;
  %vec_float = insertelement <vscale x 4 x float> poison, float %f, i32 0
  %vec_int = bitcast <vscale x 4 x float> %vec_float to <vscale x 4 x i32>
  %E = extractelement <vscale x 4 x i32> %vec_int, i32 2147483647
  ret i32 %E
}