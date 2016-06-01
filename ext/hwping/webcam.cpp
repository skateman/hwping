#include "webcam.h"
#include <opencv2/photo.hpp>

using namespace cv;
VALUE mHWPing = Qnil;

void process(std::vector<Mat> images, Mat* image) {
  int channels = images[0].channels();
  CV_Assert(channels == 1 || channels == 3);
  Size size = images[0].size();
  int CV_32FCC = CV_MAKETYPE(CV_32F, channels);

  std::vector<Mat> weights(images.size());
  Mat weight_sum = Mat::zeros(size, CV_32F);

  for(size_t i = 0; i < images.size(); i++) {
      Mat img, gray, contrast, saturation, wellexp;
      std::vector<Mat> splitted(channels);

      images[i].convertTo(img, CV_32F, 1.0f/255.0f);
      if(channels == 3) {
          cvtColor(img, gray, COLOR_RGB2GRAY);
      } else {
          img.copyTo(gray);
      }
      split(img, splitted);

      Laplacian(gray, contrast, CV_32F);
      contrast = abs(contrast);

      Mat mean = Mat::zeros(size, CV_32F);
      for(int c = 0; c < channels; c++) {
          mean += splitted[c];
      }
      mean /= channels;

      saturation = Mat::zeros(size, CV_32F);
      for(int c = 0; c < channels;  c++) {
          Mat deviation = splitted[c] - mean;
          pow(deviation, 2.0f, deviation);
          saturation += deviation;
      }
      sqrt(saturation, saturation);

      wellexp = Mat::ones(size, CV_32F);
      for(int c = 0; c < channels; c++) {
          Mat expo = splitted[c] - 0.5f;
          pow(expo, 2.0f, expo);
          expo = -expo / 0.08f;
          exp(expo, expo);
          wellexp = wellexp.mul(expo);
      }

      pow(contrast, 1.0, contrast);
      pow(saturation, 1.0, saturation);
      pow(wellexp, 0.0, wellexp);

      weights[i] = contrast;
      if(channels == 3) {
          weights[i] = weights[i].mul(saturation);
      }
      weights[i] = weights[i].mul(wellexp) + 1e-12f;
      weight_sum += weights[i];
  }
  int maxlevel = static_cast<int>(logf(static_cast<float>(min(size.width, size.height))) / logf(2.0f));
  std::vector<Mat> res_pyr(maxlevel + 1);

  for(size_t i = 0; i < images.size(); i++) {
      weights[i] /= weight_sum;
      Mat img;
      images[i].convertTo(img, CV_32F, 1.0f/255.0f);

      std::vector<Mat> img_pyr, weight_pyr;
      buildPyramid(img, img_pyr, maxlevel);
      buildPyramid(weights[i], weight_pyr, maxlevel);

      for(int lvl = 0; lvl < maxlevel; lvl++) {
          Mat up;
          pyrUp(img_pyr[lvl + 1], up, img_pyr[lvl].size());
          img_pyr[lvl] -= up;
      }
      for(int lvl = 0; lvl <= maxlevel; lvl++) {
          std::vector<Mat> splitted(channels);
          split(img_pyr[lvl], splitted);
          for(int c = 0; c < channels; c++) {
              splitted[c] = splitted[c].mul(weight_pyr[lvl]);
          }
          merge(splitted, img_pyr[lvl]);
          if(res_pyr[lvl].empty()) {
              res_pyr[lvl] = img_pyr[lvl];
          } else {
              res_pyr[lvl] += img_pyr[lvl];
          }
      }
  }
  for(int lvl = maxlevel; lvl > 0; lvl--) {
      Mat up;
      pyrUp(res_pyr[lvl], up, res_pyr[lvl - 1].size());
      res_pyr[lvl - 1] += up;
  }
  res_pyr[0].copyTo(*image);
}

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

  vector<Mat> images;
  Mat frame, *image = new Mat(frame.rows, frame.cols, CV_8U, 3);

  for (int j = 0; j < 5; j++) {
    cap.set(CV_CAP_PROP_BRIGHTNESS, 0.25 * j);
    Scalar mean;
    cap >> frame;
    for (int i=0; i<3; i++) {
      mean = cv::mean(frame);
      if (mean[0] + mean[1] + mean[2] > 100) break;
      frame.release();
      cap >> frame;
    }
    images.push_back(frame);
    frame.release();
  }

  process(images, image);

  *image = *image * 255;

  // Ptr<MergeMertens> merge_mertens = createMergeMertens();
  // merge_mertens->process(images, *image);

  // images[2].copyTo(*image);
  // frame.release();
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
