#include "webcam.h"

using namespace cv;
VALUE mHWPing = Qnil;

void destroy_snapshot(void *ptr) {
  ((Mat*) ptr)->release();
  delete (Mat*) ptr;
}

void* stitch_without_gvl(void *data) {
  cv::Stitcher stitcher = cv::Stitcher::createDefault();
  VALUE snapshots = *((VALUE*)data);
  std::vector<Mat> images;
  Mat *image, panorama;

  for (int i = 0; i < RARRAY_LEN(snapshots); i++) {
    Data_Get_Struct(rb_ary_entry(snapshots, i), Mat, image);
    images.push_back(*image);
  }

  stitcher.stitch(images, panorama);
  images.clear();

  image = new Mat(panorama.rows, panorama.cols, CV_8U, 3);
  panorama.copyTo(*image);
  return (void*) image;
}

static VALUE rb_create_snapshot(VALUE self) {
  VideoCapture cap(0);
  cap.set(CV_CAP_PROP_FRAME_WIDTH, 1280);
  cap.set(CV_CAP_PROP_FRAME_HEIGHT, 720);
  Mat frame, *image = new Mat(frame.rows, frame.cols, CV_8U, 3);

  Scalar mean;
  cap >> frame;
  for (int i=0; i<3; i++) {
    mean = cv::mean(frame);
    if (mean[0] + mean[1] + mean[2] > 100) break;
    frame.release();
    cap >> frame;
  }

  frame.copyTo(*image);
  frame.release();
  cap.release();

  return Data_Wrap_Struct(self, NULL, destroy_snapshot, image);
}

static VALUE rb_save_snapshot(VALUE self, VALUE file) {
  Mat *image;
  Data_Get_Struct(self, Mat, image);
  return INT2NUM(imwrite(StringValuePtr(file), *image));
}

static VALUE rb_stitch_snapshots(VALUE self, VALUE snapshots) {
  Mat *image = (Mat*) rb_thread_call_without_gvl(stitch_without_gvl, (void*) &snapshots, RUBY_UBF_IO, NULL);
  return Data_Wrap_Struct(self, NULL, destroy_snapshot, image);
}

void Init_webcam(void) {
  mHWPing = rb_define_module("HWPing");

  VALUE webcam = rb_define_class_under(mHWPing, "Webcam", rb_cObject);
  rb_define_alloc_func(webcam, rb_create_snapshot);
  rb_define_method(webcam, "write", RUBY_METHOD_FUNC(rb_save_snapshot), 1);
  rb_define_singleton_method(webcam, "stitch", RUBY_METHOD_FUNC(rb_stitch_snapshots), 1);
}
