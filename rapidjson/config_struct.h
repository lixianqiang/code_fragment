#ifndef _H_CONFIG_STRUCT_H_
#define _H_CONFIG_STRUCT_H_

#include <string>
#include <vector>

struct IConfig {
public:
  virtual ~IConfig() {}
};

struct ConcentrateConfig : IConfig {
  std::string stringObject = "stringObject";
  bool boolObject = true;
  int intObject = 555;
  double doubleObject = 888.888;
  std::vector<int> int_list;
  std::vector<std::string> string_list;
  std::vector<bool> bool_list;
  std::vector<double> doule_list;
};

#endif // _H_CONFIG_STRUCT_H_