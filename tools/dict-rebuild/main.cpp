#include <stdio.h>
#include <stdlib.h>
#define ___BUILD_MODEL___
#include "dicttrie.h"
#include "ngram.h"

int main(int argc, char **argv) {
  setvbuf(stdout, NULL, _IONBF, 0);
  printf("start argc=%d\n", argc);
  if (argc < 4) { printf("usage: builddict raw valid out\n"); return 1; }
  printf("creating trie\n");
  ime_pinyin::DictTrie *trie = new ime_pinyin::DictTrie();
  printf("trie created, building\n");
  if (!trie->build_dict(argv[1], argv[2])) { printf("build_dict failed\n"); return 2; }
  printf("build ok, saving\n");
  if (!trie->save_dict(argv[3])) { printf("save_dict failed\n"); return 3; }
  printf("saved %s\n", argv[3]);
  delete trie;
  return 0;
}
