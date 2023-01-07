//#include <cstdint>
using uint64_t = unsigned long long;
using uint8_t = unsigned char;

extern "C" void KernelMain()
{
  while (1) __asm__("hlt");
}
