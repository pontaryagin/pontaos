#include <cstdint>
#include <cstddef>
#include <algorithm>

// using uint64_t = unsigned long long;
// using uint8_t = unsigned char;

#include "frame_buffer_config.hpp"

struct PixelColor {
  uint8_t r,g,b;
};

class PixelWriter
{
public:
  virtual void Write(int x, int y, const PixelColor& c) = 0;
  static uint8_t* PixelAt(const FrameBufferConfig& config, int x, int y) {
    return config.farme_buffer + 4 * (config.pixels_per_scan_line * y + x);
  }
};

class RGBResv8BitPerColorPixelWriter: public PixelWriter
{
public:
  RGBResv8BitPerColorPixelWriter(const FrameBufferConfig& config)
    : config_(config){}
  virtual void Write(int x, int y, const PixelColor& c) override {
    auto p = PixelAt(config_, x, y);
    p[0] = c.r;
    p[1] = c.g;
    p[2] = c.b;
  }
private:
  const FrameBufferConfig& config_;
};

class BGRResv8BitPerColorPixelWriter: public PixelWriter
{
public:
  BGRResv8BitPerColorPixelWriter(const FrameBufferConfig& config)
    : config_(config){}
  virtual void Write(int x, int y, const PixelColor& c) override {
    auto p = PixelAt(config_, x, y);
    p[0] = c.b;
    p[1] = c.g;
    p[2] = c.r;
  }
private:
  const FrameBufferConfig& config_;
};

// only for debug mode
extern "C" void __cxa_pure_virtual() {
  while (1) __asm__("hlt"); 
}

static PixelWriter* getPixelWrite(const FrameBufferConfig& config){
  static char pixel_writer_buf[std::max({
    sizeof(RGBResv8BitPerColorPixelWriter),
    sizeof(BGRResv8BitPerColorPixelWriter)})];
  static PixelWriter* pixel_writer = [&]() -> PixelWriter*{
    switch (config.pixel_format) {
      case kPixelRGBResv8BitPerColor:
        return new(pixel_writer_buf) RGBResv8BitPerColorPixelWriter{config};
      case kPixelBGRResv8BitPerColor:
        return new(pixel_writer_buf) BGRResv8BitPerColorPixelWriter{config};
    }
  }();
  return pixel_writer;
}


int WritePixel(const FrameBufferConfig& config,
               int x, int y, const PixelColor& c)
{
  const int pixel_position = config.pixels_per_scan_line * y + x;
  if (config.pixel_format == kPixelRGBResv8BitPerColor)
  {
    uint8_t* p = &config.farme_buffer[4*pixel_position];
    p[0] = c.r;
    p[1] = c.g;
    p[2] = c.b;
  }
  else if (config.pixel_format == kPixelBGRResv8BitPerColor)
  {
    uint8_t* p = &config.farme_buffer[4*pixel_position];
    p[0] = c.b;
    p[1] = c.g;
    p[2] = c.r;
  }
  else
  {
    return -1;
  }
  return 0;
}

extern "C" void KernelMain(const FrameBufferConfig& frame_buffer_config)
{
  const auto pixel_writer = getPixelWrite(frame_buffer_config);
  for (int x = 0; x < frame_buffer_config.horizontal_resolution; ++x){
    for (int y = 0; y < frame_buffer_config.vertical_resolution; ++y){
      pixel_writer->Write(x, y, {255, 255, 255});
    }
  }
  for (int x = 0; x < 200; ++x) {
    for (int y = 0; y < 100; ++y){
      pixel_writer->Write(100+x, 100+y, {0,255,0});
    }
  }
  while (1) __asm__("hlt");
}
