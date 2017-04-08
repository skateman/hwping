#ifndef __hwping_webcam_h__
#define __hwping_webcam_h__

#include <ruby.h>
#include <ruby/thread.h>
#include <opencv2/opencv.hpp>
#include <opencv2/stitching/stitcher.hpp>

extern VALUE mHWPing;

extern "C" void Init_webcam(void);

static VALUE rb_create_snapshot(VALUE self);
static VALUE rb_save_snapshot(VALUE self, VALUE file);
static VALUE rb_stitch_snapshots(VALUE self, VALUE snapshots);

#endif
