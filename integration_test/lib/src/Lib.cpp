#include "Lib.hpp"
#include <nlohmann/json.hpp>

struct S {
  int val;
};

NLOHMANN_DEFINE_TYPE_NON_INTRUSIVE(S, val);

int gimmeFive() {
  S s = nlohmann::json::parse("{val: 5}");
  return s.val;
}
