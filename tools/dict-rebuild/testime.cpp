#include <stdio.h>
#include <string.h>
#include "pinyinime.h"
using namespace ime_pinyin;
static void pr(const char16* s){
  for (const char16* p = s; *p; p++) {
    unsigned c = *p;
    if (c < 0x80) putchar(c);
    else if (c < 0x800) { putchar(0xC0|(c>>6)); putchar(0x80|(c&0x3F)); }
    else { putchar(0xE0|(c>>12)); putchar(0x80|((c>>6)&0x3F)); putchar(0x80|(c&0x3F)); }
  }
}
static void probe(const char* py){
  im_reset_search();
  size_t n = im_search(py, strlen(py));
  printf("== %s -> %zu cands\n", py, n);
  char16 buf[64];
  for (size_t i = 0; i < n && i < 4; i++) {
    if (im_get_candidate(i, buf, 64)) { printf("  [%zu] ", i); pr(buf); printf("\n"); }
  }
  if (n > 0) {
    im_choose(0);
    printf("  after choose(0): fixed=%zu cand0=", im_get_fixed_len());
    if (im_get_candidate(0, buf, 64)) pr(buf);
    printf("\n");
  }
}
int main(int argc, char** argv){
  if (!im_open_decoder(argv[1], "/data/local/tmp/imebuild/usr_test.dat")) { printf("open fail\n"); return 1; }
  im_set_max_lens(28, 12);
  probe("woxiangchifan");
  probe("zhongguoren");
  probe("jintiantianqihenhao");
  probe("nihaoma");
  probe("dianhua");
  probe("mingtianhuijiar");
  probe("bei");
  im_close_decoder();
  return 0;
}
